// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function owner() external view returns (address);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external;
}

error ICO_NoMoreFunds();
error ICO_RemainingSupplyIsLessThanAmount(int256);
error ICO_AmountIsLessThanPrice();

contract ICO {
    event TokensBoughtWithUSDT(address indexed user, uint256 amount);
    event TokensBoughtWithUSDC(address indexed user, uint256 amount);
    event TokensBoughtWithBUSD(address indexed user, uint256 amount);
    event TokensBoughtWithBNB(address indexed user, uint256 amount);
    event Withdraw(address indexed owner, uint256 amount);

    AggregatorV3Interface internal priceFeed;
    AggregatorV3Interface internal usdcNode;
    AggregatorV3Interface internal bnbNode;
    AggregatorV3Interface internal busdNode;
    
    IERC20 private usdt;
    IERC20 private usdc;
    IERC20 private bnb;
    IERC20 private busd;
    IERC20 private token;
    int256 public remainingSupply;
    address public owner;
    bool paused = false;

    mapping (address => uint256) public balanceOf;

    constructor (address usdtAddress, address tokenAddress,
     int256 _remainingSupply, address _bnb, address _busd, address _usdc) {
        
        priceFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        remainingSupply = _remainingSupply;

        usdcNode = AggregatorV3Interface(
            0x986b5E1e1755e3C2440e960477f25201B0a8bbD4
        );
        bnbNode = AggregatorV3Interface(
            0xc546d2d06144F9DD42815b8bA46Ee7B8FcAFa4a2
        );
        busdNode = AggregatorV3Interface(
            0x614715d2Af89E6EC99A233818275142cE88d1Cfd
        );
        usdt = IERC20(usdtAddress);
        token = IERC20(tokenAddress);
        bnb = IERC20(_bnb);
        busd = IERC20(_busd);
        usdc = IERC20 (_usdc);
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier notPaused {
        require(!paused, "The ICO is paused");
        _;
    }

    modifier whenPaused {
        require(paused, "The ICO is not paused");
        _;
    }

    function buyWithUSDT(uint256 amountToBuy) external notPaused {
        require(amountToBuy > 0, "You have to buy more than zero");
        uint256 amountToBeGiven = getPriceUSDT(amountToBuy);
        require(usdt.balanceOf(msg.sender) >= amountToBeGiven, "Not enough USDT balance");
        buyWithUSDTTokens(amountToBuy, amountToBeGiven);
    }

    function buyWithUSDTTokens(uint256 amountToBuy, uint256 amountToBeGiven) internal {
        if (remainingSupply == 0) revert ICO_NoMoreFunds();
        uint256 tokensToBeGiven = amountToBuy;
        if (remainingSupply - int256(tokensToBeGiven) < 0) revert ICO_RemainingSupplyIsLessThanAmount(remainingSupply);
        usdt.transferFrom(msg.sender, address(this), amountToBeGiven);
        token.transfer(msg.sender, tokensToBeGiven);
        balanceOf[msg.sender] += tokensToBeGiven;
        remainingSupply = remainingSupply - int256(tokensToBeGiven);
        emit TokensBoughtWithUSDT(msg.sender, tokensToBeGiven);
    }

    function buyWithUSDC(uint256 amountToBuy) external notPaused {
        require(amountToBuy > 0, "You have to buy more than zero");
        uint256 amountToBeGiven = getPriceUSDC(amountToBuy);
        require(usdc.balanceOf(msg.sender) >= amountToBeGiven, "Not enough USDT balance");
        buyWithUSDCTokens(amountToBuy, amountToBeGiven);
    }

    function buyWithUSDCTokens(uint256 amountToBuy, uint256 amountToBeGiven) internal {
        if (remainingSupply == 0) revert ICO_NoMoreFunds();
        uint256 tokensToBeGiven = amountToBuy;
        if (remainingSupply - int256(tokensToBeGiven) < 0) revert ICO_RemainingSupplyIsLessThanAmount(remainingSupply);
        usdc.transferFrom(msg.sender, address(this), amountToBeGiven);
        token.transfer(msg.sender, tokensToBeGiven);
        balanceOf[msg.sender] += tokensToBeGiven;
        remainingSupply = remainingSupply - int256(tokensToBeGiven);
        emit TokensBoughtWithUSDC(msg.sender, tokensToBeGiven);
    }

    function buyWithBUSD(uint256 amountToBuy) external notPaused {
        require(amountToBuy > 0, "You have to buy more than zero");
        uint256 amountToBeGiven = getPriceUSDT(amountToBuy);
        require(busd.balanceOf(msg.sender) >= amountToBeGiven, "Not enough USDT balance");
        buyWithBUSDTokens(amountToBuy, amountToBeGiven);
    }

    function buyWithBUSDTokens(uint256 amountToBuy, uint256 amountToBeGiven) internal {
        if (remainingSupply == 0) revert ICO_NoMoreFunds();
        uint256 tokensToBeGiven = amountToBuy;
        if (remainingSupply - int256(tokensToBeGiven) < 0) revert ICO_RemainingSupplyIsLessThanAmount(remainingSupply);
        busd.transferFrom(msg.sender, address(this), amountToBeGiven);
        token.transfer(msg.sender, tokensToBeGiven);
        balanceOf[msg.sender] += tokensToBeGiven;
        remainingSupply = remainingSupply - int256(tokensToBeGiven);
        emit TokensBoughtWithBUSD(msg.sender, tokensToBeGiven);
    }

    function buyWithBNB(uint256 amountToBuy) external notPaused {
        require(amountToBuy > 0, "You have to buy more than zero");
        uint256 amountToBeGiven = getPriceUSDT(amountToBuy);
        require(bnb.balanceOf(msg.sender) >= amountToBeGiven, "Not enough USDT balance");
        buyWithBNBTokens(amountToBuy, amountToBeGiven);
    }

    function buyWithBNBTokens(uint256 amountToBuy, uint256 amountToBeGiven) internal {
        if (remainingSupply == 0) revert ICO_NoMoreFunds();
        uint256 tokensToBeGiven = amountToBuy;
        if (remainingSupply - int256(tokensToBeGiven) < 0) revert ICO_RemainingSupplyIsLessThanAmount(remainingSupply);
        bnb.transferFrom(msg.sender, address(this), amountToBeGiven);
        token.transfer(msg.sender, tokensToBeGiven);
        balanceOf[msg.sender] += tokensToBeGiven;
        remainingSupply = remainingSupply - int256(tokensToBeGiven);
        emit TokensBoughtWithBNB(msg.sender, tokensToBeGiven);
    }

    function withdrawUSDTTokens(uint256 amount) external onlyOwner {
        require(amount <= usdt.balanceOf(address(this)), "Insufficient funds in the contract");
        usdt.transfer(owner, amount);
        emit Withdraw(owner, amount);
    }

    function withdrawUSDCTokens(uint256 amount) external onlyOwner {
        require(amount <= usdc.balanceOf(address(this)), "Insufficient funds in the contract");
        usdc.transfer(owner, amount);
        emit Withdraw(owner, amount);
    }

    function withdrawBUSDTokens(uint256 amount) external onlyOwner {
        require(amount <= busd.balanceOf(address(this)), "Insufficient funds in the contract");
        busd.transfer(owner, amount);
        emit Withdraw(owner, amount);
    }

    function withdrawBNBTokens(uint256 amount) external onlyOwner {
        require(amount <= bnb.balanceOf(address(this)), "Insufficient funds in the contract");
        bnb.transfer(owner, amount);
        emit Withdraw(owner, amount);
    }

    function getPriceUSDT(uint256 amountToBuy) public view returns (uint256) {
        (, int price, , , ) = priceFeed.latestRoundData();
        uint256 usdAmount = (amountToBuy * uint256(price)) / (10**6);
        return usdAmount;
    }

    function getPriceUSDC (uint256 amountToBuy) public view returns (uint256) {
        (, int price, , , ) = usdcNode.latestRoundData();
        uint256 usdcAmount = (amountToBuy * uint256 (price)) / (10**18);
        return usdcAmount;
    }

    function getPriceBNB (uint256 amountToBuy) public view returns (uint256) {
        (, int price, , , ) = bnbNode.latestRoundData();
        uint256 bnbAmount = (amountToBuy * uint256 (price)) / (10**8);
        return bnbAmount;
    }

    function getPriceBUSD (uint256 amount) public view returns (uint256) {
        (, int price, , , ) = busdNode.latestRoundData();
        uint256 busdAmount = (amount * uint256(price)) / (10**18);
        return busdAmount;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause () external onlyOwner {
        paused = false;
    }
}
