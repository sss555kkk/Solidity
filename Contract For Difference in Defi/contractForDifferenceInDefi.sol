

/*
CFD(Contract For Difference)는 특정한 금융상품의 현물거래(spot)와는 다르게
직접 매입매도를 하지 않고 조건에 따른 차이(difference)를 정산하는
계약(contract)을 가리킨다. 선물, 옵션, 등 현물거래가 아닌 조건에 따른 
정산은 모두 CFD의 일종이다. 

여기서는 CFD의 가장 기본적인 형태로 레버리지가 없고, 현물가격변동과 
1대1로 대응하는 CFD 거래를 탈중앙화된 스마트 컨트랙으로 구현하는 방법을 다룬다. 

*/


contract CFD_1 {
    
    int public currentIndexPrice;
    mapping(address => int) public entryIndexPriceMapping;
    mapping(address => int) public valueMapping;

    function settlement() public returns(int) {
        int difference = 0;
        currentIndexPrice = _updateIndexPrice();
        int entryIndexPrice = entryIndexPriceMapping[msg.sender];
        int value = valueMapping[msg.sender];
        difference = currentIndexPrice - entryIndexPrice;
        int currentValue = value + diffenence;
        if(currentValue =< 0) {
            emit(default, value, currentValue, "your fund already cleared!!");
            valueMapping[msg.sender] = 0;
            return currentValue;
        }
        valueMapping[msg.sender] = currentValue;
        return currentValue;
    }

    function _updateIndexPrice() internal returns(int) {
        // 현재의 indexPrice를 받아와서 업데이트하는 로직
        return updatedIndexPrice;
    }
}

/*
위의 CFD_1 컨트랙은 어떤 address가 최초에 이 거래에 진입할 때 가격을 
valueMapping에 기록하고 해당 주소가 settlement() 함수를 호출해서
정산을 신청하면 _updateIndexPrice() 함수로 currentIndexPrice를
업데이트한다. 이렇게 업데이트한 currentIndexPrice와 Value의 차이를 
currentValue로 업데이트 한다. 이때 currentValue가 0이하라면 이 거래는
청산된 것이고 돌려받을 금액도 0이 된다. 여기에는 아직 많은 부분이 생략되어 있다.
예를 들어서 여기에 거래를 시작하기 위해서 자금을 투자하기, 정산하고 자금 회수하기,
liqudity pool에 유동성을 공급하기, 유동성을 제거하고 자금 돌려받기, 등. 
이런 부분들은 하나씩 더해갈 것이다. 지금은 CFD거래의 핵심 로직을 하나씩 추가해보자. 

CFD_1은 잘 작동한다. 그런데 Long(indexPrice가 오르는 경우에 수익을 내는 거래)거래만 
가능하다. CFD는 실제로 현물을 사고 파는 것이 아니고 정산 시점에서 
차이에 대한 정산만 하기 때문에 Long/short 거래가 모두 가능하다. 
이번에는 Long/short이 모두 가능하도록 수정해서 CFD_2를 만들어 보자. 
*/

contract CFD_2 {
    
    int public currentIndexPrice;
    mapping(address => int) public entryIndexPriceMapping;
    mapping(address => int) public valueMapping;
    mapping(address => bool) public longShortMapping;

    function settlement() public returns(int) {
        int difference = 0;
        currentIndexPrice = _updateIndexPrice();
        int entryIndexPrice = entryIndexPriceMapping[msg.sender];
        int value = valueMapping[msg.sender];
        bool isLong = longShortMapping[msg.sender];
        difference = isLong 
            ? (currentIndexPrice - entryIndexPrice) 
            : (entryIndexPrice - currentIndexPrice);

        int currentValue = value + diffenence;
        if(currentValue =< 0) {
            emit(default, value, currentValue, "your fund already cleared!!");
            valueMapping[msg.sender] = 0;
            return currentValue;
        }
        valueMapping[msg.sender] = currentValue;
        return currentValue;
    }

    function _updateIndexPrice() internal returns(int) {
        // 현재의 indexPrice를 받아와서 업데이트하는 로직
        return updatedIndexPrice;
    }
}

/*
이번에는 레버리지 요소를 추가해보자. CFD_2는 IndexPrice 변화량과
difference 변화량이 1:1 비율로 정비례한다. 예를 들어서 indexPrice가 
1% 상승했다면 내 투자금액도 1%상승(short일 경우에는 하락)한다. 
이 방식에서는 IndexPrice의 변동이 너무 크거나 너무 작을 때 자신이 원하는 
수준으로 조절할 수가 없다. 예를 들어서 어떤 Index가 상승할 것이라고 예상하지만
상승폭이 매우 작아서 투자수익이 적거나, 또는 반대로 장기적으로 상승할 것이라고
예상하지만 변동폭이 너무 커서 단기적인 변동만으로도 청산이 될 것 같다고 
생각하는 경우에 원하는 변동폭이 되도록 조절할 수가 없다. 
레버리지 요수를 추가하면 이러한 변동폭 조절이 가능해진다. 
CFD_3에서는 레버리지를 추가해보자.  
*/

contract CFD_3 {
    
    int public currentIndexPrice;
    mapping(address => int) public entryIndexPriceMapping;
    mapping(address => int) public valueMapping;
    mapping(address => bool) public longShortMapping;
    mapping(address => int) public leverageMapping

    function settlement() public returns(int) {
        int difference = 0;
        currentIndexPrice = _updateIndexPrice();
        int entryIndexPrice = entryIndexPriceMapping[msg.sender];
        int value = valueMapping[msg.sender];
        bool isLong = longShortMapping[msg.sender];
        int leverage = leverageMapping[msg.sender];
        difference = isLong 
            ? (leverage*(currentIndexPrice - entryIndexPrice)) 
            : (leverage*(entryIndexPrice - currentIndexPrice));

        int currentValue = value + diffenence;
        if(currentValue =< 0) {
            emit(default, value, currentValue, "your fund already cleared!!");
            valueMapping[msg.sender] = 0;
            return currentValue;
        }
        valueMapping[msg.sender] = currentValue;
        return currentValue;
    }

    function _updateIndexPrice() internal returns(int) {
        // 현재의 indexPrice를 받아와서 업데이트하는 로직
        return updatedIndexPrice;
    }
}

/*
CFD_3에서는 state variable의 mapping(address => )로 거래자의 포지션
정보를 저장하고 사용했다. 그런데 이렇게 하면 모든 거래자는 이 풀에서 
1개의 거래만 가능하고 1개의 거래가 완전히 종료되기 전에는 다른 거래를 
할 수가 없다. 하나의 address에서 복수의 포지션을 거래할 수 있으려면 
어떻게 해야 할까?

단순하게 데이터저장하는 mapping을 mapping(포지션번호 => ) 라는 식으로 
바꾸어서는 안 된다. 왜냐하면 어떤 address가 2개의 포지션을 가지고 있는데
청산을 위해서 settlement() 함수를 호출하면 스마트 컨트랙은 이 address가 
가지고 있는 2개의 포지션 중에서 어떤 것을 청산할지를 알 수가 없다. 

디파이에서 자주 사용하는 방법으로 ERC-20 토큰을 일종의 recipt 으로 
사용해서 거래에 진입하면 토큰을 주고 이 토큰을 반환하면 해당 토큰에 
대한 거래를 종료(여기서는 청산)하는 방식으로도 안 된다. 이런 방식은 
모든 포지션의 정보(entryPrice, long/short, leverage)가 동일한 
경우에만 적용가능하다. 다시 말해서 CFD 거래처럼 모든 포지션이 각각
다른 정보를 가지고 있으며, 하나의 address가 복수의 포지션을 가질 수 있어야 한다면
이런 경우에는 토큰이되 각각의 토큰이 별도로 구별되고 다른 정보를 가지고 있는 토큰을
receipt로 사용해야 한다. 바로 erc-721, NFT이다. 

CFD_4에서는 NFT를 도입해서 포지션 정보를 정리해보자. 
*/

contract CFD_4 {
    
    address public baseToken = 0xaaaaaaaaaa....aaa;
    uint public nftNumberCounter = 1;
    

    int public currentIndexPrice;
    mapping(uint nftNum => address owner) public nftOwnerMapping;
    mapping(uint nftNum => bool isExist) public nftMapping;
    mapping(uint nftNum => int entryIndex) public entryIndexPriceMapping;
    mapping(uint nftNum => int value) public valueMapping;
    mapping(uint nftNum => bool isLong) public longShortMapping;
    mapping(uint nftNum => int leverage) public leverageMapping

    function settlement(uint _nftNum) public returns(string memory) {
        require(nftMapping[_nftNum] == true, "this nft does not exist!!");
        require(nftOwnerMapping[_nftNum] == msg.sender, "invalid owner!!");
        int difference = 0;
        currentIndexPrice = _updateIndexPrice();
        uint nftNum = _nftNum;
        int entryIndexPrice = entryIndexPriceMapping[nftNum];
        int value = valueMapping[nftNum];
        bool isLong = longShortMapping[nftNum];
        int leverage = leverageMapping[nftNum];
        difference = isLong 
            ? (leverage*(currentIndexPrice - entryIndexPrice)) 
            : (leverage*(entryIndexPrice - currentIndexPrice));

        int currentValue = value + diffenence;
        if(currentValue =< 0) {
            emit(default, value, currentValue, "your fund already cleared!!");
            nftMapping[nftNum] = false;
            return ("your fund already cleared!!");
        }
        nftMapping[nftNum] = false;
        _burn(nftNum);
        baseToken.transferFrom(this, msg.sender, currentValue)
        return ("settlement cleared!!");
    }

    function _updateIndexPrice() internal returns(int) {
        // 현재의 indexPrice를 받아와서 업데이트하는 로직
        return updatedIndexPrice;
    }

    function _burn(uint _nftNum) internal {
        // 해당 nft 소각하는 로직. 확인은 필요없음. 이미
        // 이전 단계에서 이 nftNum 소유자가 msg.sender인지 확인했음.
    }
}

/*
CFD_4는 모든 포지션을 nft로 관리한다. 이제 더 이상 address를 기반으로
포지션을 관리하지 않기 때문에 이 nft가 하나의 address에 종속될 필요도 없다.
nft 자체를 다른 address로 보내고 새로운 address가 청산을 요청하고 청산금액을 
받을 수도 있다. 

사용자는 하나의 CFD 거래 포지션에 진입하고 나면 baseToken으로 자금을 투자한다.
그 receipt로 nft를 받는다. 거래를 끝내고 청산을 하고 싶다면 
settlement() 함수를 호출해서 보유하고 있는 nft 중에서 청산을 원하는
nftNum를 입력한다. 
msg.sender가 이 nftNum의 소유자가 맞다면 청산가치를 계산해서
청산금액을 msg.sender에게 transfer하고 이 nft를 burn 한다. 

여기까지 하고 나면 CFD거래를 하기 위한 핵심 로직이
거의 완성됐다. 다만 중앙화된 방식과는 다르게 탈중앙화된 방식에서는
청산가치를 자주 계산하기 위한 로직이 필요하다. 

CFD 거래에서는 투자자금으로 실제 현물을 사거나 팔지 않고
종료시점에서 정해진 조건에 따라서 차익을 정산한다. 종료시점 이전이라도
투자자금이 모두 소진된다면 이 포지션은 강제로 청산되어야 한다. 
이를 위해서 중앙화된 CFD 는 실시간으로 indexPrice를 업데이트해서 
현재가치가 0인 포지션을 강제로 청산시키고 해당 포지션을 삭제한다. 
그런데 탈중앙화된 스마트컨트랙에서는 실시간으로 이런 청산가치계산을 
하는 것은 너무 비용이 많이 든다. 그래서 CFD_4 컨트랙은 포지션 보유자가
직접 청산요청을 하는 경우에는 청산가치계산을 하도록 했다. 
이렇게 하면 포지션 보유자는 중간시점에서 가치가 0이하로 내려가도 
청산가치계산을 하지 않는한 포지션은 여전히 살아 있다. 이는 공정하지 못한
계산방법이기 때문에 어떤 포지션의 가치가 0 이하가 되면 그것을 감지해서
강제로 청산하고 해당 포지션을 삭제하는 방법이 있어야 한다. 
가장 먼저 떠오르는 방법은 이 프로토콜의 작성자가 직접 모든 포지션의 
청산가격을 알고 감시하다가 indexPrice가 청산가격까지 도달하면 강제청산을 
시도하는 것이다. 
그러나 이 방법은 모니터링, 강제청산이라는 작업이 프로토콜 작성자에
의해서 독점된다는 점에서 좋은 방법이 아니다. 
더 좋은 방법은 모니터링, 강제청산 작업을 모든 사용자가 할 수 있도록 하고
인센티브를 제공하되, 그 필요한 비용(가스비용)도 사용자가 부담하도록 하는 것이다. 

이 기능을 청산가치계산 함수라고 하자. 
이 함수는 이 pool과 모든 nft 포지션의 가치를 현재indexPrice로 계산하고, 
포지션 중에서 가치가 0 이하인 포지션을 강제청산시킨다. 그리고 강제청산된 
포지션 가치의 일정 퍼센트 (예를 들어 1%)를 msg.sender에게 보상으로 지급한다. 
그 대신 이 함수를 호출하는데 필요한 가스비용은 msg.sender 부담해야 한다. 
이렇게 하면 모니터 요원은 공개된 정보를 보고 강제청산보상이 자신이 소모해야 하는
가스비용보다 큰 경우에는 청산가치계산 함수를 호출해서 보상을 받을 것이다. 
청산가치계산 함수는 nft 보유여부와 상관없이 누구나 호출가능하다. 
이 기능을 통해서 포지션의 가치가 0이 될 때에 강제청산이 
이루어지도록 유인한다.

지금까지 만들어본 CFD, long/short, leverage, nft 포지션 관리에
청산가치계산 함수까지 작성하고, 지금까지는 생략했었던
mint, burn, addLiquidity, removeLiquidity 함수도 추가해보자. 
그리고 이제는 하나의 스마트 컨트랙으로 모든 것을 처리하지 말고
depolyer, tradingManager, nftPositonManager, tradingContract 으로
스마트 컨트랙을 나누어서 각각 필요한 기능을 분리하도록 작성해보자. 
이 과정에서 모두 mapping으로만 작성했었던 state variable들도
structs, 배열로 적절하게 수정할 것이다. 
그래서 최종적으로 Index Leverage Protocol을 완성할 것이다.
https://github.com/sss555kkk/Solidity/tree/main/IndexLeverageProtocol
에서 완성된 프로토콜을 볼 수 있다. 
*/

