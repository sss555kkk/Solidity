// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.18;
/*
32바이트 이상의 데이터를 메모리에서 읽기. 
mload(offset)에서 offset은 메모리 번호(ex:0x40)를 가리킬 수도 있고 찾고 싶은 바이트값을
직접 입력해도 됨. 
입력값으로 65바이트를 넣은 경우, 메모리 1개의 크기(32바이트)를 초과했기 때문에
p = 이 데이터의 length(바이트로 41, 십진수로65)
r = 이 데이터의 처음 32바이트
s = 이 데이터의 33 ~64 바이트
v = 마지막 1 바이트의 십진수 환산값
이 나옴. 

함수 실행을 다 한 다음에 memory를 보면 이 65바이트의 값이 2번 반복되어 있음.
아마도 저장할 때에 메모리에 사용하고, 마지막에 반환값으로 내가 p, r, s, v를 
지정했으니 그 값들의 반환을 위해서 p, r, s, v를 차례대로 메모리에 저장하고 사용한거인듯.
*/

contract TestMemoryNum {

    function readMultiBytesFromMemory(
        bytes memory sig
    ) public pure returns (bytes32 p, bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            p := mload(sig)
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

}
