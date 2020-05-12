pragma solidity ^0.5.0;

contract FauAdv {

	address owner = 0xfb74C9012A57B0E1dB837b624080b3CbCd3Bb248;

	mapping(address => uint256) internal balance;

	function refill (address account) external payable returns(bool){
		require(msg.sender == owner, 'Non sei autorizzato a ricaricare i conti');
		balance[account] = balance[account] + msg.value;
		return true;
	}

	event Refilled(address indexed owner, address indexed recipient, uint256 amount);
	event Withdraw(address indexed recipient, uint256 amount);

	function transfer(address recipient, uint256 amount) external returns (bool){
		require(balance[msg.sender] >= amount, 'Credito non sufficiente');
		balance[msg.sender] = balance[msg.sender] - amount;
		balance[recipient] = balance[recipient] + amount;
		return true;
	}

	function balanceOf(address account) external view returns (uint256){
		return balance[account];
	}

     function withdraw(uint withdraw_amount) public{
        require(withdraw_amount <= balance[msg.sender],'Credito insufficiente'); //pongo un limite massimo all'ether da mandare
        msg.sender.transfer(withdraw_amount); //manda gli ether richiesti
        balance[msg.sender] = balance[msg.sender] - withdraw_amount;
    }

}