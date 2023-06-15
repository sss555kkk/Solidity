// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
Alice와 Bob 컨트랙은 둘다 Test1 컨트랙을 인스턴스화해서 함수를 호출함. 
Alice는 test1Instance = new Test1();으로 인스턴스화함. 
Bob은 test1Instance = Test1(_addr);로 Test1의 주소를 넣어서 인스턴스화함. 
Alice처럼 new Test1();으로 인스턴스화하면 Test1의 로직만 복사하면 
저장된 값을 가져오지도 저장을 하지도 않음. Test1와 연결이 되지도 않음. 
매번 호출할 때마다 새로운 인스턴스화가 됨. 
Bob처럼 Test1(_addr);으로 Test1의 주소를 넣어서 사용하면
그냥 Test1.increaseNum으로 호출하는 것과 결과가 동일함. 
단지 가스비가 절약됨. 
*/

contract Test1 {
    uint public num;

    function increaseNum(uint _num) public returns(uint) {
        num += _num;
        return num;
    }
}

contract Alice {
    uint public num;
    Test1 public test1Instance;

    function increaseNum(uint _num) public returns(uint) {
        test1Instance = new Test1();
        num = test1Instance.increaseNum(_num);
        return num;
    }
}


contract Bob {
    uint public num;
    Test1 public test1Instance;

    function increaseNum(uint _num, address _addr) public returns(uint) {
        test1Instance = Test1(_addr);
        num = test1Instance.increaseNum(_num);
        return num;
    }
}

contract Chris {
    uint public num;
    Test1 public test1Instance;

    function increaseNum(uint _num) public returns(uint) {
        test1Instance = Test1(msg.sender);
        num = test1Instance.increaseNum(_num);
        return num;
    }
}