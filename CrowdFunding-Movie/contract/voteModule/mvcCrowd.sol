pragma solidity ^0.4.25;

contract mvcCrowd{



    string public desc;//描述 string desc
    bool public isFinished;// isFinished
    address public foundation;// owner,基金会
    uint public totalSupply;// totalSupply
    uint public totalCrowd;// totalCrowd 已经发行量 已众筹到的
    uint userCount;//userCount 从0开始

    struct CrowdInfo {
        address crowdAddr;
        uint crowdAmount;
        uint crowdTime;
    }
    //struct CrowdInfo address,amount,crowdTime 地址，投额，投的时间

    CrowdInfo[1000] crowdinfos; //最多支持1000用户,所有用户的众筹信息
    //一个下标代表一个用户

    mapping(address=>uint) userID; //用户唯一，对应crowdinfo的下标

    //构造函数
    //传入desc,totalSupply
    //基金会占一个众筹名额，额度为总量的10%,初始化三个信息
    constructor(string _desc,uint _totalSupply) public{

        desc = _desc;
        foundation = msg.sender;
        totalSupply = _totalSupply;

        crowdinfos[0].crowdAddr = foundation;
        crowdinfos[0].crowdAmount = totalSupply / 10;
        crowdinfos[0].crowdTime = now;

        userID[foundation] = userCount++;
        totalCrowd = crowdinfos[0].crowdAmount;
    }

    function airDrop(address _to,uint _value) public returns (bool) {
        //判断未结束，判断空投人为基金会|即owner，
        //if判_value溢出，小于等于totalsupply,to不为空
        //两种情况，判userCount关系，一种为更新，一种为插入 修改变量数不同

        //require id < 1000 ；totalCrowd += _value
        //if(totalCrowd == totalSupply) finish
        require(!isFinished,"众筹活动已结束！");
        require(msg.sender==foundation,"基金会才可空投");

        if(totalCrowd+_value>totalCrowd&&
           totalCrowd+_value<=totalSupply&&
           address(0)!=_to ){

            if(userID[_to]>0&&userID[_to]<userCount){
                //已经存在的用户，更新数额和事件即可
                crowdinfos[userID[_to]].crowdAmount += _value;
                crowdinfos[userID[_to]].crowdTime = now;
            }else {
                //新用户，插入，更新三个数据
                uint newid = userCount++;
                require(userCount<=1000,"众筹满了，编号超标了！");
                userID[_to] = newid;
                crowdinfos[newid].crowdAddr = _to;
                crowdinfos[newid].crowdAmount = _value;
                crowdinfos[newid].crowdTime = now;
            }
            totalCrowd += _value;
            if(totalCrowd == totalSupply){
                isFinished = true;
            }
            return true;

        }else{
            return false;
        }
    }

    //获得众筹信息
    function getCrowdInfo(address _user) public view returns (uint,uint){
        uint userid = userID[_user];
        if(userid==0 && msg.sender!=foundation){
            return (0,0);
        }
        return (crowdinfos[userid].crowdAmount,crowdinfos[userid].crowdTime);
    }

    //分账功能 售票然后分成
    function ticketBooking() public payable {
        require(msg.value > 0,"value得大于0！");
        //require(!isFinished,"得众筹完成！");// 众筹完成了 isFinished
        uint i = 0;
        for(i=0;i<crowdinfos.length;i++){
            crowdinfos[i].crowdAddr.transfer(msg.value*crowdinfos[i].crowdAmount/totalCrowd);
            //transfer， .amount / totalSupply 由于完成了 所以totalSupply与totalCrowd应该相等

        }
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function getSelfAddr() public view returns (address) {
        return address(this);
    }
}
