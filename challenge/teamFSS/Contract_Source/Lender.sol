pragma solidity ^0.5.0;

import "./PayCoin.sol";
import "../interfaces/IT_PayCoin.sol"; 
import "./AdminRole.sol"; 

contract Lender is AdminRole {
    using SafeMath for uint256; 

    IT_PayCoin payCoin;

    mapping (address=>uint256) _loan;
    mapping (address=>uint256) _debt;
    // add mapping to keep trace of block.number when loan is open
    mapping (uint256=>uint256) _blockNumber; 

    uint256[] _id_loan; 
    uint256 private _maxLoan = 250000; 
    //uint256 private _exp = 10**(uint256(payCoin.decimals()));
     

    event OpenLoan(address indexed who, uint256 indexed amount, uint256 indexed id_loan); 
    event CloseLoan(address indexed who, uint256 indexed id_loan); 

    constructor (address payCoinAddress) public {
        payCoin = IT_PayCoin(payCoinAddress); 
    }

    function openLoan(uint256 amount) external returns(uint256) {
        uint256 _id ; 
        require(_loan[msg.sender].add(amount) <= _maxLoan.mul(10**(uint256(payCoin.decimals()))), "Can't loan more than 250k totally."); 

        payCoin.mint(msg.sender, amount); 

        _loan[msg.sender] = _loan[msg.sender].add(amount); 
        _debt[msg.sender] = _debt[msg.sender].add(amount); 
        
        _id = _id_loan.push(amount).sub(1); 
        _blockNumber[_id] = block.number; 

        emit OpenLoan(msg.sender, amount, _id);  

        return _id; 
    }

    function closeLoan(uint256 id_loan) external {
        uint256 amount = _id_loan[id_loan]; 

        payCoin.burnFrom(msg.sender, amount.add(getFee(amount, id_loan))); 
        _debt[msg.sender] = _debt[msg.sender].sub(amount); 

        emit CloseLoan(msg.sender, id_loan); 
    }

    function loanStatus(uint256 id_loan) external view returns(uint256, uint256){
        return(_id_loan[id_loan], getFee(_id_loan[id_loan], id_loan)); 
    }

    function penalty(address teamAddress) onlyAdmin external returns(uint256) {
        //require(now >= "18 dell'ultimo giorno");
        payCoin.burnFrom(teamAddress, _debt[teamAddress].mul(15).div(10)); 
        return _debt[teamAddress].mul(15).div(10); 
    }

    function getFee(uint256 amount, uint256 id_loan) internal view returns(uint256) {
        return amount.div(10).mul(block.number.sub(_blockNumber[id_loan])).div(500); 
    }
    
}