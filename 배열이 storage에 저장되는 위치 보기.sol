// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
/*
이 컨트랙에서 이해가 안 가는 부분이 있다. state variable로 uint와 uint[]을 선언하고 
값도 저장했다. 배포한 다음에 readStorageNB 함수로 slot 번호를 0부터 확인해보면 
slot0에 10이 저장되어 있고, slot1에 "3" 이 저장되어 있고, 
그 뒤부터는 그냥 0으로만 나옴. 배열 arr0의 size가 3이라는 거는 저장이 되어 있는데,
값인 [2, 4, 6] 은 저장된 곳을 찾을 수가 없다. 이 값들은 도데체 어디에 저장되어 있는가?
*/

contract Base {
    uint public num0 = 10;
    uint[] public arr0 = [2, 4, 6];

    function readStorageNb(uint256 slotNb) public view returns (bytes32 result0) {
        assembly {
            result0 := sload(slotNb)
        }
        return result0;
    }

    function getSlotNumbers() public pure returns(uint256 slotA, uint256 offsetA) {        
        assembly {            
            slotA := arr0.slot
            offsetA := arr0.offset
        }
    }   

    function strToBytes(string memory _str) public pure returns (bytes memory) {
        bytes memory result1 = bytes(_str);
        return result1;
    }
}

/*
    bytes32 public myBytes = 0xcafecafecafecafecafecafecafecafecafecafecafecafecafecafecafecafe;
    string public str0 = "Hello";
    mapping (uint num1 => string str2) public map0;
    struct structure0 {
        uint num2;
        uint num3;
    state variable에 여러가지 data type을 넣어보면서 위치를 찾아볼 수 있음. 
*/
