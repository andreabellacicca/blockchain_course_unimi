
pragma solidity ^0.5.0;

contract faucetadvance {

    // contract constructor: set owner
    address owner;

    constructor() public {
            owner = msg.sender;
    }


     modifier onlyOwner {
            require(msg.sender == owner);
             _;
     }
    mapping(address => uint256) internal balance;
    uint256 private max_withdraw = 100000000000000000;

    event Refilled(address indexed owner, address indexed recipient, uint256 amount);
    event Withdraw(address indexed recipient, uint256 amount);

    function withdraw(uint withdraw_amount) public {
        require(withdraw_amount <= max_withdraw);
        require(balance[msg.sender] >= withdraw_amount, "Not enough credit");
        balance[msg.sender] = balance[msg.sender] - withdraw_amount;
        msg.sender.transfer(withdraw_amount);
        emit Withdraw(msg.sender, withdraw_amount);
    }

    function refill(address account) external payable onlyOwner returns(bool){
        require(msg.value > 0, "Please insert amount to recharge");
        balance[account] = balance[account] + msg.value;
        emit Refilled(msg.sender, account, msg.value);
        return true;
    }

    function available(address account) external view returns (uint256){
        return balance[account];
    }

    function () external payable {}


}



