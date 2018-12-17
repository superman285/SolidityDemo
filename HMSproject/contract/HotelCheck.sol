pragma solidity >=0.4.22 <0.6.0;


import "./InfoManagement.sol";

contract HotelCheck {

    InfoManagement infoContractObj;

    function getInfoContract(address _addr) public {

        infoContractObj = InfoManagement(_addr);
    }

    function checkInSerial(uint _customerSerialNum) public view returns(string memory) {
        if(infoContractObj.isAdult_Serial(_customerSerialNum)&&(!infoContractObj.isCriminal_Serial(_customerSerialNum))){
            return "可以入住";
        }else {
            return "不可以入住！";
        }
    }

    function checkInID(uint _customerID) public view returns(string memory) {
        if( (keccak256(abi.encodePacked(infoContractObj.isAdult_ID(_customerID)))==keccak256(abi.encodePacked("查无此人"))) ||
            (keccak256(abi.encodePacked(infoContractObj.isCriminal_ID(_customerID)))==keccak256(abi.encodePacked("查无此人"))) ){
            return "查无此人";
        } else if( (keccak256(abi.encodePacked(infoContractObj.isAdult_ID(_customerID)))==keccak256(abi.encodePacked("此人已成年"))) &&
            (keccak256(abi.encodePacked(infoContractObj.isCriminal_ID(_customerID)))==keccak256(abi.encodePacked("此人无犯罪记录")))
        ){
            return "可以入住";
        }else {
            return "不可以入住！";
        }
    }
    
    function showCustomerIDs() public view returns(uint[] memory){
        return infoContractObj.getCustomerIDs();
    }

}
