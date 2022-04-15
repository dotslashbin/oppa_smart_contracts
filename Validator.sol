// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Authorizer.sol";
import "./Interfaces.sol";

contract Validator {

    address public _staking_token = 0x10eF5967D0c89263dDFe3417F2649756c6c6DbD7; // TODO: repalce this with the correct OPPA address
    uint256 private _minimum_balance = 1; 

    // Modifiiers
    modifier hasEnoughTokens() {
        uint256 balance = getTokenBalance();
        require(balance >= _minimum_balance, "The wallet does not have enough balance");
        _;
    }

    function getTokenBalance() private view returns(uint256) {
        return IBEP20(_staking_token).balanceOf(msg.sender);
    }

    function CanStake() hasEnoughTokens public view returns(bool success) {
        require(getTokenBalance() > 0, "There is not enough balance for to stake"); 
        // TODO: check if the staker has current stake
        return true; 
    }

    function CanUnstake() public pure returns(bool success) {
        // TODO implemet checking if there are tokens staked currently
        return true; 
    }
}