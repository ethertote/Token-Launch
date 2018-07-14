// Ethertote - Team Tokens timelocked smart contract

pragma solidity 0.4.24;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "github.com/ethertote/core/SafeMath.sol";

// ----------------------------------------------------------------------------
// Imported Token Contract functions
// ----------------------------------------------------------------------------

contract Test777Token {
    function thisContractAddress() public pure returns (address) {}
    function balanceOf(address) public pure returns (uint256) {}
    function transfer(address, uint _amount) public {}
}


contract TeamTokens {
    using SafeMath for uint256;
    
    //   Test345Token public test345token;
  Test777Token public token;

    address public creator;
    address public owner;
    address public thisContractAddress;
    address public tokenContractAddress;
    
    // times/dates that tokens can be withdrawn 
    // expressed as Unix epoch time 
    // https://www.epochconverter.com/
    uint256 public unlockDate1;
    uint256 public unlockDate2;
    uint256 public unlockDate3;
    uint256 public unlockDate4;
    uint256 public createdAt;
    
    // percentage that the team can withdraw tokens
    uint public quarter1 = 25;
    uint public quarter2 = 25;
    uint public quarter3 = 25; 
    

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor (
        address _creator,
        address _owner,
        address _tokenAddress,
        uint256 _unlockDate1,
        uint256 _unlockDate2,
        uint256 _unlockDate3,
        uint256 _unlockDate4
    ) public {
        creator = _creator;
        owner = _owner;
        unlockDate1 = _unlockDate1;
        unlockDate2 = _unlockDate2;
        unlockDate3 = _unlockDate3;
        unlockDate4 = _unlockDate4;
        tokenContractAddress = _tokenAddress;
        createdAt = now;
        
    // admin = msg.sender;
    thisContractAddress = address(this);
    // tokenContractAddress = _tokenAddress;
    token = Test777Token(tokenContractAddress);
    
        
    }
    
      // check balance of this smart contract
  function thisContractTokenBalance() public view returns(uint) {
      return token.balanceOf(thisContractAddress);
  }

    // keep any ether sent to this address
    function() payable public { 
        emit Received(msg.sender, msg.value);
    }

    // callable by owner only, after specified time
    function withdraw1() onlyOwner public {
       require(now >= unlockDate1);
       // now allow a percentage of the balance
       token.transfer(owner, (thisContractTokenBalance().div(quarter1)));
       
       emit WithdrewTokens(thisContractAddress, owner, (thisContractTokenBalance().div(quarter1)));    // 25%
    }
    
    // callable by owner only, after specified time
    function withdraw2() onlyOwner public {
       require(now >= unlockDate2);
       // now allow a percentage of the balance
       token.transfer(owner, (thisContractTokenBalance().div(quarter2)));
       
       emit WithdrewTokens(thisContractAddress, owner, (thisContractTokenBalance().div(quarter2)));    // 25%
    }
    
    // callable by owner only, after specified time
    function withdraw3() onlyOwner public {
       require(now >= unlockDate3);
       // now allow a percentage of the balance
       token.transfer(owner, (thisContractTokenBalance().div(quarter3)));
       
       emit WithdrewTokens(thisContractAddress, owner, (thisContractTokenBalance().div(quarter3)));    // 25%
    }
    
    // callable by owner only, after specified time
    function withdraw4() onlyOwner public {
       require(now >= unlockDate4);
       // now allow a percentage of the balance
       token.transfer(owner, (thisContractTokenBalance()));
       
       emit WithdrewTokens(thisContractAddress, owner, (thisContractTokenBalance()));    // 25%
    }


    function infoWithdraw1() public view returns(address, address, uint256, uint256, uint256) {
        return (creator, owner, unlockDate1, createdAt, address(this).balance);
    }

    function infoWithdraw2() public view returns(address, address, uint256, uint256, uint256) {
        return (creator, owner, unlockDate2, createdAt, address(this).balance);
    }
    
    function infoWithdraw13() public view returns(address, address, uint256, uint256, uint256) {
        return (creator, owner, unlockDate3, createdAt, address(this).balance);
    }
    
    function infoWithdraw4() public view returns(address, address, uint256, uint256, uint256) {
        return (creator, owner, unlockDate4, createdAt, address(this).balance);
    }



    event Received(address from, uint256 amount);
    event WithdrewTokens(address tokenContract, address to, uint256 amount);
}
