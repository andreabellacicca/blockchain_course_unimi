pragma solidity ^0.5.0;

contract FaucetAdvanced{

	address owner;
	uint256 internal totalBalance = address(this).balance;
	
	mapping(address => uint256) internal balance;
	
   	event Withdraw(address indexed account, uint256 amount);
	
	constructor() public payable {
		owner = msg.sender;
		balance[address(this)] = msg.value;
	}
	
	
	function totalSupply() external view returns (uint256){
		return totalBalance;
	} 
	
	
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
	
	// Per trasferimenti da un indirizzo all'altro, utilizzabile solo dalle funzioni del contratto.
	function _transfer(address sender, address receiver, uint256 amount) internal returns (bool){
		require(balance[sender] >= amount, 'Credito non sufficiente');
		balance[sender] = balance[sender] - amount;
		balance[receiver] = balance[receiver] + amount;
		return true;
	}
	
	
	// Ogni account può ritirare soldi dal proprio conto.
	function withdraw(uint withdraw_amount) public { 
		require(withdraw_amount <= balance[msg.sender], 'Credito insufficiente');
		totalBalance -= withdraw_amount;
		balance[msg.sender] -= withdraw_amount;
		msg.sender.transfer(withdraw_amount);	
		emit Withdraw(msg.sender, withdraw_amount);
	}
	
	// Il proprietario del contratto può depositare ether sul contratto.
	function () external payable { 
		require(msg.sender == owner, 'Solo il proprietario può ricaricare il contratto');
		totalBalance = totalBalance + msg.value;
		balance[address(this)] += msg.value;
	}
}
