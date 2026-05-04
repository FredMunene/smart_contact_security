# [H-1] TITLE: Private variables aren't hidden, and are discoverable. Storage variables on-chain are public visible

## **Description:** 

we have the password stored as a private variable. 

All data stored on chain is public and visible to anyone. The `PasswordStore::s_password` variable is intended to be hidden and only accessible by the owner through the `PasswordStore::getPassword` function.

## **Impact:** 

Password is dicoverable by anyone.
anyone can view the stored password, severely breaking the functionality of the protocol.

## **Proof of Concept:**

1. Deploy the contract
```bash
anvil
make deploy
```
2. View the stored password using Anvil's console
```bash
#  cast storage <address> <storageSlot> 
cast storage 0x5FbDB2315678afecb367f032d93F642f64180aa3 1
```

we retrieve byte from of data at `storage slot 1`

3. We decode that data
```bash
cast parse-byte32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014

```



## **Recommended Mitigation:** 

1. Do not store sensitive information such as passwords on-chain, even if they are marked as private. Consider using off-chain storage solutions or hashing the password before storing it on-chain.


# [H-2] `PasswordStore::setPassword` has no access controls, meaning a non-owner could change the password

## Description
The `PasswordStore::setPassword` function is set to be an external function, however purpose of smart contract and function natspec indicate the function allows only owner to set a new password.

```
function setPassword(string memory newPassword) external {
    // @Audit - There are no Access Controls.
    s_password = newPassword;
    emit SetNewPassword();
}
```
## Impact
Anyone can set/change the stored password, severely breaking the contracts's intended functionality.

## Proof of Concept/ Proof of Code

Fuzz test

```
    function test_anyone_can_set_password(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.startPrank(randomAddress);
        string memory expectedPassword = "myNewPassword";
        passwordStore.setPassword(expectedPassword);
​
        vm.startPrank(owner);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, expectedPassword);
    }

```

## Recommended Mitigations
1. Implement access control mechanisms to restrict the `setPassword` function to only be callable by the contract owner. This can be achieved using OpenZeppelin's `Ownable` contract or by implementing a custom access control mechanism.




# [I-1] The `PasswordStore::getPassword` natspec indicates a parameter that doesn't exist, causing the natspec to be incorrect.

## Description
```
/*
 * @notice This allows only the owner to retrieve the password.
@> * @param newPassword The new password to set.
 */
function getPassword() external view returns (string memory) {}
```
The `passwordStore:getPassword` function signature is `getPassword()` while the natspec says it should be `getPassword(string)`.

## Impact

The natspec is incorrect.

## Proof of Concept
Not applicable

## Recommended Mitigation
Remove the incorrect natspec line

```diff
    /*
     * @notice This allows only the owner to retrieve the password.
-   * @param newPassword The new password to set.
     */
```
