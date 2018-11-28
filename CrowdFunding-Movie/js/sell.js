var ensureBtn = document.querySelector(".ensureModal"),
    unsureBtn = document.querySelector(".unsureModal");
var popupModal = document.querySelector(".popModal");
var addrInput = document.querySelector(".addrInput");

var buyTicketBtn = document.getElementsByClassName("buyTicket")[0];

var ticketBuyer;

var accountEmpty = true;

unsureBtn.onclick = function () {
    popupModal.classList.remove("shown");
};
ensureBtn.onclick = function () {
    //登录用户

    if (!web3.utils.isAddress(addrInput.value)) {
        alert("地址格式不对");
        addrInput.value = "";
        return;
    }
    ticketBuyer = addrInput.value;
    accountEmpty = false;
    console.log(`获取的地址${ticketBuyer}`);
    popupModal.classList.remove("shown");
};

buyTicketBtn.onclick = function () {

    if (!ticketBuyer) {
        alert("请输入购买人账户!");
        popupModal.classList.add("shown");
    }
    if(!accountEmpty) {
        mvcContractObj.methods.ticketBooking().send({
            from: ticketBuyer,
            value: 20000000000000000,
            gas: 3000000
        }, function (err, result) {
            if (!err) {
                alert("购票成功！")
            } else {
                console.log(err);
                alert("购票失败！")
            }
        })
    }

};