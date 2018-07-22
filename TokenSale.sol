// Ethertote - Token Sale Contract
// 22.07.18


pragma solidity ^0.4.24;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

// ----------------------------------------------------------------------------
// Imported Token Contract functions
// ----------------------------------------------------------------------------

contract EthertoteToken {
    function thisContractAddress() public pure returns (address) {}
    function balanceOf(address) public pure returns (uint256) {}
    function transfer(address, uint _amount) public {}
}


// ----------------------------------------------------------------------------
// Main Contract
// ----------------------------------------------------------------------------

contract TokenSale {
  using SafeMath for uint256;
  
  EthertoteToken public token;

  address public wallet;
  
  address public admin;
  address public thisContractAddress;
  address public tokenContractAddress;
  
  uint public preIcoPhaseCountdown;       // used for website tokensale
  uint public icoPhaseCountdown;          // used for website tokensale
  uint public postIcoPhaseCountdown;      // used for website tokensale
  
  // address of TokenBurn contract to "burn" unsold tokens
  // for further details, review the TokenBurn contract and verify code on Etherscan
  address public burnAddress;
  
  // confirm token sale has completed
  bool public tokenSaleCompleted = false;
  
  // Amount of wei raised
  uint256 public weiRaised;
  
  // 1000 tokens per Eth - 9,000,000 tokens for sale
  uint public maxEthRaised = 9000;
  
  // Maximum amount of Wei that can be raised
  // e.g. 9,000,000 tokens for sale with 1000 tokens per 1 eth
  // means maximum Wei raised would be maxEthRaised * 1000000000000000000
  uint public maxWeiRaised = maxEthRaised.mul(1000000000000000000);

  // starting time and closing time of Crowdsale
  uint public openingTime;
  uint public closingTime;
  
  // used as a divider so that 1 eth will buy 1000 tokens
  // set rate to 1,000,000,000,000,000
  uint public rate = 1000000000000000;
  
  // minimum and maximum spend of eth per transaction
  uint public minSpend = 100000000000000000;    // 0.1 Eth
  uint public maxSpend = 100000000000000000000; // 100 Eth 

  
  // MODIFIERS
  modifier onlyAdmin { 
        require(msg.sender == admin
        ); 
        _; 
  }
  
  
  
 // ---------------------------------------------------------------------------
 // Constructor function
 // _wallet = Address where collected funds will be forwarded to
 // _tokenAddress = Address of the original token contract being sold
 // ---------------------------------------------------------------------------
 
  constructor(
      address _wallet, 
      address _tokenContractAddress, 
      address _burnAddress
      uint _openingTime, 
      uint _closingTime
      ) public {
    
    admin = msg.sender;
    thisContractAddress = address(this);
    burnAddress = _burnAddress;
    tokenContractAddress = _tokenContractAddress;
    token = EthertoteToken(tokenContractAddress);

    // require(rate > 0);
    require(_wallet != address(0));
    require(_tokenAddress != address(0));

    wallet = _wallet;
    openingTime = _openingTime;
    closingTime = _closingTime;
    
    preIcoPhaseCountdown = openingTime;
    icoPhaseCountdown = closingTime;
    
    // after 28 days the post-token-sale section of the website will be removed based on this time
    postIcoPhaseCountdown = closingTime + 28 days;
    
  }
  
  

  // check balance of this smart contract
  function tokenSaleTokenBalance() public view returns(uint) {
      return token.balanceOf(thisContractAddress);
  }
  
  
  // check the token balance of any ethereum address  
  function getAnyAddressTokenBalance(address _address) public view returns(uint) {
      return token.balanceOf(_address);
  }
  

  // confirm if The Token Sale has finished
  function crowdsaleHasClosed() public view returns (bool) {
    return block.timestamp > closingTime;
  }
  
  // this function will send any unsold tokens to the null TokenBurn contract address
  // once the crowdsale is finished, anyone can publicly call this function!
  function burnUnsoldTokens() public {
      require(tokenSaleCompleted == true);
      token.transfer(burnAddress, tokenSaleTokenBalance());
  }

  // function to temporarily pause token sale if needed
  function pauseTokenSale(bool _trueorfalse) onlyAdmin public {
  

    

// ----------------------------------------------------------------------------
// Event for token purchase logging
// purchaser = the contract address that paid for the tokens
// beneficiary = the address who got the tokens
// value = the amount (in Wei) paid for purchase
// amount = the amount of tokens purchased
// ----------------------------------------------------------------------------
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );



// -----------------------------------------
// Crowdsale external interface
// -----------------------------------------


// ----------------------------------------------------------------------------
// fallback function ***DO NOT OVERRIDE***
// allows purchase of tokens directly from MEW and other wallets
// will conform to require statements set out in buyTokens() function
// ----------------------------------------------------------------------------
   
  function () external payable {
    buyTokens(msg.sender);
  }


// ----------------------------------------------------------------------------
// function for front-end token purchase on our website ***DO NOT OVERRIDE***
// _beneficiary = Address of the wallet performing the token purchase
// ----------------------------------------------------------------------------
  function buyTokens(address _beneficiary) public payable {
    
    // check Crowdsale is open (can disable for testing)
    require(openingTime <= block.timestamp);
    require(block.timestamp < closingTime);
    
    // minimum purchase of 100 tokens (0.1 eth)
    require(msg.value >= minSpend);
    
    // maximum purchase per transaction to allow broader
    // token distribution during tokensale
    require(msg.value <= maxSpend);
    
    // stop sales of tokens if token balance is 0
    require(tokenSaleTokenBalance() > 0);
    
    // stop sales of tokens if Token sale is paused
    require(tokenSalePaused == false);
    
    // log the amount being sent
    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be sold
    uint256 tokens = _getTokenAmount(weiAmount);
    
    // check that the amount of eth being sent by the buyer 
    // does not exceed the equivalent number of tokens remaining
    require(tokens <= tokenSaleTokenBalance());

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

// ----------------------------------------------------------------------------
// Validation of an incoming purchase
// ----------------------------------------------------------------------------
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal pure
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

// ----------------------------------------------------------------------------
// Validation of an executed purchase
// ----------------------------------------------------------------------------
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal pure
  {
    // optional override
  }

// ----------------------------------------------------------------------------
// Source of tokens
// ----------------------------------------------------------------------------
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.transfer(_beneficiary, _tokenAmount);
  }

// ----------------------------------------------------------------------------
// The following function is executed when a purchase has been validated 
// and is ready to be executed
// ----------------------------------------------------------------------------
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

// ----------------------------------------------------------------------------
// Override for extensions that require an internal state to check for 
// validity (current user contributions, etc.)
// ----------------------------------------------------------------------------
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal pure
  {
    // optional override
  }

// ----------------------------------------------------------------------------
// Override to extend the way in which ether is converted to tokens.
// _weiAmount Value in wei to be converted into tokens
// return Number of tokens that can be purchased with the specified _weiAmount
// ----------------------------------------------------------------------------
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.div(rate);
  }

// ----------------------------------------------------------------------------
// how ETH is stored/forwarded on purchases.
// ----------------------------------------------------------------------------
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
  
//   function sendToSpecificAddress(address _to, uint _amount) public {
//       token.transfer(_to, _amount);
//   }


    function maximumRaised() public view returns(uint) {
        return maxWeiRaised;
    }
    
    function amountRaised() public view returns(uint) {
        return weiRaised;
    }
  
    function timeComplete() public view returns(uint) {
        return closingTime;
    }
    
    
      
// ----------------------------------------------------------------------------  
// test functions - not used for final contract
// ----------------------------------------------------------------------------
    
    function abandonContract() onlyAdmin public {
	    address(admin).transfer(address(this).balance);
	  }
    
    function setMaxEthRaised(uint _maxethraised) onlyAdmin public {  
        maxEthRaised = uint(_maxethraised);
    }
    
    function setMaxWeiRaised(uint _maxweiraised) onlyAdmin public {
        maxWeiRaised = uint(_maxweiraised);
    }
    
    function setRate(uint _value) onlyAdmin public {
      rate = uint(_value);
   }
   
   function setOpeningTime(uint256 _openingTime) onlyAdmin public {  
    openingTime = _openingTime;
    closingTime = openingTime.add(7 days);
    preIcoPhaseCountdown = openingTime;
    icoPhaseCountdown = closingTime;
   }
   
   function setClosingTime(uint256 _closingTime) onlyAdmin public { 
    closingTime = _closingTime;
    icoPhaseCountdown = closingTime;
   }
   
   function setPostIcoPhaseCountdown(uint256 _posticocountdown) onlyAdmin public { 
    postIcoPhaseCountdown = _posticocountdown;
   }
   
  function setTokenContractAddress(address _address) onlyAdmin public {
      tokenContractAddress = address(_address);
      token = Test777Token(tokenContractAddress);
  }
  
  
}
