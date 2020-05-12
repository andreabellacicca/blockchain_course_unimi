pragma solidity ^0.5.0;

contract FaucetAdv{

  address payable owner = msg.sender;

    mapping(address => uint256) internal balance; //Bilancio di ciascun conto

    event Refilled(address indexed owner, address indexed recipient, uint256 amount);
    event Withdraw(address indexed recipient, uint256 amount);

  function ricaricaSmartC(address account, uint256 paySM) payable public {
    require(msg.sender != owner, 'Errore account');

   balance[account]= balance[account] + msg.value;
} //Solo io posso ricaricare lo smart contract


    function balanceOf(address account) external view returns (uint256){
        return balance[account];
    }


  function withdraw(uint withdraw_amount)public{
    require(withdraw_amount<= 100000000000000000);
    require (balance[msg.sender]>= withdraw_amount, "Non hai abbastanza soldi per ritirare!");
    balance[msg.sender] = balance[msg.sender] - withdraw_amount;
    msg.sender.transfer(withdraw_amount);
    }

}
