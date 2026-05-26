# About

https://github.com/Cyfrin/sc-exploits-minimized

# Static Analysis
+ pattern matching, don't run the code . i.e; slither, aderyn

Aderyn - `aderyn --root . `
Slither - `slither . `

# SOlidity Metrics
`npm install -g solidity-code-metrics`

solidity-code-metrics src/PuppyRaffle.sol > metric.md


### Note
storage variables can be shown using
`uint256 public s_entranceFee;`

immutable variables can be shown using
`uint256 public immutable i_entranceFee;` , `ENTRANCE`

running specific tests
`forge test --mt  test_denialOfService -vvv`

## DOS attacks
+ service DOS attack
- for loops with unbounded length (high gas when array is arbitrary long)