// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Admin.sol";
import "./Authorizer.sol";
import "./Interfaces.sol"; 
import "./Validator.sol";

contract OPPA_staking is Admin {
    uint256 private _staking_tax_in_percentage = 0;
    uint256 private _untaking_tax_in_percentage = 0;
    uint256 private _percentage_of_rewards = 10; 
    Validator _validator; 

    constructor(address token) {
        _validator = new Validator(); 
        SetStakingTokenAddress(token);
    }

    // structures
    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    Stakeholder[] internal _stakeholders;

    // Mappings
    mapping(address => uint256) internal stakes;

    // Events
    event Staked(address indexed staker, uint256 amount, uint256 index, uint256 timestamp); 

    /**
     * adds a new staker account in the array of stakeholers. 
     */
    function _addStakeHolder(address staker) private returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        _stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = _stakeholders.length - 1;
        // Assign the address to the new index
        _stakeholders[userIndex].user = staker;
        // Add index to the _stakeHolders
        stakes[staker] = userIndex;
        return userIndex; 
    }

    /**
     * Returns the stakeholder array
     * TODO: this is a temporary function
     */
    function GetAllStakeholders() isAuthorized public view returns(Stakeholder[] memory) {
        return _stakeholders;
    }

    /**
     * Returns the number of staholders in the contract
     */
    function GetStakeHolderCount() isAuthorized public view returns(uint) {
        return _stakeholders.length;    
    }

    /**
     * Returns the current staking data of of the caller
     */
    function GetStake() isAuthorized public view returns (Stakeholder memory) {
        uint256 index = stakes[msg.sender]; 
        return _stakeholders[index]; 
    }

    /**
     * Excutes the process of staking tokens
     */
    function StakeTokens(uint256 _amount) public returns(bool success) { // TODO: change it back to boolean
        require(IsStakingActive() == true, "Staking is not active as of the moment.");
        require(_amount > 0, "Cannot stake nothing");
        require(_validator.CanStake(msg.sender, GetStakingTokenAddress()) == true, "Balance check failed.");

        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[msg.sender];
        
        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;
        
        // See if the staker already has a staked index or if its the first time
        if(index == 0){
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeHolder(msg.sender);
        }

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        _stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp));
        // Emit an event that the stake has occured
        emit Staked(msg.sender, _amount, index,timestamp);

        return true;
        
    }

    /**
     * Executes the unstaking
     * TODO: implement the proper behaviour
     */
    function UnstakeTokens() isAuthorized public view returns (Stakeholder memory) {
        uint256 index = stakes[msg.sender]; 
        return _stakeholders[index]; 
    }

}