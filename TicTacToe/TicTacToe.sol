pragma solidity >=0.5.0 <=0.6.0;
pragma experimental ABIEncoderV2;

contract TicTacToe {

    address payable public hostPlayer;
    address payable public guestPlayer;

    address public activePlayer;

    bool public gameOver;

    string[3][3] chessboard;
    uint8 public chessboardSize = 3;

    constructor() payable public{

        hostPlayer = msg.sender;
        gameOver = false;

    }

    function joinGame() public {
        require(msg.sender != hostPlayer, "gameCreator cannot join the game");
        require(guestPlayer == address(0), "You can joinGame only once");
        guestPlayer = msg.sender;
    }

    function getWholeBoard() public view returns (string[3][3] memory){
        return chessboard;
    }

    function setChess(uint8 row, uint8 column) public {

        require(gameOver == false, "the game is over!");
        require(msg.sender == activePlayer, "it's not your turn!");
        require(row < 3 && column < 3, "go beyond the scope!");
        require(keccak256(abi.encodePacked(chessboard[row][column])) == keccak256(abi.encodePacked("")), "Field not empty, you cannot set here!");


        if (msg.sender == hostPlayer) {
            //host
            chessboard[row][column] = "O";
        } else {
            //guest
            chessboard[row][column] = "X";
        }




    }

    function settleVictory() private {



    }

}
