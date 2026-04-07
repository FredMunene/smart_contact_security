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

# STEPS

## 1. Audit Readiness
+ [Rekt Test](https://blog.trailofbits.com/2023/08/14/can-you-pass-the-rekt-test/)

1. All actors, roles, and privileges documented?
2. 
..
12. 

Client should show commitment to security in their codebase.

## 2. Onboarding Questions
1. check out [onboarding questions](https://github.com/Cyfrin/security-and-auditing-full-course-s23/blob/main/minimal-onboarding-questions.md)
2. check out [detailed onoarding questions](https://github.com/Cyfrin/security-and-auditing-full-course-s23/blob/main/extensive-onboarding-questions.md)

3. About the project and business logic
4. Statistics; size of codebase, to estimate timeline  : SLOC,
 CLOC -  count blank lines, comment lines and physical lines of source code
5. Setup
6. Review scope; Exact commit hash. Github URL.
7. Compatibilities; versions, chains, tokens
8. Roles and powers
9. Known issues  `cloc ./src/`

+ Read through
+ Check tests

## 4. Reporting
[template](https://github.com/Cyfrin/security-and-auditing-full-course-s23/blob/main/finding_layout.md)
