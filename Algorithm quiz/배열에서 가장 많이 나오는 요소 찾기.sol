// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


/*
문제: 정수로 구성된 배열이 주어지면, 배열에서 가장 자주 등장하는 요소를 반환하는 함수를 구현하세요. 
가장 자주 등장하는 요소가 여러 개인 경우, 어떤 요소를 반환해도 됩니다.

예시:
입력: [1, 2, 3, 2, 2, 3, 4, 4, 5]
출력: 2
입력: [1, 1, 2, 2, 3, 3, 4, 4, 5]
출력: 1 또는 2 또는 3 또는 4 (여러 개의 요소가 동일한 빈도로 등장하므로, 어떤 요소를 반환해도 됩니다.)
*/


contract MaxFrequency {
    mapping(uint => uint) public frequency;

    function findMax(uint[] memory _arr) public returns (uint, uint, uint, uint) {
        uint[] memory arr = new uint[](_arr.length);
        for (uint i = 0; i < _arr.length; i++) {
            arr[i] = _arr[i];
        }

        uint maxNum;
        uint maxNumFrequency;

        for (uint i = 0; i < arr.length; i++) {
            if (frequency[arr[i]] == 0) {
                frequency[arr[i]] = 1;
            } else {
                frequency[arr[i]]++;
            }

            if (frequency[arr[i]] > maxNumFrequency) {
                maxNum = arr[i];
                maxNumFrequency = frequency[arr[i]];
            }
        }

        return (frequency[1], frequency[2], maxNum, maxNumFrequency);
    }
}

/*
contract findMaxEgistance {
    mapping(uint => uint) public frequency;


    function findMax(uint[] calldata _arr) public returns(uint, uint) {
        
        uint[] memory arr = new uint[](_arr.length);
        for (uint i = 0; i < _arr.length; i++) {
            arr[i] = _arr[i];
        }
        uint maxNum;
        uint maxNumFrequency;

        for(uint i = 0; i < arr.length; i++) {
            if (frequency[arr[i]] == 0) {
                frequency[arr[i]] = 1;
            } else {
                frequency[arr[i]]++;
            }
            
            if(frequency[arr[i]] > maxNumFrequency) {
                maxNum = arr[i];
                maxNumFrequency = frequency[arr[i]];
            }
        }
        return (maxNum, maxNumFrequency);

    }
}
*/


