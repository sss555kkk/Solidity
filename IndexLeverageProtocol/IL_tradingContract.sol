// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;


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