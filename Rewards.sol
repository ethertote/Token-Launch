// Ethertote - Reward/Recogniton contract
// 05.08.18 
//
// ----------------------------------------------------------------------------
// Overview
// ----------------------------------------------------------------------------
//
// There are various individuals who we will be looking to reward over the coming 
// weeks with TOTE tokens. Admins will add an ethereum wallet address and a 
// number of tokens for each individual. All the individual then needs to do is
// click on the claim button and claim their tokens.
//
// This will open immediately after the completion of the token sale, and will 
// remain open for 60 days, after which time admin will be able to recover any 
// unclaimed tokens 
// ----------------------------------------------------------------------------


pragma solidity 0.4.24;

// IMPORTS
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";


// ----------------------------------------------------------------------------
// EXTERNAL CONTRACTS
// ----------------------------------------------------------------------------

contract EthertoteToken {
    function thisContractAddress() public pure returns (address) {}
    function balanceOf(address) public pure returns (uint256) {}
    function transfer(address, uint) public {}
}


//////////////////////////////////////////////////////////////////////////////


// MAIN CONTRACT

contract Reward {
        using SafeMath for uint256;
        
    // VARIABLES
    address public admin;
    address public thisContractAddress;
    address public tokenContractAddress = 0x998C7Fb23e956ecb53fE50e311e8074ba5794D5F;
    
    uint public contractCreationBlockNumber;
    uint public contractCreationBlockTime;
    
    bool public claimTokenWindowOpen;
    uint public windowOpenTime;
  
    // ENUM
    EthertoteToken token;        // reference to token contract
    

    // EVENTS 
	event Log(string text);
        
    // MODIFIERS
    modifier onlyAdmin { 
        require(
            msg.sender == admin
        ); 
        _; 
    }
        
    modifier onlyContract { 
        require(
            msg.sender == admin ||
            msg.sender == thisContractAddress
        ); 
        _; 
    }   
        
 
    // CONSTRUCTOR
    constructor() public payable {
        admin = msg.sender;
        thisContractAddress = address(this);
        contractCreationBlockNumber = block.number;
        token = EthertoteToken(tokenContractAddress);

	    emit Log("Reward contract created.");
    }
    
    // FALLBACK FUNCTION
    function () private payable {}
    
        


////////////// Admin Only Functions

    function setTokenContractAddress(address _address) onlyAdmin public {
        tokenContractAddress = address(_address);
        token = EthertoteToken(tokenContractAddress);
    }
    
  
    function thisContractBalance() public view returns(uint) {
      return address(this).balance;
    }

    // check balance of this smart contract
    function thisContractTokenBalance() public view returns(uint) {
      return token.balanceOf(thisContractAddress);
    }


    // STRUCT 
    Claimant[] public claimants;  // special struct variable
    
        struct Claimant {
        address claimantAddress;
        uint claimantAmount;
        bool claimantHasClaimed;
    }


    // Admin fuction to add claimants
    function addClaimant(address _address, uint _amount, bool) onlyAdmin public {
            Claimant memory newClaimant = Claimant ({
                claimantAddress: _address,
                claimantAmount: _amount,
                claimantHasClaimed: false
                });
                claimants.push(newClaimant);
    }
    
    
    function adjustEntitlement(address _address, uint _amount) onlyAdmin public {
        for (uint i = 0; i < claimants.length; i++) {
            if(_address == claimants[i].claimantAddress) {
                claimants[i].claimantAmount = _amount;
            }
            else revert();
            }  
    }
    


    // check claim entitlement
    function checkClaimEntitlement() public view returns(uint) {
        for (uint i = 0; i < claimants.length; i++) {
            if(msg.sender == claimants[i].claimantAddress) {
                require(claimants[i].claimantHasClaimed == false);
                return claimants[i].claimantAmount;
            }
            else return 0;
          }  
    }
    
    
    // check claim entitlement of any wallet
    function checkClaimEntitlementofWallet(address _address) public view returns(uint) {
        for (uint i = 0; i < claimants.length; i++) {
            if(_address == claimants[i].claimantAddress) {
                require(claimants[i].claimantHasClaimed == false);
                return claimants[i].claimantAmount;
            }
            else return 0;
          }  
    }
    


    // callable by claimant after token sale is completed
    function claimTokens() public {
        require(claimTokenWindowOpen == true);
        require(now < windowOpenTime.add(60 days));
          for (uint i = 0; i < claimants.length; i++) {
            if(msg.sender == claimants[i].claimantAddress) {
                require(claimants[i].claimantHasClaimed == false);
                token.transfer(msg.sender, claimants[i].claimantAmount);
                claimants[i].claimantHasClaimed = true;
            }
          }
    }


    // open the claim window as soon as the token sale completes
    function openClaimWindow(bool _bool) onlyAdmin public {
        claimTokenWindowOpen = bool(_bool);
        windowOpenTime = now;
    }

    // recover tokens tha were not claimed 
    function recoverTokens() onlyAdmin public {
        require(now < windowOpenTime.add(61 days));
        token.transfer(admin, token.balanceOf(thisContractAddress));
    }


// ----------------------------------------------------------------------------
// This method can be used by admin to extract Eth accidentally 
// sent to this smart contract.
// ----------------------------------------------------------------------------
    function ClaimEth() onlyAdmin public {
        address(admin).transfer(address(this).balance);

    } 



}
