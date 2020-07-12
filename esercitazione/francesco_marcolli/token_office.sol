pragma solidity ^0.5.0;

import "../build/interfaces/IT_ERC20.sol";
import "./token_erc20.sol";
import "./BrokerRole.sol";
import "./AdminRole.sol";

contract token_office is BrokerRole, AdminRole {
    using SafeMath for uint256;

    IT_ERC20 public token;
    uint256 private max_amount_token;
    uint256 private tk_price;
    address payable _tokenBeneficiary;

    mapping (address => uint256) lastCall;

    event Bought(address indexed recipient, uint256 indexed amount);
    event SentToBeneficiary(address indexed benificiary, uint256 indexed amount);

    constructor(address payable tokenBeneficiary) public {
        token = new token_erc20();
        _tokenBeneficiary = tokenBeneficiary;
        max_amount_token = 1000e18 ;
        tk_price = 1 wei;
    }

    function buy() payable public returns (bool){
        uint256 tokenAmount;

        require(msg.value > 0, "You have to pay, my friend");

        tokenAmount = msg.value.mul(10**uint256(token.decimals()));
        tokenAmount = tokenAmount.div(tk_price);
        tokenAmount = tokenAmount.add(msg.value.mod(tk_price));

        _buy(_msgSender(), tokenAmount);

        return true;
    }

    function buy(uint256 tokenAmount) payable public returns (bool){

        require(msg.value > 0, "You have to pay, my friend");
        require(msg.value == getFee(tokenAmount), "That's not enough money!");

        _buy(_msgSender(), tokenAmount.mul(10**uint256(token.decimals())));

        return true;
    }

    function _buy(address recipient, uint256 amount) internal {
        uint256 currentTime = now;

        require(currentTime.sub(lastCall[recipient]) > 30 seconds, "You have to wait, my friend");
        require(amount <= max_amount_token, "Can't erogate this much token");
        
        token.mint(recipient, amount);
        _withdraw();

        lastCall[recipient] = currentTime ;

        emit Bought(recipient, amount);
    }

    function getFee(uint256 amount) public view returns (uint256){
        uint256 exp = uint256(token.decimals());
        return amount.mul(10**exp).mul(tk_price).div(10**exp);
    }

    function set_tk_price(uint256 new_value) public onlyBroker {
        tk_price = new_value;
    }

    function set_beneficiary(address payable new_beneficiary) public onlyAdmin{
        _tokenBeneficiary = new_beneficiary;
    }

    function _withdraw() internal {
        _tokenBeneficiary.transfer(address(this).balance);
        emit SentToBeneficiary(_tokenBeneficiary, address(this).balance);
    }

}
