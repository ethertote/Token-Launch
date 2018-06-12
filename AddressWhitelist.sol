// Ethertote.com - optional customer whitelist contract - dev to discuss option

// UPDATE 12.06.18 - We will opt for a full public crowdsale without a whitelist, so this functionality
// will not longer be required


// full credit for contract and functions goes to Bounty0x
// github.com/bounty0x/Bounty0xCrowdsale/contracts/AddressWhitelist.sol


pragma solidity ^0.4.21;

import "./Ownable.sol';

// A simple contract that stores a whitelist of addresses, which the owner may update
contract AddressWhitelist is Ownable {
    // the addresses that are included in the whitelist
    mapping (address => bool) public whitelisted;

    function AddressWhitelist() public {
    }

    function isWhitelisted(address addr) view public returns (bool) {
        return whitelisted[addr];
    }

    event LogWhitelistAdd(address indexed addr);

    // add these addresses to the whitelist
    function addToWhitelist(address[] addresses) public onlyOwner returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            if (!whitelisted[addresses[i]]) {
                whitelisted[addresses[i]] = true;
                LogWhitelistAdd(addresses[i]);
            }
        }

        return true;
    }

    event LogWhitelistRemove(address indexed addr);

    // remove these addresses from the whitelist
    function removeFromWhitelist(address[] addresses) public onlyOwner returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            if (whitelisted[addresses[i]]) {
                whitelisted[addresses[i]] = false;
                LogWhitelistRemove(addresses[i]);
            }
        }

        return true;
    }
}
