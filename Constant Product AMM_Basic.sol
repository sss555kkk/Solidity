// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/*
Constant Product AMM. 
2개의 토큰 x, y가 x * y = k 로 교환비율이 정해짐. 
수수료는 0.3% 고정. 
*/

contract ConstantProductAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;
    uint public reserve0;
    uint public reserve1;
    uint public receiptTokenTotalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        // 생성자를 이용해서 토큰 주소를 인터페이스가 참조하는 주소로 저장.
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function swap(address _tokenIn, uint _amountIn) external returns(uint amountOut) {
        // 이 토큰이 token0 또는 token1이 맞는가? 확인
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "invalid token");
        //들어온 토큰이 token0인지 token1인지 확인해서 들어온 tokenIn에 할당.
        // state variable을 local variable에 저장해서 계산에 사용하면 가스비를 절약할 수 있음. 
        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint resIn, uint resOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);
        // 사용자가 tokenIn에 이 컨트랙에 approve함수호출하는 과정은 생략.
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
        //swap을 끝낸 뒤에 balanceOf를 이용해서 reserve값 업데이트 함수 호출.
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function addLiquidity(uint _amount0, uint _amount1) external returns(uint receiptTokenMint) {
        //approve과정은 생략. approve받은 토큰을 이 컨트랙으로 transfer.
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        /* 
        add liquidity를 할때 2개 토큰 수량은 어떻게 받아야 되는가? 
        고정된 수량이 아니라 자유롭게 받아도 상관없음. 다만 그렇게 하면
        사용자에게 불이익이 됨. 현재의 reserve가 균형을 이루고 있다는 
        가정하에 현재의 token0/token1의 비율대로 사용자가 liquidity를 
        추가하는 것이 사용자에게도 최적의 이익이 됨. 
        따라서 여기서는 현재의 reserve0/reserve1 비율대로 사용자가
        _amout0, _amount1을 공급하도록 하겠음. 
        */
        if(reserve0 > 0 || reserve1 > 0) {
            require(reserve0/reserve1 == _amount0/_amount1, "_amount0/_amount1 ratio is different");
        }
        /*
        add liquidity를 할때 발행하는 receipt token의 수량,
        또는 remove를 할때 소각하는 receipt의 수량은 reserve들의 교환방식과는 무관함. 
        (d0 / reserve0) = (d1 / reserve1) = (receiptMint / TotalSupply)를 따름. 
        최초의 유동성 공급시에도 임의의 수량으로 mint를 해도 상관없음. 
        다만, x*y=k로 교환비율을 결정하기 때문에 최초mint 수량도 거기에 맞추어
        (d0 * d1)**(1/2) 로 결정하겠음.
        제곱근을 구하는 _sqrt 함수, 더 작은 값을 구하는 _min 함수는 별도의 함수로 만들었음. 
        */
        if (receiptTokenTotalSupply > 0) {
            receiptTokenMint = _sqrt(_amount0 * _amount1);
        } else {
            receiptTokenMint = _min(
                (_amount0 * receiptTokenTotalSupply) / reserve0,
                (_amount1 * receiptTokenTotalSupply) / reserve1
            );
        }
        require(receiptTokenMint > 0, "receiptTokenMint is Zero");
        // 발행할 receipt token 수량을 계산해서 _mint함수 호출.
        _mint(msg.sender, receiptTokenMint);
        // balanceOf를 이용해서 업데이트 함수 호출. 
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function removeLiquidity(uint _amount) external returns(uint amount0, uint amount1) {
        /*
        remove liquidity 시에 사용자가 제출한 receipt token 수량에 따른 
        내어주어야 하는 토큰0, 토큰1의 수량은
        (receiptBurn / TotalSupply) = (내줄 수량 / reserve0) = (내줄 수량 / reserve1)을 따름.
        현재의 reserve값을 읽어야 할 때, state variable reserve0/1을 읽을 수도 있고,
        balanceOf(address(this))로 읽을 수도 있음. 
        Constant Product는 정확하지 않은 값으로 계산할 때 사용자에게 손해를 미칠 수 있음.
        그래서 여기서는 balanceOf로 계산하겠음.
        */
        uint res0 = token0.balanceOf(address(this));
        uint res1 = token1.balanceOf(address(this));
        amount0 = (_amount * res0) / receiptTokenTotalSupply;
        amount1 = (_amount * res1) / receiptTokenTotalSupply;
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 is zero");
        // 값이 0이 아님을 확인한뒤, _burn과 _update 함수 호출
        _burn(msg.sender, _amount);
        _update(res0 - amount0, res1 - amount1);
        // 소각과 업데이트 후에 토큰을 msg.sender에게 보내기. 
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
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

    function _sqrt(uint y) private pure returns(uint z) {
        // _sqrt 함수는 입력값 y의 제곱근을 구하는 함수임.
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint x, uint y) private pure returns(uint) {
        // _min은 x, y 둘 중에서 더 작은 값을 반환함. 
        return x <= y ? x : y;
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