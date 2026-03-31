// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


contract Counter {
    uint256 public number;  // Storage Slot 0
    uint256 public _number1; // Storage Slot 1
    uint256 public constant _number3 = 3; // stored in contract bytecode(don't occupy space in storage)
    uint256 public number4; // Storage Slot 2

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}


// forge inspect Counter storage
// slots are 32 bytes long

//  Dynamic variables
// storage slot contains length of array. adding new elements increments the length being stored, and the elements are stored at separate locations determined by hash function.([keccak256(0)])

//  slots  :  A slot is 32 byte long
// Hexadecimal : 0x19
// Binary : 0001 1001
//  Decimal : 25