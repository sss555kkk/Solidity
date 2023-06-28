// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;


import './tradingContractTemplete.sol';
import './nftManagerTemplete.sol'


// Deployer는 새로운 trading Market을 생성하고자 할 때, 해당 tradingContract과
// 거기에 해당하는 nft contract을 생성함. 
contract Deployer {
    event Created(address indexed addr);
    
    // 여기서 _index는 거래의 대상이 인덱스를 설정하기 위해서 매개변수를 받아서
    // 탈중앙화 오라클에 설정을 만들기 위해서임. 탈중앙화 오라클에 설정하는 방법을 몰라서
    // 여기서는 생략했음. 그냥 uint _index를 받는다 라고만 작성했음. 
    function createTradingContract(uint _index, uint _feeRate) external returns (address tradingContract) {
        /* feeRate는 uint로 입력받아서 (1/100000)변환해서 계산에 활용. 예를 들어 300을 입력받았다면
        수수료는 300/100000 = 0.003 = 0.3% 임. 
        */
        require(_feeRate >= 0 && _feeRate < 100000, "invaild feeRate range");
        // 저장해놓은 templete에 입력받은 값을 salt로 활용해서 새로운 컨트랙 주소를 생성
        bytes memory bytecode = type(tradingContractTemplete).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(bytes(_index, _feeRate)));
        address tradingContract;
        assembly {
            tradingContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        _createtradingManager(tradingManager);
        _createNftManager(tradingContract);

        emit Created(tradingContract);
    }

    function _createTradingManager(uint _index, uint _feeRate) external returns (address tradingContract) {
       
        // 저장해놓은 templete에 입력받은 값을 salt로 활용해서 새로운 컨트랙 주소를 생성
        bytes memory bytecode = type(tradingManagerTemplete).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(tradingContract));
        address tradingManager;
        assembly {
            tradingManager := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        emit Created(tradingManager);
    }

    function _createNftManager(address tradingContract) private returns (address nftManager) {
        
        // 저장해놓은 templete에 입력받은 값을 salt로 활용해서 새로운 nft컨트랙 주소를 생성
        bytes memory bytecode = type(nftManagerTemplete).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(tradingContract));
        address nftManager;
        assembly {
            nftManager := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        emit Created(nftManager);
    }