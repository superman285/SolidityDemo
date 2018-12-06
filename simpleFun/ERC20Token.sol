pragma solidity ^0.4.25;


import "./erc20.sol";

contract myToken is ERC20 {

    string name;//定义名称

    string public symbol;//定义symbol，例如eth

    address public foundation;//定义owner，基金会|管理者 fundation

    uint private _totalSupply;//定义总发行量 _totalSupply


    mapping(address => uint) balance;//定义余额，账户=>余额

    mapping(address => mapping(address => uint)) public allowance;
    //授权余额，两重map，address=>(address=>uint) owner,spender,value


    //构造函数，名字，发行总量/空投总量，管理者fundation，管理者持有token比例(余额) 发行总量的20%
    constructor() public{
        name = "myToken";
        symbol = "MYT";
        foundation = msg.sender;
        _totalSupply = 10000;
        balance[foundation] = _totalSupply * 2 / 10;
    }

    //总量查询
    function totalSupply() public view returns (uint){
        return _totalSupply;
    }

    //余额查询
    function balanceOf(address _who) public view returns (uint){
        return balance[_who];
    }

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    //转账，检查余额，检查溢出
    function transfer(address _to, uint _value) public returns (bool success){

        require(balance[msg.sender] >= _value, "余额需大于等于转账额");
        require(balance[msg.sender] + _value > balance[msg.sender], "溢出了");
        require(_to != address(0), "转账对象地址不能为空！");
        balance[msg.sender] -= _value;
        balance[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success){

        require(balance[_from] >= _value, "余额需大于等于转账额");
        require(balance[msg.sender] + _value > balance[msg.sender], "溢出了");
        require(_to != address(0), "转账对象地址不能为空！");
        require(_value <= allowance[_from][_to], "转账额需小于等于配额");
        allowance[_from][_to] -= _value;
        balance[_to] += _value;
        balance[_from] -= _value;
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success){
        require(balance[msg.sender] >= _value, "余额需大于等于转账额");
        require(balance[msg.sender] + _value > balance[msg.sender], "溢出了");
        require(_spender != address(0), "转账对象地址不能为空！");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //配额
    function allowance(address _owner, address _spender) public view returns (uint remaining){
        remaining = allowance[_owner][_spender];
    }
}


