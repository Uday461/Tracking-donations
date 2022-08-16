pragma solidity ^0.5.1; //
contract FundRaising{
    
    struct fundraiser{
        uint f_id;
        string name;
        uint amount ;
        uint recieved;
        string des;
        address payable reciever; //adddress reciever
        bool status;
    }
    
    struct contributor{
        uint c_id;
        string name;
        string des;
        address payable donor;
        
    }
    
    //to store where the ether is being spent i.e tracking
    struct ledger{
         uint l_id;
         address sender;
         address reciever;
         uint amount;
         
    }
    
    event funraiserCreated(
        uint f_id,
        string name,
        uint amount,
        string des,
        address payable reciever,
        bool status
    );
    
     event contributorCreated(
        uint c_id,
        string name,
        string des,
        address payable donor
        
    );
    
    event fundapproved(
      bool status
    );
    
   modifier onlyAdmin(){
        require(msg.sender==admin);
        _;
    }
    
    address public admin=0xdD870fA1b7C4700F2BD7f44238821C26f7392148;

  
    mapping (uint=>fundraiser)  public fundraisers;
    mapping (uint=>contributor) public contributors;
    mapping (uint=>ledger)public ledgers;

    uint public fundraisersCount=0;
    uint public contributorsCount=0;
    uint public ledgerCount=0;
    
    function addFund(string  memory _name, uint _amount, string memory _des )public{
        
        fundraisers[fundraisersCount]=fundraiser(fundraisersCount, _name, _amount,0,_des,msg.sender,false);
        fundraisersCount++;
        emit funraiserCreated(fundraisersCount, _name, _amount,_des,msg.sender,false);
    }
    
    
    function approvefund(uint _f_id)public onlyAdmin(){
        fundraisers[_f_id].status=true;
        emit fundapproved(fundraisers[_f_id].status);
    }
    
    
    function addcontributors( string  memory _name,  string memory _des )public{
        
        contributors[contributorsCount]=contributor(contributorsCount, _name,_des,msg.sender);
        contributorsCount++;
        emit contributorCreated(contributorsCount, _name,_des,msg.sender);
        
    }
    
    
    function donate(uint _f_id) public payable{
        
         //fetch the details of fundraiser
         fundraiser memory _fundraiser = fundraisers[_f_id];
        
         //valid id
         require (_fundraiser.f_id >=0 && _fundraiser.f_id< fundraisersCount && _fundraiser.status==true);
         
         address payable _reciever= _fundraiser.reciever;
         
         // cheking reciever is not the message sender
         require (_reciever!=msg.sender);
        
         //transferring ether to fundraiser
         address(_reciever).transfer(msg.value);
         
         //updating the amount recieved
         fundraisers[_f_id].recieved  = fundraisers[_f_id].recieved  + msg.value/10**18 ;
         
         //updating the ledger
         ledgers[ledgerCount++]=ledger(ledgerCount,msg.sender,_reciever,msg.value/10**18);
  
    }
    
    //when the fundraiser is spending ether
    function spend(uint _f_id, address payable _reciever) public payable{
         //fetch the details of fundraiser
         fundraiser memory _fundraiser = fundraisers[_f_id];
        
         //valid id
         require (_fundraiser.f_id >=0 && _fundraiser.f_id< fundraisersCount &&  _fundraiser.status==true);
         
        // cheking reciever is not the message sender
         require (_reciever!=msg.sender);
         
         //transferring ether to fundraiser
         
         address(_reciever).transfer(msg.value);
         fundraisers[_f_id].recieved=fundraisers[_f_id].recieved-(msg.value/10**18);
         
        //updating the ledger
         ledgers[ledgerCount++]=ledger(ledgerCount,msg.sender,_reciever,msg.value/10**18);
    
    }

    
}