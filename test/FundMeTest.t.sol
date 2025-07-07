//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address alice = makeAddr("alice");
    uint256 constant STARTING_BALANCE = 10 ether; 
    uint256 constant SEND_VALUE = 0.1 ether;
    //DeployFundMe deployFundMe;

    function setUp() external {

        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(alice, STARTING_BALANCE);
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);



    }

    function testMinimumDollarIsFive() public {

        assertEq(fundMe.MINIMUM_USD(), 5e18);

    }

    function testOwnerIsMsgSender () public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {

        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {

        vm.expectRevert();

        fundMe.fund();

    }
    

    function testFundUpdatesFundedDataStructure () public{

        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(alice);
        assertEq(amountFunded, SEND_VALUE);

    }

    function testAddFunderToArrayOfFunders () public {

        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, alice);
    }

    function testOnlyOwnerCanWithdraw() public {

        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
        vm.prank(alice);
        fundMe.withdraw();

    }
    
    

}