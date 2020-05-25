pragma solidity ^0.5.0;

import "./OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20Detailed.sol";
import "./myERC20Burnable.sol";
import "./OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20Mintable.sol";
import "./OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20Capped.sol";

contract myERC20 is ERC20, ERC20Detailed, myERC20Burnable, ERC20Mintable, ERC20Capped {
	constructor() public ERC20Detailed("Sofia", "SFO", 18) ERC20Capped(10000) {}
}
