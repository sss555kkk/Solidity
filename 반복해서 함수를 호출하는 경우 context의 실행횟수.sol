// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.18;
/*
재진입 context에 따른 실행횟수.
컨트랙의 함수에 재진입이 일어날 경우, 재진입한 context들은 
각각의 context가 별도로 함수 로직의 끝까지 실행됨. 
이 예시는 Base0 컨트랙에서 공격자가 최초에는 
Base1을 호출하게 한 뒤에 그 다음에는 정상적인 Base2를 호출하게 해서 
다시 진입함으로써 총 2회 진입함. 
재진입을 유발하는 코드 이후의 로직도 2회 실행됨. 
이 원리는 재진입 공격의 횟수를 결정하기 위해서 중요함. 
공격자 입장에서 무조건 재진입을 무제한으로 많이 하는게 좋지 않음. 
조건(예를 들어서 보유한 토큰이 떨어지면 revert가 일어나는 경우)에 
따라서 재진입 횟수를 일부러 제한하거나 특정조건이 되면 더이상 재진입을
하지 않도록 설정해야 됨. 
*/

contract Base0 {
    uint public counter0;
    function deposit(address _addr) public {
        IBase(_addr).callme();
        counter0 += 1;
    }
}

interface IBase {
    function callme() external;
}


contract Base1 is IBase {
    uint public counter1;
    address public base1Addr;
    address public base2Addr;
    address public targetAddr;
    Base0 public base0Instance;

    function start(address _targetAddr, address _base1Addr, address _base2Addr) public {
        targetAddr = _targetAddr;
        base1Addr = _base1Addr;
        base2Addr = _base2Addr;
        base0Instance = Base0(targetAddr);
        base0Instance.deposit(base2Addr);
    }

    function callme() public {
        base0Instance = Base0(targetAddr);
        base0Instance.deposit(base2Addr);
        counter1 += 1;
    }
}

contract Base2 is IBase {
    uint public counter2;

    function callme() public {
        counter2 += 1;
    }
}
