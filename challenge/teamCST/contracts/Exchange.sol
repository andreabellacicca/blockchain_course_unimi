pragma solidity ^0.5.0;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/math/SafeMath.sol";
import "./TeamRole.sol";
import "./PayCoin.sol";
import "./ERC20Challenge.sol";

contract Exchange is TeamRole {
    // Libraries
    using SafeMath for uint256;

    // Variables
    address _PayTknAddress;
    address _OurTokenAddress;
    address _ChallengeContractAddress;
    uint256[] prices;
    uint _open;
    uint _end;
    uint count = 0; // Counter for addPrice 

    // Events
    event Buy(address indexed buyer, uint256 indexed amount, uint256 indexed price);
    event Sell(address indexed buyer, uint256 indexed amount, uint256 indexed price);
    event ChangeStart(address indexed who, uint256 indexed when);
    event ChangeEnd(address indexed who, uint256 indexed when);
    event PriceChange(address indexed addr, uint256 indexed price_id, uint256 indexed price);

    // Constructor
    constructor(address PayTknAddress, address OurTokenAddress, address ChallengeContractAddress) public {
        _PayTknAddress = PayTknAddress;
        _OurTokenAddress = OurTokenAddress;
        _ChallengeContractAddress = ChallengeContractAddress;
        _open = now;
        _end = now + 7 days;
        prices.push(1e18);
    }

    // Functions

    // Input: _amount of OurTkn they want to buy
    // Output: return true if success
    function buy(uint256 _amount) external isNotTeam isOpen returns(bool) {
        uint256 price;          // Price for 1 OurTkn
        uint256 id;             // Placeholder to read lastPrice()
        uint256 cost;           // Price for _amount our token
        uint256 fee;            // 0.2% of cost
        (id, price) = lastPrice();
        cost = _amount.mul(price);
        cost = cost.div(1e18);
        fee = cost.div(500);
        PayCoin(_PayTknAddress).burnFrom(msg.sender, cost+fee);
        ERC20Challenge(_OurTokenAddress).mint(msg.sender, _amount);
        emit Buy(msg.sender, _amount, cost+fee);
        return true;
    }

    // Input: _amount of OurTkn they want to sell
    // Output: return true if success
    function sell(uint256 _amount) external isNotTeam isOpen returns(bool) {
        uint256 price;          // Price for 1 OurTkn
        uint256 id;             // Placeholder to read lastPrice()
        uint256 cost;           // Price for _amount our token
        uint256 fee;            // 0.2% of cost
        (id, price) = lastPrice();
        cost = _amount.mul(price);
        cost = cost.div(1e18);
        fee = cost.div(500);
        PayCoin(_PayTknAddress).mint(msg.sender, cost-fee);
        ERC20Challenge(_OurTokenAddress).burnFrom(msg.sender, _amount);
        emit Sell(msg.sender, _amount, cost-fee);
        return true;
    }

    function getHour() internal returns (uint256){
        uint256 time = block.timestamp;
        time = time.add(2 hours);           // 1 ora per fuso orario e 1 per ora legale
        time = time.mod(1 days);            // Secondi da mezzanotte
        return time.div(1 hours);           // Divido per secondi in un'ora e prendo parte intera
    }

    function setOpening(uint start) external isTeam{
      _open=start;
      emit ChangeStart(msg.sender, start);
    }

    function setEnding(uint stop) external isTeam{
      _end=stop;
      emit ChangeEnd(msg.sender, stop);
    }

    function setPayTknAddress(address PayTknAddress) external isTeam returns(bool){
        _PayTknAddress = PayTknAddress;
    }

    function setOurTknAddress(address OurTokenAddress) external isTeam returns(bool){
        _OurTokenAddress = OurTokenAddress;
    }
    
	function lastPrice() public view returns (uint256, uint256) {
		uint256 last_price_id = prices.length;
		uint256 last_price = prices[last_price_id - 1];
		return (last_price_id, last_price);
	}

	function getHistory(uint256 price_id) external view returns (uint256) {
		require(price_id <= prices.length, "This price id does not exist.");
		return prices[price_id - 1];
	}

	function setPrice(uint256 price_id, uint256 price) public isTeam returns (bool) {
		prices[price_id - 1] = price;
		return true;
	}

	// Input: new price
	// Output: new price id
	function addPrice(uint256 new_price) public isTeam returns (uint256) {
		if (msg.sender == _ChallengeContractAddress) {
            uint256 old_price = prices[prices.length - 1];
			require(10*new_price<=10*old_price+old_price && 10*new_price>=10*old_price-old_price,"Challenge contract cannot change the price more than 10%");
			require(count < 4, "Challenge contract cannot call addPrice function more than 4 times!");
			count += 1;
			_addPrice(new_price);
		} else {
			uint256 hour = getHour();
			require(hour >= 9 && hour < 18, "You can add a price only between 9am and 6pm.");
			_addPrice(new_price);
			emit PriceChange(msg.sender, new_price, prices.length);
		}
		return prices.length;		
	}
	
    function massiveLoadPrice(uint256 price1, uint256 price2, uint256 price3, uint256 price4, uint256 price5, uint256 price6, uint256 price7, uint256 price8, uint256 price9, uint256 price10) external isTeam {
        _addPrice(price1);
		emit PriceChange(msg.sender, price1, prices.length);
        _addPrice(price2);
		emit PriceChange(msg.sender, price2, prices.length);
        _addPrice(price3);
		emit PriceChange(msg.sender, price3, prices.length);
        _addPrice(price4);
		emit PriceChange(msg.sender, price4, prices.length);
        _addPrice(price5);
		emit PriceChange(msg.sender, price5, prices.length);
        _addPrice(price6);
		emit PriceChange(msg.sender, price6, prices.length);
        _addPrice(price7);
		emit PriceChange(msg.sender, price7, prices.length);
        _addPrice(price8);
		emit PriceChange(msg.sender, price8, prices.length);
        _addPrice(price9);
		emit PriceChange(msg.sender, price9, prices.length);
        _addPrice(price10);
		emit PriceChange(msg.sender, price10, prices.length);
    }

    // Internal Functions
	function _addPrice(uint256 new_price) internal returns (bool) {
		prices.push(new_price);
		return true;
	}

    // Modifiers
    modifier isOpen() {
        require(block.timestamp>_open && block.timestamp<_end, "Market is not open! (Wrong day)"); 
        uint256 hour = getHour();
        require(hour >= 9 && hour<18, "Market is not open! (Wrong hour)");
        _;
    }

}
