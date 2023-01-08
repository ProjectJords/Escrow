/*
This is the NFT for the lease agreement.
This NFT will be a nested NFT to:
    [] Hold the lease documentation
    [] Facilitate funds transfers from leasee to property owner
*/

pragma solidity ^0.8.1;

import "./Escrow.sol";
import "./ERC721";
import "./SafeMath.sol";
import "./Owner.sol";

contract Payment_Facility is ERC721 {

    address public paymentAsset; //asset for payment
    uint256 public monthlyRent; //monthly rate
    uint256 public rentDeposit; //lease deposit
    uint256 public leaseTerm; //number of months to be leased

    uint256 public leaseStart; //lease start date
    uint256 public leaseEnd; //lease end date

    uint256 public totalAmountPaid; // total amount paid
    uint256 public amountRemaining; // amount remaining based on current monthly rent
    uint256 public amountOwed; // how much is owed if bill is not paid
    uint256 public monthsRemaining; // months remaining in lease term

    address public propertyOwner; // address of the property owner
    address public leasee; // address of the leasee

    uint256 public feePercent; // fee percentage taken
    address public feeAccount; // account to receive fees
    bool public firstPaymentMade; //stores first payment


    constructor(uint256 setDeposit, uint256 setMonthlyRent, address setPaymentAsset, uint256 setLeaseTerm) {
        rentDeposit = setDeposit;
        monthlyRent = setMonthlyRent;
        paymentAsset = setPaymentAsset;
        leaseTerm = setLeaseTerm;
        monthsRemaining = leaseTerm;
        feeAccount = msg.sender;
        firstPaymentMade = false;
    }

    function changeMonthlyRent (uint256 _newRent) external {
        require(msg.sender == propertyOwner);
        monthlyRent = _newRent;
    }

    function changeFeeAccount (address _newFeeAccount) external onlyOwner{
        feeAccount = _newFeeAccount;
    }

    function changeRentDeposit(uint256 _newDeposit) external {
        require(msg.sender == propertyOwner);
        rentDeposit = newDeposit;
    }

    // for depositing lease document nfts
    function depositLeaseDocuments(address _leaseDocument, uint256 _tokenId) external {
        IERC721 token = IERC721 (_leaseDocument);
        token.safeTransferFrom(msg.sender, address(this), _tokenId);
        propertyOwner = msg.sender;
    }

    function amountPaid() view external return(uint memory) {
        return(totalAmountPaid);
    }

    function manualPayment (uint256 _amount) external return(string memory){
        require(_amount == monthlyRent && monthsRemaining > 0);
        require(firstPaymentMade == true);
        ERC20 token = ERC20(paymentAsset);
        token.approve(address(this), _amount);
        token.transferFrom(msg.sender, owner, _amount);
        monthsRemaining = monthsRemaining - 1;
        totalAmountPaid = totalAmountPaid + _amount;
        return("Thanks you for your payment. There are " + monthsRemaining + "months to be paid on the lease.");   
        
    }

    // assumes the last months rent is the deposit
    function firstPayment(uint _amount) external returns(string memory){
        require(_amount >= monthlyRent);
        require(firstPaymentMade == false);
        ERC20 token = ERC20(paymentAsset);

        if (_amount = monthlyRent + rentDeposit) {

            token.approve(address(this), _amount);
            token.transferFrom(msg.sender, propertyOwner, _amount);
            monthsRemaining = monthsRemaining - 2;
            totalAmountPaid = totalAmountPaid + _amount;
            return("Your first payment plus deposit has been made");

        } else if (_amount != monthlyRent + rentDeposit) {
            monthsRemaining = monthsRemaining - 1;
        }
    }


    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function _finalMonth() internal {
        if(rentDepositPaid == true ){

        }
    }
}