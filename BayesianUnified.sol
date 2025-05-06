// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BayesianUnified {
    enum VisitType { PPH, PPR }

    struct Evidence {
        bool gpsCat;
        bool pc;
        bool pr;
        bool pmd;
        bool hasGps;
        bool hasPc;
        bool hasPr;
        bool hasPmd;
    }

    mapping(address => Evidence) private evidences;

    // PPH Conditional Probabilities
    uint256 private constant PPH_PRIOR = 60;
    uint256 private constant gpsClosePPH = 90;
    uint256 private constant gpsFarPPH = 40;
    uint256 private constant pcTruePPH = 85;
    uint256 private constant prTruePPH = 80;
    uint256 private constant pmdTruePPH = 75;

    // PPR Conditional Probabilities
    uint256 private constant PPR_PRIOR = 40;
    uint256 private constant gpsClosePPR = 10;
    uint256 private constant gpsFarPPR = 60;
    uint256 private constant pcTruePPR = 20;
    uint256 private constant prTruePPR = 30;
    uint256 private constant pmdTruePPR = 25;

    event PosteriorComputed(address user, VisitType visitType, uint256 posterior);

    function provideEvidence(bool value, string memory key) public {
        Evidence storage e = evidences[msg.sender];
        if (keccak256(bytes(key)) == keccak256("gpsCat")) { e.gpsCat = value; e.hasGps = true; }
        else if (keccak256(bytes(key)) == keccak256("pc")) { e.pc = value; e.hasPc = true; }
        else if (keccak256(bytes(key)) == keccak256("pr")) { e.pr = value; e.hasPr = true; }
        else if (keccak256(bytes(key)) == keccak256("pmd")) { e.pmd = value; e.hasPmd = true; }
    }

    function finalizeInference(VisitType vt) public returns (uint256) {
        Evidence storage e = evidences[msg.sender];
        uint256 likelihood = 100;

        if (e.hasGps) {
            if (vt == VisitType.PPH)
                likelihood = (likelihood * (e.gpsCat ? gpsClosePPH : gpsFarPPH)) / 100;
            else
                likelihood = (likelihood * (e.gpsCat ? gpsClosePPR : gpsFarPPR)) / 100;
        }

        if (e.hasPc) {
            if (vt == VisitType.PPH)
                likelihood = (likelihood * (e.pc ? pcTruePPH : (100 - pcTruePPH))) / 100;
            else
                likelihood = (likelihood * (e.pc ? pcTruePPR : (100 - pcTruePPR))) / 100;
        }

        if (e.hasPr) {
            if (vt == VisitType.PPH)
                likelihood = (likelihood * (e.pr ? prTruePPH : (100 - prTruePPH))) / 100;
            else
                likelihood = (likelihood * (e.pr ? prTruePPR : (100 - prTruePPR))) / 100;
        }

        if (e.hasPmd) {
            if (vt == VisitType.PPH)
                likelihood = (likelihood * (e.pmd ? pmdTruePPH : (100 - pmdTruePPH))) / 100;
            else
                likelihood = (likelihood * (e.pmd ? pmdTruePPR : (100 - pmdTruePPR))) / 100;
        }

        uint256 prior = (vt == VisitType.PPH) ? PPH_PRIOR : PPR_PRIOR;
        uint256 posterior = (likelihood * prior) / 100;

        emit PosteriorComputed(msg.sender, vt, posterior);
        return posterior;
    }
}
