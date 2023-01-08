const { result } = require("lodash")
const BN = require("bignumber.js")

require("chai").use(require("chai-as-promised")).should()

// get token 
const Escrow = artifacts.require("./Escrow")
const Token = artifacts.require("./Erc20")
const Nft = artifacts.require("./Erc721")

//decimal places
const tokens = (n) => { return new BN(n * 10 ** 18)}

//rejections
const EVM_REVERT = "VM Exception while processing transaction: revert"
const reject = "ERC20: transfer amount exceeds balance"

contract("Escrow", ([witness, escrow, seller, buyer]) => {
    let token
    let escrow
    let nft
    let reqAsset
    let reqAmount
    let reqNft
    let tokenId
    let buyer
    let seller

    beforeEach(async () => {
        token = await Token.new()
        escrow = await Escrow.new()
        nft = await Nft.new()
        await escrow.setDeal(reqAsset, reqAmount, reqNft, tokenId, buyer, seller)
    })


    describe("deal", () => {

        it("checks setDeal", async () => {

            let result

            result = await escrow.seller()
            result.should.equal(seller.toString())

            result = await escrow.tokenId()
            result.should.equal(tokenId.toString())
            
            result = await escrow.buyer()
            result.should.equal(buyer.toString())

            result = await escrow.reqAsset()
            result.should.equal(reqAsset.toString())

            result = await escrow.reqAmount()
            result.should.equal(reqAmount.toString())

            result = await escrow.reqNft()
            result.should.equal(reqNft.toString())

        })
    })
    describe("deposits", async () => {

        beforeEach(async () => {
            let reqAsset
            let reqAmount
            let reqNft
            let tokenId
            let buyer
            let seller

            await escrow.setDeal(reqAsset, reqAmount, reqNft, tokenId, buyer, seller);
        })
        
        describe("success", async () =>{

            it("checks token deposit")


        })
        
    })
    

})