// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract A {
    uint256 public num;
    address public sender;
    uint256 public value;
    
    // delegate to  B
    function setVars(address _contractB, uint256 _num) public payable {
        // A's storage is set, B is not modified.
        (bool success, ) = _contractB.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
        require(success, "delegatecall failed");
    }
}