// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract StakerContext {
	// structures
	struct Stake {
		address holder;
		uint256 amount;
		uint256 since;
	}

	struct Stakeholder {
		address holder;
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
		uint256 holderIndex = _stakeholders.length - 1;
		// Assign the address to the new index
		_stakeholders[holderIndex].holder = staker;
		// Add index to the _stakeHolders
		stakes[staker] = holderIndex;
		return holderIndex; 
	}

	/**
	 * Excutes the process of staking tokens
	 */
	function _initStake(uint256 amount) internal returns(bool success) { 

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
		_stakeholders[index].address_stakes.push(Stake(msg.sender, amount, timestamp));
		// Emit an event that the stake has occured
		emit Staked(msg.sender, amount, index,timestamp);

		return true;
	}

	function _initUnstake(address holder) internal returns(bool success) {
		uint256 userIndex = stakes[holder];
		delete _stakeholders[userIndex];
		return true;
	}
}
