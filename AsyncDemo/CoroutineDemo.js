/*
启动三个协程，第一个协程将0，1，2，3……依次传递给第二个协程，
第二个协程将得到的数字平方后传递给第三个协程，第三个协程负责打印得到的数字。
*/

var async = require('async');

var inputNum=[],
    inputNumSquare=[];

var task1 = function (callback) {
    console.log("第一个协程:赋值");
    setTimeout(function () {
        inputNum = [0,1,2,3,4,5];
        callback(null, inputNum);
    },1000);
};
var task2 = function (task1_result, callback) {
    setTimeout(function () {
        console.log("第二个协程:求平方");
        for (let i = 0; i < inputNum.length; i++) {
            inputNumSquare[i] = Math.pow(inputNum[i],2);
        }
        callback(null, inputNumSquare);
    },1000);
};
var task3 = function (twoarg, callback) {
    setTimeout(function () {
        console.log("第三个协程:打印结果");
        console.log(twoarg);
        callback(null, twoarg);
    },2000);

};

console.time('waterfall from async');
async.waterfall([task1,task2,task3], function (error, result) {
    console.log("结束");
    console.timeEnd('waterfall from async');
});