pragma solidity ^0.8.7;

import "smartcontractkit/chainlink@1.0.0/contracts/src/v0.8/VRFConsumerBase.sol";



interface gameBrainInterface {
  function depositLink(uint _amount) external;

  function balanceOf(address _account) external returns (uint amount);

  function newBalance(address _account) external;
}

interface gameTokens {
  function mintToken(address _player, uint _amount) external;
}

contract ItemFactory is VRFConsumerBase {

  mapping(bytes32 => address) public requestIdTorequester;
  mapping(uint => ItemfromFac) public itemIdToItem;
  mapping(uint => address) public itemIdToOwner;
  mapping(address => uint) public playerToMintableQuant;

  gameTokens internal HealthToken;
  gameTokens internal AttackToken;
  gameTokens internal DefenseToken;
  gameTokens internal SpeedToken;

  address public owner;


  uint public rando;

  bytes32 internal keyHash;
  uint internal fee;

  uint public itemCount;

  address internal gameBrain;

  gameBrainInterface internal brain;


  struct ItemfromFac {
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

/* fix item to owner */


  constructor(address _vrfcoordinator, address _link, address _gamebrain)
    VRFConsumerBase(_vrfcoordinator, _link) public {
    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 100000000000000000;
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

  function increaseMintableQuant(address _player) public {
    playerToMintableQuant[msg.sender] += 1;
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
      ItemfromFac memory randItemStats = _itemStats(_seed);
      uint[4] memory item;
      uint[4] memory tieredStatArray = [randItemStats.hp, randItemStats.atk, randItemStats.def, randItemStats.spd];
      for (uint i; i < tier; i++) {
        uint digits = 10**(2*i);
        uint num = (_seed / digits) % 4;
        item[num] = (item[num] + tieredStatArray[num] + tier);
      }
      itemIdToItem[id] = ItemfromFac(id, item[0], item[1], item[2], item[3]);
      itemIdToOwner[id] = requestIdTorequester[_requestId];
      itemCount++;
    }
  }

  function _itemStats(uint seed) private pure returns(ItemfromFac memory randoItem) {
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

    randoItem = ItemfromFac(0,hp, atk, def, spd);
  }

  /* too many non zero tier items being generated out of 10 attempts 7 lead to items */

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

  function getItemData(uint _id) external returns (ItemfromFac memory requestedItem) {
    requestedItem = itemIdToItem[_id];
  }

  function getItemOwner(uint _id) external returns (address itemOwner) {
    itemOwner = itemIdToOwner[_id];
  }

}
