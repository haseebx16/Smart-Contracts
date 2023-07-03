//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TUG is ERC20, ERC20Burnable, Ownable {
    uint public initialSupply = 5000 ether;
    constructor() ERC20("The Underverse Gold", "TUG") {
        _mint(msg.sender, initialSupply);
    }
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}
