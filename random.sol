pragma solidity ^0.4.24;

contract random {
    function random(){

    }

    function getRandom() public view returns (bytes32) {
        return keccak256("hello",msg.sender,now,block.number);
    }

    function getRandom2() public view returns (uint) {
        return uint(keccak256("hello",msg.sender,now,block.number)) % 100;
    }
    function getRandom3() public view returns (uint) {
        return uint(block.blockhash(block.number-1));
    }
}
