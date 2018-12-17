pragma solidity ^0.4.25;

//构造函数
//
import {Console} from "./Console.sol";

contract ShowHandDemo {

    address private dealer; //平台方
    bytes32 randSeed;   //随机种子

    uint public bringInBet; //最小底注额
    uint public minmalBet; //最小下注额

    uint8 joinTurn;

    address public hostPlayer;  //主位
    address public guestPlayer; //客位
    address public activePlayer; //说话的玩家，即应该行动的玩家
    address public winner; //获胜者

    mapping(address => uint8[5]) public pokers; //52张牌，uint8够用 0~255, 5代表5轮
    mapping(address => uint) public totalBalance;    //玩家总下注金额
    mapping(address => uint) public roundBalance;    //玩家每一轮下注金额
    mapping(address => bool) public isPlayerActioned; //玩家是否下过注(包括底注)

    // round 轮次
    uint8 public round;

    // isGameFinished 游戏是否结束
    bool public isGameFinished;

    constructor() public{
        bringInBet = 100;
        minmalBet = 100;
        round = 0;
        dealer = msg.sender;
        randSeed =  blockhash(block.number - 1);
        emit OnGameCreated();
    }

    event OnPlayerJoined(address player);
    function joinGame(address _joiner) public {
        require(round == 0, "轮次得从0开始");
        require(address(0) == hostPlayer || address(0) == guestPlayer, "已有两个玩家加入！");

        if(joinTurn==0){
            hostPlayer = _joiner;
            joinTurn = 1;
            //emit OnPlayerJoined(hostPlayer);
            Console.log("timeNow",now);
            Console.log("hostP",hostPlayer);
        }else {
            require(hostPlayer != _joiner,"两方地址不能相同！");
            guestPlayer = _joiner;
            emit OnPlayerJoined(guestPlayer);
        }

    }

    function isAllPlayerActioned() public view returns (bool) {
        Console.log("isAllPlayerActionedStart",now);
        return isPlayerActioned[hostPlayer] && isPlayerActioned[guestPlayer];
    }
    function dealPoker() private returns (uint8) {
        Console.log("dealPokerStart",now);
        randSeed = keccak256(abi.encodePacked(now,randSeed));
        return uint8(randSeed)%52;
        //有空了考虑下发牌重复的问题
    }

    event OnPokerDealLight(address player,uint8 poker);
    event OnPokerDealDark(address player,uint8 poker);
    event OnGameCreated();


    function bringIn() public payable{
        require(round == 0, "轮次得从0开始");
        require(msg.sender == guestPlayer || msg.sender == hostPlayer,"你必须是参与的玩家！");
        require(msg.value == bringInBet,"下底注必须为规定额");

        totalBalance[msg.sender] = msg.value;
        isPlayerActioned[msg.sender] = true;    //记得重置数据的地方

        //所有玩家都下了底注，就发牌
        if(isAllPlayerActioned()) {
            //发牌，先发暗牌，再发一张明牌
            pokers[hostPlayer][round] = dealPoker();
            uint pokerhostRound = pokers[hostPlayer][round];
            Console.log("darkh",pokerhostRound);
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

    function bet() public payable{
        require(msg.value >= minmalBet,"下注额必须大于等于规定最小下注额");
        require(msg.sender == activePlayer,"必须是到你说话你才可以下");
        require(round>0 && !isGameFinished,"轮次大于0才可以下注，轮次等0时下底注，且游戏未结束");
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

    function nextPlayer() public {
        Console.log("nextPlayerStart",now);
        activePlayer = (activePlayer==hostPlayer)?guestPlayer:hostPlayer;
    }

    function nextMove() public {
        require(round>0,"轮次大于0");
        Console.log("nextMoveStart",now);

        if(!isAllPlayerActioned()){
            Console.log("someone hasn't action",now);
            nextPlayer();
            return;
        }


        Console.log("roundNum andthen deal",uint(round));
        pokers[hostPlayer][round] = dealPoker();
        emit OnPokerDealLight(hostPlayer,pokers[hostPlayer][round]);

        pokers[guestPlayer][round] = dealPoker();
        emit OnPokerDealLight(guestPlayer,pokers[guestPlayer][round]);

        nextRound();

        if(round == 5) {
            Console.log("round5come",now);
            Console.log("roundNum",uint(round));
            //游戏结束,选出winner
            if(comparePokers(0,pokers[hostPlayer],pokers[guestPlayer])){

                winner = hostPlayer;
                Console.log("hostWin",winner);
            } else {
                winner = guestPlayer;
                Console.log("guestWin",winner);
            }
            isGameFinished = true;
            //记得退出
            return;
        }
    }

    function resetRoundData() private{
        Console.log("resetRoundDataS",now);
        activePlayer = address(0);
        roundBalance[hostPlayer] = 0;
        roundBalance[guestPlayer] = 0;
        isPlayerActioned[hostPlayer] = false;
        isPlayerActioned[guestPlayer] = false;
    }

    function nextRound() private {
        Console.log("nextRoundStart",now);
        round++;
        //重置轮次数据
        resetRoundData();
        //决定谁先行动
        determineActivePlayer();
    }
    function determineActivePlayer() private{
        //此处比较的是明牌开始的总值，不是当前牌的大小？
        /*if(comparePokers(1,pokers[hostPlayer],pokers[guestPlayer])) {
            activePlayer = hostPlayer;
        }else {
            activePlayer = guestPlayer;
        }*/
        require(!isGameFinished,"game is over");
        Console.log("determineActivePlayerStart",now);
        //根据当前牌的大小来决定谁下次先动
        if(pokers[hostPlayer][round-1]>=pokers[guestPlayer][round-1]) {
            activePlayer = hostPlayer;
            Console.log("determineNowHost",activePlayer);
        }else {
            activePlayer = guestPlayer;
            Console.log("determineNowGuest",activePlayer);
        }

    }

    //
    function comparePokers(uint8 _start,uint8[5] _hostPokers,uint8[5] _guestPokers) private returns (bool) {
        Console.log("compareBigSmall",now);
        uint8 hostSum = 0;
        uint8 guestSum = 0;
        for(uint i = _start;i < 5;i++) {
            hostSum += _hostPokers[i];
            guestSum += _guestPokers[i];

        }
        Console.log("hostSum",uint(hostSum));
        Console.log("guestSum",uint(guestSum));

        return hostSum >= guestSum;     //相同也视为主方赢
    }

    function withDraw() public payable{
        require(winner == msg.sender,"胜者才可以提现");
        require(isGameFinished,"游戏得结束才可提现");
        uint total = totalBalance[hostPlayer] + totalBalance[guestPlayer];
        winner.transfer(total * 9 / 10);
        //平台方抽水10%
        dealer.transfer(total / 10);
    }

    //弃牌
    function fold() public {
        require(round>0 && !isGameFinished,"轮次大于0，且游戏未结束");
        require(msg.sender == activePlayer,"必须是当前行动玩家才能弃");

        //切换到下个玩家，并把下个玩家设为赢家
        nextPlayer();
        winner = activePlayer;
        isGameFinished = true;
    }

    //过牌
    function pass() public {
        require(round>0 && !isGameFinished,"过牌需要轮次大于0，且游戏未结束");
        require(msg.sender == activePlayer,"必须是当前行动玩家才能弃");
        require(roundBalance[hostPlayer]==roundBalance[guestPlayer],"本轮下注额相等才能过牌");//其实就是下注额都是0的时候才能过

        nextMove();
    }

    //查看暗牌
    function getPocket() public view returns (uint8){
        return pokers[msg.sender][0];
    }



}
