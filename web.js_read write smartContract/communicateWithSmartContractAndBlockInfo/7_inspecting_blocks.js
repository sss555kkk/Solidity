const Web3 = require('web3')
const web3 = new Web3("https://sepolia.infura.io/v3/yourInfuraKey")

// get latest block number
web3.eth.getBlockNumber().then(console.log)

// get latest block
web3.eth.getBlock('latest').then(console.log)

// get latest 10 blocks
web3.eth.getBlockNumber().then((latest) => {
  for (let i = 0; i < 10; i++) {
    web3.eth.getBlock(latest - i).then(console.log)
  }
})

// get transaction from specific block
const hash = '0x66b...f502073'; // 실제 txHash로 해당 transaction 정보보기
web3.eth.getTransactionFromBlock(hash, 2).then(console.log)
