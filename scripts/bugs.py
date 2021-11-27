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

# was a bug in pvelogic and battlelogic but that bug has now been squashed
def main():
    errorCount = 0
    successCount = 0
    for i in range(1, creaturefactory.creatureCount()):
        cret = creaturefactory.idToCreature(i)
        if cret[1] != 0:
            wins = pvelogic.creatureIdToWinCount(i)
            if wins == 0:
                errorcount += 1
            if wins == 1:
                successCount += 1
        if cret[1] == 0:
            successCount +=1
    print(f"error count {errorCount}")
    print(f"success count {successCount} ")
