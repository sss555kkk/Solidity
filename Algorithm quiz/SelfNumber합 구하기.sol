// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/* 
숫자x의 자기자신과 각 자리수의 합을 더한 값을 d(x) 라고 하자. 
x가 존재하지 않는 수를 self number라고 한다. 
1에서 N까지 self number의 합을 구하라. 
*/



pragma solidity ^0.8.0;

contract SelfNumber {
    
    uint[] public arrOfNonSelfNumber;
    uint public sumOfNonSelfNumber;
    uint public sumOf1toN;
    uint public sumOfSelfNumber;

    // 입력한 숫자까지의 nonSelfNumber의 합을 구하되 중복값을 제외하고 구하기
    function getDx(uint _num) public returns (uint) {
        uint tempSumOfNonSelfNumber;
        uint endNumber = _num;
        uint tempNum;

        // 중복값을 제외한 non selfnumber의 합 구하기
        for(uint i=1; i<(endNumber+1); i++) {
            tempNum =  (i + i/1000 + i%1000/100 + i%100/10 + i%10);
            if(tempNum > endNumber) {
                continue;
            }
            for(uint j=0; j<arrOfNonSelfNumber.length; j++) {
                if(tempNum == arrOfNonSelfNumber[j]) {
                    break;
                }
            }
            arrOfNonSelfNumber.push(tempNum);
            tempSumOfNonSelfNumber += tempNum;
        }
        sumOfNonSelfNumber = tempSumOfNonSelfNumber;
        return sumOfNonSelfNumber;
    }

    // 1부터 n까지 합 구하기
    function sumFrom1ToN(uint n) public returns(uint) {
        sumOf1toN = n*(n+1)/2;
        return sumOf1toN;
    }

    // (1~N 합) - (1~N non-selfnumber 합) = (1~N selfnumber 합)
    function getValue() public returns(uint, uint, uint) {
        sumOfSelfNumber = sumOf1toN - sumOfNonSelfNumber;
        return (sumOf1toN, sumOfNonSelfNumber, sumOfSelfNumber);
    }

}

