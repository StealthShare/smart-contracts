// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./StealthShareFiles.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract StealthShareMarket is Ownable, ERC1155Holder {

	struct Listing {
		uint256 price;
	}

	event NewListing (
		address user,
		uint256 token,
		string uri,
		uint256 price,
		uint256 supply
	);

	mapping(uint256 => Listing) public listings;
	mapping(uint256 => bool) public listed;
	mapping(address => bool) public paymentAvailable;

	address collectionAddress;

	constructor(address collectionAddress_) {
		collectionAddress = collectionAddress_;
	}

	function addPaymentType(address newPaymentToken) public onlyOwner {
		paymentAvailable[newPaymentToken] = true;
	}

	function placeListing(uint256 token, uint256 price, uint256 startingSupply) public {
		require(StealthShareFiles(collectionAddress).minter(token) == msg.sender, "StealthShareMarket: Seller is not token minter");
		require(listed[token] == false, "StealthShareMarket: Token already listed");

		ERC1155(collectionAddress).safeTransferFrom(msg.sender, address(this), token, startingSupply, "");
		listings[token] = Listing(price);
		listed[token] = true;

		emit NewListing(msg.sender, token, ERC1155(collectionAddress).uri(token), price, startingSupply);
	}

	function buyToken(uint256[] memory tokens, uint256[] memory amounts, address paymentToken) public {
		require(paymentAvailable[paymentToken] == true, "StealthShareMarket: Payment type not accepted");
		require(tokens.length == amounts.length);

		for(uint i = 0 ; i< tokens.length; i++ ) {
			Listing memory listing = listings[tokens[i]];

			ERC20(paymentToken).transferFrom(msg.sender, StealthShareFiles(collectionAddress).minter(tokens[i]), (amounts[i]*listing.price*10**ERC20(paymentToken).decimals()/100)*90);
			ERC20(paymentToken).transferFrom(msg.sender, owner(), (amounts[i]*listing.price*10**ERC20(paymentToken).decimals()/100)*10);
			ERC1155(collectionAddress).safeTransferFrom(address(this), msg.sender, tokens[i], amounts[i], "");
		}
		
	}
}