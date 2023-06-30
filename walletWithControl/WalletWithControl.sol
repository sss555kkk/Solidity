// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract walletWithControll {
    
    uint public requiredConfirmNum;
    /* 
    wallet 사용자를 레벨로 분류. 0: 사용자 아님. 
    L1: 제안, 찬/반 가능.
    L2: 제안, 찬/반, 거부권, 사용자 추가/삭제 가능
    L3: 제안, 찬/반, 거부권, 사용자 추가/삭제, 
    사용자 레벨업, 레벨다운, 단독 실행, 실행을 위해 필요한 찬성숫자 변경 가능
    */
    mapping(address => uint) public accountsLevel;
    mapping(uint => mapping(address => bool)) public isConfirmed;
    struct OrderInfo {
        address submitter;
        address to;
        bytes data;
        uint numConfirmations;
        bool rejected;
        bool executed;
    }
    OrderInfo[] public orderInfos;

    event submition (address, address, bytes);
    event accountLevelChange(address, uint, uint);
    event orderExecuted(address, address, bytes);
    event checkLevel (address, uint);
    event viewOrderInfo (address, address, bytes, uint, bool, bool);
    

    //  최초생성자는 자동으로 level 3로 설정. 
    constructor() {
        accountsLevel[msg.sender] = 3;
    }

    // level에 따른 호출할 수 있는 권한을 조절하기 위한 modifier들

    modifier onlyLevel1Above() {
        require(accountsLevel[msg.sender] >= 1, "invalid account");
        _; 
    }
    modifier onlyLevel2Above() {
        require(accountsLevel[msg.sender] >= 2, "invalid account");
        _;     
    }
    modifier onlyLevel3() {
        require(accountsLevel[msg.sender] >= 3, "invalid account");
        _; 
    }

    // order의 상태에 따라서 함수실행을 승인/거절하는 modifier들
    modifier orderExists(uint _orderNum) {
        require(_orderNum < orderInfos.length, "order does not exist");
        _;
    }
    modifier notExecuted(uint _orderNum) {
        require(!orderInfos[_orderNum].executed, "order already executed");
        _;
    }
    modifier notRejected(uint _orderNum) {
        require(!orderInfos[_orderNum].rejected, "order already rejected");
        _;
    }
    modifier notConfirmed(uint _orderNum) {
        require(!isConfirmed[_txIndex][msg.sender], "order already confirmed");
        _;
    }

    
    // 멤버를 추가하거나 제거하는 함수
    function addLevel1 (address _newAddr) public onlyLevel2Above {
        require(accountsLevel[_newAddr] == 0, "already level account");
        accountsLevel[_newAddr] = 1;
        emit accountLevelChange(_newAddr, 0, 1);
    }
    function removeLevel1 (address _newAddr) public onlyLevel2Above {
        require(accountsLevel[_newAddr] != 0, "not level account");
        accountsLevel[_newAddr] = 0;
        emit accountLevelChange(_newAddr, 1, 0);
    }
    
    // 기존멤버의 레벨을 올리거나 내리는 함수
    function levelUp(address _newAddr) public onlyLevel3 {
        uint i = accountsLevel[_newAddr];
        require((i == 1 || i ==2), "invalid or already level3");
        i += 1;
        accountsLevel[_newAddr] = i;
        emit accountLevelChange(_newAddr, (i-1), i);
    }
    function leveldown(address _newAddr) public onlyLevel3 {
        uint i = accountsLevel[_newAddr];
        require((i == 3 || i ==2), "invalid or already level1");
        i -= 1;
        accountsLevel[_newAddr] = i;
        emit accountLevelChange(_newAddr, (i+1), i);
    }

    // order 실행을 위해서 필요한 최소찬성숫자를 변경하는 함수
    function changeRequiredConfirmNum(uint _newNum) public onlyLevel3 {
        require(_newNum > 0, "invalid number");
        requiredConfirmNum = _newNum;
    }

    // order를 생성하고 저장. calldata를 입력받아서 struct에 저장
    function submitOrder(address _to, bytes memory _data) public onlyLevel1Above {
        isConfirmed[i][msg.sender] = true;
        orderInfos.push(
            OrderInfo({
                submitter: msg.sender,
                to: _to,
                data: _data,
                numConfirmations: 1,
                rejected: false,
                executed: false
            });
        if (accountsLevel[msg.sender] == 3) {
            executeOrder(_to, _data);
        }
        emit submition(msg.sender, _to, _data);
    }
    
    //order에 대한 찬/반 투표
    function confirmOrder(uint _orderNum
    ) public onlyLevel1Above 
             orderExists(_orderNum) 
             notExecuted(_orderNum) 
             notRejected(_orderNum) 
             notConfirmed(_orderNum) {
                 Orderinfo storage orderInfo = orderInfos[_txIndex];
                 orderInfo.numConfirmations += 1;
                 isConfirmed[_orderNum][msg.sender] = true;
                 if (accountsLevel[msg.sender] == 3) {
                     executeOrder(_to, _data);
                 }
    }

    //Level2 이상은 거부권 가능. 다른 멤버의 찬/반 여부에 상관없이 order를 reject함.
    function rejectOrder(uint _orderNum
    ) public onlyLevel2Above 
             orderExists(_orderNum) 
             notExecuted(_orderNum) 
             notRejected(_orderNum) 
             notConfirmed(_orderNum) {
                 Orderinfo storage orderInfo = orderInfos[_txIndex];
                 orderInfo.rejected = true;
    }

    // order를 실행하는 함수. 저장한 order 정보에서 주소와 calldata를 읽어서
    // 주소로 calldata를 보내는 low-level call을 함으로 원하는 주소의 
    // 원하는 함수, 원하는 매개변수를 보냄. 
    function executeOrder(uint _orderNum
    ) onlyLevel1Above 
      orderExists(_orderNum) 
      notExecuted(_orderNum) 
      notRejected(_orderNum) {
          Orderinfo storage orderInfo = orderInfos[_txIndex];
          require(orderInfo.numConfirmations >= requiredConfirmNum, "cannot execute order");
          orderInfo.executed = true;
          (bool success, ) = orderInfo.to.call{value: 0}(orderInfo.data);
          require(success, "order execution failed");
          emit orderExecuted(msg.sender, orderInfo.to, orderInfo.data);
      }
    
    // account의 level, order 정보를 보는 view 함수들
    function checkAccountLevel(address _addr) view onlyLevel1Above returns(uint) {
        uint level = accountsLevel[_addr];
        emit checkLevel (_addr, level);
        return level;
    }
    function checkOrderInfo(uint _num) view onlyLevel1Above {
        Orderinfo storage orderInfo = orderInfos[_num];
        uint level = accountsLevel[_addr];
        emit viewOrderInfo (
            orderInfo.submitter, 
            orderInfo.to, 
            orderInfo.data, 
            orderInfo.numConfirmations,
            orderInfo.rejected,
            orderInfo.executed);
    }

    // receive 함수
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
}

