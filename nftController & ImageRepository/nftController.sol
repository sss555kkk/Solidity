// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract MyNewNFTContract is ERC721 {
    
    event Transfer(address indexed from, address indexed to, uint indexed id);
    event Approval(address indexed owner, address indexed spender, uint indexed id);
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    constructor(address _addr) {
        admin = _addr;
    }
    
    // ImageRepository address가 admin이 되고 admin이 mint 권한을 가지도록 함. 
    address admin;
    // 토큰 아이디와 owner 주소를 매핑
    mapping(uint => address) internal _ownerOf;

    // owner 주소와 보유하고 있는 토큰(NFT) 갯수를 매핑
    mapping(address => uint) internal _balanceOf;

    // 토큰 아이디와 approval을 받은 주소를 매핑
    mapping(uint => address) internal _approvals;

    // owner 주소와 operator 주소와 approval 여부를 매핑
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    // nft uri와 title을 struct[] 으로 저장
    struct NFTMetadata {
        string uri;
        string title;
    }

    NFTMetadata[] public nfts;

    modifier onlyAdmin {
        require(msg.sender == admin, "invaild caller");
        _;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        /* 외부에서 이 함수를 호출해서 bytes4(keccak256(인터페이스 이름))을 입력하면
         이 컨트랙은 상속받은 2개의 인터페이스 IERC721, IERC165의 해쉬, bytes4와
         대조해서 맞는 여부를 알려줌. 상속받은 인터페이스를 물어보면 bool로 응답함.  
        */ 
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    // 토큰ID를 입력하면 owner 주소를 반환함.
    function ownerOf(uint id) external view returns (address owner) {
        owner = _ownerOf[id];
        require(owner != address(0), "token doesn't exist");
    }
    
    // owner 주소를 입력하면 이 주소가 가지고 있는 토큰의 갯수를 반환함.
    function balanceOf(address owner) external view returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return nfts[tokenId].uri;
    }

    function getTitle(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: Title query for nonexistent token");
        return nfts[tokenId].title;
    }

    /* 
    msg.sender가 operator 주소와 true를 입력하면 msg.sender가 가지고 있는 
    모든 토큰(NFT)의 approval을 승인함. false를 입력하면 반대로 모든 승인을 취소함.
    */
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    //owner 또는 전체 승인을 받은 address가 토큰 ID의 approval을 받을 주소를 입력할 수 있음. 
    function approve(address spender, uint id) external {
        address owner = _ownerOf[id];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );

        _approvals[id] = spender;

        emit Approval(owner, spender, id);
    }

    // 토큰 ID를 입력하면 이 ID에 대해서 approval을 받은 주소를 반환함. 
    function getApproved(uint id) external view returns (address) {
        require(_ownerOf[id] != address(0), "token doesn't exist");
        return _approvals[id];
    }

    /*
    토큰 ID와 owner, spender 주소를 입력하면 spender가 이 토큰을 전송할 자격이 있는지 확인함.
    전송 자격은 (1)spender가 owner와 일치하는 경우, (2)approve를 받은 경우, 
    (3) setApprovalForAll을 받은 경우, 이 3개중 하나를 만족하는지 확인함.
    */
    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint id
    ) internal view returns (bool) {
        return (spender == owner ||
            isApprovedForAll[owner][spender] ||
            spender == _approvals[id]);
    }

    // 토큰 ID와 from, to 주소를 입력하면 ID와 owner 주소가 맞는지
    // msg.sender가 전송자격이 있는지를 _isApproveedOrOwner 함수로 확인한 뒤에 전송. 
    function transferFrom(address from, address to, uint id) public {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }
    
    //safeTransfer를 호출하면 매개변수를 그대로 전달해서 transfer함수를 호출함. 
    // 다만 아래에 require 조건이 있음. 
    function safeTransferFrom(address from, address to, uint id) external {
        transferFrom(from, to, id);
        
        // 코드길이가 0, 다시 말해서 CA가 아닌 EOA이거나, 또는 받는 주소로 
        // IERC721Receiver 인터페이스를 구현해서 onERC721Received 함수호출한 결과가
        // IERC721Receiver의 onERC721Received 함수selector와 일치, 다시 말해서
        // 받는 CA가 IERC721Receiver를 상속받아서 구현하고 있어야 함. 
        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(msg.sender, from, id, "") ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    // safeTransferFrom 라는 이름의 함수가 2개 있음. 오버로딩. 두번째 함수는 bytes 매개변수가 더 존재함.
    function safeTransferFrom(
        address from,
        address to,
        uint id,
        bytes calldata data
    ) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(msg.sender, from, id, data) ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    // 새로운 NFT Mint. 이 함수는 internal임. 아래에 새로운 컨트랙에서 ERC721
    // 컨트랙을 상속받아서 새 함수를 정의한 다음 그 함수가 _mint를 internal로 
    // 호출해서 사용할 것임. 
    function _mint(address to, uint id) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    // burn. 역시 internal임. 위의 transfer 함수들은 모두 address(0)로 전송을 허용하지 않음. 
    // 소각을 하고 싶다면 address(0)로 transfer 하지 말고 _burn 함수를 써야함. 
    function _burn(uint id) internal {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }

    // MyNFT.mint를 호출하면 ERC721에서 상속받은 _mint함수를 internal로 호출함. 
    function mint(address to, uint id) external onlyAdmin {
        uint256 tokenId = nfts.length;
        nfts.push(NFTMetadata(_uri, _title));
        _mint(to, id);
    }

    function burn(uint id) external {
        // MyNFT.burn을 호출하면 ERC721에서 상속받은 _burn함수를 internal로 호출함.
        // 위의 MyNFT.burn()에서는 msg.sender가 owner와 일치하는지 확인하는 과정이 없었음. 
        // 따라서 여기서 확인하고 true이면 _burn 함수 internal로 호출함.
        require(msg.sender == _ownerOf[id], "not owner");
        _burn(id);
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns(bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

    function transferFrom(address from, address to, uint tokenId) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

