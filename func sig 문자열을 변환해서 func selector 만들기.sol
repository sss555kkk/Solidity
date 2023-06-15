// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
문자열(function signature)을 bytes, keccak256, bytes4로 차례대로 변환해보기.
test1은 문자열의 bytes 변환.
test2는 32바이트 해쉬변환
test3은 앞의 4바이트만 잘라내서 저장하기. 
여기서 "transfer(address,uint256)"가 function signature,
test3의 결과값이 function selector임. 
*/
contract TestContract {
    function test1() public pure returns(bytes memory result) {
        result = bytes("transfer(address,uint256)");
        return result;
    }

    function test2() public pure returns(bytes32 result) {
        result = keccak256(bytes("transfer(address,uint256)"));
        return result;
    }

    function test3() public pure returns(bytes4 result) {
        result = bytes4(keccak256(bytes("transfer(address,uint256)")));
        return result;
    }
}