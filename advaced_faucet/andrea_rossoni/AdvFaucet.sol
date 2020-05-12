pragma solidity ^0.5.0;

contract AdvFaucet{

  address private Owner = msg.sender;
  mapping(address => uint256) internal balance;

  event Refilled(address indexed _owner, address indexed _recipient, uint256 _amount);

  function backCoinsToOwner() external {
      require(msg.sender == Owner, "ERR: Your are not the owner of the contract!");
      selfdestruct(msg.sender);
  }


  function withdraw(uint _amount) external returns (bool) {
      require( balance[msg.sender] != 0, 'ERR: Your address has not been enabled for this Faucet, contact owner' );
      require (_amount <= balance[msg.sender], 'ERR: Your balance is insufficient for this amount, check it please' );
      msg.sender.transfer(_amount);
      balance[msg.sender] -= balance[msg.sender];
      return true;
  }

  function available(address _wallet) external view returns (uint256) {
      return balance[_wallet];
  }

  function refill(address _wallet) external payable returns (bool) {
      require( msg.sender == Owner, 'ERR: Your are not the owner of the contract!' );
      balance[_wallet] += msg.value;
      emit Refilled(msg.sender, _wallet, msg.value);
      return true;
  }
}
