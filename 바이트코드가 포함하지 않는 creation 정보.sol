// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.18;


contract SimpleBytecodeTest0 {
    uint48 private constant A = 0x112233445566;  
    bytes6 private constant B = 0xaabbccddeeff;
}

/*
SimpleBytecodeTest0의 bytecode(runtime bytecode)를 봐도 constant 0x112233445566, 0xaabbccddeeff 는 나오지 않음.
코드의 실행과정에서 이 두개의 변수가 읽기, 쓰기, 호출, 등 어떤 함수에도 나오지 않음.
따라서 runtimeCode에 포함되지 않음. 
*/

contract SimpleBytecodeTest1 {
    uint48 public constant A = 0x112233445566;  
    bytes6 public constant B = 0xaabbccddeeff;
}

/*
SimpleBytecodeTest의 runtimeCode에서는 constant인 0x112233445566, 0xaabbccddeeff가 나옴. 
public인 state variable이므로 자동으로 getter 함수가 생기므로 
외부에서 getter 함수를 호출하면 이 값을 알려줘야 함. 따라서 당연히 runtimeCode 내에
외부에서 getter 함수를 호출하면 알려줄 값을 포함하고 있어야 함. 
*/