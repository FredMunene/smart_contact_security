## [M-1] Looping through the players array to check for duplicates in `PuppyRaffle::enterRaffle` causes a denial of service due to incrementing gas costs

**Description**

the `PuppyRaffle::enterRaffle` function loops through the `players` array to check for duplicates. However, the longer the `PuppyRaffle:players` array is, the more checks a new player will have to make. This means more gas costs for players who enter the raffle later on.Every additional player is an additional check the loop will have to make.


```solidity
for (uint256 i = 0; i < players.length - 1; i++) {
    for (uint256 j = i + 1; j < players.length; j++) {
        require(players[i] != players[j], "PuppyRaffle: Duplicate player");
    }
}
```

**Impact**

DOS attack on the fucntion would make it costly for users to enter the raffle. An attacker may make it very expensive for others to enter, guaranteeing themselves the win.


**Proof of Concept**

Added `testEnterRaffleGasIncreasesWithMorePlayers` that compares gas costs between a small raffle roster(1 player) and a large raffle roster(100 players)

```solidity
    function testEnterRaffleGasIncreasesWithMorePlayers() public {
        PuppyRaffle smallRaffle = new PuppyRaffle(entranceFee, feeAddress, duration);
        PuppyRaffle largeRaffle = new PuppyRaffle(entranceFee, feeAddress, duration);

        _seedRaffle(smallRaffle, 10); // create a raffle with 10 players
        _seedRaffle(largeRaffle, 100); // create a raffle with 100 players

        //  create a new player and add them to the small raffle
        address[] memory newPlayer = new address[](1);
        newPlayer[0] = address(111);

        uint256 gasBefore = gasleft();
        smallRaffle.enterRaffle{value: entranceFee}(newPlayer);
        uint256 gasUsedSmall = gasBefore - gasleft();

        //  create a new player and add them to the big raffle
        newPlayer[0] = address(222);
        gasBefore = gasleft();
        largeRaffle.enterRaffle{value: entranceFee}(newPlayer);
        uint256 gasUsedLarge = gasBefore - gasleft();


        console2.log("Gas used for small raffle:", gasUsedSmall); // gas - 82097
        console2.log("Gas used for large raffle:", gasUsedLarge); // gas - 4277087


        //  confirm gas spent in big raffle is more than in small raffle
        assertGt(gasUsedLarge, gasUsedSmall);
    }

```

**Recommended Mitigation**

1. Consider using a map to check for duplicate addresses.

```diff
+    mapping(address => uint256) public addressToRaffleId;
+    uint256 public raffleId = 0;


    function enterRaffle(address[] memory newPlayers) public payable {

        require(msg.value == entranceFee * newPlayers.length, "PuppyRaffle: Must send enough to enter raffle");
        
        for (uint256 i = 0; i < newPlayers.length; i++) {
            players.push(newPlayers[i]);
            addressToRaffleId[newPlayers[i] = raffleId]
        }

-        for (uint256 i = 0; i < players.length - 1; i++) {
-           for (uint256 j = i + 1; j < players.length; j++) {
-               require(players[i] != players[j], "PuppyRaffle: Duplicate player");
-           }
-       }
+       // Check for duplicates 
+       for (uint256 i = 0; i < newPlayers.length; i++){
+           require(addressToRaffleId[newPlayers[i]] != raffleId, "PuppyRaffle: Duplicate player");
+    
+       }
        emit RaffleEnter(newPlayers);
    }

```
2. Use [OpenZepelin's EnumerableSet Library](https://docs.openzeppelin.com/contracts/5.x/api/utils#EnumerableSet)


## [I-1] Retrieving index of active players and if player is not active the return value is `0`  in `PuppyRaffle::getActivePlayerIndex` causes a confusion since player at index 0 wouldn't be unsure  whether they are in the raffle or not.

**Description**

The `PuppyRaffle::getActivePlayerIndex` function loops through the `player` list to retrieve the index using player's wallet. If the player is not on the list, the result is 0. 
Array index start at 0 which would confuse the player at index 0. 

```javascript
    function getActivePlayerIndex(address player) external view returns (uint256) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) {
                return i;
            }
        }
        // @audit this undermines player at index 0 
        return 0;
    }
```
**Impact**

Whenever the response is 0, there would be confusion as to whether truly the wallet is at index 0 of the list or they are actually not on the list.

**Proof of Concept**


```javascript
    function testPlayerAtIndexZero() public {
        address[] memory players = new address[](2);
        players[0] = playerOne;
        players[1] = playerTwo;
        puppyRaffle.enterRaffle{value: entranceFee * 2}(players);

        // player at the first index return 0
        assertEq(puppyRaffle.getActivePlayerIndex(playerOne), 0);
        // player not in the list return 0
        assertEq(puppyRaffle.getActivePlayerIndex(playerThree), 0);
    }
```
**Recommended Mitigation**

Return a second boolean value to indicate whether the player was found in the active players array. This prevents ambiguity between a valid index of 0 and the "not found" case.

```diff
-    function getActivePlayerIndex(address player) external view returns (uint256 ) {
+    function getActivePlayerIndex(address player) external view returns (uint256, bool ) {    
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) {
-                return i;
+                return (i, true)
            }
        }
        // @audit this undermines player at index 0 
-      return 0;
+      return (i, false)
    }

```

## [M-2] Weak PRNG in `PuppyRaffle::selectWinner` allows a miner or caller to manipulate the winner and NFT rarity

**Description**

The winner and NFT rarity are both derived from on-chain values that are either known in advance or controllable by a miner:

```javascript
// winner selection
uint256 winnerIndex = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.difficulty))) % players.length;

// rarity selection
uint256 rarity = uint256(keccak256(abi.encodePacked(msg.sender, block.difficulty))) % 100;
```

- `msg.sender` is chosen by the attacker.
- `block.timestamp` can be nudged by a few seconds by the block proposer.
- `block.difficulty` was replaced by `block.prevrandao` after the Merge — but `prevrandao` is also influenceable by the current validator, who can choose to withhold a block if the revealed randomness does not favour them.

Hashing known or influenceable inputs does not produce unpredictable randomness.

**Impact**

- A validator participating in the raffle can simulate the `keccak256` off-chain with different `block.timestamp` values, pick the timestamp that makes them the winner, and only propose that block.
- Any caller can brute-force `msg.sender` (e.g. by deploying from different `CREATE2` salts) to land on the winning index before calling `selectWinner`.
- The same manipulation applies to `rarity`, so an attacker can guarantee themselves a Legendary NFT.
- The prize pool and NFT rarity are therefore not fair — they are gameable by a sufficiently motivated participant.

**Proof of Concept**

1. Attacker computes off-chain: `uint256(keccak256(abi.encodePacked(attackerAddress, block.timestamp, block.prevrandao))) % players.length` for every timestamp in the valid range.
2. Attacker finds the timestamp that yields their own index as `winnerIndex`.
3. Attacker calls `selectWinner` at exactly that timestamp (or bribes a validator to include the tx at that timestamp).
4. Attacker is selected as winner and receives the prize pool.

**Recommended Mitigation**

Use Chainlink VRF (Verifiable Random Function) to obtain randomness that is verifiably unpredictable and tamper-proof:

```javascript
// 1. Request randomness from Chainlink VRF in selectWinner
uint256 requestId = i_vrfCoordinator.requestRandomWords(...);

// 2. Fulfil in the VRF callback — randomness is now provably fair
function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
    uint256 winnerIndex = randomWords[0] % players.length;
    uint256 rarity      = randomWords[1] % 100;
    // ... rest of winner logic
}
```

This removes all on-chain inputs from the randomness calculation. Until a VRF integration is feasible, at minimum avoid using `msg.sender` and `block.timestamp` as entropy sources.

## [M-3] Arithmetic precision loss in `PuppyRaffle::selectWinner` leaves funds permanently stuck in the contract

**Description**

In `selectWinner`, both `prizePool` and `fee` are calculated independently using integer division by 100:

```javascript
uint256 totalAmountCollected = players.length * entranceFee;
uint256 prizePool = (totalAmountCollected * 80) / 100;
uint256 fee = (totalAmountCollected * 20) / 100;
```

Because Solidity truncates on division, `prizePool + fee` can be less than `totalAmountCollected`. The remainder is never sent anywhere — it stays in the contract forever. This also breaks `withdrawFees`, which requires an exact balance match:

```javascript
require(address(this).balance == uint256(totalFees), "PuppyRaffle: There are currently players active!");
```

If even 1 wei is stuck from precision loss, this require will always fail and fees can never be withdrawn.

**Impact**

- ETH is permanently locked in the contract with no recovery path.
- `withdrawFees` becomes uncallable as long as any precision-loss remainder sits in the contract balance, meaning the fee address never receives its cut.
- Severity is Medium: funds are lost, but the amount per raffle is small (at most 99 wei when dividing by 100).

**Proof of Concept**

Consider 3 players each paying 1 wei entrance fee:

```
totalAmountCollected = 3 wei
prizePool = (3 * 80) / 100 = 240 / 100 = 2 wei  (truncated from 2.4)
fee       = (3 * 20) / 100 =  60 / 100 = 0 wei  (truncated from 0.6)

prizePool + fee = 2 wei  ≠  3 wei collected
→ 1 wei stuck in contract forever
```

With realistic ETH-denominated entrance fees the per-round loss is at most 99 wei, but it accumulates across every raffle and permanently blocks `withdrawFees`.

**Recommended Mitigation**

Calculate one value and derive the other by subtraction so the full amount is always accounted for:

```diff
uint256 totalAmountCollected = players.length * entranceFee;
- uint256 prizePool = (totalAmountCollected * 80) / 100;
- uint256 fee = (totalAmountCollected * 20) / 100;
+ uint256 fee = (totalAmountCollected * 20) / 100;
+ uint256 prizePool = totalAmountCollected - fee;
```

This guarantees `prizePool + fee == totalAmountCollected` exactly, with no remainder left in the contract.

## [M-4] `uint64` overflow in `PuppyRaffle::selectWinner` silently truncates accumulated fees

**Description**

`totalFees` is declared as `uint64`, but `fee` (derived from `totalAmountCollected`) is a `uint256`. The cast discards the upper bits:

```javascript
uint64 public totalFees = 0;
// ...
totalFees = totalFees + uint64(fee);
```

`uint64` can hold a maximum of ~18.4 ETH (18446744073709551615 wei). Any raffle where the accumulated fees exceed this silently wraps around to a small number, causing the protocol to record far less than it actually collected.

**Impact**

- The owner loses accumulated fees — `withdrawFees` pays out `totalFees`, which is now an undercount of what the contract actually holds.
- The exact-balance check in `withdrawFees` (`address(this).balance == uint256(totalFees)`) will fail permanently once overflow occurs, because the real contract balance is higher than the truncated `totalFees` value. Fees can never be withdrawn.
- Severity is High: direct, unrecoverable loss of protocol revenue with no admin escape hatch.

**Proof of Concept**

`uint64` max = `18446744073709551615` wei ≈ 18.4 ETH.

With a 1 ETH entrance fee and 20% fee rate, each raffle round produces 0.2 ETH in fees. After ~93 rounds the cumulative fee crosses the `uint64` ceiling and overflows:

```
93 rounds × 1 ETH × 20% = 18.6 ETH in fees
uint64(18.6e18) overflows → totalFees wraps to a small value
withdrawFees reverts forever because address(this).balance ≠ totalFees
```

**Recommended Mitigation**

Change `totalFees` to `uint256` to match the type of `fee` and eliminate the cast:

```diff
- uint64 public totalFees = 0;
+ uint256 public totalFees = 0;

- totalFees = totalFees + uint64(fee);
+ totalFees = totalFees + fee;
```
## [M-5] Forcibly sending ETH via `selfdestruct` breaks `PuppyRaffle::withdrawFees` permanently

**Description**

`withdrawFees` enforces an exact balance check before paying out:

```javascript
require(address(this).balance == uint256(totalFees), "PuppyRaffle: There are currently players active!");
```

The intent is to confirm no active players hold funds. However, `address(this).balance` counts **all** ETH in the contract, not just entrance fees. An attacker can force ETH into the contract by calling `selfdestruct` on a helper contract that targets `PuppyRaffle`. Because `selfdestruct` bypasses `receive` and `fallback` (neither of which exist here), the contract has no way to reject the ETH.

Once even 1 wei of extra ETH lands this way, `address(this).balance` will always exceed `totalFees`, the require will always fail, and fees can never be withdrawn.

**Impact**

- The protocol owner permanently loses the ability to withdraw accumulated fees.
- `withdrawFees` reverts on every call with no recovery path — there is no admin function to correct `totalFees` or drain the contract.
- A griefing attacker can execute this with as little as 1 wei. Severity is High: it permanently breaks a core protocol function at near-zero cost to the attacker.

**Proof of Concept**

```solidity
contract Attacker {
    constructor(address payable target) payable {
        // forces 1 wei into PuppyRaffle, bypassing receive/fallback
        selfdestruct(target);
    }
}
```

After deploying this with 1 wei:
```
address(puppyRaffle).balance = totalFees + 1
→ withdrawFees() reverts forever
```

**Recommended Mitigation**

Replace the strict equality check with a `>=` comparison so that any extra ETH in the contract does not block withdrawal:

```diff
- require(address(this).balance == uint256(totalFees), "PuppyRaffle: There are currently players active!");
+ require(address(this).balance >= uint256(totalFees), "PuppyRaffle: There are currently players active!");
```

This preserves the original intent (ensure fees are available to withdraw) while making the contract resilient to forced ETH deposits.

## [I-2] `PuppyRaffle::_baseURI` should be a constant variable instead of a function

**Description**

`_baseURI` is an internal override of the OpenZeppelin ERC721 hook used to prefix token metadata URIs. Its body returns a single hardcoded string literal that never changes:

```javascript
function _baseURI() internal pure returns (string memory) {
    return "data:application/json;base64,";
}
```

Because the return value is invariant, this is better expressed as a `constant` state variable, which the compiler inlines directly into bytecode at every callsite — eliminating the function dispatch overhead entirely.

**Impact**

Minor gas inefficiency on every `tokenURI` call. No security impact. Informational only.

**Recommended Mitigation**

```diff
+ string private constant BASE_URI = "data:application/json;base64,";

- function _baseURI() internal pure returns (string memory) {
-     return "data:application/json;base64,";
- }
+ function _baseURI() internal pure override returns (string memory) {
+     return BASE_URI;
+ }
```

Or, if the OZ version in use allows overriding with a constant directly, remove the function altogether and expose `BASE_URI` to the parent via the override.

## [H-1] Refunded player slot left as `address(0)` in `PuppyRaffle::selectWinner` causes prize ETH to be burned and inflated prize pool drains the contract

**Description**

When a player refunds, their slot in the `players` array is set to `address(0)` but the slot is not removed:

```javascript
// refund()
players[playerIndex] = address(0);
```

`selectWinner` then picks a winner by index from that same array without checking for zero addresses:

```javascript
address winner = players[winnerIndex]; // could be address(0)
```

Two compounding problems follow:

1. **Inflated prize pool** — `totalAmountCollected` is calculated from the full array length, including refunded slots whose ETH has already been paid back:

```javascript
uint256 totalAmountCollected = players.length * entranceFee;
uint256 prizePool = (totalAmountCollected * 80) / 100;
```

The contract overpays the prize from funds it no longer holds, draining ETH that belongs to other players or the fee balance.

2. **ETH burned or tx reverted** — the prize is sent to `address(0)`:

```javascript
(bool success,) = winner.call{value: prizePool}("");
```

A call to `address(0)` succeeds at the EVM level (`success == true`) and the ETH is burned permanently. However, `_safeMint(winner, tokenId)` — called with `winner == address(0)` — reverts in OpenZeppelin's implementation, causing the entire `selectWinner` transaction to revert. The raffle round is stuck: nobody can win until the next round resets.

**Impact**

- Prize ETH is either burned or the round is bricked with no winner selected.
- `totalAmountCollected` overcounts refunded players, so the contract pays out more ETH than it received for active players — directly draining funds that belong to fee collection or future rounds.
- Severity is High: direct, unrecoverable ETH loss with no admin escape.

**Proof of Concept**

```javascript
function test_refundedPlayerWinsRaffle() public {
    // Four players enter
    address[] memory players = new address[](4);
    players[0] = playerOne;
    players[1] = playerTwo;
    players[2] = playerThree;
    players[3] = playerFour;
    puppyRaffle.enterRaffle{value: entranceFee * 4}(players);

    // playerOne refunds — slot 0 becomes address(0)
    vm.prank(playerOne);
    puppyRaffle.refund(0);

    // If the PRNG resolves to index 0, selectWinner sends prize to address(0)
    // _safeMint(address(0)) reverts → entire round is bricked
    vm.warp(block.timestamp + duration + 1);
    puppyRaffle.selectWinner(); // reverts or burns ETH
}
```

**Recommended Mitigation**

Two changes are needed:

1. Skip zero-address slots when selecting the winner, or better, remove refunded players from the array by swapping with the last element and popping:

```diff
  function refund(uint256 playerIndex) public {
      address playerAddress = players[playerIndex];
      require(playerAddress == msg.sender, "PuppyRaffle: Only the player can refund");
      require(playerAddress != address(0), "PuppyRaffle: Player already refunded");
      payable(msg.sender).sendValue(entranceFee);
-     players[playerIndex] = address(0);
+     players[playerIndex] = players[players.length - 1];
+     players.pop();
      emit RaffleRefunded(playerAddress);
  }
```

2. Calculate `totalAmountCollected` from the contract's actual balance rather than `players.length`, or track active player count separately, to avoid the inflated prize pool:

```diff
- uint256 totalAmountCollected = players.length * entranceFee;
+ uint256 totalAmountCollected = address(this).balance;
```

## [L-1] Missing zero-address validation on `feeAddress` in `PuppyRaffle` constructor and `changeFeeAddress`

**Description**

Both the constructor and `changeFeeAddress` assign `feeAddress` without checking that the provided address is not `address(0)`:

```javascript
// constructor
feeAddress = _feeAddress;

// changeFeeAddress
function changeFeeAddress(address newFeeAddress) external onlyOwner {
    feeAddress = newFeeAddress;
}
```

If `address(0)` is passed — accidentally or through a misconfiguration — all accumulated fees sent via `withdrawFees` will be burned forever with no recovery path.

**Impact**

Accumulated protocol fees permanently lost if `feeAddress` is ever set to `address(0)`. Low severity: requires owner error or malicious owner action, not an external attacker.

**Recommended Mitigation**

Add a zero-address guard in both places:

```diff
  constructor(uint256 _entranceFee, address _feeAddress, uint256 _raffleDuration) {
+     require(_feeAddress != address(0), "PuppyRaffle: Fee address cannot be zero");
      feeAddress = _feeAddress;
  }

  function changeFeeAddress(address newFeeAddress) external onlyOwner {
+     require(newFeeAddress != address(0), "PuppyRaffle: Fee address cannot be zero");
      feeAddress = newFeeAddress;
  }
```

## [I-3] `PuppyRaffle::_isActivePlayer` is dead code and should be removed

**Description**

`_isActivePlayer` is defined as an `internal` function but is never called anywhere in the contract:

```javascript
function _isActivePlayer() internal view returns (bool) {
    for (uint256 i = 0; i < players.length; i++) {
        if (players[i] == msg.sender) {
            return true;
        }
    }
    return false;
}
```

Dead code increases the auditable surface area, adds unnecessary bytecode, and can mislead auditors into thinking it serves a purpose. It also contains an O(n) loop over `players` — the same gas scalability problem as the duplicate check in `enterRaffle`.

**Impact**

No security impact. Informational only — code quality and unnecessary gas overhead in deployed bytecode.

**Recommended Mitigation**

Remove the function entirely:

```diff
- function _isActivePlayer() internal view returns (bool) {
-     for (uint256 i = 0; i < players.length; i++) {
-         if (players[i] == msg.sender) {
-             return true;
-         }
-     }
-     return false;
- }
```
