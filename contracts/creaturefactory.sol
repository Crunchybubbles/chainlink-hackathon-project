pragma solidity ^0.8.7;

import "smartcontractkit/chainlink@1.0.0/contracts/src/v0.8/VRFConsumerBase.sol";




interface gameBrainInterface {
  function depositLink(uint _amount) external;

  function balanceOf(address _account) external returns (uint amount);

  function newBalance(address _account) external;
}

interface itemFactoryInterface {
  function getItemData(uint _id) external returns (uint id, uint hp, uint atk, uint def, uint spd);

  function getItemOwner(uint _id) external returns (address itemOwner);

  function unequip(uint _id) external;

  function deleteItem(uint _id) external;
}


contract CreatureFactory is VRFConsumerBase {

  bytes32 internal keyHash;
  uint internal fee;


  mapping(uint => Creature) public idToCreature;
  mapping(uint => address) public idToOwner;
  mapping(bytes32 => address) public requestIdTorequester;
  mapping(string => uint) public nameToId;

  address public gameBrain;
  gameBrainInterface internal brain;

  itemFactoryInterface internal itemFac;

  address public BattleLogic;
  address public PvE;


  uint public creatureCount;

  address owner;

  event CreatureDeleted(Creature deadCreature);

  modifier onlyBattleContracts {
    if (msg.sender == BattleLogic) {
      _;
    } else if (msg.sender == PvE) {
      _;
    } else {
      revert("not allowed");
    }
  }

  struct Creature {
    string name;
    uint id;
    uint hp;
    uint atk;
    uint def;
    uint spd;
    Item item;
  }


  struct Item {
    uint id;
    uint hp;
    uint atk;
    uint def;
    uint spd;
  }


  constructor(address _vrfcoordinator, address _link, uint _fee, bytes32 _keyhash, address _gamebrain, address _itemfacaddr)
    VRFConsumerBase(_vrfcoordinator, _link) public {
    keyHash = _keyhash;
    fee = _fee;
    creatureCount = 1;
    gameBrain = _gamebrain;
    brain = gameBrainInterface(_gamebrain);
    itemFac = itemFactoryInterface(_itemfacaddr);
    owner = msg.sender;
  }

  function createRandomCreature() public returns (bytes32 requestId) {
    require(brain.balanceOf(msg.sender) >= fee);
    brain.newBalance(msg.sender);
    LINK.transferFrom(gameBrain, address(this), fee);
    bytes32 requestId = requestRandomness(keyHash, fee);
    requestIdTorequester[requestId] = msg.sender;
  }


  function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
    newCreature(randomness, requestId);
  }


  function newCreature(uint _randomseed, bytes32 requestId) private {
    uint seed = _randomseed % 10000;
    uint hp = ((seed / 1000) % 10) + 5;
    uint atk = ((seed / 100) % 10) + 1;
    uint def = ((seed / 10) % 10) + 1;
    uint spd = (seed  % 10) + 1;
    uint id = creatureCount;
    Item memory zeroItem;
    idToCreature[id] = Creature("", id, hp, atk, def, spd, zeroItem);
    idToOwner[id] = requestIdTorequester[requestId];
    creatureCount++;
  }

  function nameCreature(uint _id, string calldata _name) external {
    require(idToOwner[_id] == msg.sender);
    require(nameToId[_name] == 0);
    nameToId[_name] = _id;
    idToCreature[_id].name = _name;
  }

  function equipItem(uint _creatureId, uint _itemId) public {
    require(itemFac.getItemOwner(_itemId) == idToOwner[_creatureId]);
    Creature memory creature = idToCreature[_creatureId];
    Item memory itm;
    (itm.id, itm.hp, itm.atk, itm.def, itm.spd) =  itemFac.getItemData(_itemId);
    creature.item = Item(itm.id, itm.hp, itm.atk, itm.def, itm.spd);
    idToCreature[_creatureId] = creature;
  }

  function unequipItem(uint _creatureId, uint _itemId) public {
    require(itemFac.getItemOwner(_itemId) == idToOwner[_creatureId]);
    Item memory zeroItem;
    Creature memory creature = idToCreature[_creatureId];
    creature.item = zeroItem;
    idToCreature[_creatureId] = creature;
    itemFac.unequip(_itemId);
  }

  function getCreatureData(uint _id) external returns (string memory name, uint id, uint hp, uint atk, uint def, uint spd) {
      Creature memory myCreature = idToCreature[_id];
      name = myCreature.name;
      id = myCreature.id;
      hp = myCreature.hp + myCreature.item.hp;
      atk = myCreature.atk + myCreature.item.atk;
      def = myCreature.def + myCreature.item.def;
      spd = myCreature.spd + myCreature.item.spd;
  }

  function getCreatureOwner(uint _id) external returns (address _owner) {
    _owner = idToOwner[_id];
  }

  function setBattleLogic(address _battleLogic) public {
    require(msg.sender == owner);
    BattleLogic = _battleLogic;
  }

  function setPvE(address _pve) public {
    require(msg.sender == owner);
    PvE = _pve;
  }

  function deleteCreature(uint _id) external onlyBattleContracts {
    Creature memory zeroCreature;
    address zeroAddr;
    Creature memory toBeDeleted = idToCreature[_id];
    if (toBeDeleted.item.id != 0) {
      itemFac.deleteItem(toBeDeleted.item.id);
    }
    idToCreature[_id] = zeroCreature;
    idToOwner[_id] = zeroAddr;

    emit CreatureDeleted(toBeDeleted);
  }

  function transferCreature(address _to, uint _id) public {
    require(idToOwner[_id] == msg.sender);
    idToOwner[_id] = _to;
  }

}
