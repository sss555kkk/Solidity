

/*
블록체인 defi 중에서 AMM(automated market maker)를 사용하는 dex는
amm의 방식에 따라서 아래처럼 분류할 수 있음. 

Constant Sum: pool에 보유하고 있는 토큰 2개의 수량의 합이 항상 
일정한 값을 유지하도록 하는 공식에 의해서 교환수량이 정해짐. 
mStable이 여기에 속함. 

Constant Product: pool에 보유하고 있는 토큰 2개의 수량의 곱이 항상 
일정한 값을 유지하도록 하는 공식에 의해서 교환수량이 정해짐. 
Uniswap, Sushiswap, Balancer, Curve, Dodo, Bancor 등이 여기에 속함. 

Constant Power Sum: pool에 보유하고 있는 토큰 2개의 제곱의 합이 항상 
일정한 값을 유지하도록 하는 공식에 의해서 교환수량이 정해짐.
YieldSpace가 여기에 속함. 

Constant Product 는 토큰 2개의 수량이 곱셈과 관련된 수식에 의해서
교환수량을 결정하는데, 이 수식은 프로토콜마다 다름. 
여기서는 Constant Product AMM 중에서도 대표적인 Uniswap, Curve, Dodo, Balancer의 
교환수량결정수식과 구현코드를 살펴보겠음.
*/

/*
먼저 AMM에서 가장 기본적인 Constant Sum AMM과 Constant Product AMM의
기본 공식에 따른 코드의 차이를 살펴보자.
교환수량결정수식을 제외하면 Constant Sum과 Product의 차이는 거의 없다. 
*/

contract ConstantSumAMM {
    // IERC20 인터페이스를 참조하는 토큰 주소를 정의.
    IERC20 public immutable token0;
    IERC20 public immutable token1;
    uint public reserve0;
    uint public reserve1;
    // 이 풀이 발행하는 receiptToken의 총수량과 개별소유자 보유량.
    uint public receiptTokenTotalSupply;


    function swap(address _tokenIn, uint _amountIn) external returns(uint amountOut) {
        //받은 token이 token1 or token2 인가? 확인
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "invalid token!");
        //받은 token이 token1인지, token2인지를 확인해서 _tokenIn을 token0 또는 token1에 할당.
        //받은 토큰 수량에 따른 내줄 토큰 수량을 계산하기 위해서 state variable들을 불러와서
        // local variable인 resIn, resOut에 값 복사. 
        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint resIn, uint resOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);
        //msg.sender가 token0에게 address(this)에게 approve하는 과정은 여기서는 생략했음. 
        // approve받은 토큰을 transferFrom으로 이 컨트랙으로 전송함. 
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        // 확인을 위해서 받은 수량(amountIn)은 현재 이 주소의 수량과 직전 reserve값의 차로 다시 계산함.
        uint amountIn = tokenIn.balanceOf(address(this)) - resIn;
        // 수수료가 0.3%로 고정이라서 직접 숫자 입력. 
        amountOut = (amountIn * 997) / 1000;
        // 풀안의 reserve값을 업데이트 하기 위한 계산. balanceOf(address(this))를
        //사용하지 않고 직접 계산함. balanceOf()는 계산결과 확인을 위해서만 사용함. 
        (uint res0, uint res1) = isToken0
            ? (resIn + amountIn, resOut - amountOut)
            : (resOut - amountOut, resIn + amountIn);
        _update(res0, res1);
        tokenOut.transfer(msg.sender, amountOut);
    }
    
    // swap외의 함수 내용은 모두 생략했음. 
    function addLiquidity(uint _amount0, uint _amount1) external returns(uint receiptTokenMint) {}
    function removeLiquidity(uint _amount) external returns(uint d0, uint d1) {}
    function _mint(address _to, uint _amount) private {}
    function _burn(address _from, uint _amount) private {}
    function _update(uint _res0, uint _res1) private {}
}

// Constant Product AMM

contract ConstantProductAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;
    uint public reserve0;
    uint public reserve1;
    uint public receiptTokenTotalSupply;

    function swap(address _tokenIn, uint _amountIn) external returns(uint amountOut) {

        require(_tokenIn == address(token0) || _tokenIn == address(token1), "invalid token");
        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint resIn, uint resOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        /*
        토큰 x, y가 있을 때, dx수량이 스왑에 들어옴. 보내줄 수량은 dy. 
        x*y = k
        (x+dx)*(y-dy) = k
        우리가 계산하기 원하는 것은 사용자가 dx를 입력했을 때, 
        보내줄 수량인 dy임. 따라서 2개 식을 풀어서 dy에 대해서 정리하면
        dy = ydx / (x + dx). 
        수수료가 0.3% 이므로 들어온 _amountIn 수량의 997/1000 이 dx라고 놓고 계산해서 dy를 구함. 
        */
        uint amountInAfterFee = (_amountIn * 997) / 1000;
        amountOut = (resOut * amountInAfterFee) / (resIn + amountInAfterFee);
        tokenOut.transfer(msg.sender, amountOut);
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }
}

/*
Constant Sum은 r1 + r2 = k.의 형태로 항상 풀 내의 2개의 토큰수량의 합이 
일정한 값이 되도록 교환수량을 지정함. 
Constant Product중에서 가장 기본적인 모델은 r1 x r2 =k.의 형태로 항상 풀 내의 2개의 토큰수량의 곱이 
일정한 값이 되도록 교환수량을 지정함. 
그리고 이 기본식 (r1 x r2 =k)을 다른 모델로 바꾸면 교환수량이 바뀌고, 
이를 구현하는 코드도 바뀌게 됨. 

이번에는 Constant Product AMM 중에서 Curve의 모델을 살펴보자. 

A((sigma(rk)/K) - 1) = ((((K/n)**n)/ sigma rk) - 1)
이 식은 교환수량이 (r1, r2) 수량의 일정범위 내에서는 Constant Sum처럼
1대1로 교환하고 범위 밖에서는 (r1, r2) 중 더 적은 수량에 대한 교환수량을
Constant Product보다 더 크게 요구한다. 이 범위와 기울기를 위 식의 A가 결정함. 
이 모델은 주로 stable token의 교환에서 쓰이고 stable swap이라고 부른다.
*/

