// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Authorizer.sol"; 
import "./Validator.sol";
import "./Interfaces.sol"; 

contract AdminContext {

	bool public _is_active; 
	uint internal _integer_multiplier;
	uint internal _rewards_percentage_per_epoch;
	uint internal _tax_percentage;
	uint internal _rewards_frequency_in_minutes;
	Authorizer _contract_authorizer; 
	address private _staking_token; 

	constructor() {
		_contract_authorizer = new Authorizer(msg.sender);
	}

	// Modifiers
	modifier isAuthorized() {
		require(_contract_authorizer.getDeployer() == msg.sender, "You do not have the authority for that."); 
		_;
	}

	function GetAdminAddress() isAuthorized public view returns(address) {
		return _contract_authorizer.getDeployer();
	}

	/**
	 * Returns the available tokens for staking rewards in the contract
	 */ 
	function GetAvailableStakingBalance() isAuthorized public view returns(uint256) {
		return IBEP20(_staking_token).balanceOf(address(this));
	}

	function GetStakingTokenAddress() public view returns(address) {
		return _staking_token;
	}

	function IsStakingActive() internal view returns(bool) {
		return _is_active;
	}

	/**
	 * Checks if the staking is active
	 */ 
	function Pause() isAuthorized public {
		_is_active = false;
	}

	function setIntegerMultiplier(uint _value) isAuthorized public {
		require(_value > 0, "Integer multiplier needs to be greater than 0"); 
		_integer_multiplier = _value; 
	}

	/**
	 * Sets reward frequency
	 */
	function SetRewardsFrequency(uint _value) isAuthorized public {
		require(_value > 0, "Rewarards frequency cannot be 0");
		_rewards_frequency_in_minutes = _value;
	}

	/**
	 * Set the percentage of reward 
	 */ 
	function SetRewardsPercentage(uint _value) isAuthorized public {
		require(_value > 0, "Rewards percentage value cannot be 0");
		_rewards_percentage_per_epoch = _value; 
	}

	function SetStakingTokenAddress(address input) isAuthorized public {
		// TODO: secure the value of input
		_staking_token = input;
	}

	function setTaxPercentage(uint _value) isAuthorized public {
		require(_value > 0, "Tax percentage input needs to be more than 0");
		_tax_percentage =  _value * _integer_multiplier; 
	}

	/**
	 * Sets to start / unpause the staking
	 */ 
	function UnPause() isAuthorized public {
		_is_active = true; 
	}
}