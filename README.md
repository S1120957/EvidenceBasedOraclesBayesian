**Evidence-based Oracles Using Bayesian Network**

**Introduction**
BayesianSmartContract is an on-chain implementation of Bayesian inference in Solidity that classifies physician visits as  
in-person (PPH) or remote (PPR) based on multiple real-world evidence inputs. Unlike traditional smart contracts that rely on 
external oracles to provide and interpret data, this contract embeds a probabilistic reasoning engine directly within the 
Ethereum Virtual Machine (EVM) enables trustless, transparent, automated decision-making based on real-world medical indicators.

The contract accepts four binary real-world evidence inputs, i.e.,
        1. GPS proximity (close or far),
        2. Patient Confirmation of visit,
        3. Prescription Record, and
        4. Physician Medical Device (PMD) data availability.

Then, Bayes’ Theorem is applied using predefined prior and conditional probabilities to:
        a) Compute likelihoods, joint probabilities, and posterior probabilities.
        b) Predict the most probable visit type (PPH or PPR) based on the evidence.
        c) Emit detailed inference logs via events (BayesianCalc and VisitPhysician) for auditability and verifiability.

**Repository Material**
https://opensource.org/license/MIT
https://soliditylang.org/ 
https://sepolia.etherscan.io/ 

A suite of Solidity smart contracts implementing Bayesian network inference for healthcare services. These contracts calculate the probability that a physician provided home health service (PPH) given different evidence types. The contracts calculate the posterior probability that a home health service occurred based on available evidence.
Key Features:
a) Evidence-Based Validation: Uses multiple data sources to validate healthcare services
b) Probabilistic Inference: Implements Bayesian network calculations on-chain
c) Progressive Implementation: Starts with 1 evidence type and scales to all 4
d) Transparent Logic: All probability calculations are visible and verifiable on-chain




