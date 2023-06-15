// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
/*
private state variable를 storage에서 직접 읽기. 
slot 번호로 정보를 보면 slot0에 private 변수인 num0가 저장되어 있음. 
slot1에 저장된 값의 왼쪽이 bytes값, 오른쪽이 문자열의 길이를 nibble로 나타낸 것임. 
그 bytes 값을 bytesToStr 값에 입력하고 호출하면 private 변수 string 문자열이 나옴. 
num1은 constant private이고 실행과정에서 나오지 않기 때문에 runtimeCode에도 포함되지 않음. 
creationCode에서 opcode를 보면 push1에서 0x64(= 100)이 나옴. 
*/

contract Base {
    uint private num0;
    string private str0;
    uint private constant num1 = 100;

    constructor(uint _num0, string memory _str0) {
        num0 = _num0;
        str0 = _str0;
    }

    function readStorageNb(uint256 slotNum) public view returns (bytes32 result0) {
        assembly {
            result0 := sload(slotNum)
        }
        return result0;
    }

    function bytesToStr(bytes memory _bytes) public pure returns (string memory) {
        string memory result1 = string(_bytes);
        return result1;
    }
}

