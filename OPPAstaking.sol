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

	constructor(address token, uint frequency, uint percentage ) {
		_validator = new Validator(); 
		SetStakingTokenAddress(token);
		SetRewardsFrequency(frequency);
		SetRewardsPercentage(percentage); 
		UnPause(); // TODO: REMOVE this for the final
	}

	
	struct StakeSummary {
		uint256 total_rewards;
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

	function _getPercentageOfPrincipal(uint principal) private view returns(uint) {
		uint256 percentageValue = ((principal / 100) * _percentage_of_rewards);
		return percentageValue; 
	}

	
	function _getProjections(uint256 principal) private view returns(uint256) {
		uint256 projectedValue; 

		// TODO: this is not the correct implementation
		projectedValue += principal + (_getPercentageOfPrincipal(principal));

		return projectedValue;
	}

	function GetAllStakeholders() isAuthorized public view returns(Stakeholder[] memory) {
		return _stakeholders;
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

		uint256 totalRewards = _getProjections(stakedAmount);

		StakeSummary memory summary = StakeSummary(
			totalRewards,
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
}