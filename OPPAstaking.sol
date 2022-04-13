// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Authorizer.sol";
import "./Validator.sol";
import "./Admin.sol";



contract OPPA_staking is Authorizer, Validator, Admin {
    uint256 private _staking_tax_in_percentage = 0;
    uint256 private _untaking_tax_in_percentage = 0;
    uint256 private _percentage_of_rewards = 10; // TODO: change to the correctavlue

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

    constructor() {
        SetDeployer(msg.sender);
    }

    // Events
    event Staked(address indexed staker, uint256 amount, uint256 index, uint256 timestamp); 

    function CallStake() public view returns(bool success){
        if(_isActive == true ) {
            return true;
        }

        return false;
    }
}