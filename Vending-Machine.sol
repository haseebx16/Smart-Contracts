//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

error Invalid_Price();

contract VendingMachine2 is Ownable {

    using SafeMath for uint256;

    struct Items {
        uint256 Lays;
        uint256 Pizza;
        uint256 Donut;
        uint256 Drinks;
    }

    mapping (address => Items) public Balances;
    Items internal items;
    bool paused;
    address public __owner;
    uint256 private extra;
    AggregatorV3Interface internal priceFeed;

    modifier whenPaused {
        require (!paused);
        _;
    }

    constructor () {
        __owner = msg.sender;
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        items.Donut = 100;
        items.Drinks = 100;
        items.Lays = 100;
        items.Pizza = 100;
    }
    
    function getDonutBalance () public view returns (uint256) {
        return items.Donut;
    }

    function getLaysBalance () public view returns (uint256) {
        return items.Lays;
    }

    function getPizzaBalance () public view returns (uint256) {
        return items.Pizza;
    }

    function getDrinksBalance () public view returns (uint256) {
        return items.Drinks;
    }

    function restockPizza (uint256 value) public onlyOwner {
        items.Pizza += value;
    }

    function restockLays (uint256 value) public onlyOwner {
        items.Lays += value;
    }

    function restockDrinks (uint256 value) public onlyOwner {
        items.Drinks += value;
    }

    function restockDonut (uint256 value) public onlyOwner {
        items.Donut += value;
    }

    function PurchaseDonuts (uint256 amount) public payable whenPaused {
        require(items.Donut > amount, "Not enough donuts in stock");
        require(amount == 1, "You can only buy 1 at a time !");
        require (msg.value >= amount * getPriceForOnePiece(3), "You must pay ether per donut");
        if (msg.value > amount * getPriceForOnePiece(3)) {
            extra = msg.value - amount * getPriceForOnePiece(3);
            (bool success, ) = payable(msg.sender).call{value : extra}("");
            require (success, "Failed to send remains !");
        }

        unchecked {
            items.Donut -= amount;
            Balances[msg.sender].Donut += amount;
        }
    }

    function PurchaseLays (uint256 amount) public payable whenPaused {
        require(items.Lays > amount, "Not enough pizza in stock");
        require(amount == 1, "You can only buy one at a time !");
        require (msg.value >= amount * getPriceForOnePiece(2), "You must pay ether per lays");
        if (msg.value > amount * getPriceForOnePiece(2)) {
            extra = msg.value - amount * getPriceForOnePiece(2);
            (bool success, ) = payable(msg.sender).call{value : extra}("");
            require (success, "Failed to send remains !");
        }
        unchecked {
            items.Lays -= amount;
            Balances[msg.sender].Lays += amount;
        }
    }

    function PurchasePizza (uint256 amount) public payable whenPaused {
        require(items.Pizza > amount, "Not enough pizza in stock");
        require(amount == 1, "You can only buy one at a time !");
        require (msg.value >= amount * getPriceForOnePiece(5), "You must pay ether per pizza");
        if (msg.value > amount * getPriceForOnePiece(5)) {
            extra = msg.value - amount * getPriceForOnePiece(5);
            (bool success, ) = payable(msg.sender).call{value : extra}("");
            require (success, "Failed to send remains !");
        }

        unchecked {
            items.Pizza -= amount;
            Balances[msg.sender].Pizza += amount;
        }
    }

    function PurchaseDrinks (uint256 amount) public payable whenPaused {
        require(items.Drinks > amount, "Not enough Drinks in stock");
        require (msg.value >= getPriceForOnePiece(amount), "You must pay ether per drink");
        require(amount == 1, "You can only buy one at a time !");
        if (msg.value > getPriceForOnePiece(1)) {
            extra = msg.value - getPriceForOnePiece(amount);
            (bool success, ) = payable(msg.sender).call{value : extra}("");
            require (success, "Failed to send remains !");
        }

        unchecked {
            items.Drinks -= amount;
            Balances[msg.sender].Drinks += amount;
        }
    }

    function withdrawMoney () public onlyOwner {
        require (address(this).balance > 0, "Not enough funds !");
        (bool success ,) = __owner.call{value : address(this).balance}("");
        require(success, "Not Able To Transfer Funds !");
    }

    function pause () public onlyOwner {
        paused = true;
    }

    function unpause () public onlyOwner {
        paused = false;
    }
    
    function getPriceForOnePiece(uint256 PriceOfItemYouAreBuying) public view returns (uint256) {
        if (PriceOfItemYouAreBuying == 5 || PriceOfItemYouAreBuying == 2 || PriceOfItemYouAreBuying == 1 || PriceOfItemYouAreBuying == 3) {
            (, int price, , , ) = priceFeed.latestRoundData();
            uint256 amount =  ((PriceOfItemYouAreBuying * 10 ** 18) * 10 ** 18)/ uint256(price * 10 ** 10);
            return amount;
        }
        else {
            revert Invalid_Price();
        }
    }
}
