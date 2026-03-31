//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MyToken is ERC20 {
    constructor() ERC20("MyTokenName","MTN") {};
}


// ERC-677 (Chainlink)
// upgraded ERC20 token

// ERC-777

// ERC721 : non-fungible tokens(NFTs) - unique Token ID
// - contain metasata and Token URIs






