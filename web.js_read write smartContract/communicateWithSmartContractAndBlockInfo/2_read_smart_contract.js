const Web3 = require('web3');
const rpcURL = "https://sepolia.infura.io/v3/yourInfuraKey";
const web3 = new Web3(rpcURL);
const abi = [
    {
        "inputs": [],
        "name": "accumulatedNumber",
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
        "name": "add",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getAccumulatedNumber",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];
const address = '0xafc4fe7b3b65847273a93ac99161eb2c033fb55a'; 
const contract = new web3.eth.Contract(abi, address);

contract.methods.getAccumulatedNumber().call((err, result) => {
    console.log(result);
   })

/*
//동일한 호출을 async/await로 실행하기. 
async function exampleFunction() {
  try {
    var accumulatedNumber = 
        await targetSmartContract.methods.getAccumulatedNumber().call();
    console.log('Accumulated number:', accumulatedNumber);
  } catch (error) {
    console.error(error);
  }
}


// 아래는 다른 함수들을 호출하는 예시. 
contract.methods.totalSupply().call((err, result) => {
     console.log(result) 
    })
contract.methods.name().call((err, result) => {
     console.log(result) 
    })
contract.methods.symbol().call((err, result) => {
     console.log(result) 
    })
    // account는 실제 account 로 교체
contract.methods.balanceOf('0xd261...0C07').call((err, result) => {
     console.log(result) 
    })
*/


