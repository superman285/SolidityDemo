pragma solidity >=0.5.0 <0.6.0;

contract erc20 {

    function name() public view returns (string memory);
    function symbol() public view returns (string memory);
    function decimals() public view returns (uint8);

    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256);

    function transfer(address _to,uint256 _value) public returns (bool success);
    function transferFrom(address _from,address _to,uint256 _value) public returns (bool success);
    function approve(address _spender,uint256 _value) public returns (bool success);
    function allowance(address _owner,address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from,address indexed _to,uint256 _value);
    event Approval(address indexed _owner,address indexed _spender,uint256 _value);

}
