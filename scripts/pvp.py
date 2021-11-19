import brownie
from brownie import Contract, accounts

gamebrain = Contract("0x6E808364a52b33A2Be9c65149d7f0cb74377acFE")
itemfactory = Contract("0x40A05De74e1f73F1B6A40Cf92D27C6C11d971CFc")
creaturefactory = Contract("0x9aC12457E722D7d4D4b41adCEB9bE5d143d06c97")
battlelogic = Contract("0xfEe2D9887c8B537b7270fd98E4a99f37DBC18896")
pvelogic = Contract("0xB33d2dbE63315675F83fd872907fD948556059Ed")
hptoken = Contract("0xF9cDf6bB5DC208a4107692e26262221d9fF25877")



def main():
    # for i in range(20):
    #     creaturefactory.createRandomCreature({"from": accounts[0]})

    for i in range(20):
        print(f"{creaturefactory.idToCreature(i + 21)}")


    goOn = True
    index1 = 21
    index2 = 22
    while goOn:
        battlelogic.approveFight(index1, index2, {"from": accounts[0]})
        battlelogic.approveFight(index2, index1, {"from": accounts[0]})
        battlelogic.initiateBattle(accounts[0], index1, accounts[0], index2, {"from": accounts[0]})
        index1 += 2
        index2 += 2
