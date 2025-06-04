// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//BayesianInference - implementing a smart contract for sequential Bayesian inference
 contract BSCprogEvidences {
    // fixed precision with two decimals places
    uint256 private constant PRECISION = 1e2;
    
    // evidence structure
    struct Evidence {
        string identifier;          // string identifier for the evidence
        uint256 likelihoodRatio;    // likelihood for this evidence
    }
    
    // Bayesian variables as struct
    struct ModelState {
        uint256 step;                     // the current inference step
        uint256 priorProbability;         // prior probability before calculations start
        uint256 posteriorProbability;     // current posterior probability calculated
        Evidence[] evidenceList;          // stores all the evidence submitted to the Bayesian
        uint256 complexity;               // computational complexity metric observation
    }
    
    // main state of contract
    ModelState private state;
    
    // accessing rights and control
    address public owner;
    
    // possible events we are interested in
    event PosteriorUpdated(uint256 step, uint256 newPosterior, uint256 complexity);
    event StepAdvanced(uint256 step, string evidenceId);
    event ModelReset();
    
    // the only modification allow check
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // initialization of constructor with default prior probability of 50%
    constructor() {
        owner = msg.sender;
        // Initialize with 50% prior probability (0.5 in fixed point)
        state.priorProbability = 5 * (PRECISION / 10);
        state.posteriorProbability = state.priorProbability;
        state.step = 0;
        state.complexity = 1;
    }
    
    //Submitting a new evidence and updating the posterior probability
    //evidenceId String identifier for the evidence use for iteration

    function submitEvidence(string calldata evidenceId, uint256 likelihoodRatio) external {
        // verify the evidence that it has not been submitted before and hashing the ID for comparison
        for (uint i = 0; i < state.evidenceList.length; i++) {
            require(keccak256(bytes(state.evidenceList[i].identifier)) != keccak256(bytes(evidenceId)), 
                    "Evidence already submitted");
        }
        
        // storing evidence and the likelihood
        state.evidenceList.push(Evidence({
            identifier: evidenceId,
            likelihoodRatio: likelihoodRatio
        }));
        
        // Incrementing step counter
        state.step += 1;
        
        // Recalculating posterior probability using Bayesian update
        updatePosterior(likelihoodRatio);
        
        // Updating complexity that grows exponentially with number of evidence
        
        state.complexity = 1 << state.step; // equivalent to 2^step
        
        // Emit events
        emit StepAdvanced(state.step, evidenceId);
        emit PosteriorUpdated(state.step, state.posteriorProbability, state.complexity);
    }
    
    // Updating posterior probability and likelihood
    function updatePosterior(uint256 likelihoodRatio) private {
        // Bayesian update formula for posterior
        
        // Calculating the numerator: prior * likelihood
        uint256 numerator = (state.posteriorProbability * likelihoodRatio) / PRECISION;
        
        // Calculating the denominator: prior * likelihood + (1-prior) * 1
        uint256 complement = PRECISION - state.posteriorProbability;
        uint256 denominator = numerator + complement;
        
        // Updating posterior to avoid division
        if (denominator > 0) {
            state.posteriorProbability = (numerator * PRECISION) / denominator;
        }
    }
    
    // evidenceId String identifier for a new evidence
    function performComplexInference(string calldata evidenceId) external onlyOwner {
        // Verify this evidence has not been submitted before
        for (uint i = 0; i < state.evidenceList.length; i++) {
            require(keccak256(bytes(state.evidenceList[i].identifier)) != keccak256(bytes(evidenceId)), 
                    "Evidence already submitted");
        }
        
        // Simulating complex computation based on current complexity
        uint256 workAmount = state.complexity;
        uint256 computationResult = 0;
        
        // Perform "work" proportional to complexity
        for (uint i = 0; i < workAmount && i < 100; i++) {  // Cap at 100 to prevent many loop cycles
            computationResult = uint256(keccak256(abi.encodePacked(computationResult, i))) % PRECISION;
        }
        
        // Generating a likelihood ratio based on the computation
        uint256 likelihoodRatio = (computationResult % PRECISION) + 1; // Ensure non-zero
        
        // Storing the evidence and derived likelihood
        state.evidenceList.push(Evidence({
            identifier: evidenceId,
            likelihoodRatio: likelihoodRatio
        }));
        
        // Updating incrementing step counter
        state.step += 1;
        
        // Updating posterior
        updatePosterior(likelihoodRatio);
        
        // Updating complexity - grows exponentially
        state.complexity = 1 << state.step;
        
        // Emiting events
        emit StepAdvanced(state.step, evidenceId);
        emit PosteriorUpdated(state.step, state.posteriorProbability, state.complexity);
    }
    
    // Submitting evidence with evidenceType The type of evidence (1=gpsCat, 2=PC, 3=PMD, 4=PR)
    
    function submitEvidenceByType(uint8 evidenceType, uint256 likelihoodRatio) external {
        string memory evidenceId;
        
        if (evidenceType == 1) {
            evidenceId = "gpsCat";
        } else if (evidenceType == 2) {
            evidenceId = "PC";
        } else if (evidenceType == 3) {
            evidenceId = "PMD";
        } else if (evidenceType == 4) {
            evidenceId = "PR";
        } else {
            revert("Invalid evidence type");
        }
        
        // Checking if an evidence was already submitted
        for (uint i = 0; i < state.evidenceList.length; i++) {
            require(keccak256(bytes(state.evidenceList[i].identifier)) != keccak256(bytes(evidenceId)), 
                    "This evidence type already submitted");
        }
        
        // Storing the evidence and likelihood
        state.evidenceList.push(Evidence({
            identifier: evidenceId,
            likelihoodRatio: likelihoodRatio
        }));
        
        // Updating increment step counter
        state.step += 1;
        
        // Recalculating posterior probability using Bayesian update
        updatePosterior(likelihoodRatio);
        
        // Updating complexity
        state.complexity = 1 << state.step;
        
        // events 
        emit StepAdvanced(state.step, evidenceId);
        emit PosteriorUpdated(state.step, state.posteriorProbability, state.complexity);
    }
    
    // Reset the model to initial state
    function resetModel(uint256 newPrior) external onlyOwner {
        require(newPrior <= PRECISION, "Prior probability must be between 0 and 1");
        
        // Reset all state variables
        delete state.evidenceList;
        state.step = 0;
        state.priorProbability = newPrior;
        state.posteriorProbability = newPrior;
        state.complexity = 1;
        
        emit ModelReset();
    }
    
    
    // Get current state of the Bayesian model
    function getModelState() external view returns (
        uint256 step,
        uint256 prior,
        uint256 posterior,
        uint256 complexity,
        uint256 evidenceCount
    ) {
        return (
            state.step,
            state.priorProbability,
            state.posteriorProbability,
            state.complexity,
            state.evidenceList.length
        );
    }
    
    // Get evidence and likelihood ratio at specific index
    function getEvidenceAt(uint256 index) external view returns (
        string memory evidenceId,
        uint256 likelihoodRatio
    ) {
        require(index < state.evidenceList.length, "Index out of bounds");
        return (state.evidenceList[index].identifier, state.evidenceList[index].likelihoodRatio);
    }
    
    // Allow owner to transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
}