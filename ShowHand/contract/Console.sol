pragma solidity ^0.4.25;

library Console {
    event LogUint(string, uint);
    function log(string s , uint x) internal {
        emit LogUint(s, x);
    }

    event LogUint8(string, uint8);
    function log(string s , uint8 x) internal {
        emit LogUint8(s, x);
    }

    event LogInt(string, int);
    function log(string s , int x) internal {
        emit LogInt(s, x);
    }

    event LogInt8(string, int8);
    function log(string s , int8 x) internal {
        emit LogInt8(s, x);
    }

    event LogBytes(string, bytes);
    function log(string s , bytes x) internal {
        emit LogBytes(s, x);
    }

    event LogBytes32(string, bytes32);
    function log(string s , bytes32 x) internal {
        emit LogBytes32(s, x);
    }

    event LogAddress(string, address);
    function log(string s , address x) internal {
        emit LogAddress(s, x);
    }

    event LogBool(string, bool);
    function log(string s , bool x) internal {
        emit LogBool(s, x);
    }
}
