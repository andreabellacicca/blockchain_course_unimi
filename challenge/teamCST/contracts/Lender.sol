pragma solidity ^0.5.0;

import "./TeamRole.sol";
import "./PayCoin.sol";
import "openzeppelin/contracts/math/SafeMath.sol";

contract Lender {
      // Libraries
      using SafeMath for uint256;

      // Variables
      address _PayCoinAddress;
      uint256 _id_loan = 0; 
      mapping (uint256 => uint256) loan;                    // loan[id] = amount
      mapping (uint256 => address) creator;                 // creator[id] = amount
      mapping (uint256 => bool) private _activeLoan;        // _activeLoan[id] = true/false
      mapping (uint256 => uint256) private _nBlock;         // _nBlock[id] = blockNumberOfCreation
      mapping (address => uint256) fund;                    // fund[address] = totalLoanAssociatedToAddress

      // Events
      event OpenLoan(address indexed who, uint256 indexed amount);
      event CloseLoan(address indexed who);

      // Constructor
      constructor (address PayCoinAddress) public {
            _PayCoinAddress = PayCoinAddress;
      }

      // Functions
      function openLoan(uint256 _amount) external returns(uint256){
            require(fund[msg.sender]+_amount <= 250000e18, 'You are exceeding the maximum lending amount');
            fund[msg.sender] = fund[msg.sender].add(_amount);
            loan[_id_loan] = _amount;
            _activeLoan[_id_loan] = true;
            _nBlock[_id_loan] = block.number;
            creator[_id_loan] = msg.sender;
            _id_loan = _id_loan.add(1);
            PayCoin(_PayCoinAddress).mint(msg.sender, _amount);
            emit OpenLoan(msg.sender, _amount);
            return _id_loan-1;
      }

      function closeLoan(uint256 id_loan) external{
            require(_activeLoan[id_loan], 'No existing loan with this ID or closed loan');
            require(creator[id_loan] == msg.sender, "You aren't the creator of the loan");
            _activeLoan[id_loan] = false;
            fund[msg.sender] = fund[msg.sender].sub(loan[id_loan]);
            uint256 groupBlocks = (block.number.sub(_nBlock[id_loan])).div(500);          //How many groups of 500 blocks have passed?
            uint256 fee_to_pay = loan[id_loan].div(1000);                                 //How much is 0.1% of the loan
            fee_to_pay = fee_to_pay.mul(groupBlocks);                                     //Add 0.1% for every block of 500 blocks
            uint256 total = loan[id_loan].add(fee_to_pay);
            PayCoin(_PayCoinAddress).burnFrom(msg.sender, total);
            emit CloseLoan(msg.sender);
      }

      function loanStatus(uint256 id_loan) view external returns(uint256, uint256){
            require(_activeLoan[id_loan], 'No existing loan with this ID or closed loan');
            uint256 groupBlocks = (block.number.sub(_nBlock[id_loan])).div(500);          //How many blocks of 500 blocks have passed?
            uint256 fee_to_pay = loan[id_loan].div(1000);                                 //How much is 0.1% of the loan
            fee_to_pay = fee_to_pay.mul(groupBlocks);                                     //Add 0.1% for every block of 500 blocks
            return (loan[id_loan], fee_to_pay);
      }

      function score() external view returns(int256){
          uint256 temp = fund[msg.sender].mul(3);
          return -int(temp.div(2));
      }
}
