// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Authorizer.sol"; 
import "./Validator.sol";

contract Admin is Authorizer, Validator {

    bool public _isActive; 
    uint internal _percentageOfRewards;
    uint internal _rewardsFrequencyInMinutes;

    // Modifiers
    modifier isAuthorized() {
        require(getDeployer() == msg.sender, "You do not have the authority for that."); 
        _;
    }

    /**
     * Returns the available tokens for staking rewards in the contract
     */ 
    function GetAvailableStakingBalance() isAuthorized public view returns(uint256) {
        return IBEP20(_staking_token).balanceOf(address(this));
    }

    /**
     * Checks if the staking is active
     */ 
    function Pause() isAuthorized public {
        _isActive = false;
    }

    /**
     * Sets reward frequency
     */
    function SetRewardsFrequency(uint _value) isAuthorized public {
        _rewardsFrequencyInMinutes = _value;
    }

    /**
     * Set the percentage of reward 
     */ 
    function SetRewardsPercentage(uint _value) isAuthorized public {
        _percentageOfRewards = _value; 
    }

    /**
     * Sets to start / unpause the staking
     */ 
    function UnPause() isAuthorized public {
        _isActive = true; 
    }

    function WidthrawToWallet(address _wallet, uint256 _amount) public returns(bool success) {
        require(GetAvailableStakingBalance() > 0, "There are no more toekns in the contract."); 
        // _wallet += amount
        return true; 
    }
}