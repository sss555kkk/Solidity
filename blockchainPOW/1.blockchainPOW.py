

"""
<파이썬으로 공부하는 블록체인>을 참고해서 블록체인을 만들어보겠음. 
아주 간단한 모델부터 시작해서 기능을 하나씩 추가하면서 만들어보겠음. 
최종적으로 이런 식으로 해서 합의 알고리즘을 POW, POS로 수정해보고
합의 알고리즘의 변경은 코드로 어떻게 구현하는지, 
그렇게 구현을 하면 어떤 효과가 나는지를 확인해보겠음. 

먼저 가장 간단한 형태로 Blockchain1이라는 이름의 클래스로 만들어 보겠음. 
생성자가 genesis_block 함수를 호출해서 최초블록을 생성하지만
아직 POW, hash 변환은 없기 때문에 hash 값이 필요한 부분은 
None 을 넣도록 했음. 
"""

from time import time

class Blockchain1(object):
    
    def __init__(self):
        self.chain = []
        self.current_transaction = []
        self.genesis_block()
    
    def last_block(self):
        return self.chain[-1]

    def new_transaction(self, sender, recipient, amount):
        self.current_transaction.append(
            {
                'sender' : sender,
                'recipient' : recipient,
                'amount' : amount,
                'timestamp' : time(),
            }
         )
        
    def new_block(self, proof):
        block = {
            'index' : len(self.chain)+1,
            'timestamp' : time(),
            'transactions' : self.current_transaction,
            'previous_hash' : hash(self.chain[-1]),
            'nonce' : proof,
        }
        self.current_transaction = []
        self.chain.append(block)
        return block
    
    def genesis_block(self):
        block = {
            'index' : 0,
            'timestamp' : time(),
            'transactions' : self.current_transaction,
            'previous_hash' : None,
            'nonce' : 0,
        }
        self.current_transaction = []
        self.chain.append(block)
        return block
    
# 아래는 윈도우 터미널에서 확인하기 위한 추가코드
blockchain = Blockchain1()
print(blockchain.last_block())    

"""
Blockchain1 클래스로 만든 blockchain은 잘 작동함. 
Blockchain2는 pow, valid_proof 메소드를 추가해서 
new_block() 함수를 호출하면 이전 블록의 nonce값ㅇ을 불러와서
pow() 함수를 통해서 새 블록의 nonce를 계산함. 
"""

from time import time
import hashlib
import json
import random

class Blockchain2(object):
    
    def __init__(self):
        self.chain = []
        self.current_transaction = []
        self.genesis_block()
    
    @staticmethod
    def hash(block):
        block_string = json.dumps(block, sort_keys=True).encode()
        return hashlib.sha256(block_string).hexdigest()
    
    @staticmethod
    def valid_proof(last_proof, proof):
        guess = str(last_proof + proof).encode()
        guess_hash = hashlib.sha256(guess).hexdigest()
        return guess_hash[:4] == "0000"
    
    def pow(self, last_proof):
        proof = random.randint(-1000000, 1000000)
        while self.valid_proof(last_proof, proof) is False:
            proof = random.randint(-1000000, 1000000)
        return proof

    def last_block(self):
        return self.chain[-1]

    def new_transaction(self, sender, recipient, amount):
        self.current_transaction.append(
            {
                'sender' : sender,
                'recipient' : recipient,
                'amount' : amount,
                'timestamp' : time(),
            }
         )
        
    def new_block(self, proof):
        block = {
            'index' : len(self.chain)+1,
            'timestamp' : time(),
            'transactions' : self.current_transaction,
            'previous_hash' : self.hash(self.chain[-1]),
            'nonce' : proof,
        }
        self.current_transaction = []
        self.chain.append(block)
        return block
    
    def genesis_block(self):
        block = {
            'index' : 0,
            'timestamp' : time(),
            'transactions' : self.current_transaction,
            'previous_hash' : None,
            'nonce' : 100,
        }
        self.current_transaction = []
        self.chain.append(block)
        return block


"""
Blockchain2 클래스로 만든 블록체인도 잘 작동한다. 
이제 이 블록체인을 실행하는 노드를 만들어보겠다. 
flask를 이용해서 ip와 port를 설정하고 
url API를 이용해서 
블록정보 보기, 새로운 트랜잭션 값 입력하기,
새로운 블록 만들기 명령을 받을 것이다. 
그러고 나면 이 Blockchain3 클래스로 만든 전체 코드는 
블록체인 객체를 정의하고 노드를 설정하고 
사용자가 url API로 명령을 주면 그 명령에 따라서 실행하게 될 것이다. 
"""
# 여기서 부터 노드설정 부분
blockchain = Blockchain2()
my_ip = '0.0.0.0'
my_port = '5000'
node_identifier = 'node_'+ my_port
mine_owner = 'master'
mine_profit = 0.1


app = Flask(__name__)

@app.route('/')
def index():
    return 'Hello. This is my blockchain server!!'

@app.route('/chain', methods = ['GET'])
def full_chain():
    print("chain info requested!!")
    response = {
        'chain' : blockchain.chain,
        'length' : len(blockchain.chain),
    }
    return jsonify(response), 200

@app.route('/transaction/new', methods = ['POST'])
def new_transaction():
    values = request.get_json()
    print("transactions_new!!! : ", values)
    required = ['sender', 'recipient', 'amount']

    if not all(k in values for k in required):
        return 'missing value', 400
    
    index = blockchain.new_transaction(
        values['sender'], values['recipient'], values['amount']
        )
    response = {
        'message' : 'Transaction will be added to Block {%s} % index'
        }
    return jsonify(response), 201

@app.route('/mine', methods = ['GET'])
def mine():
    print("MINING STARTED")
    last_block = blockchain.last_block
    last_proof = last_block['nonce']
    proof = blockchain.pow(last_proof)

    blockchain.new_transaction(
        sender = mine_owner,
        recipient = node_identifier,
        amount = mine_profit
    )

    previous_hash = blockchain.hash(last_block)
    block = blockchain.new_block(proof, previous_hash)
    print("MINING FINISHED")

    response = {
        'message' : 'new block found',
        'index' : block['index'],
        'transactions' : block['transactions'],
        'nonce' : block['nonce'],
        'previous_hash' : block['previous_hash']
    }
    return jsonify(response), 200

if __name__ == '__main__':
    app.run(host = my_ip, port = my_port)


# 윈도우 터미널에서 확인하기 위한 추가코드

print(blockchain.last_block())
print(blockchain.new_block(1))
print(blockchain.hash(blockchain.last_block()))
print(blockchain.pow(1))

"""
블록체인의 객체를 Blockchain2 클래스로 정의하고 
노드설정과 url api로 들어오는 명령에 따라서 
Blockchain2의 인스턴스에 메소드로 블록체인 정보를 보거나
new transaction을 추가하거나 new block을 만드는 것을 만들었다. 

사용자는 명령어를 url api로 보낼 수 있다. 트랜잭션을 만들고
블록을 만들고, 마지막으로 블록체인 정보를 보는 요청의 모음을 
json으로 데이터를 전달하는 식으로 만들 수 있다. 
그리고 현재의 Blockchain2 클래스내의 메소드들에 요청이 왔을 경우에 
return이나 print()로 요청이 잘 들어왔고 response를 보냈음을 알려주도록 
다음 파트에서 한번에 정리해서 수정하겠다. 
"""

#transaction 3 입력하기
headers = {'Content-Type' : 'application/json; charset=utf-8'}
data = {
    "sender" : "test_from",
    "recipient" : "test_to3",
    "amount" : 300,
}
requests.post(
    "http://localhost:5000/transaction/new", headers=headers, data=json.dumps(data)
    ).content

# 채굴하기
headers = {'Content-Type' : 'application/json; charset=utf-8'}
res = requests.get("http://localhost:5000/mine")
print(res)

# 노드의 블록 정보 확인
headers = {'Content-Type' : 'application/json; charset=utf-8'}
res = requests.get("http://localhost:5000/chain", headers=headers)


