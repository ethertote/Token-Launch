pragma solidity ^0.4 .23;

import "github.com/ethertote/core/SafeMath.sol";   



contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) owner = newOwner;
    }

    function kill() public {
        if (msg.sender == owner) selfdestruct(owner);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert();
            _;
    }
}

contract Pausable is Ownable {
    bool public stopped;

    modifier stopInEmergency {
        if (stopped) {
            revert();
        }
        _;
    }

    modifier onlyInEmergency {
        if (!stopped) {
            revert();
        }
        _;
    }

    // Called by the owner in emergency, triggers stopped state
    function emergencyStop() external onlyOwner {
        stopped = true;
    }

    // Called by the owner to end of emergency, returns to normal state
    function release() external onlyOwner onlyInEmergency {
        stopped = false;
    }
}




// Presale Smart Contract
// This smart contract collects ETH during presale. Tokens are not distributed during
// this time. Only informatoion stored how much tokens should be allocated in the future.
contract Presale is Pausable {
    using SafeMath for uint256;
    
    struct Backer {
        uint weiReceived;   // amount of ETH contributed
        uint TOTESent;      // amount of tokens to be sent
        bool processed;     // true if tokens transffered.
    }
    
    address public multisigETH = 0x98185e3e6af0956d9b25f5b131815693e789b017; // Multisig contract that will receive the ETH    
    uint public ETHReceived;    // Number of ETH received
    uint public TOTESentToETH;  // Number of TOTE sent to ETH contributors
    uint public startBlock;     // Presale start block
    uint public endBlock;       // Presale end block

    uint public minContributeETH;// Minimum amount to contribute
    bool public presaleClosed;  // Is presale still on going
    uint public maxCap;         // Maximum number of SOCX to sell

    uint totalTokensSold;       // tokens sold during the campaign
    uint tokenPriceWei;         // price of tokens in Wei


    uint multiplier = 1000000000000000000;              // to provide 18 decimal values
    mapping(address => Backer) public backers;  // backer list accessible through address
    address[] public backersIndex;              // order list of backer to be able to itarate through when distributing the tokens. 


    // @notice to be used when certain account is required to access the function
    // @param a {address}  The address of the authorised individual
    modifier onlyBy(address a) {
        if (msg.sender != a) revert();
        _;
    }

    // @notice to verify if action is not performed out of the campaing time range
    modifier respectTimeFrame() {
        if ((block.number < startBlock) || (block.number > endBlock)) revert();
        _;
    }



    // Events
    event ReceivedETH(address backer, uint amount, uint tokenAmount);



    // Presale  {constructor}
    // @notice fired when contract is crated. Initilizes all constnat variables.
    constructor() public {     
           
        multisigETH = 0x98185e3e6af0956d9b25f5b131815693e789b017; //TODO: Replace address with correct one
        maxCap = 500 * multiplier;  // max amount of tokens to be sold
        TOTESentToETH = 0;              // tokens sold so far
        minContributeETH = 1 ether;     // minimum contribution acceptable
        startBlock = 0;                 // start block of the campaign, it will be set in start() function
        endBlock = 0;                   // end block of the campaign, it will be set in start() function 
        tokenPriceWei = 720000000000000;// price of token expressed in Wei 
    }

    // @notice to obtain number of contributors so later "front end" can loop through backersIndex and 
    // triggger transfer of tokens
    // @return  {uint} true if transaction was successful
    function numberOfBackers() public constant returns(uint) {
        return backersIndex.length;
    }

    function updateMultiSig(address _multisigETH) public onlyOwner {
        multisigETH = _multisigETH;
    }


    // {fallback function}
    // @notice It will call internal function which handels allocation of Ether and calculates SOCX tokens.
    function () public payable {
        if (block.number > endBlock) revert();
        handleETH(msg.sender);
    }

    // @notice It will be called by owner to start the sale
    // TODO WARNING REMOVE _block parameter and _block variable in function
    function start() public onlyOwner {
        startBlock = block.number;        
        endBlock = startBlock + 57600;
        // 10 days in blocks = 57600 (4*60*24*10)
        // enable this for live assuming each bloc takes 15 sec.
    }

    // @notice called to mark contributer when tokens are transfered to them after ICO
    // @param _backer {address} address of beneficiary
    function process(address _backer) onlyOwner public returns (bool){

        Backer storage backer = backers[_backer]; 
        backer.processed = true;

        return true;
    }

    // @notice It will be called by fallback function whenever ether is sent to it
    // @param  _backer {address} address of beneficiary
    // @return res {bool} true if transaction was successful
    function handleETH(address _backer) internal stopInEmergency respectTimeFrame returns(bool res) {

        if (msg.value < minContributeETH) revert();                     // stop when required minimum is not sent
        uint TOTEToSend = (msg.value / tokenPriceWei) * multiplier; // calculate number of tokens

        
        if ((TOTESentToETH.add(TOTEToSend)) > maxCap) revert();  // ensure that max cap hasn't been reached yet

        Backer storage backer = backers[_backer];                   // access backer record
        backer.TOTESent = (backer.TOTESent.add(TOTEToSend));     // calculate number of tokens sent by backer
        backer.weiReceived = (backer.weiReceived.add(msg.value));// store amount of Ether received in Wei
        ETHReceived = (ETHReceived.add(msg.value));              // update the total Ether recived
        TOTESentToETH = (TOTESentToETH.add(TOTEToSend));         // keep total number of tokens sold
        backersIndex.push(_backer);                                 // maintain iterable storage of contributors

        emit ReceivedETH(_backer, msg.value, TOTEToSend);                // register event
        return true;
    }



    // @notice This function will finalize the sale.
    // It will only execute if predetermined sale time passed 
    // if successfull it will transfer collected Ether into predetermined multisig wallet or address
    function finalize() public onlyOwner {

        if (block.number < endBlock && TOTESentToETH < maxCap) revert();

        if (!multisigETH.send(address(this).balance)) revert();
        presaleClosed = true;

    }

    
    // @notice Failsafe drain
    // in case finalize failes, we need guaranteed way to transfer Ether out of this contract. 
    function drain() public onlyOwner {
        if (!owner.send(address(this).balance)) revert();
    }

}
