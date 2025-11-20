# Token Mortgage Contract

A Clarity smart contract for managing mortgage agreements using SIP-010 fungible tokens on the Stacks blockchain.

## Features

- **Initialization:** Set up lender, borrower, collateral token, amounts, interest rate, and duration.
- **Collateral Deposit:** Borrower deposits SIP-010 token collateral.
- **Loan Provision:** Lender provides loan in STX.
- **Repayment:** Borrower repays loan plus interest; collateral is returned.
- **Liquidation:** Lender claims collateral if loan is not repaid.
- **Read-only Helpers:** Query mortgage state and calculate repayment amount.

## Usage

### 1. Deploy SIP-010 Token Contract

Ensure a SIP-010 compliant token contract is deployed and its trait is imported.

### 2. Deploy Mortgage Contract

Deploy this contract and initialize with:

```clarity
(initialize
  lender-principal
  borrower-principal
  collateral-token-principal
  collateral-amount
  loan-amount
  interest-rate
  duration)
```

### 3. Workflow

- **Borrower:** Calls `deposit-collateral` to deposit tokens.
- **Lender:** Calls `provide-loan` to send STX to borrower.
- **Borrower:** Calls `repay` to repay loan plus interest.
- **Lender:** If not repaid, calls `liquidate` to claim collateral.

## Functions

| Function                | Type           | Description                                      |
|-------------------------|----------------|--------------------------------------------------|
| `initialize`            | public         | Set up mortgage parameters                       |
| `deposit-collateral`    | public         | Borrower deposits collateral tokens              |
| `provide-loan`          | public         | Lender provides STX loan                         |
| `repay`                 | public         | Borrower repays loan and receives collateral     |
| `liquidate`             | public         | Lender claims collateral if loan not repaid      |
| `get-mortgage-state`    | read-only      | Returns current mortgage state                   |
| `calculate-repay-amount`| read-only      | Calculates total repayment amount                |

## Notes

- Token transfer calls are left as TODOs; enable them when a SIP-010 token contract is available.
- Error codes are defined for common failure scenarios.
- Contract state is managed via data variables.

## License

MIT
