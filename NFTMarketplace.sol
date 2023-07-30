// SPDX-License-Identifier:MIT

pragma solidity ^0.8.4;

//IMPORT FROM OPEN ZEPPELIN
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC271/extensions/ERC271URIStorage.sol";
import "@openzeppelin/contracts/token/ERC271/ERC271.sol";
import "hardhat/console.sol";


contract NFTMarketplace is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    uint256 listingPirice=0.0015 ether;
    address payable owner;
    mapping(uint256=>MarketItem) private idMarketItem;
    struct MarketItem{
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    event idMarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold 
    );

    modifier onlyOwner{
        require(msg.sender==owner,"Only owner can call this ");
        _;
    }

    constructor() ERC271("NFT Metaverse Token","MYNFT"){
        owner==payable(msg.sender);

    }
    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner{
    listingPrice=_listingPrice;

    }

    function getListingPrice () public vierw returns (uint256){
        return listingPrice;
    }

    //Create NFT TOKEN FUNCTION
    function createToken(string memory tokenURI,uint256 price) public payable returns(uint256){
        tokenIds.increment();
        uint256 newTokenId=_tokenIds.current(); 
        _mint(msg.sender,newTokenId);
        _setTokenURI(newTokenId,tokenURI);
        createMarketItem(newTokenId,price);
        return newTokenId;
    }

//creating market item
    function createMarketItem(uint256 tokenId,uint256 price) private {
        require(price>0,"Price must be over 0");
        require(msg.value==listingPrice,"Price must be at least equal to listing price");
        idMarketItem[tokenId]=MarketItem(
            tokenId,
            payable(msg.sender),
            payable(addres(this)),
            price,
            false
        );
        _transfer(msg.sender,address(this),tokenId);
        emit MarketItemCreated(tokenId,msg.sender,address(this),price,false);

    }

//Function for resales
    function reSellToken(uint256 tokenId,uint256 price) public payable {
        require(idMarketItem[token.Id].owner==msg.sender,"Only item owner can make this");
        require(msg.value==listingPrice,"Price must be at least ewual to listing Pirce of 0.0015 ethers");
        idMarketItem[tokenId].price=price;
        idMarketItem[tokenId].seller=payable(msg.sender);
        idMarketItem[tokenId].owner=payable(address(this));
        _itemsSold.decrement();
        _transfer(msg.sender,address(this),tokenId);
    
    }

//function  to create market sale
    function createMarketSale(uint256 tokenId) public payable {
        uint256 price=idMarketItem[tokenId].price;
        require(msg.value==price,"Please submit the asking price in order to complete the purchase");
        idMarketItem[tokenId].owner=payable(msg.sender);
        idMarketItem[tokenId].sold=payable(address(0));
        _itemSold.increment();
        _transfer(address(this),msg.sender,tokenId);
        payable(owner).transfer(listingPrice);
        payable(idMarketItem[tokenId].seller).transfer(msg.value);

}
    //getting unsold nft data
    function fetchMarketItem() public view returns (MarketItem[] memory){
        uint256 itemCount=_tokenIds.current();
        uint256 unSoldItemCount=_tokensIds.cuurent() - _itemsSold.current();
        uint256 currentIndex=0;
        MarketItem[] memory items=new MarketItem[](unSoldItemCount);
        for (uint256 i=0;i<itemCount;i++){
            if (idMarketItem[i+1].owner==address(this)){
                uint156 currentId=i+1;
                MarketItem storage currentItem=idMarketItem[currentId];
                items[currentIndex]=currentItem;
                currentIndex+=1;
            }
        }
        return items;
    }
    //purchase item
    function fetchMyNFT() public view returns(MarketItem[] memory){
        uint256 totalCount=_tokenIds.current();
        uint256 itemCount=0;
        uint256 currentIndex=0;
        for (uint i=0;i<totalCount;i++){
            if (idMarketItem[i+1].owner==msg.sender){
                itemCount+=1;
            }
        }
        MarketItem[] memory items=new MarketItem[](itemCount);
        for (uint256 i=0;i<totalCount;i++){
            if (idMarketItem[i+1].owner==msg.sender){
            uint256 currntId=i+1;
            MarketItem storage currentItem=idMarketItem[currntId];
            item[currentIndex]=currentItem;
            currentIndex +=1;
            }
        }
        return items;
    }  

    //single user items
    function fetchItemsListed() public view return (MarketItem[] memory){
        uint256 totalCount=_tokenIds.current();
        uint256 itemCount=0;
        uint256 currentIndex=0;

        for (uint256 i=0;i<totalCount;i++){
            if (idMarketItem[i+1].seller==msg.sender){
                itemCount+=1;
            }
        }
        MarketItem[] memory items=new MarketItem[](itemCount);
        for (uint256 i=0;i<totalCount;i++){
            if (idMarketItem[i+1].seller==msg.sender){
                uint256 currentId=i+1;

                MarketItem storage currentItem=idMarketItem[currentId];
                items[currentIndex]=currentItem;
                currentIndex+=1;
            }
        }
        return items;
    }








}

