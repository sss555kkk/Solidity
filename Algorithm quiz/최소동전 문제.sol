// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/*
주어진 금액에 대해서 최소한의 동전 갯수로 해당 금액을 구성하는 방법
*/
contract MinCoinNum {

    function enterMoney(uint _num) pure public returns(uint[] memory) {

        uint[] memory arrayOfCoin = new uint[](6);
        arrayOfCoin[0] = 500;
        arrayOfCoin[1] = 100;
        arrayOfCoin[2] = 50;
        arrayOfCoin[3] = 10;
        arrayOfCoin[4] = 5;
        arrayOfCoin[5] = 1;
        uint[] memory theNumOfCoins = new uint[](6);
        uint amount = _num;

        for(uint i = 0; i<6; i++) {
            theNumOfCoins[i] = amount/arrayOfCoin[i];
            amount = amount % arrayOfCoin[i];
        }
        return theNumOfCoins;
    }
}



