// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;
/*
contract을 만들고 나면 ABI 정보가 나옴. 
아래의 TestContract1에서는 함수 2개가 나옴. 
public state variable의 getter 함수가 자동으로 생성되었음. 
ABI 정보 중에서 type은 solidity data type을 Internal type은
바이트코드 레벨에서 인식하는 data type을 가리킴. 2개의 거의 일치하는데,
예외적으로 다른 경우는 (enum, uint8), (sturcts, tuple), (contract, address)임. 
예를 들어서 내가 enum을 정의하면 EVM은 이것을 uint8이라고 인식함. 
*/

contract TestContract1 {
    uint public num;

    function test1(uint _num) public returns(uint) {
        num += _num;
        return num;
    }
}

/*
위의 TestContract1에서 나온 ABI 정보는 아래와 같음. 
[
	{
		"inputs": [],
		"name": "num",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_num",
				"type": "uint256"
			}
		],
		"name": "test1",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]

*/


contract TestContract2 {

    function test2() public pure returns(string memory) {
        return "Hello";
    }
}


/*
위의 TestContract2에서 나온 ABI 정보는 아래와 같음. 
[
	{
		"inputs": [],
		"name": "test2",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	}
]

*/
