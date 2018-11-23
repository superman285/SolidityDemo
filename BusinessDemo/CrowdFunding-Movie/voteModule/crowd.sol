pragma solidity ^0.4.25;

contract crowd {

    constructor() {

    }

    //描述 string desc
    // isFinished
    // owner
    // totalSupply
    // totalCrowd 已经发行量 已众筹到的
    //userCount 从0开始

    //struct CrowdInfo address,amount,crowdTime 地址，投额，投的时间

    CrowdInfo[1000] crowdinfos; //最多支持1000用户
    //一个下标代表一个用户

    mapping(address=>uint) userID; //用户唯一，对应crowdinfo的下标

    //构造函数
    //传入desc,owner,totalSupply
    //基金会占一个众筹名额，额度为总量的10%,初始化三个信息


    function airDrop(address _to,uint _value) public returns (bool) {
        //判断未结束，判断空投人为基金会|即owner，
        //if判_value溢出，小于等于totalsupply,to不为空
        //两种情况，判userCount关系，一种为更新，一种为插入 修改变量数不同

        //require id < 1000 ；totalCrowd += _value
        //if(totalCrowd == totalSupply) finish
    }

    //一个方法查余额 this.balance

    //分账功能 售票然后分成
    function ticketBooking() public payable {
        require(msg.sender > 1000);
        // 众筹完成了 isFinished
        uint i = 0;
        for(i=0;i<userCount;i++){
            //判地址不为空

            //transfer， .amount / totalSupply 由于完成了 所以totalSupply与totalCrowd应该相等

        }
    }
}
