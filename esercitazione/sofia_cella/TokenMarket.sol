pragma solidity ^0.5.0;

import "./RecipientSetterRole.sol";
import "./PriceSetterRole.sol";
import "./OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol"; // add, sub, mul, div, mod
import "./myERC20.sol";

contract TokenMarket is PriceSetterRole, RecipientSetterRole, myERC20 {
	using SafeMath for uint256; 
	
	myERC20 token;

	address private _owner;
	address payable _recipient;
	address tknAddress;
	
	uint256 private _tknPrice;
	uint256 private _tknLimit = 10*10e18;
	uint256 private _weiRaised; 
	
	mapping(address => uint) private _lastTransaction;
	
	event Purchase(address indexed purchaser, uint256 indexed tkn_amount);
	
	constructor (uint256 price, address payable tkn_addr, address payable recipient) public {
		require(price >= 0, "price cannot be 0!");
	
		_owner = msg.sender;
		
		_tknPrice = price;
		
		tknAddress = tkn_addr;
		_recipient = recipient;
	}
	
	function profit() public view returns (uint256) {
		return _weiRaised;
	}
	
	/*function transactionTime(address account) public view returns (uint) {
		return _lastTransaction[account];
	}*/	
	
	function setTknPrice(uint256 new_price) public onlyPriceSetter {
		require(new_price != 0, "Price cannot be 0!");
		_tknPrice = new_price;	
	}
	
	function setRecipient(address payable new_recipient) public onlyRecipientSetter {
		require(new_recipient != _recipient, "This address is already the recipient.");
		_recipient = new_recipient;	
	}
	
	
	function buyTkns(uint256 tkn_amount) public payable returns (bool) {
		uint256 wei_amount = getFee(tkn_amount);
		
		require( wei_amount <= msg.value, "Not enough weis.");
		_buyTkns(msg.sender, tkn_amount);
		return true;
	}
    
	function buyTkns() public payable returns (bool) {
   		uint256 tkn_amount = msg.value.div(_tknPrice);
   		tkn_amount = tkn_amount.mul(1e18);
    		_buyTkns(msg.sender, tkn_amount);
    		return true;
	}
    
	function _buyTkns(address account, uint256 tkn_amount) internal returns (bool) {
		
		if(myERC20(tknAddress).balanceOf(account) != 0){
			uint transaction_time = now;
			require(transaction_time.sub( _lastTransaction[account]) >= 5 minutes, "You have to wait 5 minutes from the previous transaction.");
		}
		require(tkn_amount <= _tknLimit, "You cannot purchase more than 10 tokens in one time.");
		require(tkn_amount > 0, "You cannot buy 0 (or less!) tokens.");
		
		uint256 wei_amount = getFee(tkn_amount);
		
		myERC20(tknAddress).mint(account, tkn_amount);
		_recipient.transfer(wei_amount);
		 msg.sender.transfer(msg.value - wei_amount);
		_weiRaised = _weiRaised.add(wei_amount);
		
		_lastTransaction[account] = now;
		
		emit Purchase(account, tkn_amount);
		
		return true;
	}
    
	function getFee(uint256 tkn_amount) public view returns (uint256) {
		uint256 x = tkn_amount.mul(_tknPrice);
		return x.div(1e18);
	}
	

}
