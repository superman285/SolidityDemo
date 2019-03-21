pragma solidity >=0.5.0 <=0.6.0;
pragma experimental ABIEncoderV2;

contract TicTacToe {

    address payable public hostPlayer;
    address payable public guestPlayer;

    address public activePlayer;

    bool public gameRunning;


    uint8 public chessboardSize = 3;
    string[3][3] chessboard;

    mapping(address => string) playerChess;
    mapping(address => uint8) stepCount;

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
        require(guestPlayer == address(0), "You can joinGame only once");
        guestPlayer = msg.sender;
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


    function setChess(uint8 row, uint8 column) public {

        require(gameRunning == true, "the game is over!");
        require(msg.sender == activePlayer, "it's not your turn!");
        require(row < 3 && column < 3, "go beyond the scope!");
        require(keccak256(abi.encodePacked(chessboard[row][column])) == keccak256(abi.encodePacked("")), "Field not empty, you cannot set here!");


        if (msg.sender == hostPlayer) {
            //host
            chessboard[row][column] = "O";
            stepCount[hostPlayer]++;
        } else {
            //guest
            chessboard[row][column] = "X";
            stepCount[guestPlayer]++;
        }

        settleStage(row,column);

        if(gameRunning){
            takeTurnStage();
        }

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
                    gameRunning = false;
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
                    gameRunning = false;
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
                        gameRunning = false;
                    }
                }else{
                    break;
                }
            }

            uint8 anti_diagonalCount = 0;
            for (uint8 j = 0; j < chessboardSize; j++) {
                if (keccak256(abi.encodePacked(chessboard[j][2-j])) == keccak256(abi.encodePacked(playerChess[activePlayer]))) {
                    anti_diagonalCount++;
                    if(anti_diagonalCount == 3) {
                        //activePlayer is winner
                        gameRunning = false;
                    }
                }else{
                    break;
                }
            }
        }

        //判平局
        if((stepCount[hostPlayer]+stepCount[guestPlayer])==9){
            //平局tie
            gameRunning = false;
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
