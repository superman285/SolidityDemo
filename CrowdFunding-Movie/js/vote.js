
//合约实例
console.log(kccContractObj);
console.log(mvcContractObj);
console.log(controllerContractObj);

var rechargeInput = document.getElementsByClassName("rechargeInput")[0];
var rechargeBtn = document.getElementsByClassName("rechargeBtn")[0];
var rechargeTarget = document.getElementsByClassName("rechargeTarget")[0];

var voteInput = document.getElementsByClassName("voteInput")[0],
    voteBtn = document.getElementsByClassName("voteBtn")[0];
var refreshBtn = document.getElementsByClassName("refresh")[0];

var kccFoundation = "0x00",
    mvcFoundation = "0x00";

var ensureBtn = document.querySelector(".ensureModal"),
    unsureBtn = document.querySelector(".unsureModal");
var popupModal = document.querySelector(".popModal");
var addrInput = document.querySelector(".addrInput");

var to_address = "0x00";

//信息展示span

var movieName = document.getElementsByClassName("movieName")[0],
    holdingShare = document.getElementsByClassName("holdingShare")[0],
    mvcAmount = document.getElementsByClassName("mvcAmount")[0],
    kccBalance = document.getElementsByClassName("kccBalance")[0],
    voteTime = document.getElementsByClassName("voteTime")[0];


rechargeTarget.onclick = function () {
    popupModal.classList.add("shown");
};
unsureBtn.onclick = function () {
    popupModal.classList.remove("shown");
};
ensureBtn.onclick = function () {
    //登录用户
    to_address = addrInput.value;
    if (!web3.utils.isAddress(to_address)) {
        alert("地址格式不对");
        addrInput.value = "";
        return;
    }
    console.log(`获取的地址${to_address}`);
    popupModal.classList.remove("shown");
};

function getKccFoundation() {
    kccContractObj.methods.foundation().call(function (err, result) {
        console.log(result);
        kccFoundation = result;
    });
    return kccFoundation;
}

function getMvcFoundation() {
    mvcContractObj.methods.foundation().call(function (err, result) {
        mvcFoundation = result;
    });
    return mvcFoundation;
}

kccFoundation = getKccFoundation();
mvcFoundation = getMvcFoundation();
refreshData();

//刷新数据
function refreshData() {

    //电影名
    mvcContractObj.methods.desc().call(function (err,result) {
        movieName.innerHTML = result;
    });

    if(to_address!=="0x00") {
        //kcc余额
        console.log("获取地址为"+to_address);
        kccContractObj.methods.balanceOf(to_address).call(function (err, result) {
            kccBalance.innerHTML = result;
        });
        //mvc的数量，投票时间
        //必须加上from，不然无法判断合约中的msg.sender
        mvcContractObj.methods.getCrowdInfo(to_address).call({
            from: to_address,
            gas: 300000
        },function (err,result) {
            console.log(result);
            mvcAmount.innerHTML = result[0];
            voteTime.innerHTML = result[1];
        }).then(function () {
            //持有的mvc数量/众筹总额 为 份额百分比
            mvcContractObj.methods.totalCrowd().call(function (err,result) {
                console.log("总额为:"+result);
                holdingShare.innerHTML = mvcAmount.innerHTML/result;
            })
        })
        
    }
}

refreshBtn.onclick = function(){
    refreshData();
};


//充值，链下约定好金额，然后进行kcc空投
rechargeBtn.onclick = function () {
    console.log("谁是大哥" + kccFoundation);
    console.log("谁是大哥" + mvcFoundation);
    if (!rechargeInput.value) {
        alert("请输入充值金额！");
    } else {
        if (to_address === "0x00") {
            alert("充值对象地址有误！");
            return;
        }
        var to_value = rechargeInput.value;
        kccContractObj.methods.airDrop(to_address, to_value).send({
            from: kccFoundation,
            gas: 300000
        }, function (err, result) {
            console.log(to_value);
            console.log(to_address);
            if (!err) {
                console.log(result);
                console.log("airDrop done!");
                alert("kcc充值成功");
            } else {
                console.log("airDrop failed!");
                alert("充值失败");
            }
        });
    }
};

//投票
//投票者的kcc转移给owner，空投mvc给投票者，即kcc换mvc
voteBtn.onclick = function () {
    //console.log("谁是大哥" + kccFoundation);
    //console.log("谁是大哥" + mvcFoundation);

    if (!voteInput.value) {
        alert("请输入投票支持金额！");
    } else {
        if (to_address === "0x00") {
            alert("请先输入充值对象地址！");
            return;
        }
        var _to = mvcFoundation;
        var _value = voteInput.value;
        var msgsender = to_address;
        //判断标记
        var enoughBalance = false;
        var transferSuccess = false;

        kccContractObj.methods.balanceOf(msgsender).call(function (err, result) {
            if (!err) {
                console.log(`查询余额为:${result}`);
                console.log("_value为:"+_value);
                if (_value > result) {
                    alert("投票支持金额不可大于余额！");
                } else {
                    enoughBalance = true;
                }
            } else {
                alert("取余额报错")
            }
        }).then(function () {
            console.log("kcc转移步骤");
            if (enoughBalance) {
                kccContractObj.methods.transfer(_to, _value).send({
                    from: msgsender,
                    gas: 300000,
                }, function (err, result) {
                    if (!err) {
                        console.log("结果:"+result);
                        console.log("transfer done!");
                        alert("kcc转移成功");
                        transferSuccess = true;
                    } else {
                        console.log("transfer failed!");
                        alert("转移失败");

                    }
                }).then(function () {
                    console.log("mvc空投步骤");
                    if (transferSuccess) {
                        mvcContractObj.methods.airDrop(to_address, _value).send({
                            from: mvcFoundation,
                            gas: 300000
                        }, function (err, result) {
                            if (!err) {
                                console.log(result);
                                console.log("MVC airDrop done!");
                                alert("mvc空投成功");
                            } else {
                                console.log("MVC airDrop failed!");
                                alert("mvc空投失败");
                            }
                        });
                    }
                });
            }
        });
    }
};
