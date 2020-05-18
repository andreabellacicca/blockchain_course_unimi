from brownie import web3, network, Wei, Contract, project
from brownie.network.account import LocalAccount
import json

network_selected = "ropsten"
private_key = "92f9d3a515c3ed36ef1fae28a26e503cae7fdca69bac1fb8976f06b1eae44860"

address_list = [
    #{'name': "Andrea Bellacicca", 'address': "0xf664376E7B8275852c7172781d571dd77720b36D"},
    {'name': "Tommaso Armadillo", 'address': "0x14717ce5451f03aD40535dcbCa1E75FA1c471B96"},
    {'name': "Francesco Marcolli", 'address': "0x96E7Cf89FF09659854277531FA315AFc27102E37"},
    {'name': "Alessandro Tammaro", 'address': "0x65Ad3E613b51D2f734BB6224C6fb30eB59511996"},
    {'name': "Chiara Mancuso", 'address': "0x8B64A443580c65a891355D67B8B1C139ec915CF6"},
    #{'name': "Simone Pirota", 'address': "0x743491ab1511287491af8De4Ca25b2fbc707eB88"},
    {'name': "Sofia Cella", 'address': "0xc6E53222274D5Ffd0Cf3d8933a556f46d3D2e420"},
    {'name': "Andrea Rossoni", 'address': "0xA0b0c2A3B7AD77F9cAea004b4985419a19630a90"},
    {'name': 'Marco Beretta', 'address': '0xfb74C9012A57B0E1dB837b624080b3CbCd3Bb248'}
]

sc_list_withdraw_available = [
    {'name': "Francesco Marcolli", 'address': "0xc018Ae21395C25F80968329b73906265b28D387C",
     'abi': "../blockchain_course_unimi/advaced_faucet/francesco_marcolli/faucetadvance.json"},
    {'name': "Alessandro Tammaro", 'address': "0xCd6F583212f6eF3197965A87BFf6ca7d22fb4B63",
     'abi': "../blockchain_course_unimi/advaced_faucet/alessandro_tammaro/FaucetAdvanced.json"},
    #{'name': "Simone Pirota", 'address': "0xfb8CAAD8fffB13c3584480952E3dAeBcBca20172", 'abi': "../blockchain_course_unimi/advaced_faucet/simone_pirota/BankAccount.json"},
    {'name': "Andrea Rossoni", 'address': "0xeae8B4579c6a959996C78d6779668467456EE53e",
     'abi': "../blockchain_course_unimi/advaced_faucet/andrea_rossoni/AdvFaucet.abi.json"},

]

sc_list_withdraw_balanceOf = [
    {'name': "Tommaso Armadillo", 'address': "0xCe58D18Dbac35F72BCd0b4C9d9132b7b25C888F7",
        'abi': "../blockchain_course_unimi/advaced_faucet/tommaso_armadillo/FaucetAdvancedAbi.json"},
    {'name': "Chiara Mancuso", 'address': "0xc873ca8dBBa832BA7f3eF9fbD238A7c7c09db6a7",
        'abi': "../blockchain_course_unimi/advaced_faucet/chiara_mancuso/FaucetAdvance.json"},
#    {'name': "Sofia Cella", 'address': "0x934288cf57446bD7638673c6812579AD71bf8deF",
#        'abi':"../blockchain_course_unimi/advaced_faucet/sofia_cella/FaucetAdvanced.json"},
    {'name': 'Marco Beretta', 'address': "0x7723dEf957e37d71329B60D971356A0958Ab8D67",
        'abi':"../blockchain_course_unimi/advaced_faucet/marco_beretta/FaucetABI.json"}
]

try:
    network.connect(network_selected)
except:
    network.connect(network_selected, launch_rpc=False)

account = web3.eth.account.from_key(private_key=private_key)
local_account = LocalAccount(account.address, account, account.privateKey)

with open("../blockchain_course_unimi/advaced_faucet/simone_pirota/BankAccount.json") as json_file:
    abi_json = json.load(json_file)

my_sc = Contract.from_abi('MySmartContract',address="0xfb8CAAD8fffB13c3584480952E3dAeBcBca20172",abi=abi_json,
                          owner=local_account)

for address in address_list:
    if my_sc.available(address['address']) < Wei("0.04 ether"):
        print("I'm refilling", address['name'],"'s balance")
        my_sc.refill(address['address'], {'value': Wei("0.02 ether")})
    else:
        print(address['name'],"'s balance is already filled enough")

for smart_contract in sc_list_withdraw_available:
    with open(smart_contract['abi']) as json_file:
        abi_json = json.load(json_file)
    sc = Contract.from_abi('SmartContract', address=smart_contract['address'], abi=abi_json)

    all_balance = sc.available(local_account.address)
    print("How much I can withdraw from my balance on",smart_contract['name'],"'s smart contract:",
          web3.fromWei(all_balance, "ether"))
    if all_balance != 0:
        wd_amount = float(input("How much would you like to withdraw? (Use format 0.etc) "))
        wd_amount = int(wd_amount*(10**18))
        if wd_amount <= all_balance:
            sc.withdraw(wd_amount, {'from': local_account})
        else:
            print("You can't withdraw more that you own.")

for smart_contract in sc_list_withdraw_balanceOf:
    with open(smart_contract['abi']) as json_file:
        abi_json = json.load(json_file)
    sc = Contract.from_abi('SmartContract', address=smart_contract['address'], abi=abi_json)

    all_balance = sc.balanceOf(local_account.address)
    print("How much I can withdraw from my balance on",smart_contract['name'],"'s smart contract:",
          web3.fromWei(all_balance, "ether"))
    if all_balance != 0:
        wd_amount = float(input("How much would you like to withdraw? (Use format 0.etc) "))
        wd_amount = int(wd_amount * (10 ** 18))
        if wd_amount <= all_balance:
            sc.withdraw(wd_amount, {'from': local_account})
        else:
            print("You can't withdraw more that you own.")
