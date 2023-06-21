const axios = require('axios');

// 거래소 API 호출하여 거래소 가격 데이터 받아오기
function getExchangePrice() {
    
    return axios.get('https://api.example-exchange.com/price')
        .then(response => {
            if (response.status === 200) {
                return response.data.price;
            } else {
                return null;
            }
        })
        .catch(error => {
            return null;
        });
}

// dex API 호출하여 dex 가격 데이터 받아오기
function getDexPrice() {
    
    return axios.get('https://api.example-dex.com/price')
        .then(response => {
            if (response.status === 200) {
                return response.data.price;
            } else {
                return null;
            }
        })
        .catch(error => {
            return null;
        });
}

// 두 개의 가격을 비교하여 3% 이상 차이가 날 경우 차익거래 실행
function checkAbitrage() {
    let exchangePrice, dexPrice;

    getExchangePrice()
        .then(price => {
            exchangePrice = price;
            return getDexPrice();
        })
        .then(price => {
            dexPrice = price;

            if (exchangePrice && dexPrice) {
                const priceDifference = Math.abs(exchangePrice - dexPrice) / exchangePrice * 100;

                if (priceDifference >= 3) {
                    if (exchangePrice > dexPrice) {
                        buy();
                    } else {
                        sell();
                    }
                } else {
                    console.log("Price difference is below 5%.");
                }
            } else {
                console.log("Error occurred while fetching prices.");
            }
        })
        .catch(error => {
            console.log("Error occurred while fetching prices.");
        });
}

// 10초 주기로 checkAbitrage 반복실행. 
setInterval(checkAbitrage, 10000);


const Web3 = require('web3');
const privateKey = 4bde4f3e5c1b6af3b50492c72e9b1866e8c56fa869b1d9002fc40dd16726fa42; 
const infuraUrl = 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID'; 
const dexContractAddress = 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; 
const Token0Address = 0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb;
const Token1Address = 0xcccccccccccccccccccccccccccccccccccc;
// token0, 1에서 swap할 수량의 설정. 전체 수량의 일부 퍼센트로 설정.
const amount0 = 0;
const amount1 = 0;

// dex 스마트 컨트랙트 ABI
const dexContractABI = [
    //...
];

// exchangePrice > dexPrice 인 경우, token0를 token1로 swap
async function buy() {

  const web3 = new Web3(new Web3.providers.HttpProvider(infuraUrl));
  

  // 일반적인 토큰 swap이면 nonce값이 필요없음. 해당 dex가 permit을 사용한다면 필요함. 
  //const account = web3.eth.accounts.privateKeyToAccount(privateKey);
  //const nonce = await web3.eth.getTransactionCount(account.address);

  // Dex 스마트 컨트랙트의 인스턴스
  const dexContract = new web3.eth.Contract(dexContractABI, dexContractAddress);

  // Swap 함수를 호출
  const swapResult = await dexContract.methods.swap(token0Address, token1Address, amount0);
  console.log('Swap executed:', swapResult);
}


// exchangePrice < dexPrice 인 경우, token1를 token0로 swap
async function Sell() {

    const web3 = new Web3(new Web3.providers.HttpProvider(infuraUrl));
    

    // nonce는 permit을 사용하는 경우에만 필요함. 
    //const account = web3.eth.accounts.privateKeyToAccount(privateKey);
    //const nonce = await web3.eth.getTransactionCount(account.address);

    const dexContract = new web3.eth.Contract(dexContractABI, dexContractAddress);
    // Swap 함수를 호출
    const swapResult = await dexContract.methods.swap(token1Address, token0Address, amount1);
    console.log('Swap executed:', swapResult);
}

