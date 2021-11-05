import brownie
from brownie import Contract, accounts, interface

test_acc = accounts.load("testacc")

LINK_ADDR = '0xa36085F69e2889c224210F603D836748e7dC0088'
# link = Contract(LINK_ADDR)
test_contract_addr = '0x1c24e0D6A77C873B91ac9c1F4DA05034EE711a97'
test_contract = Contract(test_contract_addr)

def approveLinkdeposit(amount, to, token_addr, myacc):
    print(f"approving {token_addr}")
    linkInterface = interface.LinkTokenInterface(token_addr)
    tx = linkInterface.approve(to, amount, {"from": myacc})
    tx.wait(1)
    return tx
#
# def tokenbalance(account, token):
#     t = interface.LinkTokenInterface(token)
#     return t.balanceOf(account)

def linkdeposit(amount, contract, token, myacc):
    approveLinkdeposit(amount, contract, token, myacc)
    depo_tx = test_contract.depositLink(amount, {"from": myacc})
    depo_tx.wait(1)
    return depo_tx




def main():
    amount = 1
    linkdeposit(amount, test_contract_addr, LINK_ADDR, test_acc)
