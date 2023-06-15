//SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.18;
/*
contract Daniel은 Add 라이브러리를 이용해서 계산을 수행함. 
uint에 대해서 add 라이브러리를 적용한다고 선언했으므로
(_num0.add(_num1))으로 _num0에 적용된 add 라이브러리에 _num1을 
대입하여 라이브러리를 사용함. 
*/
library Add {
    function add(uint _num0, uint _num1) internal pure returns(uint) {
        return _num0 + _num1;
    }
}

//import "./Add.sol";

contract Daniel {
    using Add for uint;

    function addByLibrary(uint _num0, uint _num1) public pure returns(uint) {
        return (_num0.add(_num1));
    }
}