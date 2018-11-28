pragma solidity ^0.4.25;


import "../erc20.sol";

contract kccToken is ERC20 {

    string name;//定义名称

    string public symbol;//定义symbol，例如eth

    address public foundation;//定义owner，基金会|管理者 fundation

    uint public totalSupply;//定义总发行量 _totalSupply

    uint public totalAirDrop; //空投总量

    mapping(address => uint) balance;//定义余额，账户=>余额

    mapping(address => mapping(address => uint)) public allowance;
    //授权余额，两重map，address=>(address=>uint) owner,spender,value


    //构造函数，名字，发行总量/空投总量，管理者fundation，管理者持有token比例(余额) 发行总量的20%
    constructor(uint _totalSupply) public{
        name = "kcc coin";
        symbol = "kcc";
        foundation = msg.sender;
        totalSupply = _totalSupply;
        //totalAirDrop = 0;
        balance[foundation] = _totalSupply * 2 / 10;
    }


    function airDrop(address _to, uint _value) public returns (bool){
        //判断空投人
        require(msg.sender == foundation, "基金会才可以空投");

        //totalAirDrop+ _value + > totalAirDrop 溢出
        require(totalAirDrop + _value > totalAirDrop, "溢出了额");

        // totalAirDrop + _value + _balance[fundation] <= _totalSupply
        require(totalAirDrop + _value + balance[foundation] <= totalSupply, "加起来小于总发行量方可");

        // to地址不为空
        require(address(0) != _to, "接收人地址不能为空");

        //给 to 加钱 ，
        balance[_to] += _value;

        //给totalAirDrop加上这个钱数
        totalAirDrop += _value;

        return true;
    }

    //总量查询
    /*function totalSupply() public view returns (uint){
        return totalSupply;
    }*/

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

        //_balance[_from]>=_value
        // 溢出检查 _balance[_from]+_value > _balance[_from] 既保证了value必须为正，也避免两个超大数加起来成为负值
        //_to!=address(0)

        //减钱
        //加钱
        //触发事件
        //return true

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


        //判余额,to判空
        //溢出检查
        //授权的余额得足够，

        //减去_value, 授权余额和发钱账户
        //加上value

    }


    function approve(address _spender, uint _value) public returns (bool success){

        require(balance[msg.sender] >= _value, "余额需大于等于转账额");
        require(balance[msg.sender] + _value > balance[msg.sender], "溢出了");
        require(_spender != address(0), "转账对象地址不能为空！");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;

        //判余额,spender判空
        //授权数据 双重mapping
        //触发事件
    }

    //配额
    function allowance(address _owner, address _spender) public view returns (uint remaining){
        remaining = allowance[_owner][_spender];
    }

    function getSelfAddr() public view returns (address) {
        return address(this);
    }

}


