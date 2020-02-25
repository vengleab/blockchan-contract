pragma solidity ^0.5.11;

contract Voting {
    address owner;
    VoteEvent[] events;

    constructor() public{
        owner = msg.sender;
    }


    function createEvent(string memory description) public {
        VoteEvent evt = new VoteEvent(msg.sender, description);
        events.push(evt);
    }

    function getEvents() public view returns (VoteEvent[] memory){
        return events;
    }
}

contract VoteEvent {
    address public host;
    string public description;
    mapping(address=>bool) votedAccount;
    mapping(address=>Applicant) registeredApplicants;
    address[] approvedApplicantAddr;
    address[] allRegisteredApplicants;
    bool isEnd;
    
    struct Applicant {
        uint256 votedResult;
        string name;
        bool approved;
        bool registered;
    }

    constructor(address owner, string memory des) public{
        host = owner;
        description = des;
    }

    modifier isHost() {
        require(host==msg.sender);
        _;
    }

    modifier isNotEnd {
        require(isEnd == false);
        _;
    }
    
    modifier isRegisterd(address applicant) {
        Applicant memory registeredApplicant = registeredApplicants[applicant];
        require(registeredApplicant.registered==true);
        _;
    }


    function approveApplicant(address applicant) isRegisterd(applicant) isHost public {
        registeredApplicants[applicant].approved = true;
        approvedApplicantAddr.push(applicant);
    }

    function closeEven() isNotEnd isHost public {
        isEnd = true;
    }

    function registerAsApplicant(string memory applicantName) public {
        address applicant = msg.sender;
        require( registeredApplicants[applicant].registered == false );
        registeredApplicants[applicant].name = applicantName;
        registeredApplicants[applicant].registered = true;
        allRegisteredApplicants.push(applicant);
    }

    function voteFor(address applicant) public {
        require( votedAccount[msg.sender]==false );
        require( isEnd==false );
        votedAccount[msg.sender] = true;
        Applicant storage registeredApplicant = registeredApplicants[applicant];
        
        require(registeredApplicant.approved == true);
        
        registeredApplicant.votedResult = registeredApplicant.votedResult + 1;
    }
    
    function getApplicantInfo(address applicantAddr) public view returns(uint256, string memory, bool, bool) {
        Applicant memory applicant = registeredApplicants[applicantAddr];
        return (
            applicant.votedResult,
            applicant.name,
            applicant.approved,
            applicant.registered
            );
    }
    
    function getAllApplicantAddr() public view returns(address[] memory){
        return approvedApplicantAddr;
    }
    
    function getRegisteredApplicantAddr() public view returns(address[] memory){
        return allRegisteredApplicants;
    }
    
    function getResultFor(address applicant) public view returns (uint256) {
        return registeredApplicants[applicant].votedResult;
    }
    
}