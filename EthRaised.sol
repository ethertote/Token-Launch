// Ethertote - Eth Raised from Token Sale
//
// The following contract distributes a portion of the Eth raised to a time-locked
// contract as well as Tote Liquidator contract used to liquidate the Ethertote
// for the first 3 months of launch
//
// Note that ALL Eth raised from the token sale will initially go to this contract
// ----------------------------------------------------------------------------

pragma solidity 0.4.24;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract EthRaised {
    using SafeMath for uint256;

    address public thisContractAddress;
    address public admin;
    
    // time contract was deployed
    uint public createdAt;
    
    // address of the time-locked contract
    address public teamEthContract;
    
    // address of the ToteLiquidator
    address public toteLiquidatorContract;
    
    // ensure call is only made thisContractAddress
    uint public teamEthTransferComplete = 0;
    uint public toteLiquidatorTranserComplete = 0;
    

     // percentages to be sent 
    uint public percentageToTeamEthContract = 25;
    uint public percentageToToteLiquidatorContract = 25;
    
    // The remainder will be used for marketing, promotion,
    // running costs, exchange listing fees, and other things
    uint public remainingPercentage = 50;

    event Received(address from, uint256 amount);
    event Sent(address to, uint256 amount);
    
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

    // move Eth to team eth contract
    function sendToTeamEthContract() onlyAdmin public {
       require(teamEthTransferComplete == 0);
       require(address(this).balance > 0);
       // now allow a percentage of the balance
       address(teamEthContract).transfer((address(this).balance).div(percentageToTeamEthContract));
       emit Sent(msg.sender, (address(this).balance).div(percentageToTeamEthContract)); 
       //ensure function can only ever be called once
       teamEthTransferComplete = teamEthTransferComplete.add(1);
    }
    
    // move Eth to tote liquidator contract
    function sendToToteLiquidatorContract() onlyAdmin public {
       require(toteLiquidatorTranserComplete == 0);
       require(address(this).balance > 0);
       // now allow a percentage of the balance
       address(toteLiquidatorContract).transfer((address(this).balance).div(percentageToToteLiquidatorContract));
       emit Sent(msg.sender, (address(this).balance).div(percentageToToteLiquidatorContract)); 
       //ensure function can only ever be called once
       toteLiquidatorTranserComplete = toteLiquidatorTranserComplete.add(1);
    }
    
    
    // withdraw remainder to use to manage the business
    function withdrawRemainingEth() onlyAdmin public {
        // first confirm Eth has already been transferred to TeamEth fund
        // and ToteLiquidator fund
       require(teamEthTransferComplete == 1);
       require(toteLiquidatorTranserComplete == 1);
       
       // now allow all remaining balance
       msg.sender.transfer(address(this).balance);
       emit Sent(msg.sender, address(this).balance);    // all remaining balance
    }



}
