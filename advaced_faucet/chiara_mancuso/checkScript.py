from brownie import *
from brownie.network.account import PublicKeyAccount
from brownie.network.account import LocalAccount
from terminaltables import AsciiTable
from brownie.project import build
import json
import yaml

network_selected = "ropsten"

network.connect(network_selected)

private_key = "126093AAE1B57F85936FF2E7A3BA69A1C247435B16AAC3F67B893639717395E7"

address_list = [
    {'name':'Prof', 'address': '0xf664376E7B8275852c7172781d571dd77720b36D'},
    {'name': 'Tommaso Armadillo', 'address': '0x14717ce5451f03aD40535dcbCa1E75FA1c471B96'},
    {'name': 'Francesco Marcolli', 'address': '0x96E7Cf89FF096598542777531FA315Fc27102E37'},
    {'name': 'Alessandro Tammaro', 'address': '0x65Ad3E613b51D2f734BB6224C6fb30eB59511996'},
    {'name': 'Simone Pirota', 'address': '0x743491ab1511287491af8De4Ca25b2fbc707eB88'},
    {'name': 'Sofia Cella', 'address': '0xc6E53222274D5Ffd0Cf3d8933a556f46d3D2e420'},
    {'name': 'Andrea Rossoni', 'address': '0xA0b0c2A3B7AD77F9cAea004b4985419a19630a90'},
    {'name': 'Marco Beretta', 'address': '0xfb74C9012A57B0E1dB837b624080b3CbCd3Bb248'}]

with open('./brownie-config.yaml') as yaml_file:
    bc_yaml = yaml.load(yaml_file, Loader=yaml.FullLoader)

#config['network']['networks']['ropsten'] = bc_yaml['network']['networks']['ropsten']
'''
config['networks']['default'] = bc_yaml['networks']['ropsten']
'''

data = [['Owner', 'Address', 'Balance']]

account_mio = web3.eth.account.from_key(private_key)
local_account = LocalAccount(account_mio.address, account_mio, account_mio.privateKey)

print("Balance local account: {}".format(local_account.balance()))

for address in address_list:
    account = PublicKeyAccount(address['address'])
    data.append([address['name'], account.address, account.balance()])

data_table = AsciiTable(data)
print(data_table.table)

#bAccount_prj = project.load('./', name='FaucetAdvDef')

#print(local_account.address)

#fc = local_account.deploy(bAccount_prj.FaucetAdvDef)

#local_account.transfer(fc.address, Wei('1 ether'))
f = open("blockchain_course_unimi/advaced_faucet/chiara_mancuso/FaucetAdvance.sol","r")
abi = json.load(f)
'''
abi = [
    {
        'anonymous': False,
        'inputs': [
            {
                'indexed': True,
                'internalType': "address",
                'name': "owner",
                'type': "address"
            },
            {
                'indexed': True,
                'internalType': "address",
                'name': "recipient",
                'type': "address"
            },
            {
                'indexed': False,
                'internalType': "uint256",
                'name': "amount",
                'type': "uint256"
            }
        ],
        'name': "Refilled",
        'type': "event"
    },
    {
        'anonymous': False,
        'inputs': [
            {
                'indexed': True,
                'internalType': "address",
                'name': "recipient",
                'type': "address"
            },
            {
                'indexed': False,
                'internalType': "uint256",
                'name': "amount",
                'type': "uint256"
            }
        ],
        'name': "Withdraw",
        'type': "event"
    },
    {
        'constant': True,
        'inputs': [
            {
                'internalType': "address",
                'name': "account",
                'type': "address"
            }
        ],
        'name': "balanceOf",
        'outputs': [
            {
                'internalType': "uint256",
                'name': "",
                'type': "uint256"
            }
        ],
        'payable': False,
        'stateMutability': "view",
        'type': "function"
    },
    {
        'constant': False,
        'inputs': [
            {
                'internalType': "address payable",
                'name': "account",
                'type': "address"
            }
        ],
        'name': "refill",
        'outputs': [],
        'payable': True,
        'stateMutability': "payable",
        'type': "function"
    },
    {
        'constant': False,
        'inputs': [
            {
                'internalType': "uint256",
                'name': "withdraw_amount",
                'type': "uint256"
            }
        ],
        'name': "withdraw",
        'outputs': [],
        'payable': False,
        'stateMutability': "nonpayable",
        'type': "function"
    }
]
'''
#{'from': local_account}

bAccount = Contract.from_abi("FaucetAdvDef", "0x7e4f3586435430e680299A9C48A0A120e19120e9", abi, owner=local_account)

for address in address_list:
    print('Sent to: {}'.format(address['name']))
    transaction = bAccount.refill(address['address'])
    print(transaction.txid)

data_table = AsciiTable(data)
print(data_table.table)

contract_list = [
    {'name': 'Tommaso Armadillo', 'address': '0xCe58D18Dbac35F72BCd0b4C9d9132b7b25C888F7', 'abi': 'blockchain_course_unimi/advaced_faucet/tommaso_armadillo/FaucetAdvancedAbi.json'},
    {'name': 'Francesco Marcolli', 'address': '0xc018Ae21395C25F80968329b73906265b28D387C', 'abi': 'blockchain_course_unimi/advaced_faucet/faucetadvance.json'},
    {'name': 'Alessandro Tammaro', 'address': '0xCd6F583212f6eF3197965A87BFf6ca7d22fb4B63', 'abi': 'blockchain_course_unimi/advaced_faucet/alessandro_tammaro/FaucetAdvanced.json'},
    {'name': 'Simone Pirota', 'address': '0xfb8CAAD8fffB13c3584480952E3dAeBcBca20172', 'abi': 'blockchain_course_unimi/advaced_faucet/simone_pirota/BankAccount.json'},
    {'name': 'Sofia Cella', 'address': '0xaeBe787d23bb02E66893A02b7C6b2Af6d8218955', 'abi': 'blockchain_course_unimi/advaced_faucet/sofia_cella/FaucetAdvanced.json'},
    {'name': 'Andrea Rossoni', 'address': '0xeae8B4579c6a959996C78d6779668467456EE53e', 'abi': 'blockchain_course_unimi/advaced_faucet/andrea_rossoni/AdvFaucet.abi.json'},
    {'name': 'Marco Beretta', 'address': '0x7723dEf957e37d71329B60D971356A0958Ab8D67', 'abi': 'blockchain_course_unimi/advaced_faucet/marco_beretta/FaucetABI.json'}]

for contract in contract_list:
    print('Withdraw from {}'.format(contract['name']))
    abi_read = open(contract['abi'],"r").read()
    conto = Contract.from_abi(contract['address'], abi_read)
    conto.withdraw(Wei('0.0001 ether'))
    print("Balance local account: {}".format(local_account.balance()))
