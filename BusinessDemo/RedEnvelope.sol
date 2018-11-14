pragma solidity ^0.4.24;

contract RedEnvelope {
    /*function RedEnvelope(){

    }*/

    address public richer;//定义土豪
    uint public redNumber; //红包数量

    //构造函数
    constructor(uint _number) payable public {
        richer = msg.sender;
        //创建合约者为土豪
        redNumber = _number;
    }

    //show balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    //抢红包
    function stakeMoney() public payable returns (bool) {
        //address who = msg.sender;

        require(redNumber > 0, "红包抢光了！");
        require(getBalance() > 0, "合约账户没钱啦");

        redNumber--;

        //除以100求余数
        uint random = uint(keccak256(now, msg.sender, "土豪")) % 100;
        uint balance = getBalance();
        msg.sender.transfer(balance * random / 100);
        //或者用who

        return false;
    }

    //destroy contract
    function kill() public {
        require(msg.sender == richer);
        selfdestruct(richer);
        //destroy合约
    }


}
