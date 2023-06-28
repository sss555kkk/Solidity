Index Leverage Protocol

이 프로토콜은 누구나 자유롭게 trading의 대상이 되는 Index를 설정하고 
상대방이 거기에 leverageTrading을 하는 Contract을 만들 수 있다. 
유동성 공급자는 자신이 원하는 인덱스를 설정한 뒤 USDT로 유동성을 공급.
유동성 공급자는 최초에 tradingContract을 생성할 때, 인덱스와 수수료 비율을 설정함. 
수수료는 trader에게서 유동성공급자에게 이전됨. 프로토콜은 받지 않음. 
따라서 유동성 공급자들은 이 인덱스가 무작위로 움직이기 때문에 인덱스의 변화에서는 
수익이 발생하지 않고 수수료로 수익을 낸다는 것에 베팅하고 있음. 
trader들은 Long/short과 leverage(min: 1, max: 100)을 설정해서 USDT로 진입. 
인덱스, 현재Value, long/short, leverage에 따라서 청산되거나 현재가치가 업데이트됨.
수수료는 진입과 나가기 시에 설정된 수수료 비율만큼 유동성 공급자에게 이전. 
trader들은 수수료를 제외하고도 인덱스의 방향성을 예측해서 수익을 낼 수 있다는 것에 베팅하고 있음. 
Pool(유동성 공급자들의 자금의 모음)과 trader position 모두 청산될 수 있음. 
유동성을 추가,제거, trading에 진입, 나가기 를 할때에 전체정산을 함. 
전체 정산은 탈중앙화오라클 제공업체에서 제공하는 오라클에서 해당 Index의 현재값을 받아서 계산함. 
하나의 TradingContract을 생성하기 위해서는 해당하는 Oracle을 설정하고 연결해야 하는데,
그 부분은 아직 할 줄 몰라서 생략했음. 

이 프로토콜에서 누구나 전체 포지션과 풀에 대한 정산신청을 할 수 있고, 결과로 청산된 position이나 pool이 있으면
청산된 가치의 0.2%를 받음. 이 과정은 2가지 의미가 있음. 
(1) 스마트 컨트랙이 인덱스변화를 보면서 스스로 업데이트(정산 등)를 하는 것은 불가능함. 
업데이트 신청(=정산신청)에 대한 인센티브를 제공해서 청산대상이 바로 바로 청산이 되도록 했음. 
(2) 정산신청에는 누구나 참여가능. 약간의 이해만 있으면 누구나 수익을 낼 수 있음. 
누구라도 디파이에 참여하고 수익을 낼 수 있는 메커니즘을 포함시켰음. 

이 프로토콜은 전체 4개의 contract으로 나누어짐. 
Deployer는 새로운 trading 생성신청이 들어왔을 때,
TradindManager, TradingContract, nftManager 컨트랙을 생성함. 
TradingManager는 유동성공급/제거, trading 진입/나가기, 계산, 정산, 청산을 모두 관리하고 
TradingContract과 NftManager에 지시를 전달함. 
TradingContract은 자금을 관리하고 유동성공급자들에게 pooltoken을 발행함.  
nftManager는 trader에게 position에 대한 nft를 발행함. 
