pragma solidity >=0.4.22 < 0.6.0;
//pragma experimental ABIEncoderV2;

contract InfoManagement {

    struct CustomerInfo {
        uint customerID;      //相当于身份证号
        uint customerSerialNum; //客户编号，相当于索引
        string customerName;
        uint customerAge;
        bool criminalRecord;
    }

    //客户身份ID map
    mapping(uint => CustomerInfo) customerInfoMap;
    //客户编号id array
    CustomerInfo[] customerInfoArr;
    
    //customerIDs arrays
    uint[] customerIDs;

    //客户年龄map
    mapping(uint => uint) customerAges;
    //客户犯罪记录map
    mapping(uint => bool) customerCriminalRecords;

    address public Administrator;

    constructor() public {

        Administrator = msg.sender;

        CustomerInfo memory admin = CustomerInfo({
            customerID : 101,
            customerSerialNum : customerInfoArr.length,
            customerName : "Administrator",
            customerAge : 666,
            criminalRecord : false});

        customerInfoMap[101] = admin;
        customerInfoArr.push(admin);
        customerIDs.push(101);
        customerAges[101] = 666;
        customerCriminalRecords[101] = false;

    }

    modifier onlyAdmin() {
        require(msg.sender == Administrator, "管理员才有权限操作");
        _;
    }
    
    function getCustomerIDs() public view returns(uint[] memory){
        return customerIDs;
    }

    //录入信息
    function entryInfo(uint _customerID,string memory _customerName, uint _customerAge, bool _criminalRecord) public onlyAdmin {
        CustomerInfo memory newcustom = CustomerInfo({
            customerSerialNum: customerInfoArr.length,
            customerID : _customerID,
            customerName : _customerName,
            customerAge : _customerAge,
            criminalRecord : _criminalRecord});

        customerInfoMap[_customerID] = newcustom;
        customerInfoArr.push(newcustom);
        customerIDs.push(_customerID);
        customerAges[_customerID] = _customerAge;
        customerCriminalRecords[_customerID] = _criminalRecord;
    }

    function getDetailInfoFromID(uint _customerID) public view onlyAdmin returns (uint,uint, string memory, uint, bool) {
        return (
        customerInfoMap[_customerID].customerID,
        customerInfoMap[_customerID].customerSerialNum,
        customerInfoMap[_customerID].customerName,
        customerInfoMap[_customerID].customerAge,
        customerInfoMap[_customerID].criminalRecord);
    }

    function getDetailInfoFromSerial(uint _customerSerialNum) public view onlyAdmin returns (uint,uint, string memory, uint, bool){
        return (
        customerInfoArr[_customerSerialNum].customerID,
        customerInfoArr[_customerSerialNum].customerSerialNum,
        customerInfoArr[_customerSerialNum].customerName,
        customerInfoArr[_customerSerialNum].customerAge,
        customerInfoArr[_customerSerialNum].criminalRecord);
    }

    function getAgeInfo(uint _customerSerialNum) public view onlyAdmin returns (uint){
        return customerAges[_customerSerialNum];
    }

    function getCriminalRecordInfo(uint _customerSerialNum) public view onlyAdmin returns (bool) {
        return customerCriminalRecords[_customerSerialNum];
    }

    function getCustomerNum() public view returns (uint) {
        return customerInfoArr.length;
    }

    //查询接口
    //通过身份证
    function isAdult_ID(uint _customerID) public view returns (string memory) {

        for(uint i=0;i < customerInfoArr.length;i++){
            if(_customerID==customerInfoArr[i].customerID){
                if(customerInfoMap[_customerID].customerAge>18){
                    return "此人已成年";
                }else {
                    return "此人未成年";
                }
            }
        }
        return "查无此人";
    }

    function isCriminal_ID(uint _customerID) public view returns (string memory) {
        for(uint i=0;i < customerInfoArr.length;i++){
            if(_customerID==customerInfoArr[i].customerID){
                if(customerInfoMap[_customerID].criminalRecord){
                    return "此人犯罪过";
                }else {
                    return "此人无犯罪记录";
                }
            }
        }
        return "查无此人";
    }

    //通过编号
    function isAdult_Serial(uint _customerSerialNum) public view returns (bool) {
        if (customerInfoArr[_customerSerialNum].customerAge >= 18) {
            return true;
        } else {
            return false;
        }
    }

    function isCriminal_Serial(uint _customerSerialNum) public view returns (bool) {
        return customerInfoArr[_customerSerialNum].criminalRecord;
    }

}
