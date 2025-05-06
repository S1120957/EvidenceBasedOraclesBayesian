// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BayesianPPR_4 {
    uint256 private constant PRIOR_PPR = 40;
    uint256 private constant gpsCloseGivenPPR = 10;
    uint256 private constant gpsFarGivenPPR = 60;
    uint256 private constant pcGivenPPRTrue = 20;
    uint256 private constant pcGivenPPRFalse = 80;
    uint256 private constant prGivenPPRTrue = 30;
    uint256 private constant prGivenPPRFalse = 70;
    uint256 private constant pmdGivenPPRTrue = 25;
    uint256 private constant pmdGivenPPRFalse = 75;

    event PosteriorComputed(uint256 posterior);

    function predict(bool gpsCat, bool pc, bool pr, bool pmd) public returns (uint256) {
        uint256 gpsLikelihood = gpsCat ? gpsCloseGivenPPR : gpsFarGivenPPR;
        uint256 pcLikelihood = pc ? pcGivenPPRTrue : pcGivenPPRFalse;
        uint256 prLikelihood = pr ? prGivenPPRTrue : prGivenPPRFalse;
        uint256 pmdLikelihood = pmd ? pmdGivenPPRTrue : pmdGivenPPRFalse;

        uint256 likelihood = gpsLikelihood;
        likelihood = (likelihood * pcLikelihood) / 100;
        likelihood = (likelihood * prLikelihood) / 100;
        likelihood = (likelihood * pmdLikelihood) / 100;

        uint256 joint = (PRIOR_PPR * likelihood) / 100;
        emit PosteriorComputed(joint);
        return joint;
    }
}
