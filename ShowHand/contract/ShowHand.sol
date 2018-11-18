pragma solidity ^0.4.25;

//构造函数
//
import {Console} from "./Console.sol";

contract ShowHandDemo {

    uint public bringInBet; //最小底注额
    uint public minmalBet; //最小下注额

    address private dealer; //平台方
    address public hostPlayer;  //主位
    address public guestPlayer; //客位
    address public activePlayer; //说话的玩家，即应该行动的玩家
    address public winner; //获胜者

    mapping(address => uint8[5]) public pokers; //52张牌，uint8够用 0~255, 5代表5轮
    mapping(address => uint) public totalBalance;    //玩家总下注金额
    mapping(address => uint) public roundBalance;    //玩家每一轮下注金额
    mapping(address => bool) public isPlayerActioned; //玩家是否下过注(包括底注)
    mapping(address => bool) private passThisRound; //本轮是否过牌了，一轮最多过一次

    bytes32 randSeed;   //随机种子
    uint8 joinRand; //区分加入方为主方或客方,做个随机处理
    uint8 public round;     // round 轮次

    bool public isGameFinished;     // isGameFinished 游戏是否结束

    constructor() public{
        bringInBet = 100;
        minmalBet = 100;
        round = 0;
        dealer = msg.sender;
        randSeed =  blockhash(block.number - 1);
        joinRand = uint8(keccak256(abi.encodePacked(now,msg.sender,block.number))) % 2;
    }

    modifier inGaming() {
        require(round>0 && !isGameFinished,"轮次必须大于0且游戏未结束");
        _;
    }

    modifier nowActived() {
        require(msg.sender == activePlayer,"必须到你的回合才可以行动！");
        _;
    }

    //加入游戏，主客随机而定
    function joinGame(address _joiner) public {
        require(round == 0, "轮次得从0开始");
        require(address(0) == hostPlayer || address(0) == guestPlayer, "已有两个玩家加入！");

        if(joinRand==0){
            require(guestPlayer != _joiner,"两方地址不能相同！");
            hostPlayer = _joiner;
            joinRand = 1;
            Console.log("hostPlayer",hostPlayer);
        }else {
            require(hostPlayer != _joiner,"两方地址不能相同！");
            guestPlayer = _joiner;
            joinRand = 0;
            Console.log("guestPlayer",guestPlayer);
        }

    }

    event OnPokerDealLight(address player,uint8 poker);
    event OnPokerDealDark(address player,uint8 poker);

    //下底注功能
    function bringIn() public payable{
        require(round == 0, "轮次必须为0");
        require(msg.sender == guestPlayer || msg.sender == hostPlayer,"你必须是参与的玩家！");
        require(msg.value == bringInBet,"下底注必须等于规定额100！");
        require(!isPlayerActioned[msg.sender],"你已经下过底注！");

        totalBalance[msg.sender] = msg.value;
        isPlayerActioned[msg.sender] = true;    //记得重置数据的地方

        //所有玩家都下了底注，就发牌
        if(isAllPlayerActioned()) {
            //发牌，先发暗牌，再发一张明牌
            pokers[hostPlayer][round] = dealPoker();
            uint pokerhostRound = pokers[hostPlayer][round];
            Console.log("darkhost",pokerhostRound);
            pokers[guestPlayer][round] = dealPoker();
            //Console.log("darkg",pokers[guestPlayer][round]);
            round++;

            pokers[hostPlayer][round] = dealPoker();
            emit OnPokerDealLight(hostPlayer,pokers[hostPlayer][round]);
            pokers[guestPlayer][round] = dealPoker();
            emit OnPokerDealLight(hostPlayer,pokers[guestPlayer][round]);

            nextRound();
        }
    }

    //下注功能
    function bet() public inGaming nowActived payable{
        require(msg.value >= minmalBet,"下注额必须大于等于规定最小下注额100！");
        if(msg.sender == hostPlayer) {
            require(roundBalance[msg.sender]+msg.value >= roundBalance[guestPlayer],"下注额必须大于等于客方");
            //require(msg.value >= roundBalance[guestPlayer],"下注额必须大于等于客方");
        }else if(msg.sender == guestPlayer){
            require(roundBalance[msg.sender]+msg.value >= roundBalance[hostPlayer],"下注额必须大于等于主方");
            //require(msg.value >= roundBalance[guestPlayer],"下注额必须大于等于主方");
        }

        isPlayerActioned[msg.sender] = true; // 必须有重置该数据的地方，轮次往下走时重置
        roundBalance[msg.sender] += msg.value; //下注时可以多次调这个方法，本轮下注总额
        totalBalance[msg.sender] += msg.value;

        //下一步
        nextMove();
    }

    //判断是否所有玩家都行动完毕
    function isAllPlayerActioned() private view returns (bool) {
        Console.log("isAllPlayerActionedStart",now);
        return isPlayerActioned[hostPlayer] && isPlayerActioned[guestPlayer];
    }

    //发牌，返回牌序号
    function dealPoker() private returns (uint8) {
        Console.log("dealPokerStart",now);
        randSeed = keccak256(abi.encodePacked(now,randSeed));
        return uint8(randSeed)%52;
        //有空考虑下发牌重复的问题
    }

    //下一个玩家
    function nextPlayer() private {
        Console.log("nextPlayerStart",now);
        activePlayer = (activePlayer==hostPlayer)?guestPlayer:hostPlayer;
    }

    //下一步行动
    function nextMove() private {
        require(round>0,"轮次需要大于0");
        Console.log("nextMoveStart",now);

        if(!isAllPlayerActioned()){
            Console.log("someone hasn't action",now);
            nextPlayer();
            return;
        }

        Console.log("当前轮次为，接下来发牌",uint(round));
        pokers[hostPlayer][round] = dealPoker();
        emit OnPokerDealLight(hostPlayer,pokers[hostPlayer][round]);

        pokers[guestPlayer][round] = dealPoker();
        emit OnPokerDealLight(guestPlayer,pokers[guestPlayer][round]);

        nextRound();

        if(round == 5) {
            Console.log("终于结束，目前轮数为",uint(round));
            //游戏结束,选出winner
            if(comparePokers(0,pokers[hostPlayer],pokers[guestPlayer])){
                winner = hostPlayer;
                Console.log("hostWin",winner);
            } else {
                winner = guestPlayer;
                Console.log("guestWin",winner);
            }
            isGameFinished = true;
            return;
        }
    }

    //重置轮次数据
    function resetRoundData() private{
        Console.log("resetRoundDataS",now);
        //激活玩家置为空
        activePlayer = address(0);
        //双方本轮金额置为0
        roundBalance[hostPlayer] = 0;
        roundBalance[guestPlayer] = 0;
        //双方置为未行动
        isPlayerActioned[hostPlayer] = false;
        isPlayerActioned[guestPlayer] = false;
        //双方置为本轮未过牌
        passThisRound[hostPlayer] = false;
        passThisRound[guestPlayer] = false;
    }

    //下一轮次
    function nextRound() private {
        Console.log("nextRoundStart",now);
        round++;
        //重置轮次数据
        resetRoundData();
        //决定谁先行动
        determineActivePlayer();
    }

    //决定下一个行动玩家
    function determineActivePlayer() private inGaming{
        Console.log("determineActivePlayerStart",now);
        //根据当前牌面大小决定谁下次先动
        if(pokers[hostPlayer][round-1]>=pokers[guestPlayer][round-1]) {
            activePlayer = hostPlayer;
            Console.log("determineNowHost",activePlayer);
        }else {
            activePlayer = guestPlayer;
            Console.log("determineNowGuest",activePlayer);
        }
    }

    //比较所有牌大小
    function comparePokers(uint8 _start,uint8[5] _hostPokers,uint8[5] _guestPokers) private pure returns (bool) {
        //Console.log("compareBigSmall",now);
        uint8 hostSum = 0;
        uint8 guestSum = 0;
        for(uint i = _start;i < 5;i++) {
            hostSum += _hostPokers[i];
            guestSum += _guestPokers[i];
        }
        return hostSum >= guestSum;     //相同也视为主方赢
    }

    //提现
    function withDraw() public inGaming payable{
        require(winner == msg.sender,"胜者才可以提现");
        require(isGameFinished,"游戏得结束才可提现");
        require(address(this).balance>0,"胜方已经提现了！");
        uint total = totalBalance[hostPlayer] + totalBalance[guestPlayer];
        winner.transfer(total * 9 / 10);
        //平台方抽水10%
        dealer.transfer(total / 10);
    }

    //弃牌
    function fold() public inGaming nowActived{

        //切换到下个玩家，并把下个玩家设为赢家
        nextPlayer();
        winner = activePlayer;
        isGameFinished = true;
    }

    //过牌
    function pass() public inGaming nowActived{
        require(roundBalance[hostPlayer]==roundBalance[guestPlayer],"本轮下注额相等才能过牌");//其实就是下注额都是0的时候才能过
        require(!passThisRound[msg.sender],"本轮你不可以再次过牌！");
        passThisRound[msg.sender] = true;

        nextMove();
    }

    //查看暗牌
    function getPocket() public view returns (uint8){
        return pokers[msg.sender][0];
    }

    //显示玩家牌
    function getPlayerPoker(uint8 pos) public view returns(uint8 hostShow,uint8 guestShow){

        if(pos==0 || pos>=round){
            hostShow = 55;
            guestShow = 55;
            return;
        }
        hostShow = pokers[hostPlayer][pos];
        guestShow = pokers[guestPlayer][pos];
    }

    function getRoundBalance() public view returns (uint) {
        return roundBalance[msg.sender];
    }

}