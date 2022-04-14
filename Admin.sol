// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Authorizer.sol"; 
import "./Validator.sol";
import "./Interfaces.sol"; 

contract Admin {

    bool public _isActive; 
    uint internal _percentageOfRewards;
    uint internal _rewardsFrequencyInMinutes;
    Authorizer _contractAuthorizer; 

    constructor() {
        _contractAuthorizer = new Authorizer(msg.sender);
    }

    // Modifiers
    modifier isAuthorized() {
        require(_contractAuthorizer.getDeployer() == msg.sender, "You do not have the authority for that."); 
        _;
    }

    function GetAdminAddress() isAuthorized public view returns(address) {
        return _contractAuthorizer.getDeployer();
    }

    /**
     * Returns the available tokens for staking rewards in the contract
     */ 
    function GetAvailableStakingBalance() isAuthorized public view returns(uint256) {
        // return IBEP20(_staking_token).balanceOf(address(this));
        return 102323;
    }

    function IsStakingActive() isAuthorized internal view returns(bool) {
        return _isActive;
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
    function UnPause() isAuthorized internal {
        _isActive = true; 
    }

    // function WidthrawToWallet(address _wallet, uint256 _amount) public returns(bool success) {
    //     require(GetAvailableStakingBalance() > 0, "There are no more toekns in the contract."); 
    //     // _wallet += amount
    //     return true; 
    // }
}