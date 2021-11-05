pragma solidity ^0.8.7;

import "smartcontractkit/chainlink@1.0.0/contracts/src/v0.8/VRFConsumerBase.sol";


contract CreatureFactory is VRFConsumerBase {

  bytes32 internal keyHash;
  uint internal fee;


  mapping(uint => Creature) public idToCreature;
  mapping(uint => address) public idToOwner;
  mapping(bytes32 => address) public requestIdTorequester;
  mapping(string => uint) public nameToId;
  mapping(address => uint) public linkBalance;

  uint public creatureCount;


  struct Creature {
    string name;
    uint id;
    uint health;
    uint atk;
    uint def;
    uint spd;
    Item item;
  }


  struct Item {
    uint id;
    uint health;
    uint atk;
    uint def;
    uint spd;
  }


  constructor(address _vrfcoordinator, address _link)
    VRFConsumerBase(_vrfcoordinator, _link) public {
    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 100000000000000000;
    creatureCount = 1;
  }



  function depositLink(uint _amount) public {
    LINK.transferFrom(msg.sender, address(this), _amount);
    linkBalance[msg.sender] = _amount;
  }

  function withdrawLink() public {
    LINK.transferFrom(address(this), msg.sender, linkBalance[msg.sender]);
    linkBalance[msg.sender] = 0;
  }


  function createRandomCreature() public returns (bytes32 requestId) {
    return requestRandomness(keyHash, fee);
  }


  function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
    newCreature(randomness, requestId);
  }


  function newCreature(uint _randomseed, bytes32 requestId) private {
    uint seed = _randomseed % 1000;
    uint health = ((seed / 1000) % 10) + 5;
    uint atk = ((seed / 100) % 10) + 1;
    uint def = ((seed / 10) % 10) + 1;
    uint spd = (seed  % 10) + 1;
    uint id = creatureCount;
    Item memory zeroItem;
    idToCreature[id] = Creature("", id, health, atk, def, spd, zeroItem);
    idToOwner[id] = requestIdTorequester[requestId];
    creatureCount++;
  }

  function nameCreature(uint _id, string calldata _name) public {
    require(idToOwner[_id] == msg.sender);
    require(nameToId[_name] == 0);
    nameToId[_name] = _id;
    idToCreature[_id].name = _name;
  }
}
