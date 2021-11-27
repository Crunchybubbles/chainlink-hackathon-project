import brownie
import time
from brownie import Contract, accounts

vrf = "0x8C7382F9D8f56b33781fE506E897a4F1e2d17255"

gamebrain = Contract("0x4B38Ba757376f5924b034aB80F6fA7b0c67aDd3c")
itemfactory = Contract("0x24361ecaf63ac897cbB585997B91cD217eEc9B54")
creaturefactory = Contract("0xb9Febd5D49F4CEc8B474aEc52C5831d26DD4524A")
battlelogic = Contract("0xD5748582428dD991836999d399f4E04ABFa92E58")
pvelogic = Contract("0x680b5e1FbB72dB95B9a3247A59e553678E7F02d3")

hptoken = Contract("0xFA179d83f8511E6b9117CcFC43Af86Bc1e4B50a3")
atktoken = Contract("0x2023EAa14c5c428cD0808f792a9924093188A76D")
deftoken = Contract("0xD8C7B51B698eb170E8b0eB839BC6e2F259470152")
spdtoken = Contract("0x3A099f1e0850Bc2c219a9855D108cA25163285A9")

# gamebrain = Contract("0xE67ae7DC5636d5Cd2466Abc23Defb80621f19243")
# itemfactory = Contract("0x1628353d0a064d20634f7b173A69464174Fd5BF1")
# creaturefactory = Contract("0x80c0B5CDd71D10dDbBAac85d8206B0bDCf38a9dF")
# battlelogic = Contract("0x9791116BF0455c97f8C7C8c785158bd03A071C79")
# pvelogic = Contract("0xcDE50a456C822f045E37489e2a677b5DD3B63Db2")
#
# hptoken = Contract("0x04bC405B12e5D3B521f84007dC7419677DC65E7f")
# atktoken = Contract("0x4A5C764C120eE4B55EeDcb4d9a88F4a1CfC2FC6b")
# deftoken = Contract("0x9cCB2a8E8Efc5dD358b9895EdFa627bdb4513701")
# spdtoken = Contract("0x5153a32079DBA7Bb9C06d89eCdcAFB0182af2be3")



def newCreature(i):
    creaturefactory.createRandomCreature({"from": accounts[0]})
    creatureIsAlive = 0
    while creatureIsAlive == 0:
        creature = creaturefactory.idToCreature(i)
        if creature[2] != 0:
            creatureIsAlive = 1
            print(f"A new creature is born! {creature}")
        else:
            time.sleep(2)


def pvebattle(i, wincount):
    pvelogic.randomPveFight(i, {"from": accounts[0]})
    battleComplete = 0
    while battleComplete == 0:
        winC = pvelogic.creatureIdToWinCount(i)
        if winC == wincount:
            creature = creaturefactory.idToCreature(i)
            if creature[2] == 0:
                print(f"creature {i} died")
                battleComplete = 1
            else:
                time.sleep(2)
        else:
            creature = creaturefactory.idToCreature(i)
            print(f"{creature} won!")
            battleComplete = 1






def main():
    fee = 100000000000000000
    # newCreature(creaturefactory.creatureCount())
    # pvebattle(creaturefactory.creatureCount() - 1, pvelogic.creatureIdToWinCount(creaturefactory.creatureCount() - 1))
    # print(f"{gamebrain.linkBalance(accounts[0])/fee}")

    startindex = creaturefactory.creatureCount()
    n=10
    for i in range(n):
        creaturefactory.createRandomCreature({"from": accounts[0]})

    for i in range(startindex, startindex+n+1):
        pvelogic.randomPveFight(i, {"from":accounts[0]})




    # for i in range(20):
    #     creaturefactory.createRandomCreature({"from": accounts[0]})

    # for i in range(20):
    #     pvelogic.randomPveFight(15, {"from": accounts[0]})
