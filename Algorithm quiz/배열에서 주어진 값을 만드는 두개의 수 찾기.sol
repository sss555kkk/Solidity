// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


/*
문제: 정수로 이루어진 배열이 주어지면, 
배열에서 두 수의 합이 주어진 특정한 값과 동일한 쌍을 찾는 함수를 구현하세요. 
중복된 쌍을 포함하여 모든 쌍의 조합을 찾아도 되며, 
쌍이 존재하지 않는 경우에는 빈 배열을 반환해야 합니다.

예시:
입력: [2, 4, 5, 7, 8, 9], 합: 12
출력: [[4, 8], [5, 7]]
입력: [1, 2, 3, 4, 5], 합: 10
출력: [[4, 6]]
입력: [3, 1, 5, 2, 7], 합: 12
출력: []
*/


pragma solidity ^0.8.0;

contract FindTwoNumber {
    mapping(uint => bool) public arrToMap;
    uint[] public arr = new uint[](2);

    function findNumber(uint[] calldata _arr, uint _num) public returns (uint[] memory) {
        for (uint i = 0; i < _arr.length; i++) {
            uint tempNum = _num - _arr[i];
            for (uint j = i + 1; j < _arr.length; j++) {
                if (_arr[j] == tempNum) {
                    arr[0] = _arr[i];
                    arr[1] = _arr[j];
                    return arr;
                }
            }
        }
        return arr;
    }
}
