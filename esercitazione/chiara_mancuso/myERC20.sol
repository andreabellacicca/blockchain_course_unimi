pragma solidity ^0.5.0;

import "./contracts/GSN/Context.sol";
//import "./contracts/token/ERC20/IERC20.sol";
import "./contracts/math/SafeMath.sol";
import "./contracts/access/roles/BurnerRole.sol";
import "./contracts/token/ERC20/ERC20Detailed.sol";
import "./contracts/token/ERC20/ERC20Burnable.sol";
import "./contracts/token/ERC20/ERC20Mintable.sol";

contract myERC20 is ERC20Detailed, ERC20Mintable, ERC20Burnable, BurnerRole {
    using SafeMath for uint256;

    constructor() public ERC20Detailed("ChiaraBankCoin", "CBC", 18){
        _mint(_msgSender(), 10000 * (10 ** uint256(decimals())));
    }

/*
    addMinter();
    addMinter();


    addBurner();
    addBurner();
*/
}
