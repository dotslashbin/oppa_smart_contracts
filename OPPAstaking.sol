// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Admin.sol";
import "./Authorizer.sol";
import "./Interfaces.sol"; 
import "./Validator.sol";


contract OPPA_staking is Admin {
	uint256 private _staking_tax_in_percentage = 0;
	uint256 private _untaking_tax_in_percentage = 0;

	Validator _validator; 

	constructor(address token) {
		_validator = new Validator(); 
		SetStakingTokenAddress(token);
	}

	// structures
	struct Stake {
		address holder;
		uint256 amount;
		uint256 since;
	}

	struct Stakeholder {
		address holder;
		Stake[] address_stakes;
	}

	struct StakeSummary {
		uint256 epoch_difference;
		uint256 iterations; 
		uint256 remainingSeconds;
	}

	Stakeholder[] internal _stakeholders;

	// Mappings
	mapping(address => uint256) internal stakes;

	// Events
	event Staked(address indexed staker, uint256 amount, uint256 index, uint256 timestamp); 

	/**
	 * adds a new staker account in the array of stakeholers. 
	 */
	function _addStakeHolder(address staker) private returns (uint256) {
		// Push a empty item to the Array to make space for our new stakeholder
		_stakeholders.push();
		// Calculate the index of the last item in the array by Len-1
		uint256 holderIndex = _stakeholders.length - 1;
		// Assign the address to the new index
		_stakeholders[holderIndex].holder = staker;
		// Add index to the _stakeHolders
		stakes[staker] = holderIndex;
		return holderIndex; 
	}

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

		return (frequency, differenceInSeconds - (60* frequency)); 
	}

	function _getProjections(uint256 stakedAmount, uint iterations) private pure returns(uint256 nextReward, uint256 totalRewards, uint256 nextEpochTime) {
		uint256 initialReward = 0;

		for( uint i = 1; i <= iterations; i++ ) {
			if(initialReward == 0) {
				initialReward = stakedAmount; // TODO change this with the proper computation
			} 

			initialReward += i; 
		}

		return (8008, initialReward, 10); 
	}

	/**
	 * Returns the stakeholder array
	 * TODO: this is a temporary function
	 */
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
		

		uint x;
		uint256 totalRewards; 
		uint z; 

		(x,totalRewards,z) = _getProjections(stakedAmount, difference);

		// TODO: this was all 
		// StakeSummary memory summary = StakeSummary(difference, 
		// stakeholder.address_stakes[0].amount, 
		// stakeholder.address_stakes[0].holder, 
		// totalRewards, 
		// iterations, 
		// remainingSeconds); 

		StakeSummary memory summary = StakeSummary(
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

	function  GetValueToAdd(uint256 amount) public view returns(uint256) {
		// Compute for percentage
		uint256 valueToAdd = ((amount / 100) * _percentage_of_rewards);

		return valueToAdd; 
	}

	/**
	 * Excutes the process of staking tokens
	 */
	function StakeTokens(uint256 amount) public returns(bool success) { // TODO: change it back to boolean
		require(IsStakingActive() == true, "Staking is not active as of the moment.");
		require(amount > 0, "Cannot stake nothing");
		require(_validator.CanStake(msg.sender, GetStakingTokenAddress()) == true, "Balance check failed.");

		// Mappings in solidity creates all values, but empty, so we can just check the address
		uint256 index = stakes[msg.sender];
		
		// block.timestamp = timestamp of the current block in seconds since the epoch
		uint256 timestamp = block.timestamp;
		
		// See if the staker already has a staked index or if its the first time
		if(index == 0){
			// This stakeholder stakes for the first time
			// We need to add him to the stakeHolders and also map it into the Index of the stakes
			// The index returned will be the index of the stakeholder in the stakeholders array
			index = _addStakeHolder(msg.sender);
		}

		// Use the index to push a new Stake
		// push a newly created Stake with the current block timestamp.
		_stakeholders[index].address_stakes.push(Stake(msg.sender, amount, timestamp));
		// Emit an event that the stake has occured
		emit Staked(msg.sender, amount, index,timestamp);

		return true;
		
	}

	/**
	 * Executes the unstaking
	 * TODO: implement the proper behaviour
	 */
	function UnstakeTokens() isAuthorized public view returns (Stakeholder memory) {
		uint256 index = stakes[msg.sender]; 
		return _stakeholders[index]; 
	}

	///////////////////////////////////////////////////// temp methods
	function CleanStakes() isAuthorized public returns(bool success) {
		delete _stakeholders; 
		return true; 
	}
}