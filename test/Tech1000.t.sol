// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Tech1000.sol";

contract Tech1000Test is Test {
    using stdStorage for StdStorage;

    Tech1000 public nft;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        nft = new Tech1000();
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    function testInitialState() public {
        assertEq(uint256(nft.currentPhase()), uint256(Tech1000.Phase.Closed));
        assertEq(nft.totalSupply(), 10);
        assertEq(nft.balanceOf(owner), 10);
    }

    function testPhaseProgression() public {
        nft.setPhase(Tech1000.Phase.Whitelist);
        assertEq(uint256(nft.currentPhase()), uint256(Tech1000.Phase.Whitelist));

        nft.setPhase(Tech1000.Phase.Public);
        assertEq(uint256(nft.currentPhase()), uint256(Tech1000.Phase.Public));
    }

    function testCannotRegressPhase() public {
        nft.setPhase(Tech1000.Phase.Public);
        vm.expectRevert("Cannot go backwards in phases");
        nft.setPhase(Tech1000.Phase.Whitelist);
    }

    function testZeroQuantityMinting() public {
        nft.setPhase(Tech1000.Phase.Public);

        vm.prank(user1);
        vm.expectRevert("Invalid quantity");
        nft.mint{value: 2 ether}(0);
    }

    function testWhitelistMinting() public {
        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;
        nft.addToWhitelist(users, 2);

        nft.setPhase(Tech1000.Phase.Whitelist);

        vm.prank(user1);
        nft.mint{value: 1 ether}(1);
        assertEq(nft.balanceOf(user1), 1);

        vm.prank(user2);
        nft.mint{value: 1 ether}(1);
        assertEq(nft.balanceOf(user2), 1);
    }

    function testWhitelistMintLimit() public {
        address[] memory users = new address[](1);
        users[0] = user1;
        nft.addToWhitelist(users, 2);
        nft.setPhase(Tech1000.Phase.Whitelist);

        vm.startPrank(user1);

        // Mint within allowed limit
        nft.mint{value: 2 ether}(2);
        assertEq(nft.balanceOf(user1), 2);

        // Attempt to exceed limit
        vm.expectRevert("Exceeds allowed mint limit");
        nft.mint{value: 1 ether}(1);

        vm.stopPrank();
    }

    function testPublicMint() public {
        nft.setPhase(Tech1000.Phase.Public);

        vm.prank(user1);
        nft.mint{value: 2 ether}(1);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.totalSupply(), 11);
    }

    function testIncorrectPayment() public {
        nft.setPhase(Tech1000.Phase.Public);

        vm.prank(user1);
        vm.expectRevert("Wrong payment amount");
        nft.mint{value: 1 ether}(1);
    }

    function testMaxSupply() public {
        nft.setPhase(Tech1000.Phase.Public);

        vm.startPrank(user1);
        vm.deal(user1, 2000 ether); // Give enough ETH

        uint256 remainingSupply = 990; // 1000 - 10 (owner reserve)
        nft.mint{value: remainingSupply * 2 ether}(remainingSupply);

        vm.expectRevert("Collection is minted out");
        nft.mint{value: 2 ether}(1);
        vm.stopPrank();
    }

    function testWithdraw() public {
        nft.setPhase(Tech1000.Phase.Public);

        vm.prank(user1);
        nft.mint{value: 2 ether}(1);

        uint256 initialBalance = address(this).balance;
        nft.withdraw();
        assertEq(address(this).balance - initialBalance, 2 ether);
    }

    function testSetBaseURI() public {
        string memory newURI = "ipfs://newURI/";
        nft.setBaseURI(newURI);
        assertEq(nft.tokenURI(1), string(abi.encodePacked(newURI, "1")));
    }

    function testTokenURIInvalidToken() public {
        vm.expectRevert();
        nft.tokenURI(1001); // Non-existent token ID
    }

    function testSetCreator() public {
        nft.setCreator(user1);
        (address receiver, uint256 royaltyAmount) = nft.royaltyInfo(1, 10000);
        assertEq(receiver, user1);
        assertEq(royaltyAmount, 500);
    }

    receive() external payable {}
}
