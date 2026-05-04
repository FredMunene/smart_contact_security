
---
title: Protocol Audit Report
author: Fred Gitonga
date: May 4, 2026
header-includes:
  - \usepackage{titling}
  - \usepackage{graphicx}
---

\begin{titlepage}
    \centering
    \begin{figure}[h]
        \centering
        \includegraphics[width=0.5\textwidth]{logo.pdf} 
    \end{figure}
    \vspace*{2cm}
    {\Huge\bfseries PasswordStore Audit Report\par}
    \vspace{1cm}
    {\Large Version 1.0\par}
    \vspace{2cm}
    {\Large\itshape Cyfrin.io\par}
    \vfill
    {\large \today\par}
\end{titlepage}

\maketitle

<!-- Your report starts here! -->

Prepared by: [Fred Gitonga](https://gitongacodes.co.ke)
Lead Auditors: 
- Fred Gitonga         

# Table of Contents
- [Table of Contents](#table-of-contents)
- [Protocol Summary](#protocol-summary)
- [Disclaimer](#disclaimer)
- [Risk Classification](#risk-classification)
- [Audit Details](#audit-details)
  - [Scope](#scope)
  - [Roles](#roles)
- [Executive Summary](#executive-summary)
  - [Issues found](#issues-found)
- [Findings](#findings)
  - [High](#high)
  - [Informational](#informational)

# Protocol Summary

PasswordStore is a smart contract application that allows a single owner to store and retrieve a private password on-chain. The protocol enforces that only the deploying address (the owner) can set and read the stored password. The contract is written in Solidity 0.8.18 and is intended for deployment on an EVM-compatible blockchain.

# Disclaimer

The FRED GITONGA team makes all effort to find as many vulnerabilities in the code in the given time period, but holds no responsibilities for the findings provided in this document. A security audit by the team is not an endorsement of the underlying business or product. The audit was time-boxed and the review of the code was solely on the security aspects of the Solidity implementation of the contracts.

# Risk Classification

|            |        | Impact |        |     |
| ---------- | ------ | ------ | ------ | --- |
|            |        | High   | Medium | Low |
|            | High   | H      | H/M    | M   |
| Likelihood | Medium | H/M    | M      | M/L |
|            | Low    | M      | M/L    | L   |

Severity is determined by two factors:

- **Impact**: How severe is the outcome if the vulnerability is exploited?
  - **High**: Funds directly at risk, or severe disruption of protocol functionality. Highly probable to happen.
  - **Medium**: Funds indirectly at risk, or some disruption under specific conditions.
  - **Low**: Funds not at risk, minimal impact, unlikely to occur.

- **Likelihood**: How probable is it that the vulnerability will be exploited?

We use the [CodeHawks](https://docs.codehawks.com/hawks-auditors/how-to-evaluate-a-finding-severity) severity matrix to determine severity. See the documentation for more details.

# Audit Details

**Commit Hash:**
```
Not available — local review
```

## Scope

The following contracts were in scope of the audit:

```
#-- src/
    #-- PasswordStore.sol
```

## Roles

- **Owner**: The deploying address. Only the owner is intended to call `setPassword` and `getPassword`.
- **Outsiders**: Any address that is not the owner. These users should have no ability to set or read the password.

# Executive Summary

The audit of the PasswordStore protocol was conducted as a focused, time-boxed security review. The primary objective was to assess the security of the on-chain password storage mechanism, the access control implementation, and the correctness of NatSpec documentation.

During the review, two critical high-severity vulnerabilities were identified — both of which fundamentally undermine the protocol's core security guarantee — along with one informational issue relating to incorrect NatSpec documentation.

## Issues found

| Severity      | Number of Issues |
| ------------- | ---------------- |
| High          | 2                |
| Medium        | 0                |
| Low           | 0                |
| Informational | 1                |
| **Total**     | **3**            |

# Findings

## High

### [H-1] Private variables aren't hidden — on-chain storage is publicly visible

**Description:**

The password is stored as a `private` variable `PasswordStore::s_password`. However, all data stored on-chain is publicly visible to anyone who queries the blockchain directly, regardless of Solidity's `private` visibility modifier. The variable is intended to be accessible only by the owner through `PasswordStore::getPassword`, but this assumption is false.

**Impact:**

The stored password is discoverable by anyone, severely breaking the core functionality and security guarantee of the protocol.

**Proof of Concept:**

1. Deploy the contract:
```bash
anvil
make deploy
```

2. Read the stored password directly from storage slot 1:
```bash
cast storage 0x5FbDB2315678afecb367f032d93F642f64180aa3 1
```

3. Decode the raw bytes into a human-readable string:
```bash
cast parse-byte32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```

**Recommended Mitigation:**

Do not store sensitive information such as passwords on-chain, even if marked as `private`. Consider using off-chain storage solutions, or hash the password before storing it on-chain so the raw value is never exposed.

---

### [H-2] `PasswordStore::setPassword` has no access controls — any user can change the password

**Description:**

The `PasswordStore::setPassword` function is declared `external` with no access control checks. The protocol's purpose and NatSpec indicate that only the owner should be able to set a new password, but there is nothing preventing any address from calling this function.

```solidity
function setPassword(string memory newPassword) external {
    // @Audit - There are no Access Controls.
    s_password = newPassword;
    emit SetNewPassword();
}
```

**Impact:**

Anyone can set or change the stored password, severely breaking the contract's intended functionality and access control invariant.

**Proof of Concept:**

```solidity
function test_anyone_can_set_password(address randomAddress) public {
    vm.assume(randomAddress != owner);
    vm.startPrank(randomAddress);
    string memory expectedPassword = "myNewPassword";
    passwordStore.setPassword(expectedPassword);

    vm.startPrank(owner);
    string memory actualPassword = passwordStore.getPassword();
    assertEq(actualPassword, expectedPassword);
}
```

**Recommended Mitigation:**

Add an access control check to restrict `setPassword` to the contract owner:

```solidity
if (msg.sender != s_owner) {
    revert PasswordStore__NotOwner();
}
```

---

## Informational

### [I-1] `PasswordStore::getPassword` NatSpec references a non-existent parameter

**Description:**

The NatSpec for `getPassword` incorrectly documents a `@param newPassword` that does not exist in the function signature:

```solidity
/*
 * @notice This allows only the owner to retrieve the password.
 * @param newPassword The new password to set.
 */
function getPassword() external view returns (string memory) {}
```

The function signature is `getPassword()` with no parameters, making this NatSpec entry erroneous.

**Impact:**

Incorrect NatSpec reduces documentation quality and can mislead developers integrating with the contract.

**Proof of Concept:**

Not applicable.

**Recommended Mitigation:**

Remove the incorrect `@param` line from the NatSpec:

```diff
    /*
     * @notice This allows only the owner to retrieve the password.
-    * @param newPassword The new password to set.
     */
```