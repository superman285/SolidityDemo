pragma solidity >=0.5.0 <0.6;


contract Auction {


    address payable public seller;  //卖家
    address payable buyer;   //竞拍者
    uint auctionAmount;  //竞拍价
    uint auctionEndTime;        //结束时间
    bool isFinished;            //拍卖是否完成

    constructor(address payable _seller,uint _duration) public {
        seller = _seller;
        auctionEndTime = now + _duration;       //设置终止时间为当前时间加上设置的期限
        isFinished = false;
    }

    //查看剩余时间
    function leftTime() public view returns (uint _leftTime){
        _leftTime = auctionEndTime - now;
    }

    //竞价
    function bid() public payable{
        require(!isFinished);
        require(now < auctionEndTime);
        require(msg.value > auctionAmount);
        if(auctionAmount > 0 && address(0)!=buyer){
            buyer.transfer(auctionAmount);//tui qian
        }
        buyer = msg.sender;             //替换最新的最高竞价人
        auctionAmount = msg.value;      //替换最新的最高价
    }

    //终止拍卖活动
    function stopAuction() public payable {
        require(now >= auctionEndTime,"时间没到呢");
        require(!isFinished);
        isFinished = true;
        seller.transfer(auctionAmount);
    }

    //查看最高竞价者地址和价钱
    function getHightest() public view returns(address,uint) {
        return (buyer,auctionAmount);
    }

    //查看合约中的余额
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }


}