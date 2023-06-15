// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
/*
data type 변환하기. 
*/

contract Base {
    function testClick() public pure returns(bytes memory, bytes32, uint, bytes5) {
        
        //str을 bytes로 변환
        bytes memory result0 = bytes("hello");
        // string을 해쉬변환. 당연한 이야기지만 바이트변환과 해쉬변환은 다른 것임. 
        bytes32 result1 = keccak256("hello");
        //해쉬를 다시 uint로 변환하기. bytes memory는 형변환이 안 됨. 
        uint result2 = uint256(keccak256("hello"));
        //bytes를 앞의 n바이트만 잘라내기
        bytes5 result3 = bytes5(keccak256("hello"));
        /*bytes의 특정 인덱스만 출력할 수도 있음.
        bytes1 result1 = strToBytes[0]; 
        bytes1 result2  = strToBytes[1]; 
        */
        return(result0, result1, result2, result3);
    }
        function numToNum() public pure returns(uint128, uint8) {
        uint256 a = 12345;
        uint128 b = uint128(a);
        uint16 c = 256;
        uint8 d = uint8(c);
 
        return (b, d);
    }
        
    function BytesNToBytesN() public pure returns(bytes2, bytes1) {
        bytes2 a = 0x1234;
        bytes1 b = bytes1(a);
 
        return (a, b);
    }

        function BytesNToUint() public pure returns(uint32, bytes4, bytes4, uint32) {
        uint32 a = 0xcafecafe;  
        bytes4 b = bytes4(a); 
        bytes4 c = 0xabcd1234;  
        uint32 d = uint32(c); 
 
        return (a, b, c, d);
    }
}