// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract StealthShareFiles is ERC1155, ERC1155URIStorage {


    mapping(uint256 => address) public minter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => string) private _uris;

    function uri(uint256 token) public view virtual override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return _uris[token];
    }
    
    constructor() ERC1155("") {
       
    }

    function mint(string memory uri_, uint256 supply) public returns(uint256){
         uint256 id = _tokenIdCounter._value;
         _mint(msg.sender, _tokenIdCounter._value, supply, "");
         _uris[id] = uri_;
         minter[id] = msg.sender;
        
        emit URI(uri_, id);
        
        _tokenIdCounter._value += 1;
        return id;

    }
} 
