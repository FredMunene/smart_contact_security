// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/Proxy.sol";

contract SmallProxy is Proxy {
    // This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    // ERC1967
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // This function allows the owner to set the implementation contract address.
    function setImplementation(address newImplementation) public {
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    // This function allows owner to retrieve the current implementation contract address 
    function _implementation() internal view override returns (address implementationAddress) {
        assembly {
            implementationAddress := sload(_IMPLEMENTATION_SLOT)
        }
    }

    // The 'fallback' function delegates all calls to the implementation contract.
    // This functionality is inherited from OpenZeppelin's Proxy.sol contract.
    function _fallback() internal override {
        _beforeFallback();
        _delegate(_implementation());
    }
}