// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract CryptoZ is ERC721, Ownable {

    using Counters for Counters.Counter;

    event Minted (address, uint256);
    event EnabledMint(bool);

    Counters.Counter private _tokenIdCounter;
    bool public mintEnabled;
    uint256 public startTime;
    uint256 public endTime;

    constructor() ERC721("CryptoZ", "CRPZ") {}

    function safeMint(address to) public onlyOwner {
        require(mintEnabled, "Enable Mint by Enable Mint Function !");
        require (endTime > block.timestamp, "Mint time has ended" );
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        emit Minted( to , tokenId );
    }

    function mintCount () public view returns (uint256) {
        uint256 mintCounter = _tokenIdCounter.current(); 
        return mintCounter;
    }

    function enableMint () public onlyOwner {
        require( !mintEnabled, "Already Enabled !" );
        startTime = block.timestamp;
        endTime = startTime + 10 days;
        mintEnabled = true;
        emit EnabledMint( mintEnabled );
    }

    function getTime () public view returns (uint256) {
        return endTime;
    }
}
