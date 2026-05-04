## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


## How to determining a finding's severity

The severity of a finding is determined based on the potential impact and likelihood of exploitation. The following criteria can be used to classify findings into different severity levels:
+ High : funds are directly or nearly directly at risk, severe disruption of protocol functionality or availability. Highly probably to happen.
+ Medium : funds indirectly at risk or some level of disruption. Might occur under specific conditions.
+ Low Security : funds not at risk. unlikely to occur.

Impact vs Likelihood
| Impact \ Likelihood | High | Medium | Low |
|--------------------|------|--------|-----|
| High               | High | High   | Medium |
| Medium             | High | Medium | Low    |
| Low                | Medium | Low    | Low    |

How likely is it that somebody will be able to exploit this? - `High`
How much damage could be caused if somebody were to exploit this? - `High`