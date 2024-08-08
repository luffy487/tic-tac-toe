//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable(msg.sender) {
    address public authorizedContract;
    constructor() ERC20("GameToken","GT") {
    }
    function setAuthorizedContract(address _contract) public onlyOwner{
        authorizedContract = _contract;
    } 
    function mint(address to, uint256 amount) external{
        require(msg.sender == owner() || msg.sender == authorizedContract, "Not authorized");
        _mint(to, amount);
    }
}