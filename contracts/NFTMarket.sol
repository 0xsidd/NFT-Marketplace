// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether;
    address payable owner;

    mapping(uint256 => MarketItem) private idToMarketItem;

    struct MarketItem {
      uint256 tokenId;
      address payable seller;
      address payable owner;
      uint256 price;
      bool sold;
    }

    event MarketItemCreated (
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price,
      bool sold
    );

    constructor() ERC721("MilkyWay Token", "MT") {
      owner = payable(msg.sender);
    }

    /* Updates the listing price of the contract */
    function updateListingPrice(uint _listingPrice) public payable {
      require(owner == msg.sender, "Only marketplace owner can update listing price.");
      listingPrice = _listingPrice;
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
      return listingPrice;
    }

    /* Mints a token and lists it in the marketplace */
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
      // require(msg.value>=listingPrice,"Listingprice Criteria Not Satisfied");
      _tokenIds.increment();
      uint256 newTokenId = _tokenIds.current();
      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenURI);
      createMarketItem(newTokenId, price);
      return newTokenId;
    }

    function createMarketItem(
      uint256 tokenId,
      uint256 price
    ) private {
      require(price > 0, "Price must be at least 1 wei");
      require(msg.value >= listingPrice, "Price must be equal to listing price");

      idToMarketItem[tokenId] =  MarketItem(
        tokenId,
        payable(msg.sender),
        payable(address(this)),
        price*(1 ether),
        false
      );

      _transfer(msg.sender, address(this), tokenId);
      emit MarketItemCreated(
        tokenId,
        msg.sender,
        address(this),
        price,
        false
      );
    }

    function createMarketSale(uint256 _tokenId)public payable{
      require(msg.value>=idToMarketItem[_tokenId].price,"Token Selling Price Criteria Is Not Satisfied");
      address seller = idToMarketItem[_tokenId].seller;
      idToMarketItem[_tokenId].owner = payable(msg.sender);
      idToMarketItem[_tokenId].seller = payable(address(0));
      idToMarketItem[_tokenId].sold = true;
      _transfer(address(this),msg.sender,_tokenId);
      payable(owner).transfer(listingPrice);
      payable(seller).transfer(msg.value);
      _itemsSold.increment();

    }
    function resellToken(uint256 tokenId, uint256 price) public payable {
      require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
      require(msg.value == listingPrice, "Price must be equal to listing price");
      idToMarketItem[tokenId].sold = false;
      idToMarketItem[tokenId].price = price;
      idToMarketItem[tokenId].seller = payable(msg.sender);
      idToMarketItem[tokenId].owner = payable(address(this));
      _itemsSold.decrement();

      _transfer(msg.sender, address(this), tokenId);
    }

    function getprice(uint _tokenId)public view returns(uint){
      return(idToMarketItem[_tokenId].price);
    }

    function getMarketItems() public view returns(MarketItem[] memory){
      uint itemCount = _tokenIds.current();
      uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();
      uint currentIndex = 0;
      MarketItem[] memory items = new MarketItem[](unsoldItemCount);
      for(uint i=0;i<itemCount;i++){
        if(idToMarketItem[i+1].owner==address(this)){
          items[currentIndex] = idToMarketItem[i+1];
          currentIndex += 1;
        }
      }
      return items;
    }

    function getMyNFT(address _acessAddress)public view returns(MarketItem[] memory){
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;
      for(uint i=0;i<totalItemCount;i++){
        if(idToMarketItem[i+1].owner==_acessAddress){
          itemCount++;        
        }
      }
      MarketItem[] memory items = new MarketItem[](itemCount);
      for(uint i=0;i<totalItemCount;i++){
        if(idToMarketItem[i+1].owner==_acessAddress){
          items[currentIndex] = idToMarketItem[i+1];  
          currentIndex += 1;     
        }
      }
      return items;

    }

    function getItemListed()public view returns(MarketItem[] memory){
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;
      for(uint i=0;i<totalItemCount;i++){
        if(idToMarketItem[i+1].owner==address(this)){
          itemCount++;
        }
      }
      MarketItem[] memory items = new MarketItem[](itemCount);
      for(uint i=0;i<totalItemCount;i++){
        if(idToMarketItem[i+1].owner==address(this)){
          items[currentIndex] = idToMarketItem[i+1];  
          currentIndex += 1; 
        }
      }
      return items;
    }
}