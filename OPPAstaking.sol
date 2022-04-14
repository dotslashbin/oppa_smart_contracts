// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Authorizer.sol";
import "./Validator.sol";
import "./Admin.sol";



contract OPPA_staking is Admin {
    uint256 private _staking_tax_in_percentage = 0;
    uint256 private _untaking_tax_in_percentage = 0;
    uint256 private _percentage_of_rewards = 10; 
    Validator _validator; 

    constructor() {
        _validator = new Validator(); 
    }

    // structures
    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    Stakeholder[] internal stakeholders;

    // Mappings
    mapping(address => uint256) internal stakes;

    // Events
    event Staked(address indexed staker, uint256 amount, uint256 index, uint256 timestamp); 

    function CallStake() public view returns(bool success){
        if(IsStakingActive() == true ) {
            return true;
        }

        return false;
    }
}