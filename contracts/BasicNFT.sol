// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNFT is ERC721 {
    uint256 private tokenCounter;
    string public constant TOKEN_URI =
        "ipfs://bafybeihtx4lfkun6gv56giiesnvmjsx64ciggs73hlacmbo4mbdt5gwnfy.ipfs.localhost:8080/?filename=Qmek8n7XAj49DphqWMGD5okLFkz9boPWtr2V5ZsdVywShj";

    constructor() ERC721("Olivia", "OLI") {
        tokenCounter = 0;
    }

    function mintNFT() public returns (uint256) {
        _safeMint(msg.sender, tokenCounter);
        tokenCounter += 1;

        return tokenCounter;
    }

    function getTokenCounter() public returns (uint256) {
        return tokenCounter;
    }

    function tokenURI(
        uint256 /*tokenId*/
    ) public view override returns (string memory) {
        return TOKEN_URI;
    }
}
