pragma solidity ^0.8.7;

import "smartcontractkit/chainlink@1.0.0/contracts/src/v0.8/VRFConsumerBase.sol";
import "smartcontractkit/chainlink@1.0.0/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

contract CreatureFactory is VRFConsumerBase, LinkTokenInterface {

  bytes32 internal keyHash;
  uint internal fee;

  uint public rando;

  /* LinkTokenInterface public link; */
  address public link;

  /* ILinkToken internal link; */
  /* mapping(bytes32 => uint) requestIdToRandomness; */


/* deployed at */
/* 0x89147136C027e0c6e059eDF586Be45F4228919d6 */


  /* struct Creature {
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
  } */


  constructor(address _vrfcoordinator, address _link)
    VRFConsumerBase(_vrfcoordinator, _link) public {
    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 100000000000000000;
    link = _link;


  }

  function depositLink(uint _amount) public {
    LinkTokenInterface token = LinkTokenInterface(link);
    token.transfer(address(this), _amount);
  }

  function withdrawLink() public {
    LinkTokenInterface token = LinkTokenInterface(link);
    uint balance = token.balanceOf(address(this));
    token.transfer(msg.sender, balance);
  }

  function getRandomNumber() public returns (bytes32 requestId) {
    return requestRandomness(keyHash, fee);
  }


  function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
    /* requestIdToRandomness[requestId] = randomness; */
    rando = randomness;

  }
}
