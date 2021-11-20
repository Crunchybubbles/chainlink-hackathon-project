pragma solidity ^0.8.7;

import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/token/ERC20/ERC20.sol";

contract HealthToken is ERC20 {
  constructor(address _itemfacaddr) ERC20("Heath Powder", "HP" ) {
    ItemFactory = _itemfacaddr;
  }

  address private ItemFactory;

  modifier onlyItemFactory {
    require(msg.sender == ItemFactory);
    _;
  }

  function mintToken(address _player, uint _amount) external onlyItemFactory {
    _mint(_player, _amount);
  }

  function burnTokens(address _player, uint _amount) external onlyItemFactory {
    _burn(_player, _amount);
  }
}

contract AttackToken is ERC20 {
  constructor(address _itemfacaddr) ERC20("Attack Powder", "ATK" ) {
    ItemFactory = _itemfacaddr;
  }

  address private ItemFactory;

  modifier onlyItemFactory {
    require(msg.sender == ItemFactory);
    _;
  }

  function mintToken(address _player, uint _amount) external onlyItemFactory {
    _mint(_player, _amount);
  }

  function burnTokens(address _player, uint _amount) external onlyItemFactory {
    _burn(_player, _amount);
  }
}

contract DefenseToken is ERC20 {
  constructor(address _itemfacaddr) ERC20("Defense Powder", "DEF" ) {
    ItemFactory = _itemfacaddr;
  }

  address private ItemFactory;

  modifier onlyItemFactory {
    require(msg.sender == ItemFactory);
    _;
  }

  function mintToken(address _player, uint _amount) external onlyItemFactory {
    _mint(_player, _amount);
  }

  function burnTokens(address _player, uint _amount) external onlyItemFactory {
    _burn(_player, _amount);
  }
}

contract SpeedToken is ERC20 {
  constructor(address _itemfacaddr) ERC20("Speed Powder", "SPD" ) {
    ItemFactory = _itemfacaddr;
  }

  address private ItemFactory;

  modifier onlyItemFactory {
    require(msg.sender == ItemFactory);
    _;
  }

  function mintToken(address _player, uint _amount) external onlyItemFactory {
    _mint(_player, _amount);
  }

  function burnTokens(address _player, uint _amount) external onlyItemFactory {
    _burn(_player, _amount);
  }
}
