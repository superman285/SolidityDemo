pragma solidity >=0.4.22 <0.6.0;


import "./InfoManagement.sol";

contract HotelCheck {


    function getInfoContract(address _addr) public {

        InfoManagement infoContractObj = InfoManagement(_addr);

    }

    function checkIn(uint _customerID) public view returns(bool) {
        return !infoContractObj.getCrimeInfo(_customerID);
    }

}
