pragma solidity ^0.8.7;

interface CreatureFactoryInterface {
  function depositLink(uint _amount) external;

  function createRandomCreature() external returns (bytes32 requestId);

  function nameCreature(uint _id, string calldata _name) external;

  function balanceOf(address _account) external returns (uint amount);

}
