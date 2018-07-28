// Ethertote.com - contract template for ERC20

// full credit for contract and functions goes to OpenZeppelin
// github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC20/ERC20.sol


pragma solidity ^0.4.21;

import "./ERC20Basic.sol";


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
