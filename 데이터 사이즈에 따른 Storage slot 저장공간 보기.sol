// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.18;
/*
데이터 사이즈에 따른 storage 슬롯 저장공간 보기. 
a는 32바이트, b, c, d는 각각 8, 8, 16 바이트. 따라서
slot0번에 a가 저장됨. slot1번에 b, c, d가 저장되어 있음.
*/

contract StorageContract {
    uint256 a = 10;
    uint64 b = 20;
    uint64 c = 30;
    uint128 d = 40;

    function readStorageSlot0() public view returns (bytes32 result) {        
        assembly {
            result := sload(0)
        }
        return result;  
    }    
    
    function readStorageSlot1() public view returns (bytes32 result) {        
        assembly {
            result := sload(1)
        }
        return result;  
    }

}

