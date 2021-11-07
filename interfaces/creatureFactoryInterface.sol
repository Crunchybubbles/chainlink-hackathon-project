pragma solidity ^0.8.7;

interface CreatureFactoryInterface {

  function createRandomCreature() external returns (bytes32 requestId);

  function nameCreature(uint _id, string calldata _name) external;
}
