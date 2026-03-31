## Phases

1. Initial Review
        a. Scoping
        b. Reconnaissance
        c. Vulnerability identification
        d. Reporting
2. Protocol fixes
        a. Fixes issues
        b. Retests and adds tests
3. Mitigation Review
        a. Reconnaissance
        b. Vulnerability identification
        C. Reporting

## Techniques
1. the Tincho
2. the Hans

## Costs of a review
Based on :
+ Code Complexity/nSLOC
+ Scope
+ Duration
+ Timeline

Commit hash + Downpayment
Initial Report : Findings categorized according to severity
Mitigation Phase : Protocol team to address vulnerabilities
Final Report : focuses on fixes made to address initial report's issues.

### Good pointers
+ Documentation
+ Test suite
+ Clear readable code
+ Best modern Practices
+ Clear communication channels
+ video walkthrough of code

### 

1. Get context - project purpose, the what and why and how
2. Use tools
3. Manual reviews
4. Write report


### OWASP : smart contract developer cycle

1. Plan and Design
2. Develop and Test
3. Get an Audit
4. Deploy
5. Monitor and Maintain

## Tests 

+ [nacentxyz simple-security-toolkit ](https://github.com/nascentxyz/simple-security-toolkit)

+ [The Rekt Test](https://blog.trailofbits.com/2023/08/14/can-you-pass-the-rekt-test/)


### Test Suites
+ Static Analysis - slither, 4nalyzer, **Mythril**, **Aderyn**
+ Fuzz Testing - fuzz testing and stateful fuzz testing
+ Differential testing & chaos testing

+ Formal verification: Mathematical Proofs
 - symbolic execution ; Manticore, Certora, Z3

### Attack vectors
1. Private Keys 
2. Reward manipulation
3. Price Oracle Manipulation
4. Insifficient Access Controls
5. Re-entracy (and Read-Only Re-entracy)