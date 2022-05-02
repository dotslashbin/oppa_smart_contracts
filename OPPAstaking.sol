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

	constructor(address token, uint frequency, uint percentage ) {
		_validator = new Validator(); 
		SetStakingTokenAddress(token);
		SetRewardsFrequency(frequency);
		SetRewardsPercentage(percentage); 
		UnPause(); // TODO: REMOVE this for the final
	}

	
	struct StakeSummary {
		uint256 total_rewards;
		uint256 remainingSeconds;	
	}

	// Events
	event LogRewards(uint256 totalRewards);

	/**
	 * Returns the following values
	 * frequency - total number of iterations to generate
	 * remainingSeconds - remaining seconds until the next iteration is computed
	 */
	function _getTimeDifferences(uint differenceInSeconds) private view returns(uint iterations, uint remainingSeconds) {
		uint totalMinutes = differenceInSeconds / 60; 
		uint frequency = totalMinutes / _rewards_frequency_in_minutes; 

		return (frequency, differenceInSeconds - (totalMinutes*60)); 
	}

	/**
	 * Simple Interest formula
	 */
	function _getProjections(uint256 principal, uint since, uint frequency) private view returns(uint256) {
		uint frequencyInSeconds = frequency * 60; 
		uint256 rewards = (((block.timestamp - since) / frequencyInSeconds) * principal) / _rewards_percentage_per_epoch;

		return principal + rewards;
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
		uint frequency; 
		uint remainingSeconds; 
		(frequency, remainingSeconds) = _getTimeDifferences(difference);

		uint256 totalRewards;
		
		if(frequency > 0) {
			totalRewards = _getProjections(stakedAmount, startTime, frequency);
		} else {
			// These are the default values that should be returned when there is no iteraton ( based on frequency ) 
			// that has happened yet
			totalRewards = 0; 
		}

		StakeSummary memory summary = StakeSummary(
			totalRewards,
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
		// TODO: implement the transferring

		_initUnstake(msg.sender);

		// IBEP20(GetStakingTokenAddress()).approve(address(this), 10000000);
		// IBEP20(GetStakingTokenAddress()).transferFrom(address(this), msg.sender, 10000000);
		return true; 
	}

	// TODO: delete all these test methods below
	///////////////////////////////////////////////////// temp methods
	function CleanStakes() isAuthorized public returns(bool success) {
		delete _stakeholders; 
		return true; 
	}

	event Test(uint amount, uint value, address sender); 

	struct TestOutput {
		uint256 token;
		uint256 bnb;
		address bnbee;	
	}

	function testPay(uint256 amount) public payable returns(TestOutput memory) {
		emit Test(amount, msg.value, msg.sender); 
		TestOutput memory output = TestOutput(amount,msg.value,msg.sender); 
		return output; 
	}
}