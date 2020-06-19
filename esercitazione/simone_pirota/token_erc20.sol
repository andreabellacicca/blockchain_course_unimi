pragma solidity ^0.5.0;

import "../build/interfaces/IT_ERC20.sol";
import "./zeppelin/GSN/Context.sol";
import "./zeppelin/token/ERC20/ERC20.sol";
import "./zeppelin/token/ERC20/ERC20Detailed.sol";
import "./zeppelin/token/ERC20/ERC20Burnable.sol";
import "./zeppelin/token/ERC20/ERC20Mintable.sol";
import "./BurnerRole.sol";


contract token_erc20 is Context, IT_ERC20, ERC20, ERC20Detailed, ERC20Burnable, ERC20Mintable, BurnerRole{
    //function token_erc20(){}
    //Constructor meant to be called on deploy
    constructor () public ERC20Detailed("PyrosCoin", "PCO", 18){
        //_mint(_msgSender(), 10000 * (10 ** uint256(decimals())));
    }

    function burn(uint256 amount) public onlyBurner {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public onlyBurner{
        super.burnFrom(account, amount);
    }

}
