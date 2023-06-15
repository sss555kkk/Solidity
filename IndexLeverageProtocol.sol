// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
/*
Index Leverage Protocol. 
이 프로토콜은 누구나 자유롭게 trading의 대상이 되는 Index를 설정하고 
상대방이 거기에 leverageTrading을 하는 Contract을 만들 수 있다. 
유동성 공급자는 자신이 원하는 인덱스를 설정한 뒤 USDT로 유동성을 공급.
유동성 공급자는 최초에 tradingContract을 생성할 때, 인덱스와 수수료 비율을 설정함. 
수수료는 trader에게서 유동성공급자에게 이전됨. 프로토콜은 받지 않음. 
따라서 유동성 공급자들은 이 인덱스가 무작위로 움직이기 때문에 인덱스의 변화에서는 
수익이 발생하지 않고 수수료로 수익을 낸다는 것에 베팅하고 있음. 
trader들은 Long/short과 leverage(min: 1, max: 100)을 설정해서 USDT로 진입. 
인덱스, 현재Value, long/short, leverage에 따라서 청산되거나 현재가치가 업데이트됨.
수수료는 진입과 나가기 시에 설정된 수수료 비율만큼 유동성 공급자에게 이전. 
trader들은 수수료를 제외하고도 인덱스의 방향성을 예측해서 수익을 낼 수 있다는 것에 베팅하고 있음. 
Pool(유동성 공급자들의 자금의 모음)과 trader position 모두 청산될 수 있음. 
유동성을 추가,제거, trading에 진입, 나가기 를 할때에 전체정산을 함. 
전체 정산은 탈중앙화오라클 제공업체에서 제공하는 오라클에서 해당 Index의 현재값을 받아서 계산함. 
하나의 TradingContract을 생성하기 위해서는 해당하는 Oracle을 설정하고 연결해야 하는데,
그 부분은 아직 할 줄 몰라서 생략했음. 

이 프로토콜에서 누구나 전체 포지션과 풀에 대한 정산신청을 할 수 있고, 결과로 청산된 position이나 pool이 있으면
청산된 가치의 0.2%를 받음. 이 과정은 2가지 의미가 있음. 
(1) 스마트 컨트랙이 인덱스변화를 보면서 스스로 업데이트(정산 등)를 하는 것은 불가능함. 
업데이트 신청(=정산신청)에 대한 인센티브를 제공해서 청산대상이 바로 바로 청산이 되도록 했음. 
(2) 정산신청에는 누구나 참여가능. 약간의 이해만 있으면 누구나 수익을 낼 수 있음. 
누구라도 디파이에 참여하고 수익을 낼 수 있는 메커니즘을 포함시켰음. 

이 프로토콜은 전체 4개의 contract으로 나누어짐. 
Deployer는 새로운 trading 생성신청이 들어왔을 때,
TradindManager, TradingContract, nftManager 컨트랙을 생성함. 
TradingManager는 유동성공급/제거, trading 진입/나가기, 계산, 정산, 청산을 모두 관리하고 
TradingContract과 NftManager에 지시를 전달함. 
TradingContract은 자금을 관리하고 유동성공급자들에게 pooltoken을 발행함.  
nftManager는 trader에게 position에 대한 nft를 발행함. 
*/

contract TradingManager {
    
    constructor (address _tradingContract, address _nftManager, uint _feeRate) {
        tradingContract = _tradingContract;
        NFTManager = _nftManager;
        feeRate = _feeRate;
        nftManager = IERC721(NFTManager);
    }
    
    // 모든 거래는 1개의 stable token으로 진행함. 여기서는 usdt로 하고 주소는 임의값으로 넣었음.
    address public constant USDT = 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
    IERC20 public constant usdt = IERC20(USDT);
    address public immutable tradingContract;
    IERC20 public immutable poolToken = IERC20(tradingContract);
    address public immutable NFTManager;
    IERC721 public immutable nftManager;
    uint public immutable feeRate;
    
    /* 
    poolOpen 변수는 이 Trading의 Pool이 청산되었는가를 가리키는 중요한 상태변수임. 
    이 trading의 pool이 청산이 되면 Closed(bool = false) 상태가 되고 더 이상 새로운 거래는
    불가능함. trader들의 모든 포지션이 pool 청산시점에서 현재가치를 업데이트하고
    trader들이 이것을 찾아갈 수 있음(=exit position)
    */
    bool public poolOpen = true;
    uint public poolValue = 0;
    uint public nextNftId = 1;

    struct PositionInfo {
        uint256 entryIndex;
        uint32 initialValue;
        bool longOrShort;
        uint8 leverage;
        bool aliveOrCleared;
    }

    mapping (uint => PositionInfo) public nftPositionInfo;
    mapping (uint64 => uint32) public nftPositionValue;
    uint64[] public nftNumArr;

    
    // poolOpen이 false(pool 청산)가 되면 진입을 못하게 하는 modifier
    modifier entryOnlyOpen() {
        require(poolOpen == true, "this trading is closed");
        _;
    }
    
    /* 유동성 공급자가 pool에 usdt로 자금을 공급하고 pooltoken을 receipt로 받음.
    현재 시점에서 전체정산을 진행하고 pool이 청산되지 않은 경우, 
    pool의 현재가치를 계산해서 새로운 유동성을 더하고 해당하는 ERC20 poolToken을 받음.
    */ 

    function addLiquidity(address _addr, uint _amount) external entryOnlyOpen {
        require(_addr == USDT, "not USDT. accept only USDT");
        uint callerComp = _clearAllPositionAndPool();
        uint poolTokenTotalSupply = tradingContract.poolTokenTotalSupply;
        
        if(poolOpen == false) {
            revert("trading closed. You cannot add liquidity");
        }
        
        uint addAmount;
        if (poolTokenTotalSupply = 0) {
            addAmount = _amount;
        }else{
            addAmount = ((callerComp + _amount) / poolValue) * poolTokenTotalSupply;
        }
        poolValue += addAmount;
        tradingContract._mint(addAmount);
    }
    
    /*
    유동성공급자가 poolToken을 반환하고 유동성을 회수함. 
    전체정산 후 pool이 청산되지 않은 경우,
    (자신이 반환한 poolToken) / TotalPoolToken 에 해당하는 poolValue를 받음. 
    */
    function removeLiquidity(address _addr, uint _amount) external returns(string memory) {
        require(_addr == poolToken, "invaild token");
        
        uint callerComp;
        uint returnAmount;

        if(poolOpen == false) {
            return "pool closed.";
        }
        
        (callerComp, ) = _clearAllPositionAndPool();
        if(poolOpen == false) {
            return "pool closed.";
            }
        returnAmount = ((_amount / poolTokenTotalSupply) * poolValue);
        if (poolValue <= returnAmount) {
            poolOpen = false;
            returnAmount = poolValue;
            poolValue = 0;
        } else {
            poolValue -= returnAmount;
        }
        
        tradingContract._burn(returnAmount+callerComp);
        tradingContract.CommandTransfer(address(this), msg.sender, (returnAmount+callerComp))
    }
    
    /*
    trader가 포지션에 진입하고 receipt로 nft를 받음. 
    pool과 달리 모든 포지션은 각각 다르기 때문에 receipt로 ERC20이 아닌 nft를 발행함. 
    전체정산 후 pool이 청산되지 않았다면,
    */
    function enterPosition(
        address _wantedTradingContract,
        address _addr, 
        uint _amount, 
        bool _longOrShort,
        uint8 _leverage
        ) external entryOnlyOpen returns (string memory) {
            
            require(_wantedTradingContract == tradingContract, "invaild tradingContract");
            require(_addr == USDT, "invaild token");
            require(_leverage >=1 && _leverage <= 100, "invaild leverage range");
            
            uint callerComp;
            uint currentIndex;
            uint valueAfterFee;

            (callerComp, currentIdex) = _clearAllPositionAndPool();
            if(poolOpen == false) {
                return "trading closed";
            }
            
            //feeRate는 생성시에 uint로 입력받아서 계산시에 환산해서 사용.
            valueAfterFee = (_amount * (1 - (feeRate/100000))) + callerComp;
            poolValue =+ _amount * (feeRate/100000);

            PositionInfo memory newPosition = PositionInfo (currentIdex, valueAfterFee, _longOrShort, _leverage, true);
            nftPositionInfo[nextNftId] = newPosition;
            nftPositionValue[nextNftId] = valueAfterFee;
            nftNumArr.push[nextNftId];
            
            NftManager.mint(address msg.sender, uint nextNftId);
            nextNftId++;
        }
    /*
    trader가 nft를 반환하고 포지션에서 나감. 
    전체정산 후 자신의 포지션이 청산되지 않았다면 계산된 현재가치를 받음. 
    */
    function exitPosition(address _addr, uint _nftId) external returns(string memory){
        require(_addr == NFTManager, "invaild NFT");
        uint exitValue;
        uint callerComp;

        if(nftPositionValue[_nftId] == 0) {
            return "position cleared";
        }
        // poolOpen이 false라면 이미 pool청산이 되었고, 모든 포지션의 값들도 pool 청산 시점에서 
        //업데이트 되었을 것이며 더 이상 계산이 필요없음. 그냥 현재가치 값을 받으면 됨.
        if(poolOpen == false) {
            exitValue = nftPositionValue[_nftId];
        }

        // 전체정산을 실행한 뒤에, pool 청산이 되었다면 현재가치 + caller보상을 받음
        // pool 청산이 되지 않았다면, 현재가치에서 수수료를 제하고 (+caller보상)을 더해서 받음.
        // 수수료는 poolValue에 더해짐. 
        (callerComp, ) = _clearAllPositionAndPool();
        if(poolOpen == false) {
            exitValue = nftPositionValue[_nftId] + callerComp;
        }else{
            exitValue = nftPositionValue[_nftId]*(1-feeRate) + callerComp;
            poolValue = nftPositionValue[_nftId]*feeRate;
        }
        
        delete(ntfPositionValue[_nftId]);
        delete(nftPositionInfo[_nftId]);
            
        uint length = nftNumArr.length;
        for (uint i = 0; i < length; i++) {
            if (nftNumArr[i] == _nftId) {
                if (i != length - 1) {
                    nftNumArr[i] = nftNumArr[length - 1];
                }
                nftNumArr.pop();
                break;
            }
        }

        nftManager.burn(_nftId);
        tradingContract.Commandtransfer(msg.sender, exitValue);
    }
    
    //외부에서 누구나 이 함수를 통해서 전체정산을 신청하고 caller보상을 받을 수 있음.
    // 수수료에 비해서 청산으로 받을 수 있는 보상가치가 높을 때에 신청하게 될 것임. 
    function callClear() external entryOnlyOpen {
        uint callerComp = _clearAllPositionAndPool();
        tradingContract.commandTransfer(msg.sender, callerComp);
    }
    
    /* 
    전체 정산 함수. 이 함수를 실행하면 
    모든 포지션의 현재가치를 계산한뒤, 청산여부 업데이트, 현재가치 업데이트
    pool의 가치와 모든 position들의 (현재가치 - 최초가치)합을 비교해서 pool의 청산여부 업데이트.
    pool은 포지션과 달리 모든 유동성공급자들의 청산여부가 동일함. 
    pool의 현재가치 업데이트가 일어남. 
    마지막으로 호출자보상(callerComp)와 오라클에서 받아온 현재 인덱스값(currentIndex)을 반환함. 

    전체정산 과정에서 값이 안 맞는 부분이 있음. 계산을 항상 최초값과 현재값으로 비교해서 계산할 지,
    (현재 -1) 시점과 현재시점으로 비교해서 계산할지가 헷갈려서 2가지 방법이 혼용되었음. 
    하나의 방법으로 정리하고 나면 현재 배열, mapping, struct으로 분리된 데이터 구조도 맞추어서
    하나의 mapping(index - value - struct)이런 식으로 변경하는 방법을 고려중.
    여기서는 1개의 pool과 복수의 포지션 사이의 계산하는 방법에만 집중해서 작성했음.
    */
    function _clearAllPositionAndPool() internal returns(uint callerComp, uint currentIndex) {
        uint length = nftNumArr.length;
        int currentIndex = _oracle();
        int positionValueChange;
        uint clearedPositionValueSum;
        
        /* 
        i를 증가시키면서 모든 포지션에 대해서 positionInfo와 새로 업데이트한 currentIndex를 이용해서
        모든 포지션의 현재가치를 다시 계산
        */
        for (uint i=0; i < length, ++i) {
            uint nftId_in = nftNumArr[i];
            (uint256 entryIndex_in, uint32 initialValue_in, bool longOrShort_in, uint8 leverage_in, bool aliveOrCleared_in) 
            = nftPositionInfo[i]
            
            // 만약 현재가치가 0보다 작다면 포지션은 청산됨. 
            if(initialValue_in =< (((currentIndex - entryIndex_in) / entryIndex_in) * initialValue_in * leverage_in)) {
                clearedPositionValueSum += initialValue_in
                nftPositionValue[i] = 0;
                // 그렇지 않다면 포지션의 현재가치를 업데이트 함. 
            } else { 
                positionValueChange = 
                (((currentIndex - entryIndex_in) / entryIndex_in) * initialValue_in * leverage_in) - nftPositionValue[i];
                nftPositionValue(nftNumArr[i]) 
                = initialValue_in + (((currentIndex - entryIndex_in) / entryIndex_in) * initialValue_in * leverage_in);
            }
        // 포지션 변화값의 합과 poolValue를 비교해서 변화값의 합이 더 크다면 pool은 청산됨. 
        if(poolValue =< positionValueChange) {
            uint callerComp = (clearedPositionValueSum + positionValueChange) * (2/1000);
            poolValue = 0;
            poolOpen = false;
            uint currentTotalUsdt = usdt.balanceOf(address(this)) - callerComp;
            for (uint a = 0; a < length, ++a) {
                uint positionSum += nftPositionValue(nftNumArr[a]);
                nftPositionValue(nftNumArr[a]) = 
                (nftPositionValue(nftNumArr[a])/positionSum)*currentTotalUsdt;
        } else {
            callerComp = clearedPositionValueSum * (2/1000);
            poolValue -= positionValueChange;
        }
        return (callerComp, currentIndex);
    }
    
    // position value, pool value등은 모두 0이상이므로 max 함수로 (-)
    // 값이 나오지 않도록 함. 어떤 position의 현재가치가 0이 되었다면 청산되었다는 뜻임.
    function _max(uint a, uint b) internal pure returns (uint) {
        return a > b ? a : b;
    }
    
    /*
    탈중앙화 오라클(예를 들어 chainLink) 에 설정을 하고 이후에 필요할 때마다 
    호출을 해서 값을 받아옴. 설정하는 방법을 몰라서 
    오라클과 관련한 아래 2개 함수는 그냥 빈칸으로 뒀음. 
    */
    function _oracleSetting internal {}

    function _oracleCall internal return(uint currentIndex) {}

}


contract TradingContract is IERC20 {

    constructor (address _tradingManager, address _nftManager) {
        tradingManager = _tradingManager;
        NFTManager = _nftManager;
        nftManager = IERC721(NFTManager);
    }
    
    // 모든 거래는 1개의 stable token으로 진행함. 여기서는 usdt로 하고 주소는 임의값으로 넣었음.
    address public constant USDT = 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
    IERC20 public constant usdt = IERC20(USDT);
    address public tradingManager;
    address public immutable NFTManager;
    IERC721 public immutable nftManager;


    uint public poolTokenTotalSupply = 0;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public constant name = "IndexLeveragePoolToken";
    string public constant symbol = "ILPT";
    uint8 public decimals = 18;

    modifier onlyTrandingManager {
        require(msg.sender == tradingManager, "Invaild commander. only tradingManager can enter");
        _;
    }
    

    /*
    poolToken(유동성 공급자들이 receipt로 받는 토큰)을 관리하는 부분. 
    발행 함수는 tradingManager만 호출할 수 있음. 
    */
    function _mint(uint _amount) external onlyTradingManager {
        balanceOf[msg.sender] += _amount;
        poolTokenTotalSupply = 0; += _amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function _burn(uint _amount) external {
        balanceOf[msg.sender] -= amount;
        poolTokenTotalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function commandTransfer(address to, uint amount) external onlyTradingManager {
        usdt.transferFrom(address(this), to, amount);
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
}


//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol";

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// 여기서는 모든 contract을 하나의 sol 문서로 작성했으므로 import는 생략했음. 
//import './tradingContractTemplete.sol';
//import './nftManagerTemplete.sol'


// Deployer는 새로운 trading Market을 생성하고자 할 때, 해당 tradingContract과
// 거기에 해당하는 nft contract을 생성함. 
contract Deployer {
    event Created(address indexed addr);
    
    // 여기서 _index는 거래의 대상이 인덱스를 설정하기 위해서 매개변수를 받아서
    // 탈중앙화 오라클에 설정을 만들기 위해서임. 탈중앙화 오라클에 설정하는 방법을 몰라서
    // 여기서는 생략했음. 그냥 uint _index를 받는다 라고만 작성했음. 
    function createTradingContract(uint _index, uint _feeRate) external returns (address tradingContract) {
        /* feeRate는 uint로 입력받아서 (1/100000)변환해서 계산에 활용. 예를 들어 300을 입력받았다면
        수수료는 300/100000 = 0.003 = 0.3% 임. 
        */
        require(_feeRate >= 0 && _feeRate < 100000, "invaild feeRate range");
        // 저장해놓은 templete에 입력받은 값을 salt로 활용해서 새로운 컨트랙 주소를 생성
        bytes memory bytecode = type(tradingContractTemplete).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(bytes(_index, _feeRate)));
        address tradingContract;
        assembly {
            tradingContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        _createtradingManager(tradingManager);
        _createNftManager(tradingContract);

        emit Created(tradingContract);
    }

    function _createTradingManager(uint _index, uint _feeRate) external returns (address tradingContract) {
       
        // 저장해놓은 templete에 입력받은 값을 salt로 활용해서 새로운 컨트랙 주소를 생성
        bytes memory bytecode = type(tradingManagerTemplete).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(tradingContract));
        address tradingManager;
        assembly {
            tradingManager := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        emit Created(tradingManager);
    }

    function _createNftManager(address tradingContract) private returns (address nftManager) {
        
        // 저장해놓은 templete에 입력받은 값을 salt로 활용해서 새로운 nft컨트랙 주소를 생성
        bytes memory bytecode = type(nftManagerTemplete).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(tradingContract));
        address nftManager;
        assembly {
            nftManager := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        emit Created(nftManager);
    }
}
    
// nft는 trader가 포지션에 진입했을 때 포지션에 대한 receipt로 nft를 발행. 
// nft를 반환하면 trader는 전체정산을 한 뒤에 자신의 포지션에서 exit함. 
contract NFTmanager is IERC721 {
    
    constructor (address _tradingManager) {
        tradingManager = _tradingManager;
    }
    
    // 이 nft는 tradingManager에서 호출이 되었을 때에만 발행과 소각을 함. 
    modifier onlyTradingManager {
        require(msg.sender == tradingManager, "Invaild address");
        _;
        }
    
    function mint(address _to, uint _id) external onlyTradingManager {
        require(_to != address(0), "mint to zero address");

        _balanceOf[_to]++;
        _ownerOf[_id] = _to;

        emit Transfer(address(0), _to, _id);
    }

    function burn(uint id) external onlyTradingManager {
        
        address owner = _ownerOf[id];
        _balanceOf[owner] -= 1;
        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }
    // ...
}





