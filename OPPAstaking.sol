// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Authorizer.sol";
import "./Validator.sol";
import "./Admin.sol";

contract OPPA_staking is Authorizer, Validator, Admin {
    uint256 private _staking_tax_in_percentage = 0;
    uint256 private _untaking_tax_in_percentage = 0;
    uint256 private _percentage_of_rewards = 10; // TODO: change to the correctavlue

    constructor() {
        SetDeployer(msg.sender);
    }

    // Events
    event stakeTokens (
		address indexed _staker
	);

    function Stake() public returns(bool success){
        if(CanStake() == true) {
            emit stakeTokens(msg.sender);
            return true;
        }

        return false;
    }
}