pragma solidity ^0.8.7;

import "smartcontractkit/chainlink@1.0.0/contracts/src/v0.8/VRFConsumerBase.sol";




interface gameBrainInterface {
  function depositLink(uint _amount) external;

  function balanceOf(address _account) external returns (uint amount);

  function newBalance(address _account) external;
}

interface CreatureFactoryInterface {
  function getCreatureData(uint _id) external returns (string memory name, uint id, uint hp, uint atk, uint def, uint spd);

  function getCreatureOwner(uint _id) external returns (address _owner);

  function deleteCreature(uint _id) external;
}

interface itemFactoryInterface {
  function increaseMintableQuant(address _player, uint amount) external;
}

contract PvEfactory is VRFConsumerBase {
    bytes32 internal keyHash;
    uint internal fee;

    address public gameBrain;

    gameBrainInterface internal brain;
    CreatureFactoryInterface internal creatureFac;
    itemFactoryInterface internal itemFac;

    mapping(bytes32 => address) public requestIdTorequester;
    mapping(bytes32 => uint) public requestIdToCreatureId;
    mapping(uint => uint) public creatureIdToWinCount;

    event CreatureDeleted(Creature deadCreature);
    event BattleWinner(Creature winner);

    struct Creature {
      string name;
      uint id;
      uint hp;
      uint atk;
      uint def;
      uint spd;
    }

    struct Item {
      uint hp;
      uint atk;
      uint def;
      uint spd;
    }

    constructor(address _vrfcoordinator, address _link, uint _fee, address _gamebrain, address _creatureFactory, address _itemfacaddr)
      VRFConsumerBase(_vrfcoordinator, _link) public {
      keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
      fee = _fee;
      gameBrain = _gamebrain;
      brain = gameBrainInterface(_gamebrain);
      creatureFac = CreatureFactoryInterface(_creatureFactory);
      itemFac = itemFactoryInterface(_itemfacaddr);
    }

    function randomPveFight(uint _creatureId) public returns (bytes32 requestId) {
      require(brain.balanceOf(msg.sender) >= fee && creatureFac.getCreatureOwner(_creatureId) == msg.sender);
      brain.newBalance(msg.sender);
      LINK.transferFrom(gameBrain, address(this), fee);
      bytes32 requestId = requestRandomness(keyHash, fee);
      requestIdTorequester[requestId] = msg.sender;
      requestIdToCreatureId[requestId] = _creatureId;
    }


    function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
      pveEncounter(requestId, randomness);
    }

    function pveEncounter(bytes32 requestId, uint randomness) private {
      Creature memory playerCreature;
      uint creatureId = requestIdToCreatureId[requestId];
      (playerCreature.name, playerCreature.id, playerCreature.hp, playerCreature.atk, playerCreature.def, playerCreature.spd) = creatureFac.getCreatureData(creatureId);
      Creature memory randoPveCreature = pveCreature(randomness);
      Item memory randoItem = pveItem(randomness);
      randoPveCreature.hp += randoItem.hp;
      randoPveCreature.atk += randoItem.atk;
      randoPveCreature.def += randoItem.def;
      randoPveCreature.spd += randoItem.spd;
      Creature memory winner = pveBattle(playerCreature, randoPveCreature, randomness);
    }

    function pveBattle(Creature memory creature1, Creature memory creature2, uint randomness) private returns (Creature memory winner) {
      bool c1first;
      if (creature1.spd > creature2.spd) {
        c1first = true;
      }
      if (creature1.spd == creature2.spd) {
        if (randomness % 2 == 0) {
          c1first = true;
        }
      }
      uint turncount;
      Creature memory winner;
      while (creature1.hp != 0 && creature2.hp != 0) {
        uint dmg1;
        uint dmg2;
        if (c1first) {
          if (creature1.atk > creature2.def) {
            dmg1 = creature1.atk - creature2.def;
          }
          if (dmg1 > creature2.hp) {
            creature2.hp = 0;
            winner = creature1;
            break;
          } else {
            creature2.hp -= dmg1;
          }
          if (creature2.atk > creature1.def) {
            dmg2 = creature2.atk - creature1.atk;
          }
          if (dmg2 > creature1.hp) {
            creature1.hp = 0;
            winner = creature2;
            break;
          } else {
            creature1.hp -= dmg2;
          }
        } else {
          if (creature2.atk > creature1.def) {
            dmg2 = creature2.atk - creature1.atk;
          }
          if (dmg2 > creature1.hp) {
            creature1.hp = 0;
            winner = creature2;
            break;
          } else {
            creature1.hp -= dmg2;
          }
          if (creature1.atk > creature2.def) {
            dmg1 = creature1.atk - creature2.def;
          }
          if (dmg1 > creature2.hp) {
            creature2.hp = 0;
            winner = creature1;
            break;
          } else {
            creature2.hp -= dmg1;
          }
        }
        if (turncount == 10) {
          break;
        }
        turncount++;
      }
      if (winner.id != 0) {
        emit BattleWinner(winner);
        itemFac.increaseMintableQuant(creatureFac.getCreatureOwner(winner.id), 1);
        creatureIdToWinCount[winner.id] = creatureIdToWinCount[winner.id] + 1;
      }

      if (winner.id == 0) {
        creatureFac.deleteCreature(creature1.id);
      }
    }

    function pveCreature(uint randomness) private returns (Creature memory randoPveCreature) {
      uint seed = randomness % 1000000000000;
      uint hp = ((seed / 1000) % 10) + 5;
      uint atk = ((seed / 100) % 10) + 1;
      uint def = ((seed / 10) % 10) + 1;
      uint spd = (seed  % 10) + 1;
      randoPveCreature = Creature("", 0, hp, atk, def, spd);
    }

    function pveItem(uint randomness) private returns (Item memory randoPveItem) {
      uint tier = _tier(randomness);
      if (tier == 0) {
        randoPveItem = Item(0,0,0,0);
      } else {
        Item memory randItemStats = _itemStats(randomness);
        uint[4] memory item;
        uint[4] memory tieredStatArray = [randItemStats.hp, randItemStats.atk, randItemStats.def, randItemStats.spd];
        for (uint i; i < tier; i++) {
          uint digits = 10**(2*i);
          uint num = (randomness / digits) % 4;
          item[num] = (item[num] + tieredStatArray[num] + tier);
        }
        randoPveItem = Item(item[0], item[1], item[2], item[3]);
      }
    }

    function _itemStats(uint seed) private pure returns(Item memory randoItem) {
      seed = seed % 1000000000000;
      uint hp = seed / 1000000000000;
      if (hp == 0) {
        hp = 1;
      }
      uint atk = (seed / 100000000000) % 10;
      if (atk == 0) {
        atk = 1;
      }
      uint def = (seed / 10000000000) % 10;
      if (def == 0) {
        def = 1;
      }
      uint spd = (seed / 1000000000) % 10;
      if (spd == 0) {
        spd = 1;
      }

      randoItem = Item(hp, atk, def, spd);
    }

    function _tier(uint seed) private pure returns (uint tier) {
      seed = (seed / 1000000000) % 1000;

      uint n = 1000;
      uint s = 3;

      if (seed < n-8**s) {
        tier = 0;
      }

      if (seed < n-7**s && seed >= n-8**s) {
        tier = 1;
      }

      if (seed < n-6**s && seed >= n-7**s) {
        tier = 2;
      }

      if (seed < n-5**s && seed >= n-6**s) {
        tier = 3;
      }

      if (seed < n-4**s && seed >= n-5**s) {
        tier = 4;
      }

      if (seed < n-3**s && seed >= n-4**s) {
        tier = 5;
      }

      if (seed < n-2**s && seed >= n-3**s) {
        tier = 6;
      }

      if (seed < n-s && seed >= n-2**s) {
        tier = 7;
      }

      if (seed >= n-s) {
        tier = 8;
      }
    }

}
