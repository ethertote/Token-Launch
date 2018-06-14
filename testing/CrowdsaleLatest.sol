pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// Ethertote (Kovan) Crowdsale contract
//
// Symbol      : KTOTE
// Name        : Kovan Ethertote
// Total supply: 10 million tokens (10,000,000.000000000000000000)
// Decimals    : 18

// ----------------------------------------------------------------------------

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "github.com/ethertote/core/SafeMath.sol";



 
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei.
  // 1 Eth = 1000 TOTE
  // 1 Eth = 1000000000000000000 Wei = 1000 TOTE
  // therefore 1 Wei = 1000/1000000000000000000 =  0.000000000000001 TOTE
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;
  
  // starting time and closing time of Crowdsale
  uint public openingTime;
  uint public closingTime;

  /**
   * Event for token purchase logging
   * purchaser = the contract address that paid for the tokens
   * beneficiary = the address who got the tokens
   * value = the amount (in Wei) paid for purchase
   * amount = the amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * _rate = Number of token units a buyer gets per wei
   * _wallet = Address where collected funds will be forwarded to
   * _token = Address of the original token contract being sold
   */
  constructor(uint256 _rate, address _wallet, ERC20 _token, uint _openingTime, uint _closingTime) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
    
    openingTime = _openingTime;
    closingTime = _closingTime;
    
  }

  // confirm if Crowdsale has finished
  function CrowdsaleHasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

   // The following function is only used during testing - 
   // Will be disabled for official main-net crowdsale
   function setOpeningTime(uint256 _openingTime) public {
    openingTime = _openingTime;
    closingTime = openingTime + 7 days;
  }


// /**
//  * @dev Burns a specific amount of tokens.
//  * @param _value The amount of token to be burned.
//  */
// function burn(uint256 _value) public {
//     require(_value > 0);
//     require(_value <= balances[msg.sender]);
//     // no need to require value <= totalSupply, since that would imply the
//     // sender's balance is greater than the totalSupply, which *should* be an assertion failure

//     address burner = msg.sender;
//     balances[burner] = balances[burner].sub(_value);
//     totalSupply = totalSupply.sub(_value);
//     Burn(burner, _value);
// }


// test this function
function burnRemainingTokens() internal {
    wallet.transfer(wallet.balance);
}




  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * function for front-end token purchase ***DO NOT OVERRIDE***
   * _beneficiary = Address of the wallet performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {
    
    // check Crowdsale is open
    require(openingTime >= block.timestamp);
    require(block.timestamp < closingTime);

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

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

  /**
   * Validation of an incoming purchase. Use require statements to revert state 
   * when conditions are NOT met. Use super to concatenate validations.
   * _beneficiary = Address performing the token purchase
   *  _weiAmount = Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal pure
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * Validation of an executed purchase. Observe state and use revert statements
   * to undo rollback when valid conditions are not met.
   * _beneficiary = Address performing the token purchase
   * _weiAmount = Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal pure
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * _beneficiary = Address performing the token purchase
   * _tokenAmount = Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.transfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal pure
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}
