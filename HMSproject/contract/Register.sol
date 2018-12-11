pragma solidity >=0.4.22 <0.6.0;

contract Register {

    struct CustomerInfo {
        string customerName;
        uint customerID;    //从0开始
        uint customerAge;
        bool isCrime;
    }

    CustomerInfo[] customers;
    mapping(uint=>uint) customerAges;
    mapping(uint=>bool) customerIsCrimes;

    constructor() public {

        CustomerInfo memory hotelAdmin = CustomerInfo({
            customerName:"Administrator",
            customerID:customers.length,
            customerAge:666,
            isCrime:false});

        customerAges[0] = 666;
        customerIsCrimes[0] = false;
        customers.push(hotelAdmin);

    }

    function registerInfo(string memory _customerName,uint _customerAge,bool _isCrime) public {

        customerAges[customers.length] = _customerAge;
        customerIsCrimes[customers.length] = _isCrime;

        CustomerInfo memory newguest = CustomerInfo({
            customerName: _customerName,
            customerID: customers.length,
            customerAge: _customerAge,
            isCrime: _isCrime});
        customers.push(newguest);
    }

    function getDetailInfo(uint _customerID) public view returns(uint,string memory,uint,bool) {
        return (customers[_customerID].customerID,
        customers[_customerID].customerName,
        customers[_customerID].customerAge,
        customers[_customerID].isCrime);
    }

    function getAgeInfo(uint _customerID) public view returns(uint){
        return customerAges[_customerID];
    }

    function getCrimeInfo(uint _customerID) public view returns(bool) {
        return customerIsCrimes[_customerID];
    }

    function getCustomerNum() public view returns(uint) {
        return customers.length;
    }

}
