import brownie
from brownie import Contract, accounts, interface

# test_acc = accounts.load("testacc")
test_acc = accounts[0]

LINK_ADDR = '0xa36085F69e2889c224210F603D836748e7dC0088'
# link = Contract(LINK_ADDR)
test_contract_addr = '0x3D2De45C9816dee10F3F7898E81aFDE5AFFE9631'
test_contract = Contract(test_contract_addr)

#
def tokenbalance(account, token):
    t = interface.LinkTokenInterface(token)
    return t.balanceOf(account)


def main():
    print(tokenbalance(test_contract, LINK_ADDR))
