// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Authorizer.sol"; 
import "./Validator.sol";

contract Admin is Authorizer, Validator {

    modifier isAuthorized() {
        require(getDeployer() == msg.sender, "You do not have the authority for that."); 
        _;
    }

    function GetAvailableStakingBalance() isAuthorized public view returns(uint256) {
        return IBEP20(_staking_token).balanceOf(address(this));
    }

    function Pause() isAuthorized public {

    }

    function UnPause() isAuthorized public {
        
    }
}