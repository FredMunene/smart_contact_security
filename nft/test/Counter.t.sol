// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

// stateful fuzz test : utilize same contract by calling another function on it to create an interlocking sequence of functions through a single run
// import {StdInvariant} from "forge-std/StdInvariant.sol"; - invariant keyword**
// contract MyContractTest is StdInvariant, Test {...}

// we need to specify the contract we we'll be calling the random funtions on
// function setUp() public {
//    exampleContract = new MyContract();
//    targetContract(address(exampleContract));
// }

// our test
// function invariant_testAlwaysReturnsZero() public {
//     assert(exampleContract.shouldAlwaysBeZero() == 0);
// }

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
