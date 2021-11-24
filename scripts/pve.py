import brownie
import time
from brownie import Contract, accounts

vrf = "0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9"

gamebrain = Contract("0x10479593B261a7a0e699034BeFE248d65920F5a4")
itemfactory = Contract("0xccE956C45665F3B75fF72137aACF6280e7f0A83C")
creaturefactory = Contract("0xeE4de4C33A0beB83A6AEd8b84Ece0993D2cbDfEd")
battlelogic = Contract("0x44e9d88F388f1282087B41fdA5DbcCCb9424C315")
pvelogic = Contract("0xf5692c189d63ED5a7E591BE73F1bEb639035443d")

hptoken = Contract("0xd62FB78aC0140280D6f5b74baB758079A685E6C0")
atktoken = Contract("0xD70a83cD3495380C06e45CeFAc71133b156c0079")
deftoken = Contract("0x3A2A6b2E6214D1A930584EcD3bDE32372bE00447")
spdtoken = Contract("0xdE3191c1088A03DFe0c3455Bb8364060c6aec098")



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
