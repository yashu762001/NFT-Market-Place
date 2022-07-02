const { ethers } = require("hardhat");
const price = ethers.utils.parseEther("0.1");
async function mintAndList() {
  const nftMarketPlace = await ethers.getContract("NFTMarketPlace");
  const basicNft = await ethers.getContract("BasicNFT");

  console.log("Minting an NFT!!!!!");
  const mint_tx = await basicNft.mintNFT();
  const mint_receipt = await mint_tx.wait(1);
  const tokenId = mint_receipt.events[0].args.tokenId;
  console.log(tokenId.toString());
  console.log("Approving the Market to handle this NFT on owner's behalf!!!!");

  const approvalTx = await basicNft.approve(nftMarketPlace.address, tokenId);
  const approval_receipt = await approvalTx.wait(1);

  console.log("Listing an NFT!!!!");

  const tx = await nftMarketPlace.listItem(basicNft.address, tokenId, price);

  await tx.wait(1);

  console.log("Listed NFT............");
}

mintAndList()
  .then(() => {
    process.exit(0);
  })
  .catch((err) => {
    console.log(err);
  });
