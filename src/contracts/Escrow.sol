pragma solidity ^0.8.1;

//import ERC20
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

//import ERC721
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

//import IERC721Receiver
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";

contract Escrow {

    address private seller;
    address private witness;
    address private buyer;

    address public reqAsset;
    uint256 public reqAmount;
    address public reqNft; 
    uint256 public reqTokenId;

    address private depositAsset;
    uint256 private depositAmount;
    address private depositNft;
    uint256 private depositTokenId;

    bool private approved;

    constructor () {
        witness = msg.sender; //msg.sender/owner is the default witness
        approved = false;
    }

    // Witness sets the terms of the deal
    function setDeal(address _reqAsset, uint256 _reqAmount, address _reqNft, uint256 _tokenId, address _buyer, address _seller) public {
        require(msg.sender == witness);

        reqAmount = _reqAmount;
        reqAsset = _reqAsset;
        reqNft = _reqNft;
        buyer = _buyer;
        seller = _seller;
        reqTokenId = _tokenId;
    }

    // Changes the witness
    function changeWitness (address _newWitness) external {
        require(msg.sender == witness);
        witness = _newWitness;
    }

    // Views status of asset deposit
    function checkDeposit() view public returns(string memory){
        if(reqAmount <= depositAmount && reqAsset == depositAsset){
            return("Specified asset & amount has been deposited");
        } else {
            return("Specified asset & amount has not been deposited");
        }
    }

    // Views status of NFT deposit
    function checkNft() view public returns(string memory){
        if (reqNft == depositNft && reqTokenId == depositTokenId) {
            return("Specified NFT has been deposited");
        } else {
            return("Specified NFT has not been deposited");
        }
    }
    
    // buyer deposit erc20 tokens
    function depositToken (uint256 _amount, address _token) external returns(string memory){
        
        if (_token == reqAsset){
            IERC20 token = IERC20(_token);
            token.approve(address(this), _amount);
            token.transferFrom(msg.sender, address(this), _amount);

            depositAmount = token.balanceOf(address(this));
            depositAsset = _token;

            return("Deposit received.");

        } else {
            return("Not the requested deposit asset.");
        }
    }
/*
    // Sender deposit Eth
    function depositEth (uint256 _amount) external payable {
        require(msg.value == _amount);
    }
*/
    // Sender desposit NFT
    function deposit_Nft (address _token, uint256 _tokenId) external {

        if (_token == reqNft && _tokenId == reqTokenId) {
        IERC721 nft = IERC721(_token);
        nft.approve(address(this), _tokenId);
        nft.safeTransferFrom(msg.sender, address(this), _tokenId); //not sure if this is correct

        depositNft = _token;
        depositTokenId = _tokenId;

        }
    }

    // checks the requirements and transfers assets to respective parties
    function completeDeal () external returns(string memory){
        require(msg.sender == witness);
        _witnessApprove();
        uint256 remaining;

        if(approved == true) {
            IERC20 token = IERC20(reqAsset);
            token.transfer(seller, reqAmount);

            IERC721 nft = IERC721(reqNft);
            nft.safeTransferFrom(address(this), buyer, reqTokenId);

            //refunds remaining to buyer
            if (token.balanceOf(address(this)) > 0) {
                remaining = token.balanceOf(address(this)) - reqAmount;
                token.transfer(buyer, remaining);
            }

            return("Deal complete");

        } else {
            return("Deal has not been approved");
        }
    }

    // Withdraw tokens to seller incase the buyer backs out of the deal
    function refundToken (uint256 _amount, address _token) external {
        require(msg.sender == buyer || msg.sender == witness);
        IERC20 token = IERC20(_token);
        token.transfer(buyer, _amount);
    }

    //refunds nft by call from seller or witness
    function refundNFT (address _token, uint256 _tokenId) external {
        require(msg.sender == seller || msg.sender == witness);
        IERC721 token = IERC721(_token);
        token.safeTransferFrom(address(this), seller, _tokenId);
    }

    //refunds all assets to senders
    function refundAll (address _token, address _nft, uint256 _tokenId) external {
        require(msg.sender == witness);

        uint256 balance;

        IERC20 token = IERC20(_token);
        balance = token.balanceOf(address(this));
        token.transfer(buyer, balance);

        IERC721 nft = IERC721(_nft);
        nft.safeTransferFrom(address(this), seller, _tokenId);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    // Witness approval of transaction
    function _witnessApprove() internal {

        bool buyerSide;
        bool sellerSide;

        if (reqAmount <= depositAmount && reqAsset == depositAsset) {
            buyerSide = true;
        }

        if (reqNft == depositNft && reqTokenId == depositTokenId) {
            sellerSide = true;
        }

        if (buyerSide == true && sellerSide == true) {
            approved = true;
        }
    }
}

/*

single address sender escrow contract

for now this contract will only accept wrapped ether

[x] token deposit
[x] nft deposit
[x] token withdraw
[x] nft withdraw
[x] witness approve
[x] refund all

*/