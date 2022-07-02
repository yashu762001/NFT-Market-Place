<h1> NFT Market Place </h1>
<h2> About of this application : </h2>
<ul>
<li> Mint an NFT and list it on the platform. </li>
<li> Users can buy the Listed NFT's. </li>
<li> NFT Owners can delete their listed NFT. <li>
<li> NFT Owners can update listed price for their NFT. </li>

</ul>

<h2> Application Working Explained : </h2>
<p> Users can visit the platform and mint an NFT and then list on the platform. Currently I have not provided support for uploading images/gifs/videos on the platform and then adding meta data and finally minting it. I simply used my past BasicNFT project in which I created an NFT and provided it functionalities to mint it. I simply used that code within this project and used that NFT for minting and finally listed that NFT on my platform. Now One thing to note is that before listing NFT on the platform the user has to give permission to my smart contract to allow it to perform transfer operations on owner's behalf. Then I created an buyNFT function in contract that first checks if the NFT we are trying to buy is it listed or not and it also checks if the amount of money we are paying to buy is it more than listed Price or not. Now one thing to note here is that the money buyer pays for buying NFT goes to the smart contract. Now if the seller wants to withdraw the money they will simply need to press withdraw button and Yipee!!! the amount will be transferred to their wallet address. I have also provided functionalities to update the listing price or if the owner wants to delete their NFT. </p>

<h2> Learnings : </h2>
<ul>
<li> Got to know about a lot of NFT Listing Platforms such as Open Sea, Rarible etc. Also learnt about NFT's a lot and really feel this could change the world.</li>

<li> I wrote unit tests for the smart contract to check its working. This section I really find challenging since writing good tests is extremely important. </li>

</ul>

<h2> Future Updations that can be made to this application : </h2>
<ul>
<li> Currently I am writing an new contract for NFT and then using it for listing. But I can add functionality to mint NFT's from my smart contract only, without having the need to write a separate smart contract for every NFT we try to upload. </li>
<li> I used my Basic NFT in this project But I could also have used my previous projects Randomised NFT to mint a truly random NFT out of my collection and then listing it. </li>
<li> Currently a user needs Ethereum to buy an NFT. But I can add functionality to buy using other ERC20 tokens as well. </li>

</ul>
