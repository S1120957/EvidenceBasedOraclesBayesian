// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BayesianVisitClassifier {
    /// @notice Enum representing possible visit types
    enum VisitType { PPH, PPR }

    /// @notice Struct to encapsulate the input evidence
    struct Evidence {
        uint8 gpsCat;   // 0 = v_close, 1 = close, 2 = near, 3 = far
        bool pc;        // Patient Confirmation
        bool pr;        // Physician Prescription
        bool pmd;       // PMD Physician Medical Device data
    }

    /// @notice Emitted after the Bayesian decision is made and stored on-chain
    event VisitPredicted(address indexed physician, VisitType prediction, uint256 timestamp);

    /// @dev Priors for PPH and PPR in percentage * 100 (two decimal precision)
    uint256 private constant PRIOR_PPH = 6000; // 0.60
    uint256 private constant PRIOR_PPR = 4000; // 0.40

    /// @dev Conditional probabilities P(evidence | PPH) and P(evidence | PPR) in percent * 100
    uint256[4] private gpsGivenPPH = [9000, 7500, 6000, 4000];
    uint256[4] private gpsGivenPPR = [1000, 2500, 4000, 6000];

    uint256 private pcGivenPPHTrue = 8500;
    uint256 private pcGivenPPRTrue = 2000;

    uint256 private prGivenPPHTrue = 8000;
    uint256 private prGivenPPRTrue = 3000;

    uint256 private pmdGivenPPHTrue = 7500;
    uint256 private pmdGivenPPRTrue = 2500;

    /// @notice Main function to infer visit type using Bayesian inference directly in Solidity
    function predictVisit(Evidence calldata e) public returns (VisitType) {
        // Start with priors
        uint256 pph = PRIOR_PPH;
        uint256 ppr = PRIOR_PPR;

        // Update with GPS evidence
        pph = (pph * gpsGivenPPH[e.gpsCat]) / 10000;
        ppr = (ppr * gpsGivenPPR[e.gpsCat]) / 10000;

        // Update with PC
        pph = (pph * (e.pc ? pcGivenPPHTrue : (10000 - pcGivenPPHTrue))) / 10000;
        ppr = (ppr * (e.pc ? pcGivenPPRTrue : (10000 - pcGivenPPRTrue))) / 10000;

        // Update with PR
        pph = (pph * (e.pr ? prGivenPPHTrue : (10000 - prGivenPPHTrue))) / 10000;
        ppr = (ppr * (e.pr ? prGivenPPRTrue : (10000 - prGivenPPRTrue))) / 10000;

        // Update with PMD
        pph = (pph * (e.pmd ? pmdGivenPPHTrue : (10000 - pmdGivenPPHTrue))) / 10000;
        ppr = (ppr * (e.pmd ? pmdGivenPPRTrue : (10000 - pmdGivenPPRTrue))) / 10000;

        // Final Decision (MAP Estimate)
        VisitType predicted = pph >= ppr ? VisitType.PPH : VisitType.PPR;

        emit VisitPredicted(msg.sender, predicted, block.timestamp);
        return predicted;
    }
}
