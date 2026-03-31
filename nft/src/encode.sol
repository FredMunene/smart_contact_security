//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Encoding {
    function combineStrings() public pure returns (string memory) {
        return string(abi.encodePacked("Hi Mom! ", "Miss you."));
    }

    function encodeString() public pure returns (bytes memory) {
        bytes memory someString = abi.encode("some string");
        return someString;
    }

    function decodeString() public pure returns (string memory){
        string memory someString = abi.decode(encodeString(),(string));
                                                            // one string to be derived
        return someString;
    }
}