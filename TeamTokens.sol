// Ethertote - Team Tokens timelocked smart contract

pragma solidity 0.4.24;

///////////////////////////////////////////////////////////////////////////////
// SafeMath Library 
///////////////////////////////////////////////////////////////////////////////
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


// ----------------------------------------------------------------------------
// Imported Token Contract functions
// ----------------------------------------------------------------------------

contract EthertoteToken {
    function thisContractAddress() public pure returns (address) {}
    function balanceOf(address) public pure returns (uint256) {}
    function transfer(address, uint) public {}
}


///////////////////////////////////////////////////////////////////////////////
// Main contract
//////////////////////////////////////////////////////////////////////////////

contract TeamTokens {
    using SafeMath for uint256;
    
    EthertoteToken public token;

    address public admin;
    address public thisContractAddress;
    
    address public tokenContractAddress;
    
    // the first team withdrawal can be made after:
    // GMT: Saturday, 1 December 2018 00:00:00
    // expressed as Unix epoch time 
    // https://www.epochconverter.com/
    uint256 public unlockDate1 = 1543622400;
    
    // the second team withdrawal can be made after:
    // GMT: Friday, 1 March 2019 00:00:00
    // expressed as Unix epoch time 
    // https://www.epochconverter.com/
    uint256 public unlockDate2 = 1551398400;
    
    // the third team withdrawal can be made after:
    // GMT: Saturday, 1 June 2019 00:00:00
    // expressed as Unix epoch time 
    // https://www.epochconverter.com/
    uint256 public unlockDate3 = 1559347200;
    
    // the final team withdrawal can be made after:
    // GMT: Sunday, 1 September 2019 00:00:00
    // expressed as Unix epoch time 
    // https://www.epochconverter.com/
    uint256 public unlockDate4 = 1567296000;
    
    // time of the contract creation
    uint256 public createdAt;
    
    // amount of tokens that will be claimed
    uint public tokensToBeClaimed;
    
    // ensure the function is only called once
    bool public claimAmountSet;
    
    // percentage that the team can withdraw tokens
    // it can naturally be inferred that quarter4 will also be 25%
    uint public percentageQuarter1 = 25;
    uint public percentageQuarter2 = 25;
    uint public percentageQuarter3 = 25;
    
    // 100%
    uint public hundredPercent = 100;
    
    // calculating the number used as the divider
    uint public quarter1 = hundredPercent.div(percentageQuarter1);
    uint public quarter2 = hundredPercent.div(percentageQuarter2);
    uint public quarter3 = hundredPercent.div(percentageQuarter3);
    
    bool public withdraw_1Completed;
    bool public withdraw_2Completed;
    bool public withdraw_3Completed;


    // MODIFIER
    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }
    
    // EVENTS
    event ReceivedTokens(address from, uint256 amount);
    event WithdrewTokens(address tokenContract, address to, uint256 amount);

    constructor () public {
        admin = msg.sender;
        thisContractAddress = address(this);
        createdAt = now;
        
        thisContractAddress = address(this);

        token = EthertoteToken(tokenContractAddress);
    }
    
      // check balance of this smart contract
  function thisContractTokenBalance() public view returns(uint) {
      return token.balanceOf(thisContractAddress);
  }
  
  function thisContractBalance() public view returns(uint) {
      return address(this).balance;
  }

    // keep any ether sent to this address
    function() payable public { 
        emit ReceivedTokens(msg.sender, msg.value);
    }

    // callable by owner only, after specified time
    function withdraw1() onlyAdmin public {
       require(now >= unlockDate1);
       require(withdraw_1Completed == false);
       // now allow a percentage of the balance
       token.transfer(admin, (tokensToBeClaimed.div(quarter1)));
       
       emit WithdrewTokens(thisContractAddress, admin, (tokensToBeClaimed.div(quarter1)));    // 25%
       withdraw_1Completed = true;
    }
    
    // callable by owner only, after specified time
    function withdraw2() onlyAdmin public {
       require(now >= unlockDate2);
       require(withdraw_2Completed == false);
       // now allow a percentage of the balance
       token.transfer(admin, (tokensToBeClaimed.div(quarter2)));
       
       emit WithdrewTokens(thisContractAddress, admin, (tokensToBeClaimed.div(quarter2)));    // 25%
       withdraw_2Completed = true;
    }
    
    // callable by owner only, after specified time
    function withdraw3() onlyAdmin public {
       require(now >= unlockDate3);
       require(withdraw_3Completed == false);
       // now allow a percentage of the balance
       token.transfer(admin, (tokensToBeClaimed.div(quarter3)));
       
       emit WithdrewTokens(thisContractAddress, admin, (tokensToBeClaimed.div(quarter3)));    // 25%
       withdraw_3Completed = true;
    }
    
    // callable by owner only, after specified time
    function withdraw4() onlyAdmin public {
       require(now >= unlockDate4);
       require(withdraw_3Completed == true);
       // now allow a percentage of the balance
       token.transfer(admin, (thisContractTokenBalance()));
       
       emit WithdrewTokens(thisContractAddress, admin, (thisContractTokenBalance()));    // 25%
    }
    
    
// ----------------------------------------------------------------------------
// This method can be used by admin to extract Eth accidentally 
// sent to this smart contract after all previous transfers have been made
// to the correct addresses
// ----------------------------------------------------------------------------
    function ClaimEth() onlyAdmin public {
        require(address(this).balance > 0);
        address(admin).transfer(address(this).balance);

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


// test functions

function setUnlockDate1(uint _value) onlyAdmin public {
    unlockDate1 = uint(_value);
}

function setUnlockDate2(uint _value) onlyAdmin public {
    unlockDate2 = uint(_value);
}

function setUnlockDate3(uint _value) onlyAdmin public {
    unlockDate3 = uint(_value);
}

function setUnlockDate4(uint _value) onlyAdmin public {
    unlockDate4 = uint(_value);
}

function setTokenContractAddress(address _address) onlyAdmin public {
    tokenContractAddress = address(_address);
    token = EthertoteToken(tokenContractAddress);
}


}
