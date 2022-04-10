// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

import "./Authorizer.sol";

contract Validator is Authorizer {

    address _staking_token = 0x431AcF08757484eE54051978143b0a61268e1c7f; // TODO: repalce this with the correct OPPA address
    uint256 private _minimum_balance = 1; 

    // // Modifiiers

    modifier hasEnoughTokens() {
        uint256 balance = getTokenBalance();
        require(balance >= _minimum_balance, "The wallet does not have enough balance");
        _;
    }

    function getTokenBalance() private view returns(uint256) {
        return IBEP20(_staking_token).balanceOf(msg.sender);
    }

    function CanStake() hasEnoughTokens internal view returns(bool success) {

        // TODO: check if the staker has current stake
        return true; 
    }

    function CanUnstake() internal pure returns(bool success) {
        // TODO implemet checking if there are tokens staked currently
        return true; 
    }
}