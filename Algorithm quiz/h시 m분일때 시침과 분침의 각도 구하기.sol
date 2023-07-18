// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/*
현재의 시(hour)와 분(miniute)에서 시침과 분침 사이의 각도를 계산하기. 
각도는 0 =< 각도 =< 180 범위를 가진다. 
*/

contract ClockHandsAngle {
    function calculateClockHandsPoints(uint8 _hour, uint8 _miniute) public pure returns(uint8, uint8) {
        require(_hour > 12 || _miniute > 60, "invalid Number");
        uint8 hPoint = (_hour* 10) * 30 + (_miniute*10)/2;
        uint8 mPoint = (_miniute*10) *6;
        return (hPoint, mPoint);
    }

    function calculateClockHandsAngle(uint8 _hPoint, uint8 _mPoint) internal pure returns(uint16, string memory) {
        uint8 hPoint = _hPoint;
        uint8 mPoint = _mPoint;
        uint8 bigNumber;
        uint8 smallNumber;
        (bigNumber, smallNumber) = (hPoint > mPoint) ? (hPoint, mPoint) : (mPoint, hPoint);
        uint8 difference = bigNumber - smallNumber;
        if (difference > 180) {
            return (360 - difference, "please divide return value by 10");
        }
        return (difference, "please divide return value by 10");

    }
}