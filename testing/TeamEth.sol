// Ethertote - Team Eth timelocked smart contract
//
// The following contract offers peace of mind to investors as the
// Eth that will go to the members of the Ethertote team
// will be time-locked over a 12-month period whereby
// The withdraw functions can only be called when the current timestamp is 
// greater than the time specified in each functions
// ----------------------------------------------------------------------------

pragma solidity 0.4.24;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract TeamEth {
    using SafeMath for uint256;

    address public thisContractAddress;
    address public admin;
    
    // time expressed in seconds of 3 months (1 quarter of a year)
    uint public oneQuarterInSeconds = 7890000;
    
    
    // the first team withdrawal can be made after December 1st 2018
    // expressed as Unix epoch time 
    // https://www.epochconverter.com/
    uint256 public unlockDate1 = 1543622400;
    
    uint256 public unlockDate2 = unlockDate1.add(oneQuarterInSeconds);
    uint256 public unlockDate3 = unlockDate2.add(oneQuarterInSeconds);
    uint256 public unlockDate4 = unlockDate3.add(oneQuarterInSeconds);
    
    uint256 public createdAt;
    
    // percentage that the team can withdraw Eth
    // it can naturally be inferred that quarter4 will be 25%
    uint public quarter1 = 25;
    uint public quarter2 = 25;
    uint public quarter3 = 25;

    event Received(address from, uint256 amount);
    event Withdrew(address to, uint256 amount);
    
    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }

    constructor () public {
        admin = msg.sender;
        thisContractAddress = address(this);
        createdAt = now;
    }

    // fallback to store all the ether sent to this address
    function() payable public { 
        emit Received(msg.sender, msg.value);
    }
    
    function thisContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    // team withdrawal after specified time
    function withdraw1() onlyAdmin public {
       require(now >= unlockDate1);
       // now allow a percentage of the balance
       msg.sender.transfer((address(this).balance).div(quarter1));
       emit Withdrew(msg.sender, (address(this).balance).div(quarter1));    // 25%
    }
    
    // team withdrawal after specified time
    function withdraw2() onlyAdmin public {
       require(now >= unlockDate2);
       // now allow a percentage of the balance
       msg.sender.transfer((address(this).balance).div(quarter2));
       emit Withdrew(msg.sender, (address(this).balance).div(quarter2));    // 25%
    }
    
    // team withdrawal after specified time
    function withdraw3() onlyAdmin public {
       require(now >= unlockDate3);
       // now allow a percentage of the balance
       msg.sender.transfer((address(this).balance).div(quarter3));
       emit Withdrew(msg.sender, (address(this).balance).div(quarter3));    // 25%
    }
    
    // team withdrawal after specified time
    function withdraw4() onlyAdmin public {
       require(now >= unlockDate4);
       // now allow all remaining balance
       msg.sender.transfer(address(this).balance);
       emit Withdrew(msg.sender, address(this).balance);    // all remaining balance
    }


    function infoWithdraw1() public view returns(address, uint256, uint256, uint256) {
        return (admin, unlockDate1, createdAt, address(this).balance);
    }

    function infoWithdraw2() public view returns(address, uint256, uint256, uint256) {
        return (admin, unlockDate2, createdAt, address(this).balance);
    }
    
    function infoWithdraw13() public view returns(address, uint256, uint256, uint256) {
        return (admin, unlockDate3, createdAt, address(this).balance);
    }
    
    function infoWithdraw4() public view returns(address, uint256, uint256, uint256) {
        return (admin, unlockDate4, createdAt, address(this).balance);
    }


}
