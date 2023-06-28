// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// nft는 trader가 포지션에 진입했을 때 포지션에 대한 receipt로 nft를 발행. 
// nft를 반환하면 trader는 전체정산을 한 뒤에 자신의 포지션에서 exit함. 
contract NFTmanager is IERC721 {
    
    constructor (address _tradingManager) {
        tradingManager = _tradingManager;
    }
    
    // 이 nft는 tradingManager에서 호출이 되었을 때에만 발행과 소각을 함. 
    modifier onlyTradingManager {
        require(msg.sender == tradingManager, "Invaild address");
        _;
        }
    
    function mint(address _to, uint _id) external onlyTradingManager {
        require(_to != address(0), "mint to zero address");

        _balanceOf[_to]++;
        _ownerOf[_id] = _to;

        emit Transfer(address(0), _to, _id);
    }

    function burn(uint id) external onlyTradingManager {
        
        address owner = _ownerOf[id];
        _balanceOf[owner] -= 1;
        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }
    // ...
}
