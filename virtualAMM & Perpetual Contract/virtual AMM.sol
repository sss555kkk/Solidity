

/*
virtual AMM으로 perpetual contract 만들기.


CFD_decentralized 글에서 Contract For Difference에 대해서 설명하고
pool과 거래자를 분리해서 long/short, leverage, nft position을 구현하는
방법을 설명했다. 여기서는 CFD의 일종인 perpetual contract을 구현하는 
방법으로 이전에 소개한 방법과는 다른 virtual AMM을 소개한다.  
 
먼저 용어 설명을 하겠음. 

virtual AMM: 풀에 유동성을 공급하고 수수료로 수익을 받는 유동성 공급자가 
존재하지 않는 가상의 AMM이다. 이 방법을 처음 소개한 프로토콜은 Perpetual Protocol로 
무기한 선물을 vAMM으로 구현했다. 
vAMM은 x*y=k 라는 교환수량 공식은 적용되지만 
실제로 이 컨트랙 안에는 토큰 x, y가 존재하지 않는다. 최초 설정자가 
적절한 값을 입력해서 교환수량과 가격을 결정하는 데에 수식을 사용하지만 
x, y 수량은 존재하지 않는다. AMM이 현물을 교환하기 위해서 쓰인다면
vAMM은 가격과 교환수량을 결정하는 용도로 쓰인다. 

perpetual contract: 무기한 선물, 무기한 스왑, 무기한 계약, 퍼페츄얼, 이라고 부르기도 함. 
perpetual contract은 종료시점이 존재하지 않으며, 어떤 금융자산의 실제가격(index price라고 부름)과
별도로 시장참여자들이 정하는 가격(mark price라고 부름)으로 거래를 하는 Contract For Difference의 
일종이다. 
참고로 bitmax, binance 등의 해외거래소에서도 무기한선물 거래를 할 수 있다. 거래소에서 하는 무기한 선물은 
물론 중앙화된 서버에서 이루어지는 거래이다. Perpetual Protocal은 vAMM을 활용해서 블록체인 상으로 
탈중앙화된 방식으로 무기한 선물을 구현한다. 

먼저 vAMM의 작동방식을 보고 가장 간단한 형식으로 구현해보고
점점 더 세부적으로 업그레이드를 해보겠다. 
vAMM은 풀, 저장된 토큰, 유동성공급자가 존재하지 않는다. 
단지 가상의 AMM을 가정해서 virtualReserve0, virtualReserve1, virtualK 값을 
만들어내고 이 값을 거래를 한다. 
vAMM은 AMM과 많은 디파이에서 고민하는 유동성 공급의 문제, 
유동성 공급자가 많아져야 거래가 원활해지는데 유동성 공급자를 유인하기가 어렵다는
문제로부터 자유롭다. 
또한 오라클에 의존할 필요가 없다는 것도 장점이다. 오라클은 블록체인에서 
외부의 어떤 결과(예를 들면 index price)를 가져오기 위한 방법이지만
모든 가격정보가 주관적인 오라클에 의존하는 점은 취약점이다. 

vAMM의 사용예시를 보자. 
최조에 이 컨트랙을 만들면서 token0, token1이 각각 1000개, 100개가 있다고 
설정했다. k는 당연히 100000(1000 * 100)이 될 것이다. 이 풀에는 
token0, token1은 한개도 없다. 단지 숫자만 설정한 것 뿐이다. 
이제 Alice가 이 프로토콜에 접속해서 baseToken를 100개 deposit 한다. 
그리고 token1 long 계약을 100 usd 만큼 사기를 원한다. 
우리는 이 컨트랙 안에 alice의 address 정보에 baseToken 100개 deposit, 
(token1, long, 100)을 기록한다. 
그리고 컨트랙 안의 정보를 아래처럼 업데이트 한다.  
virtualReserve0 += 100;
virtualReserve1 -= dy;
이 때 dy = ydx / (x + dx); 이다. (아래 구현코드에 자세한 설명 있음).
Alice는 token1의 long perpetual contract을 100 usd 만큼 구입했고, 
이때 가격과 교환수량은 vAMM을 통해서 결정되었다. 

아래의 vAMM_1은 deposit과 buyToken1Perpetual만 코드로 작성한 것이다. 
*/

contract vAMM_1 {

    address public constant baseToken = 0xaaaa...aaaa;

    int public constant feeRate = 0.003;
    int public virtualReserve0 = 1000;
    int public virtualReserve1 =100;
    int public virtualK = 100000;

    mapping(address => int) depositAmountMapping;
    mapping(address => int) token1ValueMapping;
    int public lastPriceOfToken0 = 0;

    modifier onlyOwner {
        require(msg.sender == owner, "invalid owner!!");
        _;
    }
    
    function buyToken1Perpetual(int _token0Amount) external returns(int) {
        require(_token0Amount*lastPriceOfToken1 =< depositAmountMapping[msg.sender], "exceed deposit amount!!");
        /*
        토큰 x, y가 있을 때, dx수량이 스왑에 들어옴. 보내줄 수량은 dy. 
        x*y = k
        (x+dx)*(y-dy) = k
        우리가 계산하기 원하는 것은 사용자가 dx를 입력했을 때, 
        보내줄 수량인 dy임. 따라서 2개 식을 풀어서 dy에 대해서 정리하면
        dy = ydx / (x + dx). 
        수수료가 0.3% 이므로 들어온 _amount 수량의 997/1000 이 dx라고 놓고 계산해서 dy를 구함. 
        */
        int token0AmountInAfterFee = (_token0Amount * 997) / 1000;
        int token1Amount = (virtualReserve1 * token0AmountInAfterFee) / (virtualReserve0 + token0AmountInAfterFee);
        virtualReserve0 += _token0Amount;
        virtualReserve1 -= token1Amount;
        depositAmountMapping[msg.sender] -= _token0Amount
        token1ValueMapping[msg.sender] += token1Amount;
        return token1Amount;
    }

    function deposit(address _token, int _amount) public {
        require(_token == baseToken, "invalid token for deposit!!");
        depositAmountMapping[msg.sender] = _amount;

    }
}

/*
vAMM_1은 가상의 AMM을 통해서 perpetual contract을 만들어보는 기초이다. 
vAMM_2은 token1의 long 포지션만 가능했었던 함수를 long/short 이
모두 가능하도록 수정하고 leverage를 사용할 수 있도록 수정해보겠다. 

*/

contract vAMM_2 {

    address public constant baseToken = 0xaaaa...aaaa;

    int public constant feeRate = 0.003;
    int public virtualReserve0 = 1000;
    int public virtualReserve1 =100;
    int public virtualK = 100000;

    mapping(address => int) depositAmountMapping;
    mapping(address => bool) havePositionMapping;
    mapping(address => int) bettingAmountMapping;
    mapping(address => bool) longShortMapping;
    
    int public lastPriceOfToken1 = 0;

    modifier onlyOwner {
        require(msg.sender == owner, "invalid owner!!");
        _;
    }
    
    function enterPosition(int _token0Amount, int _leverage, bool _isLong) external {
        require(havePositionMapping[msg.sender] == false, "already have position!!");
        int bettingAmount = _token0Amount * _leverage;
        int bettingAmountAfterFee = (bettingAmount * 997) / 1000;
        int token1Amount = (virtualReserve1 * bettingAmountAfterFee) / (virtualReserve0 + bettingAmountAfterFee);
        virtualReserve0 += bettingAmount;
        virtualReserve1 -= token1Amount;
            
        bettingAmountMapping[msg.sender] = bettingAmount;
        longShortMapping[msg.sender] = _isLong;
        havePositionMapping[msg.sender] = true;
        _mint(msg.sender, _isLong, bettingAmount);
    }

    function clearPosition(int _tokenAmount) public {
        require(havePositionMapping[msg.sender] == true, "do not have position!!");
        uint clearAmount = _tokenAmount;
        int clearAmountAfterFee = (_tokenAmount * 997) / 1000;
        int token0Amount = (virtualReserve0 * clearAmountAfterFee) / (virtualReserve1 + clearAmountAfterFee);
        (depositAmountMapping[msg.sender]) = (bettingAmountMapping[msg.sender] + depositAmountMapping[msg.sender] < token0Amount)?
            (depositAmountMapping[msg.sender] + token0Amount - bettingAmountMapping[msg.sender]) :
            (0);
        havePositionMapping[msg.sender] = false;
        _burn(msg.sender);
    }

    function deposit(address _token, int _amount) public {
        require(_token == baseToken, "invalid token for deposit!!");
        depositAmountMapping[msg.sender] += _amount;

    }

    function withdraw(int _amount) public {
        require(depositAmountMapping[msg.sender] >= 0, "do not have deposit!!");
        depositAmountMapping[msg.sender] -= _amount;
        baseToken.transfer(address(this), msg.sender, _amount);
    } 

    function setVirtualNumber() onlyOwner public {}

}

/*
vAMM_2는 long/short과 leverage를 구현했다. 
Index Leverage Protocol에서 사용한 방법과는 다른 방법을 사용했다. 
(1) Pool과 유동성공급자 없이 vAMM을 사용했다.
(2) 가격 Oracle을 사용하지 않고, vAMM의 수식으로 가격과 교환수량을 결정했다. 
(3) 포지션의 entry price, clear price를 기록하지 않고, 
(leverage * amount)로 이루어진 bettingAmount를 mapping으로 기록하고,
정산결과 금액과 bettingAmount를 비교해서 손익을 결정했다. 
*/


