const Web3 = require('web3')
const web3 = new Web3("https://sepolia.infura.io/v3/yourInfuraKey")

// 기타 주요 read와 변환 함수들.
// Get average gas price in wei from last few blocks median gas price
web3.eth.getGasPrice().then((result) => {
  console.log(web3.utils.fromWei(result, 'ether'));
})

// Use sha256 Hashing function
console.log(web3.utils.sha3('Dapp University'));

// Use keccak256 Hashing function (alias)
console.log(web3.utils.keccak256('Dapp University'));

// Get a Random Hex
console.log(web3.utils.randomHex(32));

// Get access to the underscore JS library
const _ = web3.utils._;

_.each({ key1: 'value1', key2: 'value2' }, (value, key) => {
  console.log(key);
});
