pragma solidity >=0.5.0 <=0.6.0;
pragma experimental ABIEncoderV2;

//import "./Console.sol";

contract TicTacToe {

    uint constant public gameCost = 0.1 ether;

    address payable public hostPlayer;
    address payable public guestPlayer;
    address payable public activePlayer;
    address public victorPlayer;

    bool private gameRunning;
    bool private gameCreated;

    uint8 private chessboardSize = 3;
    string[3][3] private chessboard;
    //"O"(host) or "X"(guest)
    mapping(address => string) private playerChess;
    mapping(address => uint8) private movesCount;

    string public gameResult;

    event GameCreated(address creatorAddr);
    event PlayerJoined(address playerAddr);
    event ActivePlayer(address activePlayerAddr);
    event GameFinished(string gameResult, address victor);
    event VictoryAward(address receiver, uint amount);

    constructor() public{
        gameRunning = false;
    }

    function getWholeBoard() public view returns (string[3][3] memory){
        return chessboard;
    }

    function createGame() public payable {
        require(msg.value == gameCost, "creator must send gameCost to create the game");
        hostPlayer = msg.sender;
        gameCreated = true;
        playerChess[hostPlayer] = "O";
        emit GameCreated(hostPlayer);
    }

    function joinGame() public payable {
        require(gameCreated,"game must be created first!");
        require(msg.sender != hostPlayer, "gameCreator cannot join the game");
        require(guestPlayer == address(0), "guestPlayer already exist");
        require(msg.value == gameCost, "gameJoiner must send gameCost to the contract");
        guestPlayer = msg.sender;
        emit PlayerJoined(guestPlayer);
        //启动游戏
        gameRunning = true;
        playerChess[guestPlayer] = "X";
        if (randomStart() == hostPlayer) {
            activePlayer = hostPlayer;
        } else if (randomStart() == guestPlayer) {
            activePlayer = guestPlayer;
        }
        emit ActivePlayer(activePlayer);
    }

    //前端怎么判断谁先开始,处理成返回值吧?或者谁先开始由前端随机?
    //若前端随机还需要传给智能合约设置activeplayer又需要用户等待时间 还是智能合约处理吧
    function randomStart() private view returns (address) {
        uint rand = uint(keccak256(abi.encodePacked(now, block.number))) % 2;
        if (rand == 0) {
            return hostPlayer;
        } else {
            return guestPlayer;
        }
    }

    //重新启动，重置参数，相当于创建，也要投入gameCost
    function restartGame() public payable {
        require(msg.sender == hostPlayer, "only creator has the restart right");
        //游戏未运行状态且guestPlayer存在，即游戏有胜负后 才可重启。防止creator随意重启
        require(!gameRunning && guestPlayer != address(0), "you can only restart after the game is over");
        require(msg.value == gameCost, "restart must send gameCost to the contract!");

        //步数置空,要在重置guestPlayer之前
        delete movesCount[hostPlayer];
        delete movesCount[guestPlayer];
        //客方棋子置空,要在重置guestPlayer之前
        delete playerChess[guestPlayer];

        //重置guestPlayer,hostPlayer永远不变
        delete guestPlayer;
        //重置活动玩家(等价于activePlayer=address(0);)
        delete activePlayer;
        //棋盘置空
        delete chessboard;
        //上局赢家置空
        delete victorPlayer;
        delete gameResult;
    }

    function getBonuspool() public view returns (uint){
        return address(this).balance;
    }

    function setChess(uint8 row, uint8 column) public {
        require(gameRunning, "the game is not running!");
        require(msg.sender == activePlayer, "it's not your turn!");
        require(row < 3 && column < 3, "go beyond the scope!");
        require(keccak256(abi.encodePacked(chessboard[row][column])) == keccak256(abi.encodePacked("")), "Field not empty, you cannot set here!");

        if (msg.sender == hostPlayer) {
            //host
            chessboard[row][column] = "O";
            movesCount[hostPlayer]++;
        } else {
            //guest
            chessboard[row][column] = "X";
            movesCount[guestPlayer]++;
        }

        //优化下，至少5步才需要结算胜负
        if ((movesCount[hostPlayer] + movesCount[guestPlayer]) >= (chessboardSize * 2 - 1)) {
            //Console.log("settle", now);
            settleStage(row, column);
        }

        if (gameRunning) {
            takeTurnStage();
        }
    }

    //走了致胜一步的胜利者调的这个方法，多花点ether也没关系了
    function setVictor(address payable player) private {
        gameRunning = false;

        victorPlayer = player;
        if (player == hostPlayer) {
            gameResult = "hostVictory";
        } else {
            gameResult = "guestVictory";
        }
        delete activePlayer;
        emit GameFinished(gameResult, player);
        //发奖
        emit VictoryAward(player,address(this).balance);
        player.transfer(address(this).balance);
    }

    //平局了 但走最后一步的人反而因为调用这个setTie会消耗更多ether 是否不公平
    //看能否由合约来发起这个方法
    function setTie() private {
        gameRunning = false;
        gameResult = "tie";
        delete activePlayer;
        emit GameFinished(gameResult, activePlayer);
        //平局发奖
        uint tieAward = address(this).balance / 2;
        hostPlayer.transfer(tieAward);
        guestPlayer.transfer(tieAward);
    }

    //结算阶段
    function settleStage(uint8 player_row, uint8 player_column) private {
        //玩家所在列 达到3个
        //Console.log("firstJudge", now);
        //uint8 row_count = 0;
        for ((uint8 row, uint8 row_count) = (0,0); row < chessboardSize; row++) {
            if (keccak256(abi.encodePacked(chessboard[row][player_column])) == keccak256(abi.encodePacked(playerChess[activePlayer]))) {
                row_count++;
                if (row_count == 3) {
                    //activePlayer is winner
                    setVictor(activePlayer);
                    return;
                }
            } else {
                break;
            }
        }

        //Console.log("secondJudge", now);
        //玩家所在行达到3个
        //uint8 column_count = 0;
        for ((uint8 column, uint8 column_count) = (0,0); column < chessboardSize; column++) {
            if (keccak256(abi.encodePacked(chessboard[player_row][column])) == keccak256(abi.encodePacked(playerChess[activePlayer]))) {
                column_count++;
                if (column_count == 3) {
                    //activePlayer is winner
                    setVictor(activePlayer);
                    return;
                }
            } else {
                break;
            }
        }

        //Console.log("thirdJudge", now);
        //玩家不在上下左右四个位置 就判对角线
        if (keccak256(abi.encodePacked(chessboard[0][1])) != keccak256(abi.encodePacked(playerChess[activePlayer])) &&
        keccak256(abi.encodePacked(chessboard[1][0])) != keccak256(abi.encodePacked(playerChess[activePlayer])) &&
        keccak256(abi.encodePacked(chessboard[1][2])) != keccak256(abi.encodePacked(playerChess[activePlayer])) &&
        keccak256(abi.encodePacked(chessboard[2][1])) != keccak256(abi.encodePacked(playerChess[activePlayer]))) {

            //uint8 diagonalCount = 0;
            for ((uint8 i, uint8 diagonalCount) = (0,0); i < chessboardSize; i++) {
                if (keccak256(abi.encodePacked(chessboard[i][i])) == keccak256(abi.encodePacked(playerChess[activePlayer]))) {
                    diagonalCount++;
                    if (diagonalCount == 3) {
                        //activePlayer is winner
                        setVictor(activePlayer);
                        return;
                    }
                } else {
                    break;
                }
            }


            //uint8 anti_diagonalCount = 0;
            for ((uint8 j, uint8 anti_diagonalCount) = (0,0); j < chessboardSize; j++) {
                if (keccak256(abi.encodePacked(chessboard[j][chessboardSize - j - 1])) == keccak256(abi.encodePacked(playerChess[activePlayer]))) {
                    anti_diagonalCount++;
                    if (anti_diagonalCount == 3) {
                        //activePlayer is winner
                        setVictor(activePlayer);
                        return;
                    }
                } else {
                    break;
                }
            }
        }

        //判平局
        if ((movesCount[hostPlayer] + movesCount[guestPlayer]) == (chessboardSize ** 2)) {
            //平局tie
            setTie();
        }
    }

    //换轮次阶段
    function takeTurnStage() private {
        if (activePlayer == hostPlayer) {
            activePlayer = guestPlayer;
        } else if (activePlayer == guestPlayer) {
            activePlayer = hostPlayer;
        }
        emit ActivePlayer(activePlayer);
    }
}

