const fs = require('fs');
const IPFS = require('ipfs-http-client');
const Web3 = require('web3');
const contractABI = require('./contractABI.json');
const ipfs = IPFS.create();

// Ethereum 네트워크, contract address 설정
const web3 = new Web3('https://ropsten.infura.io/v3/your_infura_project_id');
const contractAddress = '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const contract = new web3.eth.Contract(contractABI, contractAddress);

// 이미지와 제목 업로드 예시
const imagePath = 'path/to/image.jpg';
const title = 'MyFirstNFT';

// 이미지 및 제목 업로드 함수
async function uploadImageAndTitle(imagePath, title) {
  try {
    // 이미지 업로드
    const imageBuffer = fs.readFileSync(imagePath);
    const imageUpload = await ipfs.add(imageBuffer);
    const imageURI = imageUpload.cid.string;

    // 제목과 이미지 URI를 스마트 컨트랙트의 mint 함수에 전달하여 NFT 발행
    const tokenId = await contract.methods.mint(imageURI, title);

    console.log('NFT mint function call.');
    console.log('Token ID:', tokenId);
  } catch (error) {
    console.error('에러 발생:', error);
  }
}



uploadImageAndTitle(imagePath, title);
