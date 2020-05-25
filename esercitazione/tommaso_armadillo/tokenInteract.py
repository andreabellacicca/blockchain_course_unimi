# To execute run 
# watch tokenInteract.py -n 120

from brownie import web3, network, Contract, Wei
from brownie.network.account import PublicKeyAccount, LocalAccount
import json
import random
from terminaltables import AsciiTable
from datetime import datetime

# Defining function to interact with blockchain
def get_logs(address, from_block, to_block, signature, topic1=None, topic2=None, topic3=None):
    return web3.eth.getLogs({
        "address": address,
        "fromBlock": from_block,
        "toBlock": to_block,
        "topics": [signature, topic1, topic2, topic3]
    })

# Connection to ropsten
network_selected = 'ropsten'
try:
    network.connect(network_selected)
except:
    network.connect(network_selected, launch_rpc=False)

# Load account
pk = "0xe551c4a450fc389324c068fe5520571c3816318a80ccac739206772657be706e"
try:
    accountTmp = web3.eth.account.from_key(pk)
    account = LocalAccount(accountTmp.address, accountTmp, accountTmp.privateKey)
except:
    print("Something went wrong while loading account")

# Load contract to interact with token
name_SC = "PayTkn"
address_SC = "0x44882aCAE4B950a6E1Dc9739B927c4195Cdba16a"

with open(f"./../abi/{name_SC}.json") as f:
    abi_SC = json.load(f)

try:
    interact = Contract.from_abi(name = name_SC, address = address_SC, abi = abi_SC, owner = account)
except:
    print("Something went wrong while loading the contract")

# Change price
newPrice = int(random.normalvariate(1e18, 2e17))
newPriceETH = web3.fromWei(newPrice, "ether")
try:
    #interact.setPrice(newPrice)

    print(f"Price has correctly been set to {newPriceETH} ether/token\n\n")
except:
    print("Something went wrong while changing the price")

# See last 10 transactions
buyTkn_event = web3.keccak(text="buyTknEvent(address,uint256)").hex()
LOGS = get_logs(address=address_SC, from_block=7956358, to_block="latest", signature=buyTkn_event, topic1=None, topic2=None, topic3=None)

i=0
data = [['#', 'From', 'Timestamp', 'Token Amount', 'Cost ETH']]
for event in LOGS:
    block = web3.eth.getBlock(event['blockNumber'])
    transaction = web3.eth.getTransaction(event['transactionHash'].hex())
    i+=1
    dt_object = datetime.fromtimestamp(block['timestamp'])
    data.append([i, transaction['from'], dt_object, web3.fromWei(int(event['data'], 0), "ether"), web3.fromWei(transaction['value'], "ether")])
    
data_table = AsciiTable(data)
print(data_table.table)