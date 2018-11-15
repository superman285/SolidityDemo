pragma solidity ^0.4.25;

//构造函数
//

contract ShowHandDemo {

    address private dealer; //庄家
    bytes32 randSeed;   //随机种子

    uint public bringInBet = 1; //最小下底注
    uint public minmalBet = 1; //最小下注

    address public hostPlayer;
    address public guestPlayer;
    address public activePlayer; //说话的玩家
    address public winner; //获胜者

    mapping(address=>uint8[5]) public pokers; //52张牌，uint8够用 0~255

    mapping(address=>uint8) public totalBalance;    //玩家总下注金额
    mapping(address=>uint8) public roundBalance;    //玩家每一轮下注金额
    // isPlayerActioned; 玩家是否下过注

    // round 轮次
    // isGameFinished 游戏是否结束


    constructor() {

    }
}
