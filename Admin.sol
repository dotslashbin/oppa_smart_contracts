// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Authorizer.sol"; 
import "./Validator.sol";

contract Admin is Authorizer, Validator {

    bool public _isActive; 
    uint internal _percentageOfRewards;
    uint internal _rewardsFrequencyInMinutes;

    modifier isAuthorized() {
        require(getDeployer() == msg.sender, "You do not have the authority for that."); 
        _;
    }

    function GetAvailableStakingBalance() isAuthorized public view returns(uint256) {
        return IBEP20(_staking_token).balanceOf(address(this));
    }

    function Pause() isAuthorized public {
        _isActive = false;
    }

    function SetRewardsFrequency(uint _value) isAuthorized public {
        _rewardsFrequencyInMinutes = _value;
    }

    function SetRewardsPercentage(uint _value) isAuthorized public {
        _percentageOfRewards = _value; 
    }

    function UnPause() isAuthorized public {
        _isActive = true; 
    }
}