const Web3 = require("web3");
const web3 = new Web3('http://127.0.0.1:8545');

contract("NFTMarket", accounts => {;
  let nftMarketContract;
  let NFTMarketAddress;
  let listingValue;
  let sellingPrice;
  let senderAddress = '0x72A53cDBBcc1b9efa39c834A540550e23463AAcB';

  beforeEach(async () => {
    const NFTMarket = await artifacts.require("NFTMarketplace");
    nftMarketContract = await NFTMarket.new();
    NFTMarketAddress = nftMarketContract.address;
  });

  it("Should Load Contract", async () => {
    await nftMarketContract;
  });

  it("Should pass all tests", async () => {
    listingValue = Web3.utils.toWei('0.025', 'ether');
    sellingPrice = Web3.utils.toWei('1', 'ether');
    //console.log(nftMarketContract);
    await nftMarketContract.createToken("token1",1,{from:senderAddress, value:listingValue});
    // await nftMarketContract.createToken("token2",1,{value:listingValue});
    // await nftMarketContract.createToken("token3",1,{value:listingValue});
    // await nftMarketContract.createToken("token4",1,{value:listingValue});
    // console.log("----------------------------------------TOKEN MINTED SUCESSFULLY--------------------------------------");
    // await nftMarketContract.createMarketSale(1,{value:sellingPrice});
    // console.log("----------------------------------------TOKEN SOLD SUCESSFULLY----------------------------------------");
    // await nftMarketContract.getItemListed();
    // console.log("----------------------------------------LOADED LISTED ITEMS SUCESSFULLY-------------------------------");
    //await nftMarketContract.getMyNFT();
    // console.log("----------------------------------------LOADED CALLERS ALL NFTS---------------------------------------");
    // await nftMarketContract.getMarketItems();
    // console.log("----------------------------------------LOADED ALL UNSOLD MARKET ITEMS--------------------------------");
    console.log(await nftMarketContract.tokenURI(1));
    // console.log("----------------------------------------URI OF TOKEN LOADED-------------------------------------------");
  });
});
