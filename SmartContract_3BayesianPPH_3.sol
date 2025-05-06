// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BayesianPPH_3 {
    uint256 private constant PRIOR_PPH = 60;
    uint256 private constant gpsCloseGivenPPH = 90;
    uint256 private constant gpsFarGivenPPH = 40;
    uint256 private constant pcGivenPPHTrue = 85;
    uint256 private constant pcGivenPPHFalse = 15;
    uint256 private constant prGivenPPHTrue = 80;
    uint256 private constant prGivenPPHFalse = 20;

    event PosteriorComputed(uint256 posterior);

    function predict(bool gpsCat, bool pc, bool pr) public returns (uint256) {
        uint256 gpsLikelihood = gpsCat ? gpsCloseGivenPPH : gpsFarGivenPPH;
        uint256 pcLikelihood = pc ? pcGivenPPHTrue : pcGivenPPHFalse;
        uint256 prLikelihood = pr ? prGivenPPHTrue : prGivenPPHFalse;

        uint256 likelihood = (((gpsLikelihood * pcLikelihood) / 100) * prLikelihood) / 100;
        uint256 joint = (PRIOR_PPH * likelihood) / 100;
        emit PosteriorComputed(joint);
        return joint;
    }
}
