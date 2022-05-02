// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract TaxerContext {

	function deductTax(uint256 tax, uint256 amount, uint intMultiplier ) internal pure returns(uint256) {
		require(amount > 0, "You need a base value to deduct tax from");

		if(tax == 0) { // returns the amount if tax is 0
			return amount;
		} 

		uint256 denominator = 100*intMultiplier;

		// At this point, "tax" has been multiplied by the multiplier use only integers
		uint256 valueToDeduct = (amount / denominator ) * tax; 
		return amount - valueToDeduct;
	}
}