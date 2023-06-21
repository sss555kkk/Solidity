# 솔리디티에서는 개인키로 signature를 생성할 수 없음. 
# message를 해쉬변환하는 것은 가능하지만 signature 생성은 솔리디티 외의 언어로 해야 됨. 
# 여기서는 python으로 개인키에서 공개키를 생성하고, message를 개인키로 암호화해서 signature를 만듬. 
# 스마트 컨트랙이 signature를 요구할 때에는 {message(ex: address, amount, etc), signature(r, s, v)}를 전달함. 

from eth_keys import keys
from secrets import token_bytes
from eth_account import Account
from web3 import Web3p

private_key_bytes = token_bytes(32)
private_key = keys.PrivateKey(private_key_bytes)
public_key = private_key.public_key

# 결과 출력
print("Private Key:", private_key.to_hex())
print("Public Key:", public_key.to_hex())



def generate_signature(message: str, private_key: str) -> dict:
    # 메시지를 해시값으로 변환
    hashed_message = Web3.keccak(text=message)

    # 개인키를 사용하여 서명 생성. 
    signed_message = Account.sign_message(hashed_message, private_key=private_key)

    # 서명 정보 반환
    signature = {
        'r': signed_message.r,
        's': signed_message.s,
        'v': signed_message.v
    }
    return signature

