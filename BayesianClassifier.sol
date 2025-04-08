// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
 * Bayesian inference smart contract for physician v isit
 * in-person (PPH) or remotely (PPR) based on multiple evidence variables 
 */
contract BayesianSmartContract {
    /// Physician possible visit types
    enum VisitType {PPH, PPR}

    /// Capturing the evidences
    struct Evidence{
        uint8 gpsCat;   // 0 = v_close, 1 = close, 2 = near, 3 = far
        bool pc;        // Patient Confirmation
        bool pr;        // Physician Prescription
        bool pmd;       // Physician Medical Device sensor data
    }

    /// Emit event after Bayesian inference completes and prediction is stored on-chain
    event VisitPhysician(
        address indexed physician,
        VisitType prediction,
        uint256 posteriorProbability,
        uint256 timestamp
    );

    /// Emit event with detailed probability info for transparency
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

    /// Priors for PPH and PPR in percentage * 10000 (four decimal precision)
    uint256 private constant PRIOR_PPH = 6000; // 0.60
    uint256 private constant PRIOR_PPR = 4000; // 0.40

    /// Conditional probabilities P(evidence | visitType) in percent * 10000
    uint256[4] private gpsGivenPPH = [9000, 7500, 6000, 4000]; 
    uint256[4] private gpsGivenPPR = [1000, 2500, 4000, 6000];
    uint256 private pcGivenPPHTrue = 8500;
    uint256 private pcGivenPPRTrue = 2000;
    uint256 private prGivenPPHTrue = 8000;
    uint256 private prGivenPPRTrue = 3000;
    uint256 private pmdGivenPPHTrue = 7500;
    uint256 private pmdGivenPPRTrue = 2500;

    /**
     * Calculating the likelihood of all evidence given a visit type
     * with e evidence structure containing all observations and 
     * the visit type for which we are calculating the likelihood
     * Returning Likelihood value scaled by 10000
     */
    function calculateLikelihood(Evidence calldata e, VisitType visitType) 
        private 
        view 
        returns (uint256) 
    {
        uint256 likelihood = 10000; // Start with 1.0

        // GPS likelihood
        likelihood = (likelihood * (
            visitType == VisitType.PPH ? 
            gpsGivenPPH[e.gpsCat] : 
            gpsGivenPPR[e.gpsCat]
        )) / 10000;

        // Patient confirmation likelihood
        likelihood = (likelihood * (
            e.pc ? 
            (visitType == VisitType.PPH ? pcGivenPPHTrue : pcGivenPPRTrue) : 
            (visitType == VisitType.PPH ? (10000 - pcGivenPPHTrue) : (10000 - pcGivenPPRTrue))
        )) / 10000; 

        // Physician prescription likelihood
        likelihood = (likelihood * (
            e.pr ? 
            (visitType == VisitType.PPH ? prGivenPPHTrue : prGivenPPRTrue) : 
            (visitType == VisitType.PPH ? (10000 - prGivenPPHTrue) : (10000 - prGivenPPRTrue))
        )) / 10000;

        // PMD data likelihood
        likelihood = (likelihood * (
            e.pmd ? 
            (visitType == VisitType.PPH ? pmdGivenPPHTrue : pmdGivenPPRTrue) : 
            (visitType == VisitType.PPH ? (10000 - pmdGivenPPHTrue) : (10000 - pmdGivenPPRTrue))
        )) / 10000;
        return likelihood;
    }

    /**
     * Predicting visit type using full Bayesian inference
     * with e evidence structure containing all observations
     * Returning predicted visit type (PPH or PPR)
     */
    function predictVisit(Evidence calldata e) public returns (VisitType) {
        // Calculate likelihoods: P(e|PPH) and P(e|PPR)
        uint256 likelihoodPPH = calculateLikelihood(e, VisitType.PPH);
        uint256 likelihoodPPR = calculateLikelihood(e, VisitType.PPR);
        
        // Calculating joint probabilities: P(PPH,e) = P(e|PPH) * P(PPH)
        uint256 jointPPH = (likelihoodPPH * PRIOR_PPH) / 10000;
        uint256 jointPPR = (likelihoodPPR * PRIOR_PPR) / 10000;
        
        // Calculating marginal evidence: P(e) = P(PPH,e) + P(PPR,e)
        uint256 marginalEvidence = jointPPH + jointPPR;
        
        // Calculating posterior probabilities: P(PPH|e) = P(PPH,e) / P(e)
        uint256 posteriorPPH = (jointPPH * 10000) / marginalEvidence;
        uint256 posteriorPPR = (jointPPR * 10000) / marginalEvidence;
        
        // Emit event having detailed calculation info
        emit BayesianCalc(
            PRIOR_PPH,
            PRIOR_PPR,
            likelihoodPPH,
            likelihoodPPR,
            jointPPH,
            jointPPR,
            marginalEvidence,
            posteriorPPH,
            posteriorPPR
        );
        
        // Final Decision: choosing the higher posterior probability
        VisitType predicted = posteriorPPH >= posteriorPPR ? VisitType.PPH : VisitType.PPR;
        
        emit VisitPhysician(
            msg.sender, 
            predicted, 
            predicted == VisitType.PPH ? posteriorPPH : posteriorPPR,
            block.timestamp
        );
        return predicted;
    }
    
    /**
     * Computing the probability of evidence using the rule of total probability
     * with e evidence structure containing all observations made 
     * The probability of evidence P(e) scaled by 10000
     */
    function calculateEvidenceProbability(Evidence calldata e) public view returns (uint256) {
        uint256 likelihoodPPH = calculateLikelihood(e, VisitType.PPH);
        uint256 likelihoodPPR = calculateLikelihood(e, VisitType.PPR);
        
        // P(e) = P(e|PPH)*P(PPH) + P(e|PPR)*P(PPR)
        return ((likelihoodPPH * PRIOR_PPH) + (likelihoodPPR * PRIOR_PPR)) / 10000;
    }
    
    /**
     *  Getting the posterior probability for a given visit type based on
     *  e Evidence structure containing all observations and 
     *  the visitType to get posterior probability
     *  Posterior probability P(visitType|e) scaled by 10000
     */
    function getPosteriorProbability(Evidence calldata e, VisitType visitType) 
        public 
        view 
        returns (uint256) 
    {
        uint256 likelihood = calculateLikelihood(e, visitType);
        uint256 prior = visitType == VisitType.PPH ? PRIOR_PPH : PRIOR_PPR;
        uint256 joint = (likelihood * prior) / 10000;
        uint256 evidence = calculateEvidenceProbability(e);
        
        // P(visitType|e) = P(e|visitType)*P(visitType) / P(e)
        return (joint * 10000) / evidence;
    }
}
