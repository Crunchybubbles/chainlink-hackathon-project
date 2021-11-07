import brownie
from brownie import Contract, accounts, interface

# test_acc = accounts.load("testacc")
test_acc = accounts[0]

LINK_ADDR = '0xa36085F69e2889c224210F603D836748e7dC0088'
# link = Contract(LINK_ADDR)
test_contract_addr = '0xaB14abdC65511b18A75f5D78aaBc58085D05D56c'
test_contract = Contract(test_contract_addr)

def approveLink(amount, to, token_addr, myacc):
    print(f"approving {token_addr}")
    linkInterface = interface.LinkTokenInterface(token_addr)
    tx = linkInterface.approve(to, amount, {"from": myacc})
    tx.wait(1)
    return tx
#
def tokenbalance(account, token):
    t = interface.LinkTokenInterface(token)
    return t.balanceOf(account)

def linkdeposit(amount, contract, token, myacc):
    approveLink(amount, contract, token, myacc)
    depo_tx = test_contract.depositLink(amount, {"from": myacc})
    depo_tx.wait(1)
    return depo_tx





def main():
    amount = 200000000000000000
    linkdeposit(amount, test_contract_addr, LINK_ADDR, test_acc)
    print(tokenbalance(test_acc, LINK_ADDR))
    print(tokenbalance(test_contract, LINK_ADDR))