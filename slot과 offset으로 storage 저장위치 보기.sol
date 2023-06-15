// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
/*
slot과 offset 정보를 보면 Storage Slot0이 이렇게 저장되어 있다는 것을 알 수 있음.
state variable이 storage에 저장되는 순서는 저장순서, data type에 영향을 받음. 
|              16bytes              |        8bytes    |        8bytes    |
000000000...                  ...003             ...002              ...001

한가지 특이한 점은 이 함수는 state variable의 값의 위치를 읽어왔는데,
view를 쓰면 compile error가 나오고 pure를 써야 error가 나오지 않음. 
아마도 opcode에서 state variable의 값을 복사해서 stack에 저장하는 과정이 없으므로
compiler는 이게 pure라고 판단한 것인거 같음. 
*/

contract Storage {    
    uint64 a = 1;
    uint64 b = 2;
    uint128 c = 3;    
    
    function getSlotNumbers() public pure returns(
        uint256 slotA, 
        uint256 slotB, 
        uint256 slotC
        ) {
        assembly {            
            slotA := a.slot
            slotB := b.slot
            slotC := c.slot
            }
    }


    function getVariableOffsets() public pure returns(
        uint256 offsetA, 
        uint256 offsetB, 
        uint256 offsetC
        ) {   
        assembly {            
            offsetA := a.offset
            offsetB := b.offset
            offsetC := c.offset
            }
    }
}

