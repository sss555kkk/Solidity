// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/*
친구들을 (이름, 주소, 머리색깔, 나이)로 저장해놨다. 
각각의 멤버로 해당하는 친구를 검색하는 방법. 
조건을 만족하는 친구가 2명 이상일 수도 있다. 
*/
contract FriendSearch {
    struct Friend {
        string name;
        string location;
        string color;
        uint age;
    }
    
    mapping(uint => Friend) public friends;
    uint public friendCount;
    
    constructor() {
        addFriend("Alice", "London", "Black", 30);
        addFriend("Bob", "London", "Red", 25);
        addFriend("Charlie", "New York", "Red", 30);
    }
    
    function addFriend(string memory _name, string memory _location, string memory _color, uint _age) private {
        friends[friendCount] = Friend(_name, _location, _color, _age);
        friendCount++;
    }
    
    function searchByLocation(string memory _location) public view returns (string memory) {
        string memory result;
        
        for (uint i = 0; i < friendCount; i++) {
            if (keccak256(bytes(friends[i].location)) == keccak256(bytes(_location))) {
                result = string(abi.encodePacked(result, friends[i].name, ", "));
            }
        }
        
        return result;
    }
    
    function searchByAge(uint _age) public view returns (string memory) {
        string memory result;
        
        for (uint i = 0; i < friendCount; i++) {
            if (friends[i].age == _age) {
                result = string(abi.encodePacked(result, friends[i].name, ", "));
            }
        }
        
        return result;
    }
}