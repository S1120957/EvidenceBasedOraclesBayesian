**Evidence-based Oracles Using Bayesian Network**

**Introduction**
BayesianSmartContract is an on-chain implementation of Bayesian inference in Solidity that classifies physician visits as  
in-person (PPH) or remote (PPR) based on multiple real-world evidence inputs. Unlike traditional smart contracts that rely on 
external oracles to provide and interpret data, this contract embeds a probabilistic reasoning engine directly within the 
Ethereum Virtual Machine (EVM), enabling trustless, transparent, and automated decision-making based on real-world medical indicators.

The contract accepts four binary real-world evidence inputs i.e.,
        1. GPS proximity (close or far),
        2. Patient confirmation of visit,
        3. Prescription issuance, and
        4. Medical device (PMD) data availability.

Then, Bayes’ Theorem is applied using predefined prior and conditional probabilities to:
        a) Compute likelihoods, joint probabilities, and posterior probabilities.
        b) Predict the most probable visit type (PPH or PPR) based on the evidence.
        c) Emit detailed inference logs via events (BayesianCalc and VisitPhysician) for auditability and verifiability.

**Event Output**
Two events are emitted by the smart contract:

1.    _BayesianCalc_ all intermediate Bayesian inference components:
        * priorPPH, priorPPR
        * likelihoodPPH, likelihoodPPR
        * jointPPH, jointPPR
        * marginalEvidence
        * posteriorPPH, posteriorPPR.

->  _VisitPhysician_:
        * The msg.sender (calling address)
        * The final predicted VisitType
        * The posterior probability of the predicted class
        * The block.timestamp
