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

 import "./Something.sol";

contract OPPA_staking is Something {
    address private _deployer;
    address _staking_token = 0x431AcF08757484eE54051978143b0a61268e1c7f; // TODO: repalce this with the correct OPPA address
    uint256 private _minimum_balance = 1; 
    uint256 private _staking_tax_in_percentage = 0;
    uint256 private _untaking_tax_in_percentage = 0;
    uint256 private _percentage_of_rewards = 10; // TODO: change to the correctavlue

    constructor() {
        _deployer = msg.sender;
    }

    // // Modifiiers
    modifier isDeployer() {
        require(_deployer == msg.sender, "This function is restricted to the deployer");
        _; 
    }

    // Events
    event Deposit(
        uint256 _amount
    );

    modifier hasEnoughTokens() {
        uint256 balance = getTokenBalance();
        require(balance >= _minimum_balance, "The wallet does not have enough balance");
        _;
    }

    modifier isAuthorized() {
        require(msg.sender == _deployer, "You do not have the privilege to make this call.");
        _;
    }

    function GetDeployer() public view returns(address) {
        return _deployer;
    }

    function GetAvailableStakingBalance() isAuthorized public view returns(uint256) {
        return IBEP20(_staking_token).balanceOf(address(this));
    }

    function getTokenBalance() isAuthorized private view returns(uint256) {
        return IBEP20(_staking_token).balanceOf(msg.sender);
    }

    function SaySomethingElse() public pure returns(string memory) {
        return string(abi.encodePacked(SaySomething(), "oieuoiur")); 
    }

    receive() external payable {
        emit Deposit(msg.value);
    }
}