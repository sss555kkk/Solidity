package main

import (
	"bytes"
	"crypto/sha256"
	"fmt"
	"strconv"
	"time"
)

// 구조체로 Block 만들기 
type Block struct {
	Timestamp     int64
	Data          []byte
	PrevBlockHash []byte
	Hash          []byte
}

/* 블록 구조체의 method 정의
timestamp: 현재시각의 uint8 배열
headers: 이전블록해쉬, data, timestamp (2중) 배열의 
구분자를 없애서 하나의 문자열처럼 만듬
hash: header 정보를 해쉬화
b.hash: 고정크기배열을 가변길이 슬라이스로 전체 슬라이싱
*/
func (b *Block) SetHash() {
	timestamp := []byte(strconv.FormatInt(b.Timestamp, 10))
	headers := bytes.Join(
		[][]byte{b.PrevBlockHash, b.Data, timestamp}, []byte{}
	)
	hash := sha256.Sum256(headers)
	b.Hash = hash[:]
}

/*
새로운 블록생성 함수 정의.
Block 구조체에 값을 입력해서
block.SetHash method로 값을 계산해서 새로운 블록을 반환.
*/
func NewBlock(data string, prevBlockHash []byte) *Block {
	block := &Block{time.Now().Unix(), []byte(data), prevBlockHash, []byte{}}
	block.SetHash()
	return block
}

// 블록 구조체의 배열을 블록체인 구조체로 정의
type Blockchain struct {
	blocks []*Block
}

/*
현재 블록체인(블록 구조체의 배열)의 가장 마지막 블록을
prevBlock으로 저장. PrevBlock.Hash와 data를 매개변수로 입력해서
NewBlock 함수 호출한 결과값을 newBlock에 저장. 
newBlock을 현재 블록체인에 삽입(append)해서 블록을 추가함. 
*/
func (bc *BlockChain) AddBlock(data string) {
	prevBlock := bc.blocks[len(bc.blocks)-1]
	newBlock := NewBlock(data, prevBlock.Hash)
	bc.blocks = append(bc.blocks, newBlock)
}

//최초블록 생성 함수 정의.
func NewGenesisBlock() *Block {
	return NewBlock("Genesis Block", []byte{})
}

// 새로운 블록체인 생성함수 정의. 
// 블록체인 생성 함수 호출하면 genesisBlock 함수가 호출됨. 
func NewBlockchain() *Blockchain {
	return &Blockchain{[]*Block{NewGenesisBlock()}}
}

/*
이 모듈의 main 함수
NewBlockchain() 함수 호출, 새로운 블록체인 인스턴스를 bc라고 저장.
bc.AddBlock() 메서드에 데이터를 입력해서 블록 1개 추가.
bc.AddBlock() 메서드에 데이터를 입력해서 블록 1개 추가.
현재 이 블록체인은 총 3개의 블록이 있음. 
*/
func main() {
	bc := NewBlockchain()

	bc.AddBlock("Send 1 BTC to Ivan")
	bc.AddBlock("Send 2 more BTC to Ivan")

	for _, block := range bc.blocks {
		fmt.Printf("Prev. hash: %x\n", block.PrevBlockHash)
		fmt.Printf("Data: %s\n", block.Data)
		fmt.Printf("Hash: %x\n", block.Hash)
		fmt.Println()
	}
}
