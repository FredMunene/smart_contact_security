// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {PasswordStore} from "../src/PasswordStore.sol";

contract PasswordStoreTest is Test {
    event SetNewPassword();

    PasswordStore private passwordStore;
    address private alice = address(1);
    string private constant NEW_PASSWORD = "supersecret";

    function setUp() public {
        passwordStore = new PasswordStore();
    }

    function test_ownerCanSetAndGetPassword() public {
        vm.expectEmit(true, false, false, false);
        emit SetNewPassword();

        passwordStore.setPassword(NEW_PASSWORD);

        assertEq(passwordStore.getPassword(), NEW_PASSWORD);
    }

    function test_nonOwnerCannotSetPassword() public {
        vm.prank(alice);
        vm.expectRevert(PasswordStore.PasswordStore__NotOwner.selector);
        passwordStore.setPassword(NEW_PASSWORD);
    }

    function test_nonOwnerCannotGetPassword() public {
        passwordStore.setPassword(NEW_PASSWORD);

        vm.prank(alice);
        vm.expectRevert(PasswordStore.PasswordStore__NotOwner.selector);
        passwordStore.getPassword();
    }

    function test_passwordIsStoredInPlaintextInStorage() public {
        passwordStore.setPassword(NEW_PASSWORD);

        bytes32 rawSlot = vm.load(address(passwordStore), bytes32(uint256(1)));
        string memory recovered = _decodeShortString(rawSlot);

        assertEq(recovered, NEW_PASSWORD);
    }

    function _decodeShortString(bytes32 raw) internal pure returns (string memory) {
        uint256 encoded = uint256(raw);
        uint256 length = encoded & 0xff;

        // Short strings store the data in the upper 31 bytes and the length marker in the low byte.
        length = length / 2;

        bytes memory out = new bytes(length);
        for (uint256 i = 0; i < length; ++i) {
            out[i] = bytes1(uint8(encoded >> (8 * (31 - i))));
        }

        return string(out);
    }
}
