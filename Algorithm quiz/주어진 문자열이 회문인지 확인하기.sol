// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 주어진 문자열이 회문(앞뒤가 동일한 문자열)인지 확인하기



contract Palindrome {
    function isPalindrome(string memory _str) public pure returns (bool) {
        bytes memory str = bytes(_str);
        uint length = str.length;
        for(uint i = 0; i< (length/2); i++) {
            if (str[i] != str[length-1-i]) {
                return false;
            }
        }
        return true;
    }
}

