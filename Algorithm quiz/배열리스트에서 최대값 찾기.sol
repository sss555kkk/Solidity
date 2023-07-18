// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/* 
배열 리스트에서 최대값 찾기
*/

contract findMaxElement {
    function findMax(uint[] calldata _arr) public pure returns(uint) {
        uint[] calldata arr = _arr;
        uint maxNum = arr[0]; 
        for(uint i = 0; i<arr.length; i++) {
            
            maxNum = (maxNum < arr[i])? arr[i] : maxNum;
        }
        return maxNum;
    }
}