pragma solidity >=0.4.22 <0.6.0;

contract InfoManagement {

    struct CustomerInfo {
        string customerName;
        uint customerID;    //从0开始
        uint customerAge;
        bool criminalRecord;
    }

    CustomerInfo[] customers;
    mapping(uint=>uint) customerAges;
    mapping(uint=>bool) customerCriminalRecords;

    address public Administrator;

    constructor() public {

        Administrator = msg.sender;

        CustomerInfo memory hotelAdmin = CustomerInfo({
            customerName:"Administrator",
            customerID:customers.length,
            customerAge:666,
            criminalRecord:false});

        customerAges[0] = 666;
        customerCriminalRecords[0] = false;
        customers.push(hotelAdmin);

    }

    modifier onlyAdmin() {
        require(msg.sender==Administrator,"管理员才有权限操作");
        _;
    }

    //录入信息
    function entryInfo(string memory _customerName,uint _customerAge,bool _criminalRecord) public onlyAdmin {

        customerAges[customers.length] = _customerAge;
        customerCriminalRecords[customers.length] = _criminalRecord;

        CustomerInfo memory newguest = CustomerInfo({
            customerName: _customerName,
            customerID: customers.length,
            customerAge: _customerAge,
            criminalRecord: _criminalRecord});
        customers.push(newguest);
    }

    function getDetailInfo(uint _customerID) public view returns(uint,string memory,uint,bool) {
        return (customers[_customerID].customerID,
        customers[_customerID].customerName,
        customers[_customerID].customerAge,
        customers[_customerID].criminalRecord);
    }

    function getAgeInfo(uint _customerID) public view returns(uint){
        return customerAges[_customerID];
    }

    function getCriminalRecordInfo(uint _customerID) public view returns(bool) {
        return customerCriminalRecords[_customerID];
    }

    function getCustomerNum() public view returns(uint) {
        return customers.length;
    }

}
