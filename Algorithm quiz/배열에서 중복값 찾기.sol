// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 주어진 배열에서 중복된 값 찾기

contract FindDup {
    function findDuplicates(uint[] memory _arr) public pure returns (uint[] memory) {
    uint length = _arr.length;
    uint[] memory duplicates = new uint[](length);
    uint duplicateCount = 0;
    
    for (uint i = 0; i < length; i++) {
        for (uint j = i + 1; j < length; j++) {
            if (_arr[i] == _arr[j]) {
                duplicates[duplicateCount] = _arr[i];
                duplicateCount++;
                break;
            }
        }
    }

    
    return duplicates;
}

}
