pragma solidity ^0.4.0;

contract Ballot{
    struct voter{
        uint weight;
        bool voted;
        uint vote;
    }
    struct Proposal{
        uint voteCount;
    }
    address chairperson;
    enum Stage{Init,Reg,Vote,Done}
    Stage public stage=Stage.Init;
    uint startTime=now;
    Proposal[] proposals;
    mapping(address=>voter) voteradr;
    event votingCompleted();
    constructor(uint numProposals){
        chairperson=msg.sender;
        voteradr[chairperson].weight=2;
        proposals.length=numProposals;
        stage=Stage.Reg;
    }
    modifier validStage(Stage requiredStage){
        require(stage==requiredStage);
        _;
    }
    function reg(address adr) public validStage(Stage.Reg){
        require(msg.sender==chairperson && voteradr[adr].voted==false);
        voteradr[adr].weight=1;
        voteradr[adr].voted=false;
        if(now>startTime+20 seconds){
            startTime=now;
            stage=Stage.Vote;
        }
    }
    function vote(uint prop) public validStage(Stage.Vote){
        voter storage sender=voteradr[msg.sender];
        require(sender.voted==false && prop<proposals.length);
        sender.voted=true;
        sender.vote=prop;
        proposals[prop].voteCount+=sender.weight;
        if(now>startTime+20 seconds){
            startTime=now;
            stage=Stage.Done;
            votingCompleted();
        }
    }
    function result() public view validStage(Stage.Done) returns(uint winningProposal){
        uint winningProposalVote=0;
        for(uint prop=0;prop<proposals.length;prop++){
            if(proposals[prop].voteCount>winningProposalVote){
                winningProposalVote=proposals[prop].voteCount;
                winningProposal=prop;
            }
        }
        assert(winningProposalVote>0);
    }
}
