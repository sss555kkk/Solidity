// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.18;

/*
abi함수로 Calldata를 만드는 법. 
매개변수에 임의의 address와 uint를 넣고 실행하면;
result0: 해쉬값이 나옴. 
result1: result0의 처음 4bytes. 이게 function selector임.
result2, 3: 68 bytes 값이 나옴. 그리고 이 값은 함수실행시의 Calldata와 동일함.
이 68 bytes는 아래 처럼 되어 있음.
| 4bytes |      12bytes       |          26bytes           |          26bytes         |
최초 4bytes는 function selector. 3번째 26bytes는 첫번째 매개변수(입력한 address값)의 bytes 형태, 
4번째 26bytes는 두번째 매개변수의 bytes 형태.
이런 방법으로 데이터를 만들어서 delegatecall(data)로 전달할 수 있음. 

result4 ~6은 참고용.

"transfer(address,uint256)"
0xa9059cbb
"transferFrom(address,address,uint256)"
0x23b872dd
이런 식으로 함수이름과 변수를 넣어서 function selector를 미리 계산해놓으면 
가스비가 약간 절약됨. 

*/

contract TestContract1 {

    function transfer(address _addr, uint256 _num) public pure returns( 
        bytes32,
        bytes4,  
        bytes memory, 
        bytes memory,
        bytes memory,
        bytes memory
        ) {
        bytes32 result0 = keccak256(bytes("transfer(address,uint256)"));
        bytes4 result1 = bytes4(keccak256(bytes("transfer(address,uint256)")));
        bytes memory result2 = abi.encodeWithSignature("transfer(address,uint256)", _addr, _num);
        bytes memory result3 = abi.encodeWithSelector(0xa9059cbb, _addr, _num);
        bytes memory result4 = abi.encode(bytes4(keccak256("transfer(address,uint256)")), _addr, _num);
        bytes memory result5 = abi.encode("transfer(address,uint256)");
        
        return (result0, result1, result2, result3, result4, result5);
    }
}
