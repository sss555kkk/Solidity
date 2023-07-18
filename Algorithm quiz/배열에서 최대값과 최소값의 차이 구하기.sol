// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


/*
주어진 배열에서 최대값과 최소값의 차이를 구하기
*/

contract findMaxDifference {


    function findMaxAndMin(uint[] calldata _arr) pure public returns(uint) {
    
        uint[] calldata arr = _arr;
        uint max= arr[0];
        uint min = arr[0];
        uint difference;
        for(uint i=0; i<arr.length; i++) {
            if(arr[i] > max) {
                max = arr[i];
            }
            if(arr[i] < min) {
                min = arr[i];
            }
        }
        difference = max - min;
        return difference;
    }
}