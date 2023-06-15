// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
/*
runtimeCode와 CreationCode의 차이 보기.
Base contract을 배포하고 BytecodeViewer 컨트랙으로 Base의 주소를 
입력해서 runtimeCode, CreationCode를 볼 수 있음. 
참고로 Bytescode만 볼 수 있음. solidity로 보는 건 불가능함. 

함수를 실행해서 결과 4개를 보면 
address(_addr).code == runtimeCode. 
address(_addr).codehash == code의 keccak256 해쉬. 
type(Base).runtimeCode == 코드 실행시에 필요한 코드.
type(Base).creationCode = (설정부분) + runtimeCode.
당연히 CreationCode가 runtimeCode보다 항상 더 큼. 
*/

contract Base {
    function doNothing() public pure {

    }
}


contract BytecodeViewer {

    function getCodeHash(address _addr) external view returns (
        bytes memory, 
        bytes32, 
        bytes memory, 
        bytes memory) {
        
        bytes memory code = address(_addr).code;
        bytes32 codeHash = address(_addr).codehash;
        bytes memory creationCode = type(Base).creationCode;
        bytes memory runtimeCode = type(Base).runtimeCode;

        return (code, codeHash, creationCode, runtimeCode);
    }
}
