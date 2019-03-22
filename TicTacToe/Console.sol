pragma solidity >=0.5.0 <0.6;

library Console {
    event LogUint(string, uint);
    function log(string memory s , uint x) internal {
        emit LogUint(s, x);
    }

    event LogUint8(string m, uint8);
    function log(string memory s , uint8 x) internal {
        emit LogUint8(s, x);
    }

    event LogInt(string, int);
    function log(string memory s , int x) internal {
        emit LogInt(s, x);
    }

    event LogInt8(string, int8);
    function log(string memory s , int8 x) internal {
        emit LogInt8(s, x);
    }

    event LogBytes(string, byte);
    function log(string memory s , byte x) internal {
        emit LogBytes(s, x);
    }

    event LogBytes32(string, bytes32);
    function log(string memory s , bytes32 x) internal {
        emit LogBytes32(s, x);
    }

    event LogAddress(string, address);
    function log(string memory s , address x) internal {
        emit LogAddress(s, x);
    }

    event LogBool(string, bool);
    function log(string memory s , bool x) internal {
        emit LogBool(s, x);
    }
}
