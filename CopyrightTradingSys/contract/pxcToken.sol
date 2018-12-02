pragma solidity ^0.4.25;

import "./ERC20.sol";

contract pxcToken is ERC20{


    //名字，符号，基金会，发行人issuer，总量，账户余额，授权余额

    string public name = "PXC Token";
    string public symbol = "PXC";
    address public issuer;
    address public foundation;
    uint256 private TotalSupply;
    mapping(address => uint256) private balance;
    mapping(address => mapping(address => uint256)) private Allowance;

    constructor(address _foundation, uint256 _totalSupply) public {
        issuer = msg.sender;
        require(msg.sender!=_foundation,"发行方与基金会不可为同一账户");
        foundation = _foundation;
        TotalSupply = _totalSupply;
        balance[foundation] = _totalSupply *2/10;
        balance[issuer] = _totalSupply - balance[foundation];
    }

    function totalSupply() public view returns (uint256) {
        return TotalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return balance[_owner];
    }
    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balance[msg.sender]>=_value);
        require(balance[_to]+_value>balance[_to]);
        require(_to!=address(0));


        balance[msg.sender] -= _value;
        balance[_to] += _value;

        emit Transfer(msg.sender,_to,_value);
        return true;
    }
    function approve(address _spender, uint256 _value) public returns (bool success){
        require(_value<=balance[msg.sender],"授权额需小于等于余额");
        require(_spender!=address(0));

        Allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender,_spender,_value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_value <= balance[_from]);
        require(_value <= Allowance[_from][msg.sender]);
        require(_to!=address(0));

        balance[_from] -= _value;
        balance[_to] += _value;
        Allowance[_from][msg.sender] -= _value;

        emit Transfer(_from,_to,_value);
        return true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return Allowance[_owner][_spender];
    }
}
