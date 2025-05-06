// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BayesianPPH_1 {
    uint256 private constant PRIOR_PPH = 60;
    uint256 private constant gpsCloseGivenPPH = 90;
    uint256 private constant gpsFarGivenPPH = 40;

    event PosteriorComputed(uint256 posterior);

    function predict(bool gpsCat) public returns (uint256) {
        uint256 likelihood = gpsCat ? gpsCloseGivenPPH : gpsFarGivenPPH;
        uint256 joint = (PRIOR_PPH * likelihood) / 100;
        emit PosteriorComputed(joint);
        return joint;
    }
}
