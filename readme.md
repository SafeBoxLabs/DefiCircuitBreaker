# CircuitBreaker

CircuitBreaker is a smart contract that implements a circuit breaker mechanism for DeFi protocols. It temporarily locks funds above a certain threshold in a separate vault and releases them gradually over time. The goal of the CircuitBreaker is to protect user funds from critical protocol failures or flaws that can lead to a significant loss of funds.

## Background

In the DeFi ecosystem, critical protocol failures can result in the loss of user funds within a single transaction. Traditional circuit breakers in DeFi often don't provide enough time to take countermeasures to protect these funds. This CircuitBreaker contract aims to address this issue by locking and gradually releasing the funds based on a predefined configuration.

## Release Mechanism

The CircuitBreaker implements two alternative functions for `f(t)` to calculate the fraction of funds to be released over time:

1. Power function: `f(t) = ((Δt - d) / p)^n`
2. Logistic function: `f(t) = 1 / (1 + e^(-(t - d - p/2)))`

Both functions have their merits depending on the specific requirements of a DeFi protocol:

- The power function allows for a faster or slower release of funds, depending on the value of `n`.
- The logistic function provides a smoother and more controlled release of funds, with an S-shaped curve that starts slow, accelerates as it approaches the midpoint, and slows down again as it approaches the end of the release period.

Currently logistic function for our CircuitBreaker is implementated because it provides a more predictable release schedule and is more suitable for general scenarios. However, we will be building the power function CircuitBreaker too.

## Integration
To use the CircuitBreaker smart contract, you will need to interact with the contract's functions, such as locking and releasing funds. You can do this using the ABI and the contract's address.

Here is a brief overview of the primary functions:

`transferTo(address recipient, uint256 amount)`: Transfers the specified amount of tokens to the recipient. If the amount is greater than or equal to the minimum lock amount, the funds will be locked and released over time.

`unlockFor(address recipient, uint256 lockTimestamp)`: Unlocks the funds for the specified recipient according to the release curve. This function can only be called by the recipient.

`getWithdrawableAmount(address recipient, uint256 lockTimestamp)` : Returns the amount of funds that can be withdrawn by the recipient at the current time.

## Repository Structure

- `src/`: Contains the CircuitBreaker and ERC20Mock smart contracts.
- `test/`: Contains the test suites for the CircuitBreaker contract, written for Hardhat and Dapp Foundry frameworks.



