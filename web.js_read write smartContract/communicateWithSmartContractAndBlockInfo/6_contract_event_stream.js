const Web3 = require('web3')
const web3 = new Web3("https://sepolia.infura.io/v3/yourInfuraKey")

// OMG Token Contract
const contractAddress = '0xB7340cEcff0627aC043b93aceAF5F34929504179'
const contractABI = [
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
]

const contract = new web3.eth.Contract(contractABI, contractAddress)

// 특정블록부터 현재까지 contract의 이벤트 확인하기
contract.getPastEvents(
  'AllEvents',
  {
    fromBlock: 5854000,
    toBlock: 'latest'
  },
  (err, events) => { console.log(events) }
)
