// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.18;
/*
delegatecall의 기본적인 사용법. 
state variable 구조가 동일해야 계산 결과를 
contract A에 정상적으로 저장할 수 있음. 
받은 데이터를 콜데이터에 받아서 읽어와서 다시 저장할 수도 있음. 
*/
contract B {
    uint public counter0;
    string public message0;

    function increaseNum(uint256 _counter0, string memory _message0) public returns(uint, string memory) {
        counter0 += _counter0;
        message0 = _message0;
        return (counter0, message0);
    }
}



contract A {
    uint public counter0;
    string public message0;

    function try1(address _addr, uint256 _counter0, string memory _message0) public returns(bool) {
        
        (bool success, ) = _addr.delegatecall(abi.encodeWithSignature("increaseNum(uint256,string)", _counter0, _message0));
        return(success);
    }
}