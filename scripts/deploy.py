import brownie
from brownie import Contract, accounts, interface, GameBrain, CreatureFactory, ItemFactory, HealthToken, AttackToken, DefenseToken, SpeedToken

link_addr = "0xa36085F69e2889c224210F603D836748e7dC0088"
vrf = "0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9"

def approveLink(amount, to, token_addr, myacc):
    print(f"approving {token_addr}")
    linkInterface = interface.LinkTokenInterface(token_addr)
    tx = linkInterface.approve(to, amount, {"from": myacc})
    tx.wait(1)
    return tx

def linkdeposit(amount, contract, token, myacc):
    approveLink(amount, contract, token, myacc)
    depo_tx = test_contract.depositLink(amount, {"from": myacc})
    depo_tx.wait(1)
    return depo_tx

def main():
    test_acc = accounts.load("testacc")
    gameBrain = GameBrain.deploy(link_addr, {"from": test_acc})
    creatureFactory = CreatureFactory.deploy(vrf, link_addr, gameBrain.address, {"from": test_acc})
    itemFactory = ItemFactory.deploy(vrf, link_addr, gameBrain.address, {"from": test_acc})
    healthToken = HealthToken.deploy(itemFactory.address, {"from": test_acc})
    attackToken = AttackToken.deploy(itemFactory.address, {"from": test_acc})
    defenseToken = DefenseToken.deploy(itemFactory.address, {"from": test_acc})
    speedToken = SpeedToken.deploy(itemFactory.address, {"from": test_acc})

    gameBrain.setCreatureFactory(creatureFactory.address, {"from": test_acc})
    gameBrain.setItemFactory(itemFactory.address, {"from": test_acc})

    itemFactory.setHealthToken(healthToken.address, {"from": test_acc})
    itemFactory.setAttackToken(attackToken.address, {"from": test_acc})
    itemFactory.setDefenseToken(defenseToken.address, {"from": test_acc})
    itemFactory.setSpeedToken(speedToken.address, {"from": test_acc})

    creatureFactory.createRandomCreature({"from": test_acc})
    itemFactory.increaseMintableQuant(test_acc, {"from": test_acc})
    itemFactory.createRandomItem({"from": test_acc})
