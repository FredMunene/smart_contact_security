### [S-#] TITLE (Root Cause + Impact)
Private variables aren't hidden, and are discoverable 
Storage variables on-chain are public visible
**Description:** 
we have the password stored as a private variable. 
All data stored on chain is public and visible to anyone. The `PasswordStore::s_password` variable is intended to be hidden and only accessible by the owner through the `PasswordStore::getPassword` function.
**Impact:** 
Password is dicoverable by anyone.
anyone can view the stored password, severely breaking the functionality of the protocol.
**Proof of Concept:**
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



**Recommended Mitigation:** 

1. Do not store sensitive information such as passwords on-chain, even if they are marked as private. Consider using off-chain storage solutions or hashing the password before storing it on-chain.