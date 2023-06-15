// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
memory에 값을 저장하고 출력하면 블록체인의 state에는 아무런 
변경이 없음. 따라서 이 두개 함수의 stateMutabliity는 pure임. 
bytesN은 고정배열, bytes는 사이즈가 변경될 수 있는 byte의 배열. 
*/

contract MemoryToMemoryEqual {
    function test1() public pure returns (bytes memory, bytes memory) {
        bytes memory data = new bytes(2);
        bytes memory greetings = hex"cafecafe";
        data[0] = 0x12;
        data[1] = 0x34;
        return (greetings, data);
    }

    function test2() public pure returns (bytes memory, bytes memory) {
        bytes memory data;
        bytes memory greetings = hex"cafecafe";
        data = greetings;
        data[0] = 0x12;
        data[1] = 0x34;
        data[2] = 0x56;
        return (greetings, data);
    }
}