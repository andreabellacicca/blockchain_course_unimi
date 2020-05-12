pragma solidity ^0.5.0;

contract FaucetAdvanced{

	// contract constructor: set owner
	
	address owner;
	
	constructor() public {
		owner = msg.sender;
	}
	
	// Per sapere il bilancio del contratto
	uint256 internal totalBalance = address(this).balance;
	
	function totalSupply() external view returns (uint256){
		return totalBalance;
	} 
	
	mapping(address => uint256) internal balance;
	
	function balanceOf(address account) external view returns (uint256){
		return balance[account];
	}
	
	// Il proprietario del contratto può caricare i conti degli altri.
	function transfer(address receiver, uint256 amount) external returns (bool){
		require(msg.sender == owner, 'Solo il proprietario del contratto può utilizzare questa funzione');
		require(address(this).balance >= amount, 'Credito insufficiente: ricarica il contratto');
		_transfer(address(this), receiver, amount);
		return true;
	}
	
	// Per trasferimenti da un indirizzo all'altro, utilizzabile solo dalle funzioni del contratto
	function _transfer(address sender, address receiver, uint256 amount) internal returns (bool){
		require(balance[sender] >= amount, 'Credito non sufficiente');
		balance[sender] = balance[sender] - amount;
		balance[receiver] = balance[receiver] + amount;
		return true;
	}
	
	
	// Ogni account può ritirare soldi dal proprio conto
	function withdraw(address recipient, uint withdraw_amount) public { // O external? e ritorna un true?
		require(withdraw_amount <= balance[msg.sender], 'Credito insufficiente');
		_transfer(msg.sender, address(this), withdraw_amount);
		msg.sender.transfer(withdraw_amount);
	}
	
	// Il proprietario del contratto può depositare ether sul contratto.
	function () external payable{ 
		require(msg.sender == owner, 'Solo il proprietario può ricaricare il contratto');
	}
}
