// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
/*
Signauture를 만들고 verifying 하는 가장 기본적인 단계. 
여기서는 계산하고 알아보기 쉽게 매개변수를 최소화했음. 
이런 식으로 signature를 만들면 
(1)다른 체인에서 사용한 signature를 메인넷에서 사용 가능,
(2)하나의 컨트랙에서 사용한 signature를 다른 컨트랙에서 사용가능, 
(3)한번 사용한 signature를 다시 사용 가능. 

이걸 각각 막는 방법은 (1)chainID, (2)verifying contract, (3)nonce를 
메시지에 포함시킴. 
메시지 확인을 더 정교하게 하는 방법은 message를 만들때, 데이터 type만 
모아서 typeHash를 만들고, 실제 변수 값들을 모아서 Hash를 만들고 이 두개를 합쳐서
최종 Hash를 만듬. 
*/

contract MakeSignature0 {
 
    function getMessageHash(address _from, address _to, uint _amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_from, _to, _amount));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
}

contract VerifySignature0 {

    function verify(address _from, address _to, uint _amount, bytes memory _signature) public pure returns (bool) {
        require(_signature.length == 65, "invaild signature");
        bytes32 messageHash = _getMessageHash(_from, _to, _amount);
        bytes32 ethSignedMessageHash = _getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, _signature) == _from;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory _signature) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }
    }

    function _getMessageHash(address _from, address _to, uint _amount) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_from, _to, _amount));
    }

    function _getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
}

