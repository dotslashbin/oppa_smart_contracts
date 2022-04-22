// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./AdminContext.sol";
import "./Authorizer.sol";
import "./Interfaces.sol"; 
import "./StakerContext.sol";
import "./Validator.sol";


contract OPPA_staking is AdminContext, StakerContext {
	uint256 private _staking_tax_in_percentage = 0;
	uint256 private _untaking_tax_in_percentage = 0;

	Validator _validator; 

	constructor(address token) {
		_validator = new Validator(); 
		SetStakingTokenAddress(token);
	}

	
	struct StakeSummary {
		uint256 next_rewards_amount; 
		uint256 total_rewards;
		uint256 total_difference;
		uint256 iterations;
		uint256 remainingSeconds;	
	}

	// Events
	event LogRewards(uint256 totalRewards);

	function _getEpochIterations(uint256 stakingPeriod) public view returns(uint256) {
		uint256 iterations = (stakingPeriod / 60) / _rewards_frequency_in_minutes; 
		return iterations; 
	}

	/**
	 * Returns the following values
	 * frequency - total number of iterations to generate
	 * remainingSeconds - remaining seconds until the next iteration is computed
	 */
	function _getNumberOfIterations(uint differenceInSeconds) private view returns(uint iterations, uint remainingSeconds) {
		uint totalMinutes = differenceInSeconds / 60; 
		uint frequency = totalMinutes / _rewards_frequency_in_minutes; 

		return (frequency, differenceInSeconds - (totalMinutes*60)); 
	}

	function _getProjections(uint256 stakedAmount, uint iterations) private view returns(uint256, uint256) {
		uint256 totalRewards = _getCalculatedReward(stakedAmount);
		uint256 nextReward = 0;
		for( uint iterator = 1; iterator <= iterations; iterator++ ) {
			nextReward = _getCalculatedReward(totalRewards);
			totalRewards += nextReward;
		}

		return (nextReward, totalRewards); 
	}

	function GetAllStakeholders() isAuthorized public view returns(Stakeholder[] memory) {
		return _stakeholders;
	}

	function _getCalculatedReward(uint256 amount) private view returns(uint256) {
		// Compute for percentage
		uint256 valueToAdd = ((amount / 100) * _percentage_of_rewards);

		return valueToAdd; 
	}

	function GetStakeSummary() public view returns(StakeSummary memory) {
		Stakeholder memory stakeholder = _stakeholders[stakes[msg.sender]]; 

		uint startTime = stakeholder.address_stakes[0].since;
		uint256 stakedAmount = stakeholder.address_stakes[0].amount;

		// Iterations
		uint difference = block.timestamp - startTime;
		uint iterations; 
		uint remainingSeconds; 
		(iterations, remainingSeconds) = _getNumberOfIterations(difference);
		

		uint nextReward;
		uint256 totalRewards; 

		(nextReward,totalRewards) = _getProjections(stakedAmount, iterations);

		StakeSummary memory summary = StakeSummary(
			nextReward, 
			totalRewards,
			difference,
			iterations,
			remainingSeconds); 

		return summary; 
	}

	/**
	 * Returns the number of staholders in the contract
	 */
	function GetStakeHolderCount() isAuthorized public view returns(uint) {
		return _stakeholders.length;    
	}

	/**
	 * Returns the current staking data of of the caller
	 */
	function GetStakes() public view returns (Stake memory) {
		uint256 holder_index = stakes[msg.sender];
		Stake memory current_stake = _stakeholders[holder_index].address_stakes[0];

		return current_stake; 
	}

	function StakeTokens(uint256 amount) public returns(bool success){
		require(IsStakingActive() == true, "Staking is not active as of the moment.");
		require(amount > 0, "Cannot stake nothing");
		require(_validator.CanStake(msg.sender, GetStakingTokenAddress()) == true, "Balance check failed.");

		_initStake(amount);

		return true;
	}

	/**
	 * Executes the unstaking
	 * TODO: implement the proper behaviour
	 */
	function UnstakeTokens() isAuthorized public view returns (bool success) {
		// TODO: implement the real one
		_initUnstake(msg.sender);

		return true; 
	}

	// TODO: delete all these test methods below
	///////////////////////////////////////////////////// temp methods
	function CleanStakes() isAuthorized public returns(bool success) {
		delete _stakeholders; 
		return true; 
	}

	function GetPercentage() isAuthorized public view returns(uint) {
		return _percentage_of_rewards; 
	}
}