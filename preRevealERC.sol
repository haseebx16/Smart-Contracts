// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

error ERC721MetadataTokenNonExistent();

contract PreReveal is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    string private baseURI;
    uint public supply = 3;

    Counters.Counter private _tokenIdCounter;

    constructor(string memory _baseUri) ERC721("PreReveal", "PRT") {
        baseURI = _baseUri;
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
     

    function tokenURI (uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            revert ERC721MetadataTokenNonExistent();
        }
        string memory uri = _baseURI();
        if (_tokenIdCounter.current() < supply) {
            return bytes(uri).length > 0 ? string(abi.encodePacked(baseURI, "preview" , ".json")) : "";
        }
        else {
            return bytes(uri).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
        }
    }
}
