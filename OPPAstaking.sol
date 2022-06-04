// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./AdminContext.sol";
import "./Authorizer.sol";
import "./Interfaces.sol"; 
import "./StakerContext.sol";
import "./TaxerContext.sol";
import "./Validator.sol";	


contract OPPA_staking is AdminContext, StakerContext, TaxerContext {
	uint256 private _staking_tax_in_percentage = 0;
	uint256 private _untaking_tax_in_percentage = 0;

	Validator _validator; 

	constructor(address token, uint frequency, uint percentage, uint integerMultipler, uint stakingTax, uint unstakingTax ) {
		_validator = new Validator(); 
		SetStakingTokenAddress(token);
		SetRewardsFrequency(frequency);
		SetRewardsPercentage(percentage); 
		SetIntegerMultiplier(integerMultipler);
		SetStakeTaxPercentage(stakingTax);
		SetUnstakeTaxPercentage(unstakingTax);
	}

	
	struct StakeSummary {
		uint block_time;
		uint256 total_rewards;
		uint start_time;	
		uint difference; 
	}

	// Events
	event LogRewards(uint256 totalRewards);

	/**
	 * Returns the following values
	 * frequency - total number of iterations to generate
	 */
	function _getFrequency(uint differenceInSeconds) private view returns(uint) {
		uint totalMinutes = differenceInSeconds / 60; 
		uint frequency = totalMinutes / _rewards_frequency_in_minutes; 

		return frequency;
	}

	/**
	 * Simple Interest formula
	 * NOTE: at this point, the _rewards_percentage_per_epoch has already been multiplied with the multiplier, 
	 * therefore, the final result should be divided wite the multiplier for the actual count.
	 */
	function _getRewards(uint256 principal, uint since) private view returns(uint256) {
		return (((block.timestamp - since) / 15 minutes) * principal) / _rewards_percentage_per_epoch;
	}

	/**
	 * Method to fetch all the stake holders in the contract
	 */
	function GetAllStakeholders() isAuthorized public view returns(Stakeholder[] memory) {
		return _stakeholders;
	}

	/**
	 * Method to generate the stake summary
	 */
	function GetStakeSummary() public view returns(StakeSummary memory) {
		Stakeholder memory stakeholder = _stakeholders[stakes[msg.sender]]; 

		uint startTime = stakeholder.address_stakes[0].since;
		uint256 stakedAmount = stakeholder.address_stakes[0].amount;

		// Iterations
		uint difference = block.timestamp - startTime;
		uint256 totalRewards;
		
		if((difference / 60) > 2) {
			totalRewards = _getRewards(stakedAmount, startTime);
		} else {
			// These are the default values that should be returned when there is no iteraton ( based on frequency ) 
			// that has happened yet
			totalRewards = 0; 
		}

		StakeSummary memory summary = StakeSummary(
			block.timestamp,
			totalRewards,
			startTime,
			difference);

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

	function GetTotalStaked() isAuthorized public view returns(uint256) {

		uint256 totalStaked; 

		for(uint i = 0; i < _stakeholders.length; i++) {
			Stake memory hodlerStake = _stakeholders[i].address_stakes[0]; // This is 0 for now because we are using only one slot at a time

			totalStaked += hodlerStake.amount; 
		}

		return totalStaked;
	}

	/**
	 * Initializes the process of staking tokens
	 */
	function StakeTokens(uint256 amount) public returns(bool success){
		require(IsStakingActive() == true, "Staking is not active as of the moment.");
		require(amount > 0, "Cannot stake nothing");
		require(_validator.CanStake(msg.sender, GetStakingTokenAddress()) == true, "Balance check failed.");

		uint256 valueTostake = deductTax(_stake_tax_percentage, amount, _integer_multiplier);
		_initStake(valueTostake);

		return true;
	}

	function UnstakeTokens() public returns (bool success) {
		require(IBEP20(GetStakingTokenAddress()).balanceOf(address(this)) > 0, "The contract does not have any balance"); 
		// Checks to see if the holder is indeed a staker
		Stake memory stake = GetStakes();
		require(stake.holder != address(0), "The sender is not a valid stake holder."); 

		StakeSummary memory summary = GetStakeSummary();

		uint256 stakePlusRewards = summary.total_rewards + stake.amount;
		uint256 totalMinusTax = deductTax(_unstake_tax_percentage, stakePlusRewards, _integer_multiplier);

		require(totalMinusTax > 0, "Rewards to send must have a value");
		IBEP20(GetStakingTokenAddress()).transfer(msg.sender, totalMinusTax);

		_initUnstake(msg.sender);
		return true; 
	}
}