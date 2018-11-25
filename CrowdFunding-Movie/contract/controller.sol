pragma solidity ^0.4.25;

import "./tokenModule/kccToken.sol";
import "./voteModule/mvcCrowd.sol";


contract controller {


    kccToken kcc; //kcc合约
    mvcCrowd mvc; //mvc合约

    uint kccUnit;  //投票时最小kcc单元
    uint mvcUnit;   //最小mvc认购单元

    address owner;

    constructor(uint _kccUnit,uint _mvcUnit) public {
        //要对应项kccToken和mvcCrowd的构造函数的参数个数和类型
        kcc = new kccToken(21000000);
        mvc = new mvcCrowd("batMan",10000);
        kccUnit = _kccUnit;
        mvcUnit = _mvcUnit;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    //通过setAddr地址修改kccToken合约和crowd合约
    function setAddr(address _kccAddr,address _mvcAddr) public onlyOwner {
        kcc = kccToken(_kccAddr);
        mvc = mvcCrowd(_mvcAddr);
    }

    //获得kcc和mvc合约地址
    function getAddr() public view returns (address kccAddr,address mvcAddr){
        kccAddr = kcc.getSelfAddr();
        mvcAddr = mvc.getSelfAddr();
    }




}