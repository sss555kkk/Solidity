// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/* 
Constant Sum Swap. 스왑 풀 안에 있는 두 개의 토큰 수량이 x + y = k 로 항상
일정한 합을 이루는 스왑. 이 contract은 그 중에서도 x, y의 교환비율은 1:1, 
풀의 수수료는 0.3%인 경우임. 
*/


contract ConstantSumSwap {
    // IERC20 인터페이스를 참조하는 토큰 주소를 정의.
    IERC20 public immutable token0;
    IERC20 public immutable token1;
    uint public reserve0;
    uint public reserve1;
    // 이 풀이 발행하는 receiptToken의 총수량과 개별소유자 보유량.
    uint public receiptTokenTotalSupply;
    mapping(address => uint) public balanceOf;

    //생성자를 통해서 이 풀이 다룰 토큰 2개의 address를 초기설정.
    constructor(address _token0, address _token1) {
        // _token0라는 address를 참조하는 인터페이스를 token0로 저장. 
        // _token0의 데이터타입은 address. token0는 address를 참조하는 인터페이스.
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    event Success(string indexed name, address indexed sender, uint tokenAmount0, uint tokenAmount1);

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
        emit Success("swap", msg.sender, amountIn, amountOut);
    }

    function addLiquidity(uint _amount0, uint _amount1) external returns(uint receiptTokenMint) {
        // approve받은 2개의 토큰을 이 컨트랙으로 transfer. 
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);
        
        // 확인을 위해 현재 balance값과 직전의 reserve값을 비교해서 들어온 수량을 계산. 
        uint res0 = token0.balanceOf(address(this));
        uint res1 = token1.balanceOf(address(this));
        uint d0 = res0 - reserve0;
        uint d1 = res1 - reserve1;
        // reserve 수량과 새로 들어온 토큰의 수량 비율이 이미 발행한 receiptTotalSupply와 
        // 새로 발행할 receiptToken 수량과 일치해야함. 
        if (receiptTokenTotalSupply > 0) {
            receiptTokenMint = (d0 + d1) * receiptTokenTotalSupply / (reserve0 + reserve1);
        } else {
            receiptTokenMint = d0 + d1;
        }

        require(receiptTokenMint > 0, "receiptTokenMint is zero");
        // 계산과 확인이 끝난 뒤에 receiptToken 발행과 reserve 수량 업데이트 함수 호출.
        _mint(msg.sender, receiptTokenMint);
        _update(res0, res1);
        emit Success("add liquidity", msg.sender, d0, d1);
    }

    function removeLiquidity(uint _amount) external returns(uint d0, uint d1) {
        // reserve 토큰과 receipt 토큰 사이의 비율의 원칙은 add, remove 시에 모두 같음. 
        // (burn / total) receipt 토큰 비율이 (remove / reserve) 토큰 비율과 같음. 
        d0 = (reserve0 * _amount) / receiptTokenTotalSupply;
        d1 = (reserve1 * _amount) / receiptTokenTotalSupply;
        _burn(msg.sender, _amount);
        _update(reserve0 - d0, reserve1 - d1);
        if (d0 > 0) {
            token0.transfer(msg.sender, d0);
        }
        if (d1 > 0) {
            token1.transfer(msg.sender, d1);
        }
        emit Success("remove liquidity", msg.sender, d0, d1);
    }

    function _mint(address _to, uint _amount) private {
        // receipt 토큰을 발행하고 totalSupply와 보유수량 업데이트.
        balanceOf[_to] += _amount;
        receiptTokenTotalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        // receipt 토큰을 소각하고 totalSupply와 보유수량 업데이트.
        balanceOf[_from] -= _amount;
        receiptTokenTotalSupply -= _amount;     
    }

    function _update(uint _res0, uint _res1) private {
        // 풀의 토큰 보유수량을 업데이트. 
        reserve0 = _res0;
        reserve1 = _res1;
    }
}

/*
IERC20 인터페이스는 ERC20 토큰의 표준 인터페이스. 
ConstantSum Swap 컨트랙은 ERC20 토큰을 사용할 때 이 인터페이스에 참조할 주소를 
넣어서 인터페이스 함수를 호출함. 
*/

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

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}


