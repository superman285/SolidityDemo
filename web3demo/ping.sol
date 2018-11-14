pragma solidity^0.4.24;

contract ping {
    string myMsg="pong2";
    function setMsg(string _msg) public {
        myMsg = _msg;
    }
    function getMsg() public view returns (string) {
        return myMsg;
    }
}