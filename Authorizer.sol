// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Authorizer {
    address internal _deployer;

    constructor(address owner) {
        _deployer = owner;
    }

    // Modifiiers
    modifier isDeployer() {
        require(_deployer == msg.sender, "You have no authroity to interact with this contract");
        _; 
    }

    function getDeployer() isDeployer public view returns(address) {
        return _deployer;
    }

}