import brownie
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



def main():
    # for i in range(20):
    #     creaturefactory.createRandomCreature({"from": accounts[0]})

    # for i in range(20):
    #     print(f"{creaturefactory.idToCreature(i + 21)}")

    goOn = True
    index1 = 101
    index2 = 102
    stop = creaturefactory.creatureCount()
    while goOn:
        print(f"index1 {index1}, index2 {index2}")
        battlelogic.approveFight(index1, index2, {"from": accounts[0]})
        battlelogic.approveFight(index2, index1, {"from": accounts[0]})
        battlelogic.initiateBattle(accounts[0], index1, accounts[0], index2, {"from": accounts[0]})
        index1 += 2
        index2 += 2
        if index1 == stop:
            goOn = False
