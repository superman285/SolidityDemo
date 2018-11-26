/*var web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"));
web3.eth.getAccounts(function (err,result) {
    console.log(err,result);
});*/

//构造合约实例



console.log(kccContractObj);
console.log(mvcContractObj);
console.log(controllerContractObj);

var rechargeInput = document.getElementsByClassName("rechargeInput")[0];
var rechargeBtn = document.getElementsByClassName("rechargeBtn")[0];
var rechargeTarget = document.getElementsByClassName("rechargeTarget")[0];

var voteInput = document.getElementsByClassName("voteInput")[0],
    voteBtn = document.getElementsByClassName("voteBtn")[0];

var kccFoundation = "0x00",
    mvcFoundation = "0x00";

var ensureBtn = document.querySelector(".ensureModal"),
    unsureBtn = document.querySelector(".unsureModal");
var popupModal = document.querySelector(".popModal");
var addrInput = document.querySelector(".addrInput");

var to_address= "0x00";

rechargeTarget.onclick = function(){
    popupModal.classList.add("shown");
}
unsureBtn.onclick = function () {
    popupModal.classList.remove("shown");
}
ensureBtn.onclick = function () {
    to_address = addrInput.value;
    if(!web3.utils.isAddress(to_address)){
        alert("地址格式不对");
        addrInput.value="";
        return;
    }
    console.log(`获取的地址${to_address}`);
    popupModal.classList.remove("shown");
};

function getKccFoundation() {
    kccContractObj.methods.foundation().call(function (err,result) {
        console.log(result);
        kccFoundation = result;
    });
    return kccFoundation;
}

function getMvcFoundation() {
    mvcContractObj.methods.foundation().call(function (err,result) {
        mvcFoundation = result;
    });
    return mvcFoundation;
}

kccFoundation = getKccFoundation();
mvcFoundation = getMvcFoundation();

rechargeBtn.onclick = function () {
    console.log("谁是大哥"+kccFoundation);
    console.log("谁是大哥"+mvcFoundation);
    if(!rechargeInput.value){
        alert("请输入充值金额！");
        return;
    }else {
        if (to_address==="0x00") {
            alert("充值对象地址有误！");
            return;
        }
        var to_value = rechargeInput.value;
        kccContractObj.methods.airDrop(to_address,to_value).send({
            from:kccFoundation,
            gas:300000
        },function(err,result){
            console.log(to_value);
            console.log(to_address);
            if(!err){
                console.log(result);
                console.log("airDrop done!");
                alert("空投成功");
            }else {
                console.log("airDrop failed!");
                alert("空投失败");
            }
        });
    }
};

//投票
//投票者的kcc转移给owner，空投mvc给投票者，即kcc换mvc
voteBtn.onclick = function () {
    console.log("谁是大哥"+kccFoundation);
    console.log("谁是大哥"+mvcFoundation);
    if(!voteInput.value){
        alert("请输入投票支持金额！");
        return;
    }else {
        if (to_address==="0x00") {
            alert("请先输入充值对象地址！");
            return;
        }
        var _to = mvcFoundation;
        var _value = voteInput.value;
        var msgsender = to_address;
        kccContractObj.methods.transfer(_to,_value).send({
            from: to_address,
            gas: 300000,
        },function (err,result) {
            if(result){
                console.log("结果");
                console.log(result);
                console.log("transfer done!");
                alert("转移成功");
            }else {
                console.log("transfer failed!");
                alert("转移失败");
            }
        });


        mvcContractObj.methods.airDrop(to_address,_value).send({
            from: mvcFoundation,
            gas: 300000
        },function(err,result){
            if(!err){
                console.log(result);
                console.log("MVC airDrop done!");
                alert("mvc空投成功");
            }else {
                console.log("MVC airDrop failed!");
                alert("mvc空投失败");
            }
        });

    }


};