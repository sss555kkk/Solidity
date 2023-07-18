var Tx     = require('ethereumjs-tx');
const Web3 = require('web3');
const rpcURL = "https://sepolia.infura.io/v3/yourInfuraKey";
const web3 = new Web3(rpcURL);

const toAddress = '0x311248Ae70F47F05A70Fcd41B1cE8B3f25c8448D';
const account1 = "0x5119...AD802a"; // 실제 account로 교체
const privateKey1 = Buffer.from(
  'c5ec...80f8daf', 
  'hex'
  );// 실제 privateKey로 교체

web3.eth.getTransactionCount(account1, (err, txCount) => {
    console.log(txCount);  
    
    const txObject = {
    nonce:    web3.utils.toHex(txCount),
    to:       toAddress,
    value:    web3.utils.toHex(web3.utils.toWei('0.02', 'ether')),
    gasLimit: web3.utils.toHex(21000),
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei'))
  }

  
  const tx = new Tx(txObject);
  tx.sign(privateKey1);

  const serializedTx = tx.serialize();
  const raw = '0x' + serializedTx.toString('hex');

  web3.eth.sendSignedTransaction(raw, (err, txHash) => {
    console.log('txHash:', txHash)
  });

  

/*
web3.eth.sendSignedTransaction(raw)
    .on('transactionHash', function(txHash){
      console.log('txHash:', txHash);
      // 로직 추가
    })
    .on('error', function(error) {
      console.error(error);
    });
  */
})

