
/*
PLF(Protocol for Loanable Fund)의 이자율 결정모델. kinked interest model과 
non-liner interest model.

PLF는 이자율결정모델을 이용해서 이자율을 정한다. 
이자율 결정모델은 {token1 deposit 수량, token1 lend 수량}을 매개변수로 받고
이자율을 결정한다. 모델은 크게 3가지로 분류할 수 있다. 
첫번째는 liner interest model로 util Ratio = (token1 lend 수량/token1 deposit 수량)일때
util Ratio를 x축으로 이자율을 y축으로 놓고 
y = ax + b 의 형태로 주어진다. 이 모델의 취약점은 lendAmount가 증가해서
depositAmout에 근접해서 default 리스크(depositor가 자신의 deposit 수량을
찾으려고 시도해도 모두 대출이 된 상황이라서 돌려받을 수 없음)가 증가해도 
제어할 수 있는 방법이 없다는 것이다. 

대부분의 PLF들은 이 문제를 해결하기 위해서 util ratio가 일정 정도 이상이 
되면 interest rate이 급격하게 올라가도록 조절한 모델들,
kinked interest model 또는 non-liner interest model을 사용한다. 
먼저 kinked(급격하게 꺽이는) interest model의 이자율 결정공식은 아래처럼 주어진다.

y = ax + b (util ratio <= kinked point)
y = cx + d (util ratio > kinked point)
kink point를 설정하고 이 값보다 util ratio가 커지면 이자율이 급격히
상승하도록 한다. kinked point는 0.8(80%)이 가장 많이 쓰인다. 
이 모델은 Compound, AAVE 등에서 쓰인다. 
아래의 PLF_1 컨트랙은 kinked interest model에서 deposit, lend, repay, withdraw를
할 때의 로직을 표현했다. 
*/

contract PLF_1 {

    address public constant token0 = 0xaaaaa...aaa;
    address public constant token1 = 0xbbbb...bbb;
    // 이 아래의 값들은 가장 많이 쓰이는 값을 대입했다. 
    int public constant collatralRate = 0.8;
    int public constant interestRateSlope1 = 0.05;
    int public constant interestRateAxis1 = 0;
    int public constant interestRateSlope2 = 20;
    int public constant interestRateAxis2 = -20;
    int constant kinkPoint = 0.8;
    int public depositOfToken0;
    int public depositOfToken1;
    int public lendOfToken0;
    int public lendOfToken1;
    mapping(address => int) public depositMapping;
    mapping(address => int) public lendMapping;
    mapping(address => int) public interestRateMapping;


    function deposit(address _token, int _amount) public returns() {
        require(_token == token0, "invalid token deposit!!");
        depositOfToken0 += _amount;
        depositMapping[msg.sender] = _amount;
    }

    function Lend(address _lendToken, int _lendAmount) public {
        int lendAmount = _lendAmount;
        (int currentPriceOfToken0, int currentPriceOfToken1) = 
            _getPrice();
        require(
            currentPriceOfToken0 * depositMapping[msg.sender] => 
            currentPriceOfToken1 * lendAmount, 
            "over collatral ratio!!"
            )
        int utilRatio = (lendOfToken1 + lendAmount) / depositOfToken1;
        interestRateMapping[msg.sender] = (utilRatio =< kinkPoint)? 
            (interestRateSlope1 * utilRatio) 
            : (interestRateSlope2 * utilRatio + interestRateAxis2);
        lendMapping[msg.sender] = lendAmount;
        emit(lendSuccess, lendAmount, interestRateMapping[msg.sender]);
    }

    function repay(address _token, int _amount) public {
        require(_token == token1, "invalid token for repay!!");
        int amount = _amount;
        int repayAmount = lendMapping[msg.sender] * interestRateMapping[msg.sender];
        require(amount == repayAmount, "invalid amount for repay!!");
        lendMapping[msg.sender] = 0;
        lendOfToken1 += amount;
        emit(repaySuccess, lendAmount, interestRateMapping[msg.sender]);
    }

    function withdraw(address _token, int _amount) external {}

    function _getPrice() internal returns(int, int) {
        int currentPriceOfToken0;
        int currentPriceOfToken1;
        return (currentPriceOfToken0, currentPriceOfToken1);
    }
}



/*
non-liner interest model은 이자율을 결정하는 수식은 아래와 같다. 

y = a(x**64) b(x**32) + c
y = 이자율
x = util ratio

이 모델은 약 0.8 부근에서 이자율 곡선이 급격하게 꺽이면서 상승해서
이자율(y)을 급격하게 높인다. util ratio가 어떤 선을 넘어서면 
이자율이 급격하게 높아지게 함으로써 default 리스크를 낮추는 원리는
kinked interest model과 비슷한 효과를 낸다.
이 모델은 dydx에서 쓰인다. 

이 모델을 적용한 PLF를 아래의 PLF_2 컨트랙으로 작성했다. 
kinked interest rate model과 비교해서 coefficient, exponentail 변수로
y = a(x**64) b(x**32) + c 수식을 만들었다. 
*/

contract PLF_2 {

    address public constant token0 = 0xaaaaa...aaa;
    address public constant token1 = 0xbbbb...bbb;

    int public constant collatralRate = 0.8;

    int public constant coefficientA = 1;
    int public constant coefficientB = 1;
    int public constant coefficientC = 1;
    int public constant exponentialA = 64;
    int public constant exponentialB = 32;
    int public constant exponentialC = 1;

    int public depositOfToken0;
    int public depositOfToken1;
    int public lendOfToken0;
    int public lendOfToken1;
    mapping(address => int) public depositMapping;
    mapping(address => int) public lendMapping;
    mapping(address => int) public interestRateMapping;


    function deposit(address _token, int _amount) public returns() {
        require(_token == token0, "invalid token deposit!!");
        depositOfToken0 += _amount;
        depositMapping[msg.sender] = _amount;
    }

    function Lend(address _lendToken, int _lendAmount) public {
        int lendAmount = _lendAmount;
        (int currentPriceOfToken0, int currentPriceOfToken1) = 
            _getPrice();
        require(
            currentPriceOfToken0 * depositMapping[msg.sender] => 
            currentPriceOfToken1 * lendAmount, 
            "over collatral ratio!!"
            )
        int utilRatio = (lendOfToken1 + lendAmount) / depositOfToken1;
        interestRateMapping[msg.sender] = 
            utilRatio**exponentialA * coefficientA +
            utilRatio**exponentialB * coefficientB +
            utilRatio**exponentialC * coefficientC;
        lendMapping[msg.sender] = lendAmount;
        emit(lendSuccess, lendAmount, interestRateMapping[msg.sender]);
    }

    function repay(address _token, int _amount) public {
        require(_token == token1, "invalid token for repay!!");
        int amount = _amount;
        int repayAmount = lendMapping[msg.sender] * interestRateMapping[msg.sender];
        require(amount == repayAmount, "invalid amount for repay!!");
        lendMapping[msg.sender] = 0;
        lendOfToken1 += amount;
        emit(repaySuccess, lendAmount, interestRateMapping[msg.sender]);
    }

    function withdraw(address _token, int _amount) external {}

    function _getPrice() internal returns(int, int) {
        int currentPriceOfToken0;
        int currentPriceOfToken1;
        return (currentPriceOfToken0, currentPriceOfToken1);
    }
}
