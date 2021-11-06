pragma solidity ^0.8.7;

import "smartcontractkit/chainlink@1.0.0/contracts/src/v0.8/VRFConsumerBase.sol";


interface CreatureFactoryInterface {
  function depositLink(uint _amount) external;

  function createRandomCreature() external returns (bytes32 requestId);

  function nameCreature(uint _id, string calldata _name) external;

  function balanceOf(address _account) external returns (uint amount);

  function newBalance(address _account) external;

}




contract ItemFactory is VRFConsumerBase {

  mapping(bytes32 => address) public requestIdTorequester;

  uint public rando;

  bytes32 internal keyHash;
  uint internal fee;

  uint public itemCount;

  address internal creatureFactory;

  CreatureFactoryInterface internal CF;


  struct Item {
    uint id;
    uint health;
    uint atk;
    uint def;
    uint spd;
  }

  constructor(address _vrfcoordinator, address _link, address _creatureFactory)
    VRFConsumerBase(_vrfcoordinator, _link) public {
    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 100000000000000000;
    itemCount = 1;
    creatureFactory = _creatureFactory;
    CF = CreatureFactoryInterface(_creatureFactory);
  }

  function createRandomItem() public returns (bytes32 requestId) {
    require(CF.balanceOf(msg.sender) >= fee);
    CF.newBalance(msg.sender);
    LINK.transferFrom(creatureFactory, address(this), fee);
    return requestRandomness(keyHash, fee);
  }


  function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
    rando = randomness;
  }
}
