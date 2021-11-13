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
}

contract BattleLogic is VRFConsumerBase {

  bytes32 internal keyHash;
  uint internal fee;

  address internal gameBrain;
  gameBrainInterface internal brain;
  CreatureFactoryInterface internal creatureFac;

  uint battleId;

  mapping(uint => mapping(uint => bool)) public isIdApprovedToFightOtherId;
  mapping(uint => Creature[2]) public battleIdToCreatures;
  mapping(bytes32 => uint) public RequestIdToBattleId;

  struct Creature {
    string name;
    uint id;
    uint hp;
    uint atk;
    uint def;
    uint spd;
  }

  uint rando;


  constructor(address _vrfcoordinator, address _link, address _gamebrain, address _creatureFactory)
    VRFConsumerBase(_vrfcoordinator, _link) public {
    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 100000000000000000;
    gameBrain = _gamebrain;
    brain = gameBrainInterface(_gamebrain);
    creatureFac = CreatureFactoryInterface(_creatureFactory);
    battleId = 1;
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
      Creature memory creature1;
      Creature memory creature2;
      (creature1.name, creature1.id, creature1.hp, creature1.atk, creature1.def, creature1.spd) = creatureFac.getCreatureData(_id1);
      (creature2.name, creature2.id, creature2.hp, creature2.atk, creature2.def, creature2.spd) = creatureFac.getCreatureData(_id2);
      battleIdToCreatures[_battleId] = [creature1, creature2];
      battleId++;
    }

    function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
      rando = randomness;
    }





}
