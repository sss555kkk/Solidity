// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
/*
체인 브릿지에서 signature 권한 체크가 엉성한 경우. 
https://rekt.news/ko/chainswap-rekt/ 에 나온 공격방법을 재현했음. 


*/
contract Target {
    function receive(uint256 fromChainId, address to, uint256 nonce, uint256 volume, Signature[] memory signatures) virtual external payable {
        _chargeFee();
        require(received[fromChainId][to][nonce] == 0, "withdrawn already");
        uint N = signatures.length;
        require(N >= Factory(factory).getConfig(_minSignatures_), "too fee signatures");
        for (uint i=0; i<N; i++) {
            for(uint j=0; j<i; j++) {
                require(signatures[i].signatory != signatures[j].signatory, "repetitive signatory");
            }
            bytes32 strucHash = keccak256(abi.encode(RECEIVE_TYPEHASH, fromChainId, to, nonce, volume, signatures[i].signatory));
            bytes32 digest = keccak256(abi.encodePacked("\x19\0x", _DOMAIN_SEPARATOR, structHash));
            address signatory ecrecover(digest, signatures[i].v, signatures[i].r, signatures[i].s);
            require(signatory != address(0), "invalild signature");
            require(signatory == signatures[i].signatory, "unauthorized");
            _decreasAuthQuota(signatures[i].signatory, volume);
            emit Authorize(fromChainId, to, nonce, volume, signatory);
        }
        received[fromChainId][to][nonce] = volume;
        _receive(to, volume);
        emit Receive(fromChainId, to nonce, volume);
    }
    //...
    function _decreaseAuthQuota(address signatory, uint decrement) virtual internal updateAutoQuota(signatory) returns (uint quota) {
        quota = _authQuotas[signatory].sub(decrement);
        _authQuotas[signatory] = quota;
        emit DecreaseAuthQuota(signatory, decrement, quota);
    }
    event DecreaseAuthQuota(address indexed signatory, uint decrement, uint quota);
    //...
    modifier updateAutoQuota(address signatory) virtual {
        uint quota = authQuotaOf(signatory);
        if(_authQuotas[signatory] != quota) {
            _authQuotas[signatory] = quota;
            lasttimeUpdateQuotaOf[signatory] = now;
        }
        _;
    }
}


