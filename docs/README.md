### Repo Metrics

As of `2026-04-06`, the Solidity metrics for this workspace are:

| Scope | Files | nSLOC / CLOC* | Estimated complexity | Max function complexity |
|---|---:|---:|---:|---:|
| Full Solidity tree (`src/` + `script/` + `test/`) | 46 | 6,201 | 1,066 | 31 |
| Audit surface only (`src/` + `script/`) | 14 | 236 | 22 | 2 |

By project, the full Solidity tree breaks down as:

| Project | Files | nSLOC / CLOC* | Estimated complexity | Max function complexity |
|---|---:|---:|---:|---:|
| `smart_contact_security/nft` | 11 | 135 | 21 | 2 |
| `battlechain/accountable_protocol` | 31 | 5,607 | 1,020 | 31 |
| `battlechain/remora` | 4 | 459 | 25 | 2 |

* `nSLOC / CLOC` means non-empty, non-comment Solidity lines.
- Count Lines of Code (CLOC)
- Normalized Source Lines of Code (nSLOC)

#### How this was computed

- I scanned all `*.sol` files in the repo with a local script.
- I excluded vendored dependencies in `lib/` and generated build artifacts in `out/`.
- For each Solidity file, I counted:
  - total lines
  - blank lines
  - comment lines
  - code lines
- `nSLOC / CLOC` is the number of non-empty lines that are not comments.
- The complexity score is a source-based cyclomatic estimate per function:
  - base score of `1`
  - `+1` for each `if`, `for`, `while`, `case`, or `catch`
  - `+1` for each `&&`, `||`, or ternary `?`
- The project totals are the sum of all files in scope.

### Data Location
`Calldata` variables are read-only and cheaper than memory. They are mostly used for input parameters.

`memory` allows for read-write access, letting variables be changed within the function. To modify calldata variables, they must first be loaded into memory.
cannot assign memory to uint256

`storage` persistent on the blockchain, retaining their values between function calls and transactions. Variables which are declared outside any function.
Declared at contract level.
You can't use the storage keyword for variables inside a function.

`string` stored as array of bytes. 
`struct`
`bool`
`uint`

`constants` and `immutable variables` don't occupy slots, they get into bytecode of the contract.

Variables scoped by function.
    - live within the function

### Inheritance

```solidity
import {SimpleStorage} from "./SimpleStorage.sol";
​
contract AddFiveStorage is SimpleStorage{}
```

To override a method from the parent contract, we must replicate the exact function signature, including its name, parameters and adding the visibility and the override keyword to it:

But we need to mark the function as `virtual` in origin contract so it can be overidden by child contracts.

```solidity
function store(uint256 _newFavNumber) public override {}
```

in the original contract:
```
function store(uint256 favNumber) public virtual {
    // function body
}
```

### Transaction Fields
- Nonce
-  Gas price(wei) : max price sender is willing to pay per unit of gas
- Gas Limit : max gas seller is willing to use for tx. usually 21000.
- To : recipient's address
- Value(Wei) : amount of crypto being transferred
- Data : | function and parameters (the contract.bin/ contract init code)
- v.r.c : signature


https://github.com/Cyfrin/security-and-auditing-full-course-s23

###

**Reentracy** flagged as most common attack vector. Proper understanding of implementation.

### Testing
- Regular Test and Fuzz Test
- Stateful fuzzing ; type of invariant tests

Testing invariants - 
what is an invariant?  A integral propert of function or entire program that must always hold true.
so, Invariant testing and Fuzz testing

- Stateless Fuzzing
    + contract stae is reset for each new run
- Stateful Fuzzing
    + contract start is not reset for each new run, ending state of previous run is the starting state of the next.

```solidity
function doStuff(uint256 data) public {
    if (data == 2){
        shouldAlwaysBeZero = 1;
    }
    if(hiddenValue == 7){
        shouldAlwaysBeZero = 1;
    }
    hiddenValue = data;
}
# Passing 7 as an argunebt will set hiddenValue to 7, which is a subsequent run of this function, will break our invariant
```

Some bugs only appear across multiple calls, not in a single transaction. So when testing, you need to ask:

- Does a single call break it? (easy to catch)
- Does a sequence of calls break it? (hard to catch)


 `stateless` fuzzing, which provides random data alone with each run independent of the last, or `stateful` fuzzing, allowing both random data and random function calls subsequently on the same contract.

 
 ### Memory
 `memory` used cause strings are dynamically sized arrays.
- tells solidity string operations are to be performed not in `Storage` but separate memory location.

```solidity
contract exampleContract{
    function getString() public pure returns (string memory) {
        return "this is a string!";
    }
}
```

### `fallback` and `receive`
 *external payable*
 in order to accept and react to native ETH sent to the contract.
 if `receive` doesn't exist in a contract, it resorts to `fallback`.



```solidity
fallback() external{} // it is  catch-all function, handles ETH sent with data
receive() external payable {} 
// set bith as payable - so they are able to receive/accept ETH
```

### Encoding
`abi.encode` - returns binary
`abi.encodePacked` - returns binary, compressed
`string.concat(stringA, stringB)`
`abi.decode`
 concatenate strings in Solidity



 ### Cheatsheet
 https://docs.soliditylang.org/en/latest/cheatsheet.html

 ### Opcodes
 - Each represents a specific operation.
  (resource)[https://www.evm.codes/?fork=shanghai]

  ###
  Function signature "encoded function, it's name and argument types" = Method ID

  `staticcall` - view/pure functions
   `call` - function that change blockchain state
: direct calls without using ABI or interface
```solidity
function withdraw(address recentWinner) public {
    (bool success, ) = recentWinner.call{value: address.(this).balance}("");                                // transfer token to wallet
    require(success, "Transfer Failed");
}

// need to call a function ; include method ID
function enterRaffle(uint256 entryFee) public payable {
    PuppyRaffle puppyRaffle = new PuppyRaffle;
    puppyRaffle.call{value: entryFee}("0x2cfcc539");
                    //  argument to 'value' property
}
```
value field and data field of the transaction in above instance are populated.

### Upgradeable Smart Contracts
#### + Proxy pattern
1. The proxy contract - contract users interact with, hold contract state(data & balances), address is permanent and unchanged. Forwards calls to logic contract.
2. The implementation (logic) contract - contains active buisness logic, it's stateless and provides code for proxy to execute.
#### + `delegatecall` - low-level EVM opcode
A -> B : A delegatecall to B,  code in B is esecuted within context of A. code is read from B and written to A's storage. `msg.sender` and `msg.value` remain as those of A.

### `selfdestruct`
- `selfdestruct` force-sends ETH to a target address and removes the contract's code and storage.
- The recipient's `fallback`/`receive` is not executed; ETH is credited directly.
- Attackers can force ETH into a contract and break assumptions that rely on `address(this).balance` being driven only by your functions.
- Post-Cancun (EIP-6780), `selfdestruct` no longer fully deletes contracts except when called in the same transaction as creation, but forced ETH still matters.
- Examples:
- `nft/src/self-destruct.sol` shows a game that can be broken by forced ETH.
- `nft/src/hack-self-destruct.sol` uses `selfdestruct` to grief the game.
- `nft/src/Proxy.sol` and `nft/src/proxy.sol` are proxy/delegatecall examples related to upgradeability, not `selfdestruct`, but are included here for study alongside call-context behavior.
