pragma solidity ^0.4.24;

contract Gambling {


    address Dealer;//管理员，荷官/庄家
    bool isFinished;//是否已经结束
    struct Player {
        address addr;
        uint amount; //下注金额
    }

    Player[] inBig; //下注大的人
    Player[] inSmall;//下注小的人

    //玩家们下注总金额
    uint totalBig;
    uint totalSmall;
    //当前时间
    uint nowTime;


    constructor() public{
        Dealer = msg.sender;
        totalSmall = 0;
        totalBig = 0;
        isFinished = false;
        nowTime = now;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getNowtime() public view returns (uint) {
        return now;
    }

    //下注
    function stake(bool BigOrSmall) public payable returns (bool) {
        require(msg.value>0);

        //构造玩法
        Player memory p = Player(msg.sender,msg.value);

        //输入真视为买大
        if(BigOrSmall){
            //big
            inBig.push(p);
            totalBig += p.amount;
        }else {
            //small
            inSmall.push(p);
            totalSmall += p.amount;
        }
        return true;

    }

    function openWinner() payable public returns (bool) {
        //时间到 20s后才开奖
        require(now > nowTime + 20);
        //开过奖则不能再开
        require(!isFinished);

        //得到开奖的随机数,0~17
        uint points = uint(keccak256(msg.sender,now,block.number)) % 18;


        if(points >= 9){
            //big win 本金+奖金
            for(uint i = 0;i < inBig.length;i++){
                p = inBig[i];
                p.addr.transfer(p.amount+totalSmall*p.amount/totalBig);
                //按自己下注大金额在总下注大金额的比例 来分下注小的人的奖金
            }
        }else {
            //small win
            for(uint i = 0;i < inSmall.length;i++){
                p = inSmall[i];
                p.addr.transfer(p.amount+totalBig*p.amount/totalSmall);
            }
        }
        isFinished = true;
        return true;
    }


    //destroy contract
    function kill() public {
        require(msg.sender == owner,"只有自己能销毁");
        selfdestruct(owner); //destroy contract
    }
}
