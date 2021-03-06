// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Authorizer.sol";
import "./Interfaces.sol";

contract Validator {
	uint256 private _minimum_balance = 1; 

	function GetTokenBalance(address wallet, address token) public view returns(uint256) {
		return IBEP20(token).balanceOf(wallet);
	}

	function CanStake(address wallet, address token) public view returns(bool success) {
		require(GetTokenBalance(wallet, token) > _minimum_balance, "There is not enough balance for you to stake"); 
		return true; 
	}
}