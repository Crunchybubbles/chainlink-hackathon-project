import brownie
from brownie import Contract, accounts, interface, GameBrain, CreatureFactory, ItemFactory, BattleLogic, PvEfactory, HealthToken, AttackToken, DefenseToken, SpeedToken

link_addr = "0xa36085F69e2889c224210F603D836748e7dC0088"
vrf = "0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9"

def approveLink(amount, to, token_addr, myacc):
    print(f"approving {token_addr}")
    linkInterface = interface.LinkTokenInterface(token_addr)
    tx = linkInterface.approve(to, amount, {"from": myacc})
    tx.wait(1)
    return tx

def main():
    fee = 100000000000000000
    test_acc = accounts.load("testacc")
    gameBrain = GameBrain.deploy(link_addr, fee {"from": test_acc})
    itemFactory = ItemFactory.deploy(vrf, link_addr, fee, gameBrain.address, {"from": test_acc})
    creatureFactory = CreatureFactory.deploy(vrf, link_addr, fee, gameBrain.address, itemFactory.address, {"from": test_acc})
    battleLogic = BattleLogic.deploy(vrf, link_addr, fee, gameBrain.address, creatureFactory.address, itemFactory.address, {"from": test_acc})
    pvE = PvEfactory.deploy(vrf, link_addr, fee, gameBrain.address, creatureFactory.address, itemFactory.address, {"from": test_acc})

    healthToken = HealthToken.deploy(itemFactory.address, {"from": test_acc})
    attackToken = AttackToken.deploy(itemFactory.address, {"from": test_acc})
    defenseToken = DefenseToken.deploy(itemFactory.address, {"from": test_acc})
    speedToken = SpeedToken.deploy(itemFactory.address, {"from": test_acc})

    gameBrain.setCreatureFactory(creatureFactory.address, {"from": test_acc})
    gameBrain.setItemFactory(itemFactory.address, {"from": test_acc})
    gameBrain.setBattleLogic(battleLogic.address, {"from": test_acc})
    gameBrain.setPvE(pvE.address, {"from": test_acc})

    itemFactory.setHealthToken(healthToken.address, {"from": test_acc})
    itemFactory.setAttackToken(attackToken.address, {"from": test_acc})
    itemFactory.setDefenseToken(defenseToken.address, {"from": test_acc})
    itemFactory.setSpeedToken(speedToken.address, {"from": test_acc})
    itemFactory.setCreatureFactory(creatureFactory.address, {"from": test_acc})
    itemFactory.setBattleLogic(battleLogic.address, {"from": test_acc})
    itemFactory.setPvE(pvE.address, {"from": test_acc})

    creatureFactory.setBattleLogic(battleLogic.address, {"from": test_acc})
    creatureFactory.setPvE(pvE.address, {"from": test_acc})

    amount = 100000000000000000000

    gameBrain.approveLink(amount, creatureFactory.address, {"from": test_acc})
    gameBrain.approveLink(amount, itemFactory.address, {"from": test_acc})
    gameBrain.approveLink(amount, battleLogic.address, {"from": test_acc})
    gameBrain.approveLink(amount, pvE.address, {"from": test_acc})

    # for i in range(5):
    #     creatureFactory.createRandomCreature({"from": test_acc})
