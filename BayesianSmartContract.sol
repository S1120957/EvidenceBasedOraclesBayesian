// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * Bayesian inference smart contract for physician visit:
 * in-person (PPH) or remotely (PPR) based on multiple evidence variables.
 * Probabilities are represented as percentages (0–100).
 */
contract BayesianSmartContract {
    /// Representing predicted visit types
    enum VisitType { PPH, PPR }

    /// Capturing evidences
    struct Evidence {
        bool gpsCat;   // true = close, false = far
        bool pc;       // Patient Confirmation
        bool pr;       // Physician Prescription
        bool pmd;      // Physician Medical Device sensor data
    }

    /// Emits event after Bayesian prediction and storage on-chain
    event VisitPhysician(
        address indexed physician,
        VisitType prediction,
        uint256 posteriorProbability,
        uint256 timestamp
    );

    /// Emits detailed Bayesian computation values
    event BayesianCalc(
        uint256 priorPPH,
        uint256 priorPPR,
        uint256 likelihoodPPH,
        uint256 likelihoodPPR,
        uint256 jointPPH,
        uint256 jointPPR,
        uint256 marginalEvidence,
        uint256 posteriorPPH,
        uint256 posteriorPPR
    );

    /// Prior probabilities (percentage scale)
    uint256 private constant PRIOR_PPH = 60;        // 60%
    uint256 private constant PRIOR_PPR = 40;        // 40%

    /// Conditional probabilities (in percentage)
    uint256 private constant gpsCloseGivenPPH = 90;
    uint256 private constant gpsFarGivenPPH = 40;
    uint256 private constant gpsCloseGivenPPR = 10;
    uint256 private constant gpsFarGivenPPR = 60;

    uint256 private constant pcGivenPPHTrue = 85;
    uint256 private constant pcGivenPPRTrue = 20;

    uint256 private constant prGivenPPHTrue = 80;
    uint256 private constant prGivenPPRTrue = 30;

    uint256 private constant pmdGivenPPHTrue = 75;
    uint256 private constant pmdGivenPPRTrue = 25;

    /// Computing full likelihood for each visit type
    function calculateLikelihood(Evidence calldata e, VisitType vt) private pure returns (uint256) {
        uint256 likelihood = 100;

        // GPS
        if (e.gpsCat) {
            likelihood = (likelihood * (vt == VisitType.PPH ? gpsCloseGivenPPH : gpsCloseGivenPPR)) / 100;
        } else {
            likelihood = (likelihood * (vt == VisitType.PPH ? gpsFarGivenPPH : gpsFarGivenPPR)) / 100;
        }

        // Patient confirmation
        likelihood = (likelihood * (
            e.pc 
                ? (vt == VisitType.PPH ? pcGivenPPHTrue : pcGivenPPRTrue)
                : (vt == VisitType.PPH ? (100 - pcGivenPPHTrue) : (100 - pcGivenPPRTrue))
        )) / 100;

        // Physician prescription
        likelihood = (likelihood * (
            e.pr 
                ? (vt == VisitType.PPH ? prGivenPPHTrue : prGivenPPRTrue)
                : (vt == VisitType.PPH ? (100 - prGivenPPHTrue) : (100 - prGivenPPRTrue))
        )) / 100;

        // Physician medical device data
        likelihood = (likelihood * (
            e.pmd 
                ? (vt == VisitType.PPH ? pmdGivenPPHTrue : pmdGivenPPRTrue)
                : (vt == VisitType.PPH ? (100 - pmdGivenPPHTrue) : (100 - pmdGivenPPRTrue))
        )) / 100;

        return likelihood;
    }

    /// Performing full Bayesian inference and emitting results
    function predictVisit(Evidence calldata e) public returns (VisitType) {
        uint256 likelihoodPPH = calculateLikelihood(e, VisitType.PPH);
        uint256 likelihoodPPR = calculateLikelihood(e, VisitType.PPR);

        uint256 jointPPH = (likelihoodPPH * PRIOR_PPH) / 100;
        uint256 jointPPR = (likelihoodPPR * PRIOR_PPR) / 100;

        uint256 marginal = jointPPH + jointPPR;

        uint256 posteriorPPH = (jointPPH * 100) / marginal;
        uint256 posteriorPPR = (jointPPR * 100) / marginal;

        emit BayesianCalc(
            PRIOR_PPH,
            PRIOR_PPR,
            likelihoodPPH,
            likelihoodPPR,
            jointPPH,
            jointPPR,
            marginal,
            posteriorPPH,
            posteriorPPR
        );

        VisitType prediction = posteriorPPH >= posteriorPPR ? VisitType.PPH : VisitType.PPR;

        emit VisitPhysician(
            msg.sender,
            prediction,
            prediction == VisitType.PPH ? posteriorPPH : posteriorPPR,
            block.timestamp
        );

        return prediction;
    }

    /// Returning posterior for a given visit type
    function getPosterior(Evidence calldata e, VisitType vt) public pure returns (uint256) {
        uint256 likelihood = calculateLikelihood(e, vt);
        uint256 prior = (vt == VisitType.PPH) ? PRIOR_PPH : PRIOR_PPR;
        uint256 joint = (likelihood * prior) / 100;
        uint256 total = (
            (calculateLikelihood(e, VisitType.PPH) * PRIOR_PPH) +
            (calculateLikelihood(e, VisitType.PPR) * PRIOR_PPR)
        ) / 100;

        return (joint * 100) / total;
    }
}
