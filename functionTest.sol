pragma solidity ^0.4.25;

contract functionTest {

    address public ceo;
    uint private totalMoney;

    function functionTest() public{
        totalMoney = 1000000000;
        ceo = msg.sender;
    }


    /*constructor() public {

    }*/

    function isEqual(string _x, string _y) private returns (bool) {
        if(keccak256(_x) == keccak256(_y)) {
            return true;
        }
        return false;
    }

    function showResult(string _x, string _y) view public returns (bool){
        return isEqual(_x,_y);
    }

    function getBalance() public view returns (uint) {
        //require第二个参数是报错时的提示
        require(msg.sender == ceo,"only ceo can call");
        return totalMoney;
    }
    function getBalance2() public view onlyceo returns (uint) {
        return totalMoney;
    }


    modifier onlyceo() {
        require(msg.sender == ceo,"only ceo can call");
        _;  //这个占位符相当于函数体中的代码，满足了require条件才会执行下面的代码
    }

}
