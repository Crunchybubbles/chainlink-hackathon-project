pragma solidity ^0.8.7;

import "smartcontractkit/chainlink@1.0.0/contracts/src/v0.8/VRFConsumerBase.sol";



interface gameBrainInterface {
  function depositLink(uint _amount) external;

  function balanceOf(address _account) external returns (uint amount);

  function newBalance(address _account) external;

  function increaseBalance(address _account) external;
}

interface CreatureFactoryInterface {
  function getCreatureData(uint _id) external returns (string memory name, uint id, uint hp, uint atk, uint def, uint spd);

  function getCreatureOwner(uint _id) external returns (address _owner);

  function deleteCreature(uint _id) external;
}

interface itemFactoryInterface {
  function increaseMintableQuant(address _player, uint amount) external;
}

contract BattleLogic is VRFConsumerBase {

  bytes32 internal keyHash;
  uint internal fee;

  address internal gameBrain;
  gameBrainInterface internal brain;
  CreatureFactoryInterface internal creatureFac;
  itemFactoryInterface internal itemFac;

  uint battleId;

  address dev;

  mapping(uint => mapping(uint => bool)) public isIdApprovedToFightOtherId;
  mapping(uint => uint[2]) private battleIdToCreatures;
  mapping(bytes32 => uint) private RequestIdToBattleId;

  event BattleWinner(Creature winner);

  struct Creature {
    string name;
    uint id;
    uint hp;
    uint atk;
    uint def;
    uint spd;
  }



  constructor(address _vrfcoordinator, address _link, address _gamebrain, address _creatureFactory, address _itemfacaddr)
    VRFConsumerBase(_vrfcoordinator, _link) public {
    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 100000000000000000;
    gameBrain = _gamebrain;
    brain = gameBrainInterface(_gamebrain);
    creatureFac = CreatureFactoryInterface(_creatureFactory);
    itemFac = itemFactoryInterface(_itemfacaddr);
    battleId = 1;
    dev = msg.sender;
    }

    function approveFight(uint _myCreatureId, uint _targetCreatureId) public {
      require(creatureFac.getCreatureOwner(_myCreatureId) == msg.sender);
      isIdApprovedToFightOtherId[_myCreatureId][_targetCreatureId] = true;
    }

    function initiateBattle(address _player1, uint _id1, address _player2, uint _id2) public returns (bytes32 requestId) {
      require(brain.balanceOf(_player1) >= fee && brain.balanceOf(_player2) >= fee && isIdApprovedToFightOtherId[_id1][_id2] && isIdApprovedToFightOtherId[_id2][_id1]);
      brain.newBalance(_player1);
      brain.newBalance(_player2);
      LINK.transferFrom(gameBrain, address(this), fee);
      bytes32 requestId = requestRandomness(keyHash, fee);
      uint _battleId = battleId;
      RequestIdToBattleId[requestId] = _battleId;
      battleIdToCreatures[_battleId] = [_id1, _id2];
      battleId++;
    }

    function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
      battle(requestId, randomness);
    }

    function battle(bytes32 requestId, uint randomness) private {
      uint[2] memory creatureIds = battleIdToCreatures[RequestIdToBattleId[requestId]];
      Creature memory creature1;
      Creature memory creature2;
      (creature1.name, creature1.id, creature1.hp, creature1.atk, creature1.def, creature1.spd) = creatureFac.getCreatureData(creatureIds[0]);
      (creature2.name, creature2.id, creature2.hp, creature2.atk, creature2.def, creature2.spd) = creatureFac.getCreatureData(creatureIds[1]);
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
      }
      if (winner.id == creature1.id) {
        creatureFac.deleteCreature(creature2.id);
        address creatureOwner = creatureFac.getCreatureOwner(creature1.id);
        brain.increaseBalance(creatureOwner);
        itemFac.increaseMintableQuant(creatureOwner, 1);
      }
      if (winner.id == creature2.id) {
        creatureFac.deleteCreature(creature1.id);
        address creatureOwner = creatureFac.getCreatureOwner(creature2.id);
        brain.increaseBalance(creatureOwner);
        itemFac.increaseMintableQuant(creatureOwner, 1);
      }
      if (winner.id == 0) {
        creatureFac.deleteCreature(creature1.id);
        creatureFac.deleteCreature(creature2.id);
        brain.increaseBalance(dev);
      }
    }
}
