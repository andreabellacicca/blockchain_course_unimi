pragma solidity ^0.5.0;

import "openzeppelin/contracts/GSN/Context.sol";
//import "./contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/math/SafeMath.sol";
import "openzeppelin/contracts/access/roles/BurnerRole.sol";
import "openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";

contract PayCoin is ERC20Detailed, ERC20Mintable, ERC20Burnable, BurnerRole {
    using SafeMath for uint256;

    constructor() public ERC20Detailed("Paycoin", "PaC", 18){
    }
}
