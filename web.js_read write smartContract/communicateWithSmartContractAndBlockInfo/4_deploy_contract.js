var Tx     = require('ethereumjs-tx')
const Web3 = require('web3')
const web3 = new Web3('https://sepolia.infura.io/v3/e20ef729a8ed485a954f975949de5f9a')

const account1 = "0x5119332457e4974ac73aeb454D4f275F07AD802a";
const privateKey1 = Buffer.from(
  'c5ec3029442b0ce8904e37874bbe7800e6f20cb4fadd8346fa699e6bc80f8daf', 
  'hex'
  );

// Deploy the contract
web3.eth.getTransactionCount(account1, (err, txCount) => {
  const data = "608060405234801561001057600080fd5b50610210806100206000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c80631003e2d2146100465780636c12770d14610076578063c35827dc14610094575b600080fd5b610060600480360381019061005b9190610120565b6100b2565b60405161006d919061015c565b60405180910390f35b61007e6100d6565b60405161008b919061015c565b60405180910390f35b61009c6100df565b6040516100a9919061015c565b60405180910390f35b6000816000808282546100c591906101a6565b925050819055506000549050919050565b60008054905090565b60005481565b600080fd5b6000819050919050565b6100fd816100ea565b811461010857600080fd5b50565b60008135905061011a816100f4565b92915050565b600060208284031215610136576101356100e5565b5b60006101448482850161010b565b91505092915050565b610156816100ea565b82525050565b6000602082019050610171600083018461014d565b92915050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b60006101b1826100ea565b91506101bc836100ea565b92508282019050808211156101d4576101d3610177565b5b9291505056fea264697066735822122047ee7d24438289452a6c818fb65d6162affcc53d45898dca08bb45906936118364736f6c63430008120033"

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(100000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    data: data
  }

  const tx = new Tx(txObject)
  tx.sign(privateKey1)

  const serializedTx = tx.serialize()
  const raw = '0x' + serializedTx.toString('hex')

  web3.eth.sendSignedTransaction(raw, (err, txHash) => {
    console.log('err:', err, 'txHash:', txHash)
    // Use this txHash to find the contract on Etherscan!
  })
})
/*
// Read the deployed contract - get the addresss from Etherscan
const abi = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"standard","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}]
const address = '0xF27844E4bBBAa29F4A20E2F6a3Df83AD49DDB39C'

const contract = new web3.eth.Contract(abi, address)

contract.methods.name().call((err, name) => {
  console.log('name:', name)
})
*/
