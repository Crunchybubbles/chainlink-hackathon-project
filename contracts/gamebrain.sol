pragma solidity ^0.8.7;

import "smartcontractkit/chainlink@1.0.0/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";



contract GameBrain {
  mapping(address => uint) public linkBalance;
  address public owner;
  address public CreatureFactory;
  address public ItemFactory;
  address public BattleLogic;
  address public PvE;

  LinkTokenInterface internal LINK;

  uint public fee;

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  modifier onlyGameContracts {
    if (msg.sender == CreatureFactory) {
      _;
    } else if (msg.sender == ItemFactory) {
      _;
    } else if (msg.sender == BattleLogic) {
      _;
    } else if (msg.sender == PvE) {
      _;
    } else {
      revert("not allowed");
    }
  }

  modifier onlyBattleLogic {
    if (msg.sender == BattleLogic) {
      _;
    } else {
      revert("not allowed");
    }
  }

  constructor(address _link) public {
    owner = msg.sender;
    LINK = LinkTokenInterface(_link);
    fee = 100000000000000000;
  }

  function changeOwner(address _newOwner) public onlyOwner {
    owner = _newOwner;
  }

  function depositLink(uint _amount) external {
    require(LINK.transferFrom(msg.sender, address(this), _amount));
    linkBalance[msg.sender] += _amount;
  }

  function approveLink(uint _amount, address _gameContract) public onlyOwner {
    LINK.approve(_gameContract, _amount);
  }

  function balanceOf(address _account) external returns (uint amount) {
    amount = linkBalance[_account];
  }

  function newBalance(address _account) external onlyGameContracts {
    linkBalance[_account] -= fee;
  }

  function increaseBalance(address _account) external onlyBattleLogic {
    linkBalance[_account] += fee;
  }

  function setCreatureFactory(address _creatureFactory) public onlyOwner {
    CreatureFactory = _creatureFactory;
  }

  function setItemFactory(address _itemfacaddr) public onlyOwner {
    ItemFactory = _itemfacaddr;
  }

  function setBattleLogic(address _battleLogic) public onlyOwner {
    BattleLogic = _battleLogic;
  }
}
