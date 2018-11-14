pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

//业务逻辑
/*
创建/管理合约
初始化合约
赋予投票者权利(主持人做的)
委托代理投票
向议案(提案)投票
宣布结果
*/

contract CommunityVote {

    constructor(string[] _proposalNames) public{
        chairman = msg.sender;
        voters[chairman].weight = 1;//主持人1票
        for(uint i=0;i < _proposalNames.length;i++){
            Proposal memory p = Proposal(_proposalNames[i],0);
            proposals.push(p);
        }
    }

    //选民信息结构
    struct Voter {
        uint weight;//可投票数
        bool hasVoted;//是否已经投票
        address delegate;//授权给其他人，被授权人的地址
        uint chooseIndex;//选择议案编号
    }

    //议案结构
    struct Proposal {
        string name;//议案名字
        uint votedCount;//被投数
    }

    //议案数组
    Proposal[] public proposals;
    //管理员/主持人
    address public chairman;
    //选民信息映射
    mapping(address=>Voter) public voters;


    //主持人授权
    function giveRightToVoter(address _to) public {
        require(msg.sender == chairman,'主持人才可以赋予权利！');
        require(!voters[_to].hasVoted,"必须没投过票！");
        require(voters[_to].weight == 0,'手里没票才可以被授权');
        //三个判断
        voters[_to].weight = 1; //真正授权
    }
    //委托，托别人帮忙投票，
    function delegate(address _to) public {
        address trustor = msg.sender;    //委托人trustor，被委托人_to

        require(voters[trustor].weight > 0,"委托人手里有票才可以");//被委托的人手里有票
        require(_to != trustor);//别自己跟自己玩儿
        //三个判断

        //循环一直找到，没再授权给别人的人，解决授权链条的问题
        while(voters[_to].delegate != address(0)){
            _to = voters[_to].delegate;
            require(_to != trustor); //不能绕了一圈又回到自己这儿
        }
        //在这里得到一个 最后可托付的人 delegate = _to
        voters[trustor].delegate = _to;
        voters[trustor].hasVoted = true; //我委托了，即我投过了
        //如果 _to已经投票，即我再支持他一下；否则加权重
        if(voters[_to].hasVoted) {
            uint chooseIndex = voters[_to].chooseIndex;
            //被委托人已经投票，我再支持他，手里有多少就支持他多少
            proposals[chooseIndex].votedCount += voters[trustor].weight;
        }else {
            //把手里的票交到被委托人手里
            voters[_to].weight += voters[trustor].weight;
        }
        voters[trustor].weight = 0;
    }

    //投票
    function vote(uint _chooseIndex) public {
        require(!voters[msg.sender].hasVoted,"没投过才可以投！");
        require(voters[msg.sender].weight>0,"手里有票才可以投");
        //需要扣票操作么？
        voters[msg.sender].weight -= 1;
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].chooseIndex = _chooseIndex;
        //增加议案投票数
        proposals[_chooseIndex].votedCount += 1;

    }

    //获取最高票的index
    function getWinIndex() public view returns (uint) {
        uint index = 0;
        uint maxCount = 0;
        for(uint i = 0;i<proposals.length;i++){
            if(proposals[i].votedCount > maxCount) {
                maxCount = proposals[i].votedCount;
                index = i;
            }
        }
        return index;
    }

    //get win name，获得最高票合约的合约名
    function getWinName() public view returns (string) {
        uint index = getWinIndex();
        return proposals[index].name;
    }

}
