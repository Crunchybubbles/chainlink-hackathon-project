import brownie
from brownie import Contract, accounts, interface, GameBrain, CreatureFactory, ItemFactory, BattleLogic, PvEfactory, HealthToken, AttackToken, DefenseToken, SpeedToken

link_addr = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB"
vrf = "0x8C7382F9D8f56b33781fE506E897a4F1e2d17255"
keyhash = "0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4"
fee = 0.0001 * 10**18

def approveLink(amount, to, token_addr, myacc):
    print(f"approving {token_addr}")
    linkInterface = interface.LinkTokenInterface(token_addr)
    tx = linkInterface.approve(to, amount, {"from": myacc})
    tx.wait(1)
    return tx

def main():
    # fee = 100000000000000000
    test_acc = accounts.load("testacc")
    gameBrain = GameBrain.deploy(link_addr, fee, {"from": test_acc})
    itemFactory = ItemFactory.deploy(vrf, link_addr, fee, keyhash, gameBrain.address, {"from": test_acc})
    creatureFactory = CreatureFactory.deploy(vrf, link_addr, fee, keyhash, gameBrain.address, itemFactory.address, {"from": test_acc})
    battleLogic = BattleLogic.deploy(vrf, link_addr, fee, keyhash, gameBrain.address, creatureFactory.address, itemFactory.address, {"from": test_acc})
    pvE = PvEfactory.deploy(vrf, link_addr, fee, keyhash, gameBrain.address, creatureFactory.address, itemFactory.address, {"from": test_acc})

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
