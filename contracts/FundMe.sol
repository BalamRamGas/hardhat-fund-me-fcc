// Get funds from other users.
// Withdraw Funds.
// Set a minimum funding value in USD.

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
import "hardhat/console.sol";

error FundMe__NotOwner();

/**
 * @title A contract for crowfunding.
 * @author Balam Ramírez.
 * @notice This contract is to demo a sample funding contract.
 * @dev This implements price feeds as our library.
 */
contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] private s_funders;

    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner;

    AggregatorV3Interface public s_priceFeed;

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not Owner!");

        //custom-error for our reverts example:
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
        // 28185.28000000 BTC / USD
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * @notice This function funds this contract.
     * @dev This implements price feeds as our library.
     */
    //@param @return are not applicable here because the function doesn't have any parameter nor returns anything.
    function fund() public payable {
        //Set a minimum funding value in USD
        //How do we send ETH to this contract
        //require(getConvertionRate(msg.value) >= 1e18, "Dind't send enough ETH");
        require(
            msg.value.getConvertionRate(s_priceFeed) >= 1e18,
            "Didn't send enough ETH"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public payable onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            //reset the balances of the mapping
            s_addressToAmountFunded[funder] = 0;
        }

        //reset the array... we could delete the objects by looping through the array or we can do the following...
        s_funders = new address[](0);

        //transfer
        //payable(msg.sender).transfer(address(this).balance)

        //send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require (sendSuccess, "Send Failed");

        //call
        (bool callSuccess /*bytes memory dataReturned */, ) = payable(
            msg.sender
        ).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        //slightly different from the withdraw function
        (bool callSuccess, ) = i_owner.call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
