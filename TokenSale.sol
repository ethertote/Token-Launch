
// Ethertote - Token Sale Contract
// 27.07.18


pragma solidity ^0.4.24;

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


// ----------------------------------------------------------------------------
// Main Contract
// ----------------------------------------------------------------------------

contract TokenSale {
  using SafeMath for uint256;
  
  EthertoteToken public token;

  address public admin;
  address public thisContractAddress;
  address public tokenContractAddress;
  
  uint public preIcoPhaseCountdown;       // used for website tokensale
  uint public icoPhaseCountdown;          // used for website tokensale
  uint public postIcoPhaseCountdown;      // used for website tokensale
  
  // address of TokenBurn contract to "burn" unsold tokens
  // for further details, review the TokenBurn contract and verify code on Etherscan
  address public tokenBurnAddress = 0xadCa18DC9489C5FE5BdDf1A8a8C2623B66029198;
  
  // address of EthRaised contract, that will be used to distribute funds 
  // raised by the token sale. Added as "wallet address"
  address public ethRaisedAddress = 0xdcEcF412C14b50dC033A37c14728bb7Bbb152159;
  
  // confirm token sale has completed
  bool public tokenSaleCompleted;
  
  // pause tokensale in an emergency
  bool public tokenSalePaused;
  
  // note pause time to allow special function to extend closingTime
  uint public tokenSalePausedTime;
  
  // time that needs to be added on to the closing time in the event of 
  // an emergency pause of the token sale
  uint public tokenSaleTimeExtender;
  
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
 // _ethRaisedContract = Address where collected funds will be forwarded to
 // _tokenContractAddress = Address of the original token contract being sold
 // ---------------------------------------------------------------------------
 
  constructor(
      address _ethRaisedAddress, 
      address _tokenContractAddress, 
      address _burnAddress,
      uint _openingTime, 
      uint _closingTime
      ) public {
    
    admin = msg.sender;
    thisContractAddress = address(this);
    tokenBurnAddress = _burnAddress;
    tokenContractAddress = _tokenContractAddress;
    token = EthertoteToken(tokenContractAddress);

    // require(rate > 0);
    require(_ethRaisedAddress != address(0));
    require(_tokenContractAddress != address(0));

    ethRaisedAddress = _ethRaisedAddress;
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
      token.transfer(tokenBurnAddress, tokenSaleTokenBalance());
  }

  // function to temporarily pause token sale if needed
  function pauseTokenSale() onlyAdmin public {
      // confirm the token sale hasn't already completed
      require(tokenSaleCompleted == false);
      
      // pause the sale and note the time of the pause
      tokenSalePaused = true;
      tokenSalePausedTime = now;
      
      // now calculate the difference in time between the pause time
      // and what woud've been the later closing time
      
      // Note: if the token sale was paused when the sale was live and was
      // paused before the sale ended, then the value of tokenSalePausedTime
      // will always be less than the value of closingTime
      
      tokenSaleTimeExtender = closingTime.sub(tokenSalePausedTime);
  }
  
    // function to resume token sale
  function resumeTokenSale() onlyAdmin public {
      closingTime = closingTime.add(tokenSaleTimeExtender);
      
      // extend post ICO countdown for the web-site
      postIcoPhaseCountdown = closingTime + 28 days;
      tokenSalePaused = false;
  }
  

    

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
// buyer = Address of the wallet performing the token purchase
// ----------------------------------------------------------------------------
  function buyTokens(address buyer) public payable {
    
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
    preValidatePurchase(buyer, weiAmount);

    // calculate token amount to be sold
    uint256 tokens = getTokenAmount(weiAmount);
    
    // check that the amount of eth being sent by the buyer 
    // does not exceed the equivalent number of tokens remaining
    require(tokens <= tokenSaleTokenBalance());

    // update state
    weiRaised = weiRaised.add(weiAmount);

    processPurchase(buyer, tokens);
    emit TokenPurchase(
      msg.sender,
      buyer,
      weiAmount,
      tokens
    );

    updatePurchasingState(buyer, weiAmount);

    forwardFunds();
    postValidatePurchase(buyer, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

// ----------------------------------------------------------------------------
// Validation of an incoming purchase
// ----------------------------------------------------------------------------
  function preValidatePurchase(
    address buyer,
    uint256 weiAmount
  )
    internal pure
  {
    require(buyer != address(0));
    require(weiAmount != 0);
  }

// ----------------------------------------------------------------------------
// Validation of an executed purchase
// ----------------------------------------------------------------------------
  function postValidatePurchase(
    address,
    uint256
  )
    internal pure
  {
    // optional override
  }

// ----------------------------------------------------------------------------
// Source of tokens
// ----------------------------------------------------------------------------
  function deliverTokens(
    address buyer,
    uint256 tokenAmount
  )
    internal
  {
    token.transfer(buyer, tokenAmount);
  }

// ----------------------------------------------------------------------------
// The following function is executed when a purchase has been validated 
// and is ready to be executed
// ----------------------------------------------------------------------------
  function processPurchase(
    address buyer,
    uint256 tokenAmount
  )
    internal
  {
    deliverTokens(buyer, tokenAmount);
  }

// ----------------------------------------------------------------------------
// Override for extensions that require an internal state to check for 
// validity (current user contributions, etc.)
// ----------------------------------------------------------------------------
  function updatePurchasingState(
    address,
    uint256
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
  function getTokenAmount(uint256 weiAmount)
    internal view returns (uint256)
  {
    return weiAmount.div(rate);
  }

// ----------------------------------------------------------------------------
// how ETH is stored/forwarded on purchases.
// Sent to the EthRaised Contract
// ----------------------------------------------------------------------------
  function forwardFunds() internal {
    ethRaisedAddress.transfer(msg.value);
  }
  

// functions for tokensale information on the website 

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
      token = EthertoteToken(tokenContractAddress);
  }
  
  function setTokenBurnAddress(address _address) onlyAdmin public {
      tokenBurnAddress = address(_address);
  }
  
  function setEthRaisedAddress(address _address) onlyAdmin public {
      ethRaisedAddress = address(_address);
  }
  
}
