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

We chose the logistic function for our CircuitBreaker implementation because it provides a more predictable release schedule and is more suitable for general scenarios. However, protocols can choose to implement the power function or any other suitable function based on their requirements.

## Integration

To integrate the CircuitBreaker with an existing DeFi protocol, follow these steps:

1. Deploy the CircuitBreaker contract, providing the required parameters: token address, delay period, release period, and liquidation resolver address.
2. In the DeFi protocol smart contract, add a condition to check if the transfer amount is above the predefined threshold.
3. If the transfer amount is above the threshold, call the `lockFunds` function of the CircuitBreaker contract to lock the funds temporarily.
4. Users can call the `unlockFunds` function of the CircuitBreaker contract to gradually release their locked funds over time.

Before deploying the CircuitBreaker on the mainnet, make sure to conduct a thorough review, testing, and auditing of the contract.

## Repository Structure

- `contracts/`: Contains the CircuitBreaker and ERC20Mock smart contracts.
- `test/`: Contains the test suites for the CircuitBreaker contract, written for Hardhat and Dapp Foundry frameworks.



