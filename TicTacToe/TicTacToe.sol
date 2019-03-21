pragma solidity >=0.5.0 <=0.6.0;
pragma experimental ABIEncoderV2;

contract TicTacToe {

    address payable public hostPlayer;
    address payable public guestPlayer;
    address public activePlayer;
    address public victorPlayer;

    bool public gameRunning;

    uint8 public chessboardSize = 3;
    string[3][3] chessboard;

    mapping(address => string) playerChess;
    mapping(address => uint8) movesCount;

    function getWholeBoard() public view returns (string[3][3] memory){
        return chessboard;
    }

    constructor() payable public{
        hostPlayer = msg.sender;
        gameRunning = false;
        playerChess[hostPlayer] = "O";
    }

    function joinGame() public {
        require(msg.sender != hostPlayer, "gameCreator cannot join the game");
        require(guestPlayer == address(0), "guestPlayer already exist");
        guestPlayer = msg.sender;
        //启动游戏
        gameRunning = true;
        playerChess[guestPlayer] = "X";
        randomStart();
    }

    function randomStart() public {
        uint rand = uint(keccak256(abi.encodePacked(now, hostPlayer, guestPlayer))) % 2;
        if (rand == 0) {
            activePlayer = hostPlayer;
        } else {
            activePlayer = guestPlayer;
        }
    }

    //重新启动，重置参数
    function restartGame() public {
        require(msg.sender==hostPlayer,"only creator has the restart right");
        //游戏未运行状态且guestPlayer存在，即游戏有胜负后 才可重启。防止creator随意重启
        require(!gameRunning&&guestPlayer!=address(0),"you can only restart after the game is over");
        //重置guestPlayer,hostPlayer永远不变
        delete guestPlayer;
        //重置活动玩家
        delete activePlayer;
        //棋盘置空
        delete chessboard;
        //上局赢家置空
        delete victorPlayer;
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

        settleStage(row,column);

        if(gameRunning){
            takeTurnStage();
        }

    }

    function setVictor(address player) private {
        gameRunning = false;
        victorPlayer = player;
        //emit event
        //发奖
    }

    function setTie() private {
        gameRunning = false;
        //emit event
        //平局发奖
    }

    //每步结算阶段
    function settleStage(uint8 player_row, uint8 player_column) private {
        //玩家所在列 达到3个
        uint8 row_count = 0;
        for (uint8 row = 0; row < chessboardSize; row++) {
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

        //玩家所在行达到3个
        uint8 column_count = 0;
        for (uint8 column = 0; column < chessboardSize; column++) {
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

        //玩家不在上下左右四个位置 就判对角线
        if (keccak256(abi.encodePacked(chessboard[0][1])) != keccak256(abi.encodePacked(playerChess[activePlayer])) &&
         keccak256(abi.encodePacked(chessboard[1][0])) != keccak256(abi.encodePacked(playerChess[activePlayer])) &&
         keccak256(abi.encodePacked(chessboard[1][2])) != keccak256(abi.encodePacked(playerChess[activePlayer])) &&
         keccak256(abi.encodePacked(chessboard[2][1])) != keccak256(abi.encodePacked(playerChess[activePlayer])) ) {

            uint8 diagonalCount = 0;
            for (uint8 i = 0; i < chessboardSize; i++) {
                if (keccak256(abi.encodePacked(chessboard[i][i])) == keccak256(abi.encodePacked(playerChess[activePlayer]))) {
                    diagonalCount++;
                    if(diagonalCount == 3) {
                        //activePlayer is winner
                        setVictor(activePlayer);
                        return;
                    }
                }else{
                    break;
                }
            }

            uint8 anti_diagonalCount = 0;
            for (uint8 j = 0; j < chessboardSize; j++) {
                if (keccak256(abi.encodePacked(chessboard[j][chessboardSize-j])) == keccak256(abi.encodePacked(playerChess[activePlayer]))) {
                    anti_diagonalCount++;
                    if(anti_diagonalCount == 3) {
                        //activePlayer is winner
                        setVictor(activePlayer);
                        return;
                    }
                }else{
                    break;
                }
            }
        }

        //判平局
        if((movesCount[hostPlayer]+movesCount[guestPlayer])==(chessboardSize**2)){
            //平局tie
            setTie();
        }
    }

    //换轮次阶段
    function takeTurnStage() public {
        if (activePlayer == hostPlayer) {
            activePlayer = guestPlayer;
        } else if (activePlayer == guestPlayer) {
            activePlayer = hostPlayer;
        }
    }

}
