pragma solidity ^0.5.6;

interface erc20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to,uint256 _value) external returns (bool success);
    function transferFrom(address _from,address _to,uint256 _value) external returns (bool success);
    function approve(address _spender,uint256 _value) external returns (bool success);
    function allowance(address _owner,address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from,address indexed _to,uint256 _value);
    event Approval(address indexed _owner,address indexed _spender,uint256 _value);

}

contract SkrToken is erc20 {

    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint public _totalSupply;
    address public foundation;

    mapping(address => uint) balance;
    //owner,spender,value
    mapping(address => mapping(address => uint)) _allowance;

    constructor(uint8 input_decimals,uint _initialSupply) public{
        _name = "SkrToken";
        _symbol = "SKT";
        _decimals = input_decimals;
        _totalSupply = _initialSupply;
        foundation = msg.sender;
        //发行量的50% 基金会拿
        balance[foundation] = _totalSupply * 1 / 2;
        balance[address(this)] = _totalSupply * 1 / 2;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function name() public view returns (string memory){
        return _name;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimals;
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return balance[_owner];
    }

    //msg.sender自己动手转账_value给_to
    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balance[msg.sender] >= _value, "余额不足以转账！");
        require(_to != address(0), "目标地址不可为空！");
        require(balance[_to] + _value > balance[_to], "金额溢出了！");

        balance[msg.sender] -= _value;
        balance[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    //供spender调用的函数 _from为token实际持有人
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(balance[_from] >= _value, "主人的余额不足以转账！");
        require(_allowance[_from][msg.sender] >= _value, "被批准金额需大于等于转账额！");
        require(_to != address(0), "目标地址不可为空！");
        require(balance[_to] + _value > balance[_to], "金额溢出了！");


        _allowance[_from][msg.sender] -= _value;
        balance[_from] -= _value;
        balance[_to] += _value;
        //计算这个和，所以需要判溢出

        emit Transfer(_from, _to, _value);

        return true;
    }

    //msg.sender授权_value金额给_spender
    function approve(address _spender, uint256 _value) public returns (bool success){
        require(balance[msg.sender] >= _value, "批准额需小于等于余额！");
        require(_spender != address(0), "spender地址不可为空！");

        _allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    //销毁部分代币，从基金会账户中
    function burn(uint _value) public {
        require(msg.sender == foundation, "基金会才有销毁token的权限！");
        require(balance[msg.sender] >= _value, "销毁token数需小于等于基金会拥有token余额！");

        balance[msg.sender] -= _value;
        _totalSupply -= _value;

        //销毁相当于向0地址发送代币
        emit Transfer(msg.sender, address(0), _value);
    }

    //增发代币，
    function mint(uint _value) public {
        require(msg.sender == foundation, "基金会才有增发token的权限！");
        //相当于_value要大于0，增发后的总量不可溢出，由于totalSupply>=balance[msg.sender]，所以不需要再判balance的情况了
        require(_totalSupply + _value > _totalSupply, "增发后总量溢出了！");

        balance[msg.sender] += _value;
        _totalSupply += _value;

    }

    //查询_owner授权给_spender的金额
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        remaining = _allowance[_owner][_spender];
    }


}
