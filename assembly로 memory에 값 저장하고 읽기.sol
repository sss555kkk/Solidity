// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;
/*
assembly로 memory에 값 저장하고 읽기. 
assembly내의 4줄은 아래처럼 실행함. 
EVM의 메모리 0x40은 free memory pointer임. 
mload(0x40)으로 free memory pointer 값을 저장함. 
mstore(add(result1, 0x20), _str)로 free memory pointer에서 
0x20 (32 바이트) 떨어진 위치에 _str 값을 저장함. 
여기서는 일부러 0x20을 더했음. 
mstore(0x40, add(result1, 0x40)) 로 기존의 free memory pointer 값을 
업데이트 함. 
지금처럼 더이상 메모리를 사용하지 않고 함수가 종료되면 안해도 됨. 여기서는 
시험삼아 일부러 넣었음. 
(add(result1, 0x20), 32)로 result1에서 0x20 떨어진 위치에서부터 32바이트 값을 읽기. 
*/
contract writeWithAssembly {

    function add(string memory _str) public pure returns (string memory) {
        assembly {
            let result1 := mload(0x40)
            mstore(add(result1, 0x20), _str)
            mstore(0x40, add(result1, 0x40))
            return (add(result1, 0x20), 32)    
        }
    }
}