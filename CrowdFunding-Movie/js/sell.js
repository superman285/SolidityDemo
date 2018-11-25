var web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"));
web3.eth.getAccounts(function (err,result) {
    console.log(err,result);
});