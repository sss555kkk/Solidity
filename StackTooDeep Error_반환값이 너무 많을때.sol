// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
/* 
아래 함수는 compiler에서 stack too deep 에러가 나옴. struct을 만들어서 변수를 만들고
각각의 변수에 값을 넣고, 반환할 때에는 구조체를 반환할 수 없음. 
구조체의 값을 일일히 하나씩 반환하거나, 구조체의 값을 배열로 다시 만들어서 반환해야 함. 
*/
contract Base {
    function testClick() public pure returns(uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        uint a = 100;
        uint b = 100;
        uint c = 100;
        uint d = 100;
        uint e = 100;
        uint f = 100;
        uint g = 100;
        uint h = 100;
        uint i = 100;
        uint j = 100;

        return(a, b, c, d, e, f, g, h, i, j);
    }
}

