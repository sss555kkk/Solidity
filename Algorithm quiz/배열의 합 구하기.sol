// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/* 
배열의 합 구하기
*/

contract SumOfArray {
    function calculateSum(uint[] memory _arr) public pure returns (uint) {
        uint result = 0;
        for(uint i=0; i<_arr.length; i++) {
            result += _arr[i];
        }
        return result;
    }
}