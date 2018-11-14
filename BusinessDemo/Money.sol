pragma solidity ^0.4.24;

contract Money {
    /*function Money(){

    }*/

    //owner
    address public owner;
    constructor() public {
        owner = msg.sender; //管理员赋值,创建合约的eoa地址
    }

    //给合约账户充值
    function payMoney() payable public {
        //nothing to do
    }

    //fallback payable -> wallet transfer to address ok
    /*function() payable public {

    }*/

    //show balance,看智能合约账户的余额，this是指合约而不是创建者
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    //从合约账户取钱，外部账户调用的，所以gas从外部账户扣
    function getMoney() public payable{
        address who = msg.sender;
        require(getBalance() > 1 ether,"余额得大于1以太");
        //require(msg.sender != owner,"不能给管理员转噢");
        who.transfer(1 ether); //发送1个ether给who
    }

    //destroy contract
    function kill() public {
        require(msg.sender == owner,"只有自己能销毁");
        selfdestruct(owner); //destroy contract
    }


}
