// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BayesianPPH_4 {
    uint256 private constant PRIOR_PPH = 60;
    uint256 private constant gpsCloseGivenPPH = 90;
    uint256 private constant gpsFarGivenPPH = 40;
    uint256 private constant pcGivenPPHTrue = 85;
    uint256 private constant pcGivenPPHFalse = 15;
    uint256 private constant prGivenPPHTrue = 80;
    uint256 private constant prGivenPPHFalse = 20;
    uint256 private constant pmdGivenPPHTrue = 75;
    uint256 private constant pmdGivenPPHFalse = 25;

    event PosteriorComputed(uint256 posterior);

    function predict(bool gpsCat, bool pc, bool pr, bool pmd) public returns (uint256) {
        uint256 gpsLikelihood = gpsCat ? gpsCloseGivenPPH : gpsFarGivenPPH;
        uint256 pcLikelihood = pc ? pcGivenPPHTrue : pcGivenPPHFalse;
        uint256 prLikelihood = pr ? prGivenPPHTrue : prGivenPPHFalse;
        uint256 pmdLikelihood = pmd ? pmdGivenPPHTrue : pmdGivenPPHFalse;

        uint256 likelihood = gpsLikelihood;
        likelihood = (likelihood * pcLikelihood) / 100;
        likelihood = (likelihood * prLikelihood) / 100;
        likelihood = (likelihood * pmdLikelihood) / 100;

        uint256 joint = (PRIOR_PPH * likelihood) / 100;
        emit PosteriorComputed(joint);
        return joint;
    }
}
