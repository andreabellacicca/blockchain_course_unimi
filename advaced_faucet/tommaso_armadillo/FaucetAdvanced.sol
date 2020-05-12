pragma solidity ^0.6.4;

contract FaucetAdvanced {
    
    address payable internal owner = 0x14717ce5451f03aD40535dcbCa1E75FA1c471B96;

    mapping(address => uint256) internal balance;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    //function to know the credit of account
    function balanceOf (address account) external view returns (uint256){
        return balance[account];
    }

    //function to withdraw amount from my balance
    function withdraw (uint256 amount) external returns (bool) {
        require(amount <= balance[msg.sender], 'Insufficient founds');
        msg.sender.transfer(amount);
        balance[msg.sender] = balance[msg.sender] - amount;
        emit Withdraw(msg.sender, amount);
        return true;
    }

    function deposit (address account) external payable returns(bool){
        require(msg.sender == owner, "Only the contract owner can recharge it");
        balance[account] = balance[account] + msg.value;
        emit Deposit(account, msg.value);
        return true;
    }

}




