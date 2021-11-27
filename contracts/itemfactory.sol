pragma solidity ^0.8.7;


import "smartcontractkit/chainlink@1.0.0/contracts/src/v0.8/VRFConsumerBase.sol";



interface gameBrainInterface {
  function depositLink(uint _amount) external;

  function balanceOf(address _account) external returns (uint amount);

  function newBalance(address _account) external;
}

interface gameTokens {
  function mintToken(address _player, uint _amount) external;

  function burnTokens(address _player, uint _amount) external;

  function balanceOf(address _player) external returns (uint amount);
}

contract ItemFactory is VRFConsumerBase {

  mapping(bytes32 => address) public requestIdTorequester;
  mapping(uint => Item) public itemIdToItem;
  mapping(uint => address) public itemIdToOwner;
  mapping(address => uint) public playerToMintableQuant;
  mapping(uint => bool) public itemIdToisEquiped;

  gameTokens internal HealthToken;
  gameTokens internal AttackToken;
  gameTokens internal DefenseToken;
  gameTokens internal SpeedToken;

  address public owner;
  address public creatureFactory;
  address public battleLogic;
  address public PvE;


  uint public rando;

  bytes32 internal keyHash;
  uint internal fee;

  uint public itemCount;

  address internal gameBrain;

  gameBrainInterface internal brain;

  event ItemDeleted(Item deletedItem);



  struct Item {
    uint id;
    uint hp;
    uint atk;
    uint def;
    uint spd;
  }

  modifier isAbleToMint(address _player) {
    if (playerToMintableQuant[_player] != 0) {
      playerToMintableQuant[_player] -= 1;
      _;
    } else {
      revert("no mintable quantity");
    }
  }

  modifier onlyOwner {
    if (msg.sender != owner) {
      revert("not owner");
    } else {
      _;
    }
  }

  modifier onlyCreatureFac {
    if (msg.sender == creatureFactory) {
      _;
    } else {
      revert("not authorized");
    }
  }

  modifier onlyBattleContracts {
    if (msg.sender == battleLogic) {
      _;
    } else if (msg.sender == PvE) {
      _;
    } else {
      revert("not allowed");
    }
  }

  constructor(address _vrfcoordinator, address _link, uint _fee, bytes32 _keyhash, address _gamebrain)
    VRFConsumerBase(_vrfcoordinator, _link) public {
    keyHash = _keyhash;
    fee = _fee;
    itemCount = 1;
    gameBrain = _gamebrain;
    brain = gameBrainInterface(_gamebrain);
    owner = msg.sender;
  }

  function setHealthToken(address _healthToken) public onlyOwner {
    HealthToken = gameTokens(_healthToken);
  }

  function setAttackToken(address _attackToken) public onlyOwner {
    AttackToken = gameTokens(_attackToken);
  }

  function setDefenseToken(address _defenseToken) public onlyOwner {
    DefenseToken = gameTokens(_defenseToken);
  }

  function setSpeedToken(address _speedToken) public onlyOwner {
    SpeedToken = gameTokens(_speedToken);
  }

  function changeOwner(address _newOwner) public onlyOwner {
    owner = _newOwner;
  }

  function setCreatureFactory(address _creatureFactory) public onlyOwner {
    creatureFactory = _creatureFactory;
  }

  function setBattleLogic(address _battleLogic) public onlyOwner {
    battleLogic = _battleLogic;
  }

  function setPvE(address _PvE) public onlyOwner {
    PvE = _PvE;
  }

  function increaseMintableQuant(address _player, uint _amount) external onlyBattleContracts {
    playerToMintableQuant[_player] = playerToMintableQuant[_player] + _amount;
  }

  function transferItemMint(address _from, address _to, uint _amount) public {
    require(playerToMintableQuant[_from] >= _amount && _from == msg.sender);
    playerToMintableQuant[_from] = playerToMintableQuant[_from] - _amount;
    playerToMintableQuant[_to] = playerToMintableQuant[_to] + _amount;
  }

  function transferItem(address _to, uint _id) public {
    require(itemIdToOwner[_id] == msg.sender);
    itemIdToOwner[_id] = _to;
  }


  function createRandomItem() public isAbleToMint(msg.sender) returns (bytes32 requestId) {
    require(brain.balanceOf(msg.sender) >= fee);
    brain.newBalance(msg.sender);
    LINK.transferFrom(gameBrain, address(this), fee);
    bytes32 requestId = requestRandomness(keyHash, fee);
    requestIdTorequester[requestId] = msg.sender;
  }


  function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
    newItem(randomness, requestId);
  }


  function newItem(uint _seed, bytes32 _requestId) private {
    uint tier = _tier(_seed);

    if (tier == 0) {
      mintTokens(requestIdTorequester[_requestId], 1);
    } else {
      uint id = itemCount;
      Item memory randItemStats = _itemStats(_seed);
      uint[4] memory item;
      uint[4] memory tieredStatArray = [randItemStats.hp, randItemStats.atk, randItemStats.def, randItemStats.spd];
      for (uint i; i < tier; i++) {
        uint digits = 10**(2*i);
        uint num = (_seed / digits) % 4;
        item[num] = (item[num] + tieredStatArray[num] + tier);
      }
      itemIdToItem[id] = Item(id, item[0], item[1], item[2], item[3]);
      itemIdToOwner[id] = requestIdTorequester[_requestId];
      itemCount++;
    }
  }

  function _itemStats(uint seed) private pure returns(Item memory randoItem) {
    seed = seed % 10000;
    uint hp = seed / 10000;
    if (hp == 0) {
      hp = 1;
    }
    uint atk = (seed / 1000) % 10;
    if (atk == 0) {
      atk = 1;
    }
    uint def = (seed / 100) % 10;
    if (def == 0) {
      def = 1;
    }
    uint spd = (seed / 10) % 10;
    if (spd == 0) {
      spd = 1;
    }

    randoItem = Item(0,hp, atk, def, spd);
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

  function mintTokens(address _player,uint _amount) private {
    HealthToken.mintToken(_player, _amount);
    AttackToken.mintToken(_player, _amount);
    DefenseToken.mintToken(_player, _amount);
    SpeedToken.mintToken(_player, _amount);
  }

  function getItemData(uint _id) external returns (uint id, uint hp, uint atk, uint def, uint spd) {
    require(itemIdToisEquiped[_id] == false);
    Item memory requestedItem = itemIdToItem[_id];
    id = requestedItem.id;
    hp = requestedItem.hp;
    atk = requestedItem.atk;
    def = requestedItem.def;
    spd = requestedItem.spd;
    itemIdToisEquiped[_id] = true;
  }

  function getItemOwner(uint _id) external returns (address itemOwner) {
    itemOwner = itemIdToOwner[_id];
  }

  function unequip(uint _id) external onlyCreatureFac {
    itemIdToisEquiped[_id] = false;
  }

  function deleteItem(uint _id) external onlyCreatureFac {
    Item memory zeroItem;
    address zeroAddr;
    emit ItemDeleted(itemIdToItem[_id]);
    itemIdToItem[_id] = zeroItem;
    itemIdToOwner[_id] = zeroAddr;
  }

  function deconstructItem(uint _id) public {
    require(itemIdToOwner[_id] == msg.sender && itemIdToisEquiped[_id] == false);
    Item memory zeroItem;
    address zeroAddr;
    Item memory item = itemIdToItem[_id];
    uint hp = item.hp;
    uint atk = item.atk;
    uint def = item.def;
    uint spd = item.spd;
    itemIdToItem[_id] = zeroItem;
    itemIdToOwner[_id] = zeroAddr;
    HealthToken.mintToken(msg.sender, hp);
    AttackToken.mintToken(msg.sender, atk);
    DefenseToken.mintToken(msg.sender, def);
    SpeedToken.mintToken(msg.sender, spd);
  }

  function upgradeItem(uint _id, uint _hptokens, uint _atktokens, uint _deftokens, uint _spdtokens) public {
    require(itemIdToOwner[_id] == msg.sender && HealthToken.balanceOf(msg.sender) >= _hptokens && AttackToken.balanceOf(msg.sender) >= _atktokens && DefenseToken.balanceOf(msg.sender) >= _deftokens && SpeedToken.balanceOf(msg.sender) >= _spdtokens);
    Item memory item = itemIdToItem[_id];
    HealthToken.burnTokens(msg.sender, _hptokens);
    AttackToken.burnTokens(msg.sender, _atktokens);
    DefenseToken.burnTokens(msg.sender, _deftokens);
    SpeedToken.burnTokens(msg.sender, _spdtokens);
    item.hp += _hptokens;
    item.atk += _atktokens;
    item.def += _deftokens;
    item.spd += _spdtokens;
    itemIdToItem[_id] = item;
  }

}
