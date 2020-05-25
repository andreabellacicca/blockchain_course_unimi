# Stabilisco un prezzo iniziale di 0.001 ether, aumento il prezzo di 0.001 ether ogni due minuti fino a raggiungere gli 0.01 ether.

from brownie import *
from brownie.network.account import LocalAccount
import time

network_selected = 'ropsten'
eth = 1000000000000000000.0

file_pk = open("private_key", "r")
private_key = file_pk.read().splitlines()
file_pk.close()

try:
	network.connect(network_selected)
except:
	network.connect(network_selected, launch_rpc=False)
	
account = web3.eth.account.from_key(private_key=private_key[0])
local_account = LocalAccount(account.address, account, account.privateKey)

contract_address = '0x86Bc231d9adB9FcB6267cBB5fF204243BC97d880'
market = Contract(contract_address, owner = local_account)

market.setTknPrice(10**15)

time1 = time.time()
t1 = time.localtime(time1)
print("{} {} {} {} {}".format("Initial situation: ", time.asctime(t1), ", price: ", market.getFee(10**18)/eth, "ether"))
while market.getFee(10**18) < 10**16:
	time2 = time.time()
	if (time2-time1 >= 120):
		market.setTknPrice(market.getFee(10**18) + 10**15)
		t2 = time.localtime(time2)
		print("{} {} {} {}".format(time.asctime(t2), " price: ", market.getFee(10**18)/eth, "ether"))
		time1 = time2
		
		
		
