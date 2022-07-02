// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NFTMarketPlace__Price_MustBe_AboveZero();
error NFTMarketPlace__NotApprovedForMarketPlace();
error NFTMarketPlace__AlreadyListed(address nftAddress, uint256 tokenId);
error NFTMarketPlace__NotOwner();
error NFTMarketPlace__NotListed(address nftAddress, uint256 tokenId);
error NFTMarketPlace__PriceNotMet(
    address nftAddress,
    uint256 tokenId,
    uint256 price
);
error NFTMarketPlace__NoProceeds();
error NFTMarketPlace__TransferFailed();

contract NFTMarketPlace {
    struct Listing {
        uint256 price;
        address seller;
    }
    event ItemListedOnMarketPlace(
        address NFTAddress,
        uint256 tokenId,
        address seller,
        uint256 price
    );

    event ItemBought(
        address buyer,
        address nft,
        uint256 tokenId,
        uint256 price
    );
    event ItemCancelled(address seller, address nftAddress, uint256 tokenId);
    event ListingUpdated(
        address seller,
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    );

    mapping(address => mapping(uint256 => Listing)) private listings;
    mapping(address => uint256) EarnedAmount;

    modifier NotListed(
        address nftAddress,
        uint256 tokenId,
        address owner
    ) {
        Listing memory list = listings[nftAddress][tokenId];
        if (list.price > 0) {
            revert NFTMarketPlace__AlreadyListed(nftAddress, tokenId);
        }

        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        if (nft.ownerOf(tokenId) != spender) {
            revert NFTMarketPlace__NotOwner();
        }

        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory l1 = listings[nftAddress][tokenId];
        if (l1.price <= 0) {
            revert NFTMarketPlace__NotListed(nftAddress, tokenId);
        }

        _;
    }

    function listItem(
        address NFTAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        NotListed(NFTAddress, tokenId, msg.sender)
        isOwner(NFTAddress, tokenId, msg.sender)
    {
        if (price <= 0) {
            revert NFTMarketPlace__Price_MustBe_AboveZero();
        }

        // Owners would approve the contract to sell their nft for them
        IERC721 nft = IERC721(NFTAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NFTMarketPlace__NotApprovedForMarketPlace();
        }

        listings[NFTAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListedOnMarketPlace(NFTAddress, tokenId, msg.sender, price);
    }

    // Allowing people to buy Listed NFT'S :

    function buyNFT(address nftAddress, uint256 tokenId)
        external
        payable
        isListed(nftAddress, tokenId)
    {
        Listing memory list = listings[nftAddress][tokenId];
        if (msg.value < list.price) {
            revert NFTMarketPlace__PriceNotMet(nftAddress, tokenId, list.price);
        }

        EarnedAmount[list.seller] += msg.value;
        delete listings[nftAddress][tokenId];

        IERC721 nft = IERC721(nftAddress);
        nft.safeTransferFrom(list.seller, msg.sender, tokenId);

        emit ItemBought(msg.sender, nftAddress, tokenId, list.price);
    }

    // Cancelling Listing Items :

    function cancelListing(address nftAddress, uint256 tokenId)
        external
        isOwner(nftAddress, tokenId, msg.sender)
        isListed(nftAddress, tokenId)
    {
        delete listings[nftAddress][tokenId];

        emit ItemCancelled(msg.sender, nftAddress, tokenId);
    }

    // Update Listing :

    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    )
        external
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        listings[nftAddress][tokenId].price = newPrice;

        emit ListingUpdated(msg.sender, nftAddress, tokenId, newPrice);
    }

    // Withdraw payments for nfts sold :

    function withdraw() external {
        uint256 proceeds = EarnedAmount[msg.sender];

        if (proceeds <= 0) {
            revert NFTMarketPlace__NoProceeds();
        }

        EarnedAmount[msg.sender] = 0;

        (bool succ, ) = payable(msg.sender).call{value: proceeds}("");
        if (!succ) {
            revert NFTMarketPlace__TransferFailed();
        }
    }

    function getListing(address nftAddress, uint256 tokenId)
        external
        view
        returns (Listing memory)
    {
        return listings[nftAddress][tokenId];
    }

    function getProceeds(address seller) external view returns (uint256) {
        return EarnedAmount[seller];
    }
}
