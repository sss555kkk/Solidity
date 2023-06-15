//SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.18;
/*
Icontroller 인터페이스를 상속해서 television과 radio를 생성함. 
사용자 alice 컨트랙은 Icontroller에 television이나
radio의 주소를 참조로 입력해서 함수를 호출해서 원하는 컨트랙의 
함수를 호출할 수 있음. 
USDT와 같은 토큰을 사용할 때, IERC20 인터페이스에 USDT의 주소를 참조하여
여러가지 함수들(ex: transfer)을 사용하는 것도 같은 방법임. 
*/
//import "./Icontroller.sol";

contract Alice {
    
    function versionCheck(address _addr) public returns(uint) {
        return (Icontroller(_addr).versionCheck());
    }
    function getDeviceName(address _addr) public returns(string memory) {
        return (Icontroller(_addr).getDeviceName());
    }
    function getDeiveNameAndVersion(address _addr) public returns(string memory, uint) {
        return (Icontroller(_addr).getDeiveNameAndVersion());
    }
}


interface Icontroller {
    function versionCheck() external returns(uint);
    function getDeviceName() external returns(string memory);
    function getDeiveNameAndVersion() external returns(string memory, uint);
}

//import "./Icontroller.sol";

contract Television is Icontroller {
    uint public version = 1;
    string public deviceName = "television";
    
    function versionCheck() public view override returns(uint) {
        return version;
    }
    function getDeviceName() public view override returns(string memory) {
        return deviceName;
    }
    function getDeiveNameAndVersion() public view override returns(string memory, uint) {
        return (deviceName, version);
    }
}

//import "./Icontroller.sol";

contract Radio is Icontroller {
    uint public version = 2;
    string public deviceName = "radio";
    
    function versionCheck() public view override returns(uint) {
        return version;
    }
    function getDeviceName() public view override returns(string memory) {
        return deviceName;
    }
    function getDeiveNameAndVersion() public view override returns(string memory, uint) {
        return (deviceName, version);
    }
}
    