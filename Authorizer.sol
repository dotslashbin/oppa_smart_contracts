// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Authorizer {
    address private _deployer;

    // Modifiiers
    modifier isDeployer() {
        require(_deployer == msg.sender, "You have no authroity to interact with this contract");
        _; 
    }

    function getDeployer() isDeployer internal view returns(address) {
        return _deployer;
    }

    function SetDeployer(address _input) internal {
        _deployer = _input;
    }
}