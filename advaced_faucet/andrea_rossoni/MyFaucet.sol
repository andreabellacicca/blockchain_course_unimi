pragma solidity ^0.5.17;

contract MyFaucet{

    uint256 internal wdMaxAmount = 1000000000;
    uint256 internal walletCount = 0;
    address internal Owner = msg.sender;
    mapping (uint256 => address) internal walletIndex;
    mapping (address => bool) internal walletEnabled;
    mapping (address => uint256) internal walletOutBalance;

    function resetWalletOutBalance() external {
          require(msg.sender == Owner, "ERR: Your are not the owner of the contract!");
          for (uint256 i=0; i < walletCount; ++i) {
                walletOutBalance[walletIndex[i]] = 0;
          }
    }

    function backCoinsToOwner() external {
          require(msg.sender == Owner, "ERR: Your are not the owner of the contract!");
          selfdestruct(msg.sender);
    }

    function enableWallet(address _wallet) external {
          require(msg.sender == Owner, "ERR: Your are not the owner of the contract!");
          walletEnabled[_wallet] = true;
          walletIndex[walletCount] = _wallet;
          walletCount += 1;
    }

    function getCoins(uint256 _amount) external {
        require(walletEnabled[msg.sender], "ERR: Your address has not been enabled for this Faucet, contact owner");
        require((walletOutBalance[msg.sender] + _amount) < wdMaxAmount, "ERR: Your balance is insufficient for this amount, check it please");
        walletOutBalance[msg.sender] += _amount;
        msg.sender.transfer(_amount);
    }

    function getBalance(address _wallet) external view returns(uint256) {
      	require(walletEnabled[msg.sender], "ERR: Your address has not been enabled for this Faucet, contact owner");
        require(walletEnabled[_wallet], "ERR: The address you are searching has not been enabled for this Faucet, contact owner");
        return wdMaxAmount - walletOutBalance[_wallet];
    }

    function () external payable {
        require(msg.sender == Owner, "ERR: Your are not the owner of the contract!");
    }
}
