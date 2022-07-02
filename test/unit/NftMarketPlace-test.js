const { assert, expect } = require("chai");
const { networks, deployments, getNamedAccounts, ethers } = require("hardhat");
const { developmentChains } = require("../../helper-hardhat-config");

if (developmentChains.includes(network.name)) {
  describe("NFT Market Place Tests", async function () {
    let nftMarketPlace, deployer, basicNft, player;
    const TOKEN_ID = 0;
    const price = ethers.utils.parseEther("0.1");
    const updated_price = ethers.utils.parseEther("0.1");

    beforeEach(async () => {
      deployer = (await getNamedAccounts()).deployer;
      const accounts = await ethers.getSigners();
      player = accounts[1];
      await deployments.fixture(["all"]);

      nftMarketPlace = await ethers.getContract("NFTMarketPlace", deployer);
      basicNft = await ethers.getContract("BasicNFT", deployer);

      await basicNft.mintNFT();
      await basicNft.approve(nftMarketPlace.address, TOKEN_ID);
    });

    it("List NFT and can be bought", async function () {
      await nftMarketPlace.listItem(basicNft.address, TOKEN_ID, price);
      const listedItem = await nftMarketPlace.getListing(
        basicNft.address,
        TOKEN_ID
      );
      assert(listedItem.price > 0);

      // Player wants to buy the nft listed : for that he first needs to get connected to the nft market place :
      const playerConnectedtoNFTMarketPlace = nftMarketPlace.connect(player);
      await playerConnectedtoNFTMarketPlace.buyNFT(basicNft.address, TOKEN_ID, {
        value: price,
      });

      const proceeds = await nftMarketPlace.getProceeds(deployer);
      assert.equal(proceeds.toString(), price.toString());

      const newOwner = await basicNft.ownerOf(TOKEN_ID);
      assert.equal(newOwner.toString(), player.address.toString());
    });

    it("Update Listing", async function () {
      await nftMarketPlace.listItem(basicNft.address, TOKEN_ID, price);
      await nftMarketPlace.updateListing(
        basicNft.address,
        TOKEN_ID,
        updated_price
      );

      const listing = await nftMarketPlace.getListing(
        basicNft.address,
        TOKEN_ID
      );

      assert.equal(listing.price.toString(), updated_price.toString());
    });

    it("Cancel Listing", async function () {
      await nftMarketPlace.listItem(basicNft.address, TOKEN_ID, price);
      await nftMarketPlace.cancelListing(basicNft.address, TOKEN_ID);

      const listing = await nftMarketPlace.getListing(
        basicNft.address,
        TOKEN_ID
      );
      assert(listing.price <= 0);
    });

    it("Withdraw Money obtained from sold NFT", async function () {
      await nftMarketPlace.listItem(basicNft.address, TOKEN_ID, price);
      const initialBalance = await nftMarketPlace.provider.getBalance(deployer);
      const playerConnectedtoNFTMarketPlace = await nftMarketPlace.connect(
        player
      );

      await playerConnectedtoNFTMarketPlace.buyNFT(basicNft.address, TOKEN_ID, {
        value: price,
      });
      const transactionResponse = await nftMarketPlace.withdraw();
      const transactionReceipt = await transactionResponse.wait(1);

      const gasFees = transactionReceipt.gasUsed.mul(
        transactionReceipt.effectiveGasPrice
      );

      const finalBalance = await nftMarketPlace.provider.getBalance(deployer);

      assert.equal(
        finalBalance.add(gasFees).toString(),
        initialBalance.add(price).toString()
      );
    });
  });
}
