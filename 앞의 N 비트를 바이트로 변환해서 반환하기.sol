// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
/*
앞의 N 비트를 바이트로 변환해서 반환하기
bytes1 값과 _n을 입력받아서 _x를 바이너리 비트로 변환해서 가장 왼쪽 _x개 만큼의 
비트를 다시 bytes1 데이터 타입으로 변환해서 반환함. 
중간의 계산 과정은 비트연산이 정수계산, bytes 계산과 어떤 식으로 연관되는지를 
알아야 됨.  
*/

contract Base {

    function getFirstNBytes(bytes1 _x, uint8 _n) public pure returns (bytes1) { 
    require(2 ** _n < 255, "Overflow encountered !"); 
    bytes1 nOnes = bytes1(abi.encode(uint(2 ** _n - 1))); 
    bytes1 mask = nOnes >> (8 - _n); // Total 8 bits 
    return _x & mask; 
    }
}
