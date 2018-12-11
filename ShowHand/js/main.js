//绑定界面元素
var joinBtn = document.querySelector(".join");
var ensureBtn = document.querySelector(".ensureModal"),
    unsureBtn = document.querySelector(".unsureModal");
var popupModal = document.querySelector(".popModal");
var addrInput = document.querySelector(".addrInput");

var ethInput = document.querySelector("#weiInput"),
    bringInBtn = document.querySelector(".bringInBtn"),
    betBtn = document.querySelector(".betBtn"),
    passBtn = document.querySelector(".passBtn"),
    foldBtn = document.querySelector(".foldBtn"),
    showActiveBtn = document.querySelector(".showActiveBtn"),
    winnerBtn = document.querySelector(".winnerBtn");

var hostPokerWrap = document.querySelector(".hostPokerWrap"),
    guestPokerWrap = document.querySelector(".guestPokerWrap");

var hostPokers = hostPokerWrap.getElementsByClassName("poker"),
    guestPokers = guestPokerWrap.getElementsByClassName("poker");

//构造web3对象
var web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"));
web3.eth.getAccounts(function (err, result) {
    console.log(`web3获取账户:${result}`);
});
//remix获取abi
var abi = [
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "LogUint",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "",
                "type": "uint8"
            }
        ],
        "name": "LogUint8",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "",
                "type": "int256"
            }
        ],
        "name": "LogInt",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "",
                "type": "int8"
            }
        ],
        "name": "LogInt8",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "",
                "type": "bytes"
            }
        ],
        "name": "LogBytes",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "",
                "type": "bytes32"
            }
        ],
        "name": "LogBytes32",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "",
                "type": "address"
            }
        ],
        "name": "LogAddress",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "",
                "type": "bool"
            }
        ],
        "name": "LogBool",
        "type": "event"
    }
];
var myContract = web3.eth.contract(abi);
//remix获取合约地址
var contractAddr = "0x2cc813e4139ed4f107d9ef5979855eebd25a1a9d";
//构造合约实例
var showhandContract = new web3.eth.Contract(abi,contractAddr);
console.log("合约实例如下：");
console.log(showhandContract);


//功能相关

var accountAddr;

//joinGame
joinBtn.onclick = function () {
    popupModal.classList.add("shown");
}
unsureBtn.onclick = function () {
    popupModal.classList.remove("shown");
}
ensureBtn.onclick = function () {

    accountAddr = addrInput.value;
    console.log(`获取的地址${accountAddr}`);
    /*showhandContract.methods.joinGame(accountAddr).send({
        gas: 300000
    },function (err,result) {
        if(!err) {
            alert("加入成功！");
            popupModal.classList.remove("shown");
        }else {
            alert("加入失败！")
        }
    });*/
    showhandContract.methods.joinGame(accountAddr);
}

bringInBtn.onclick = function () {
    console.log(showhandContract.methods);
    showhandContract.methods.bringIn().send({
        from: accountAddr,
        value: 100,
        gas: 300000
    },function (err,result) {
        if(!err) {
            alert("下底注成功！");
        }else {
            alert("下底注失败！");
            console.log(err);
        }
    });
}