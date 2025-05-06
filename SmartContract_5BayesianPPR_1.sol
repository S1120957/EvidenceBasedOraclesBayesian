// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BayesianPPR_1 {
    uint256 private constant PRIOR_PPR = 40;
    uint256 private constant gpsCloseGivenPPR = 10;
    uint256 private constant gpsFarGivenPPR = 60;

    event PosteriorComputed(uint256 posterior);

    function predict(bool gpsCat) public returns (uint256) {
        uint256 likelihood = gpsCat ? gpsCloseGivenPPR : gpsFarGivenPPR;
        uint256 joint = (PRIOR_PPR * likelihood) / 100;
        emit PosteriorComputed(joint);
        return joint;
    }
}
