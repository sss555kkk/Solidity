const Web3 = require('web3');
const rpcURL = "https://sepolia.infura.io/v3/yourInfuraKey";
const web3 = new Web3(rpcURL);
const address = "0x511...802a"; // your account

web3.eth.getBalance(address, (err, wei) => { 
    var balance = web3.utils.fromWei(wei, 'ether');
    console.log(balance);
})

/*
본문 코드는 callback 함수를 사용했음. 

(1) callback을 쓰지 않고 간단한.then을 사용하면 아래와 같음. 
web3.eth.getBalance(address)
.then(console.log);

(2) 메서드도 쓰고, then/catch를 사용한 경우
web3.eth.getBalance(address)
  .then((wei) => {
    var balance = web3.utils.fromWei(wei, 'ether');
    console.log(balance);
  })
  .catch((err) => {
    console.error(err);
  });


(2) async/await를 사용한 경우
async function getBalance() {
  try {
    const wei = await web3.eth.getBalance(address);
    const balance = web3.utils.fromWei(wei, 'ether');
    console.log(balance);
  } catch (error) {
    console.error('Error:', error);
  }
}

getBalance();

*/
