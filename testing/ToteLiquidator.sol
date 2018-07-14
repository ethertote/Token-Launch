// Ethertote - Tote Liquidator
// 14.07.18
//
// The smart contract is used to randomly liquidate the Tote
// by sending eth to the cryptopot smart contracts
// 10% of the amount will be distrubited on week 1
// 8% of the amount will be distributed on weeks 2-11 (10 weeks)
// 10% of the amount will be distributed on week 12
// all additional eth will also be distributed on week 12

pragma solidity 0.4.24;



// used to update all references of smart contracts if ever needed


// EXTERNAL CONTRACTS
//////////////////////////////////////////////////////////

contract PotManager {
    function thisContractAddress() public pure returns(address) {}
    
    function masterUpdaterCoreAddress() public pure returns(address) {}

    function cryptoPotAddress01() public pure returns(address) {}
    function cryptoPotAddress02() public pure returns(address) {}
    function cryptoPotAddress03() public pure returns(address) {}
    function cryptoPotAddress04() public pure returns(address) {}
    function cryptoPotAddress05() public pure returns(address) {}
    function cryptoPotAddress06() public pure returns(address) {}
    function cryptoPotAddress07() public pure returns(address) {}
    function cryptoPotAddress08() public pure returns(address) {}
    function cryptoPotAddress09() public pure returns(address) {}
    function cryptoPotAddress10() public pure returns(address) {}
    function cryptoPotAddress11() public pure returns(address) {}
    function cryptoPotAddress12() public pure returns(address) {}
    function cryptoPotAddress13() public pure returns(address) {}
    function cryptoPotAddress14() public pure returns(address) {}
    function cryptoPotAddress15() public pure returns(address) {}
    function cryptoPotAddress16() public pure returns(address) {}
    function cryptoPotAddress17() public pure returns(address) {}
    function cryptoPotAddress18() public pure returns(address) {}
    function cryptoPotAddress19() public pure returns(address) {}
    function cryptoPotAddress20() public pure returns(address) {}
    function cryptoPotAddress21() public pure returns(address) {}
    function cryptoPotAddress22() public pure returns(address) {}
    function cryptoPotAddress23() public pure returns(address) {}
    function cryptoPotAddress24() public pure returns(address) {}
    function cryptoPotAddress25() public pure returns(address) {}
}

////////////////////////////////////////////////////////////////////////////////


contract ToteLiquidator { 
     
                    
    // stored address variables
    address public admin;
    address public thisContractAddress;
    
    address public masterUpdaterCoreAddress;


    address public potManagerAddress;
    
    address public cryptoPotAddress01; 
    address public cryptoPotAddress02;
    address public cryptoPotAddress03;
    address public cryptoPotAddress04;
    address public cryptoPotAddress05; 
    address public cryptoPotAddress06;
    address public cryptoPotAddress07;
    address public cryptoPotAddress08;
    address public cryptoPotAddress09; 
    address public cryptoPotAddress10;
    address public cryptoPotAddress11; 
    address public cryptoPotAddress12;
    address public cryptoPotAddress13;
    address public cryptoPotAddress14;
    address public cryptoPotAddress15; 
    address public cryptoPotAddress16;
    address public cryptoPotAddress17;
    address public cryptoPotAddress18;
    address public cryptoPotAddress19; 
    address public cryptoPotAddress20;
    address public cryptoPotAddress21; 
    address public cryptoPotAddress22;
    address public cryptoPotAddress23;
    address public cryptoPotAddress24;
    address public cryptoPotAddress25; 

    // ENUMS
    PotManager potmanager;

    // EVENTS
    event Deployed(string, uint);
    event ReferencesUpdated(string, uint);


    // MODIFIERS
    modifier onlyAdmin { 
        require(msg.sender == admin); 
        _; 
    }

    modifier remoteControl { 
        require(
            msg.sender == admin ||
            msg.sender == thisContractAddress ||
            msg.sender == masterUpdaterCoreAddress    
        ); 
        _; 
    }

    
    // fallback function to top-up contract if ever necessary
        function () private payable {}


    // CONSTRUCTOR FUNCTION - executed upon contract launch
        constructor() public {   
            admin = msg.sender;
            thisContractAddress = address(this);
            emit Deployed("Ethertote - MasterUpdater_Pot contract deployed:", block.timestamp);
            
            potmanager = PotManager(potManagerAddress);
            
        }
        



    // MAIN FUNCTIONS
    function setAllAddresses(address Pot) onlyAdmin public {
        potManagerAddress = address(Pot);
        
        
        updateInternalReferences();

    }


        function updateInternalReferences() remoteControl public {
            
            if (potManagerAddress != 0x0) {
                potmanager = PotManager(potManagerAddress);
                
                masterUpdaterCoreAddress = potmanager.masterUpdaterCoreAddress();
                
             cryptoPotAddress01 = potmanager.cryptoPotAddress01();
             cryptoPotAddress02 = potmanager.cryptoPotAddress02();
             cryptoPotAddress03 = potmanager.cryptoPotAddress03();
             cryptoPotAddress04 = potmanager.cryptoPotAddress04();
			       cryptoPotAddress05 = potmanager.cryptoPotAddress05();
             cryptoPotAddress06 = potmanager.cryptoPotAddress06();
             cryptoPotAddress07 = potmanager.cryptoPotAddress07();
             cryptoPotAddress08 = potmanager.cryptoPotAddress08();
			       cryptoPotAddress09 = potmanager.cryptoPotAddress09();
             cryptoPotAddress10 = potmanager.cryptoPotAddress10();
			       cryptoPotAddress11 = potmanager.cryptoPotAddress11();
             cryptoPotAddress12 = potmanager.cryptoPotAddress12();
             cryptoPotAddress13 = potmanager.cryptoPotAddress13();
             cryptoPotAddress14 = potmanager.cryptoPotAddress14();
	           cryptoPotAddress15 = potmanager.cryptoPotAddress15();
             cryptoPotAddress16 = potmanager.cryptoPotAddress16();
             cryptoPotAddress17 = potmanager.cryptoPotAddress17();
             cryptoPotAddress18 = potmanager.cryptoPotAddress18();
             cryptoPotAddress19 = potmanager.cryptoPotAddress19();
             cryptoPotAddress20 = potmanager.cryptoPotAddress20();
             cryptoPotAddress21 = potmanager.cryptoPotAddress21();
             cryptoPotAddress22 = potmanager.cryptoPotAddress22();
             cryptoPotAddress23 = potmanager.cryptoPotAddress23();
             cryptoPotAddress24 = potmanager.cryptoPotAddress24();
	           cryptoPotAddress25 = potmanager.cryptoPotAddress25();
            }
        }

}
