// deployed to address 0xe5d91e4574dd5e043034a91b2e46a6caebc13db8    (Kovan)

pragma solidity 0.4.24;

import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol';

contract KovanToteToken is MintableToken {
    string public name = "Ethertote Kovan Token";
    string public symbol = "KTOTE";
    uint8 public decimals = 18;
}
