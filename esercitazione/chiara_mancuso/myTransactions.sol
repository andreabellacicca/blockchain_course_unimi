pragma solidity ^0.5.0;

import "./myERC20.sol";
import "./contracts/token/ERC20/ERC20.sol";
import "./contracts/access/roles/PricerRole.sol";
import "./contracts/access/roles/AdminRole.sol";
import "./contracts/token/ERC20/TokenTimelock.sol";

contract myTransactions is myERC20, PriceMakerRole, AdminSetterRole {

  event Transaction(address indexed account, uint256 indexed nToken);
  uint256 public PriceTkn;
  address public tokenContract;
  uint256 public totSupply;
  address private _creator;
  uint256 public timeLimit = 5 minutes;

  mapping(address => uint256) transactionTime;

  function initContract(address addrContract, uint256 _priceTkn, uint256 initSupply) public {
    tokenContract = addrContract;
    PriceTkn = _priceTkn;
    totSupply = initSupply;
  }

  function SetAdminAddress(address admin) public {
    require(isAdminSetter(_msgSender()), 'Indirizzo non abilitato');
    _creator = admin;
  }

  function buyTkns(uint256 amount) external payable {
    uint256 money = amount*priceTkn()/10**uint256(decimals());
    _buyTkns(money, _msgSender());
  }

  function _buyTkns(uint256 amount, address payable account) internal {
    require(transactionTime[account] + 5 minutes <= now, "Transazioni possibili ogni 5 minuti");
    require(amount < balanceOf(account), 'Non hai abbastanza credito per effettuare la transazione');
    require(amount > 0);
    transferFrom(account, _creator, msg.value);
    uint256 nTkn = amount*(10**uint256(decimals()))/(priceTkn());
    uint256 resto = amount%priceTkn();
    require (nTkn <= 20, 'Compravendita concessa solo per una quantità inferiore a 20 CBC');
    totSupply = totSupply - nTkn;
    transfer(_msgSender(), nTkn);
    transfer(_msgSender(), resto);
    transactionTime[msg.sender] = now;

    emit Transaction(_msgSender(), nTkn);
  }

  function buyTkns() external payable {
    _buyTkns(msg.value, _msgSender());
  }

  function priceTkn() public view returns(uint256){
    return PriceTkn;
  }

  function SetPriceTkn(uint256 value) public {
    require(isPriceMaker(_msgSender()), 'Indirizzo non abilitato');
    PriceTkn = value;
  }

  function getFee(uint256 amount) public view returns(uint256){
    return amount*priceTkn()/10**uint256(decimals());
  }

}
