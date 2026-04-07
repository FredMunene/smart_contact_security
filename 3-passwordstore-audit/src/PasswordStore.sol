// SPDX-License-Identifier: MIT
pragma solidity 0.8.18; // Q: Is this the correct compiler version for this contract?

/*
 * @author not-so-secure-dev
 * @title PasswordStore
 * @notice This contract allows you to store a private password that others won't be able to see. 
 * You can update your password at any time.
 */
contract PasswordStore {
    error PasswordStore__NotOwner(); // custom error for unauthorized access

    address private sOwner; // storage variables
    // @ Audit - High - storing passwords in plaintext is not secure, consider hashing the password before storing it
    string private sPassword; // storage variables

    event SetNewPassword(); // event emitted when a new password is set

    constructor() {
        sOwner = msg.sender; // set the contract deployer as the owner, access control
    }


    // NatSpec comments for the functions to provide better documentation and clarity on their purpose and usage.
    /*
     * @notice This function allows only the owner to set a new password.
     * @param newPassword The new password to set.
     */

    // @Audit - High - any user can set a password  - Access Control : 'the owner' is the invariant
    function setPassword(string memory newPassword) external {
        if (msg.sender != sOwner) {
            revert PasswordStore__NotOwner();
        }
        sPassword = newPassword;
        emit SetNewPassword();
    }

    /*
     * @notice This allows only the owner to retrieve the password.
    //  @Audit - parameter not used by function, NatSpec can be removed
     * @param newPassword The new password to set.
     */
    function getPassword() external view returns (string memory) {
        if (msg.sender != sOwner) {
            revert PasswordStore__NotOwner();
        }
        return sPassword;
    }

    // Q: Should we add a function to change the owner of the contract? If so, how would that function look like?
    // Q: What's this function doing?

    //  Access Control
    //  every variable in a contract is public by default, even private variables can be accessed and can be retrieved by anyone, blockchains are transparent.
}
