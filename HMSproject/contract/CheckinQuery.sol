pragma solidity >=0.4.22 <0.6.0;


import "./Register.sol";

contract CheckinQuery {


    function checkIn(uint _customerID) public view returns(bool) {
        return !getCrimeInfo(_customerID);
    }

}
