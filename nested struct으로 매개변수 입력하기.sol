// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
/*
nested struct 으로 매개변수 입력하기.
Garden struct은 struct안에 다시 struct Flower가 포함되어 있음. 
값을 입력(전달)할 때에는 [1,2,[[3,"White"],[4,"Red"]]] 같은 형식으로 입력함. 
*/

contract Sunshine {
    struct Garden {
      uint slugCount;  
      uint wormCount;
      Flower[] theFlowers;
    }
    struct Flower {
        uint flowerNum;
        string color;
    }
      
    function picker(Garden memory gardenPlot) public pure returns(uint, uint, Flower[] memory, uint, string memory) {
        uint a = gardenPlot.slugCount;
        uint b = gardenPlot.wormCount;
        Flower[] memory cFlowers = gardenPlot.theFlowers;
        uint d = gardenPlot.theFlowers[0].flowerNum;
        string memory e = gardenPlot.theFlowers[0].color;
    
        return (a, b, cFlowers, d, e);
    }
}
