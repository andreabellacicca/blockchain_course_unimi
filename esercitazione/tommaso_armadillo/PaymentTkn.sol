pragma solidity ^0.6.4;

/*
*   Importing interface for ERC20 Token
*   Importing library for roles
*   Importing safe math library
*/
import "./MyToken.sol";
import "zeppelin/contracts/access/AccessControl.sol";
import "zeppelin/contracts/math/SafeMath.sol";

// direi che funziona tutto abbastanza bene implementare safe math


contract PayTkn is AccessControl {
    using SafeMath for uint256;

    bytes32 public constant PRICER_ROLE = keccak256("PRICER_ROLE");
    bytes32 public constant SETBENEFICIARY_ROLE = keccak256("SETBENEFICIARY_ROLE");

    uint256 private price = 1e18;           // Wei for 1 token (1e18) => if price=1e18 then 1 token = 1 ether
    uint256 private maxTkn = 100*1e18;      // Max number of token one can purchase in one time

    mapping(address => uint256) lastCall;   // Mapping for preventing user to buy tokens once in 5 minutes

    address _tokenAddress;
    address payable _beneficiary;

    event buyTknEvent (address indexed to, uint256 amount);

    constructor(address pricer, address setBeneficiary, address tokenAddress, address payable beneficiaryAddress) public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PRICER_ROLE, pricer);
        _setupRole(SETBENEFICIARY_ROLE, setBeneficiary);
        _tokenAddress = tokenAddress;
        _beneficiary = beneficiaryAddress;
    }

    function buyTkn (uint256 amount) public payable returns (bool){
        require (getFee(amount) <= msg.value, "You're not sending enough money");
        _buyTkn(amount, msg.sender);
        return true;
    }

    // Buying the more tokens I can
    function buyTkn () public payable returns (bool){
        // (amount / price) * 1e18 + amount % price;
        uint256 amount = msg.value.div(price);
        amount = amount.mul(1e18);
        amount = amount.add(msg.value.mod(price));
        _buyTkn(amount, msg.sender);
        return true;
    }

    function _buyTkn (uint256 amount, address to) internal returns (bool){
        require(lastCall[to] + 5 minutes <= now, "You can buy token once in 5 minutes");
        require(amount < maxTkn, "You are trying to buy too many tokens");
        uint256 priceForAmount = getFee(amount);
        MyTkn(_tokenAddress).mint(to, amount);
        lastCall[to] = now;
        _beneficiary.transfer(priceForAmount);
        msg.sender.transfer(msg.value - priceForAmount);
        emit buyTknEvent(to, amount);
        return true;
    }

    // Input the number of token you want to buy
    // Returns the cost in Wei for 'amount' of tokens
    function getFee (uint256 amount) public view returns (uint256){
        uint256 tmp = amount.mul(price);
        return tmp.div(1e18);
    }

    function setToken (address newTokenAdd) external isAdmin returns (bool){
        _tokenAddress = newTokenAdd;
        return true;
    }

    function setBeneficiary (address payable newBeneficiary) external isSetBeneficiary returns (bool){
        _beneficiary = newBeneficiary;
        return true;
    }

    function setPrice (uint256 newPrice) external isPricer returns (bool){
        price = newPrice;
        return true;
    }

    modifier isPricer () {
        require(hasRole(PRICER_ROLE, msg.sender), "Caller is not a pricer");
        _;
    }

    modifier isSetBeneficiary () {
        require(hasRole(SETBENEFICIARY_ROLE, msg.sender), "Caller is not the correct privilege");
        _;
    }

    modifier isAdmin () {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a admin");
        _;
    }
}