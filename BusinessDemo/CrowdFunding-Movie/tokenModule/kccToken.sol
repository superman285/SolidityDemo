pragma solidity ^0.4.25;

contract kccToken {

    //定义名称

    //定义symbol，例如eth

    //定义owner，基金会|管理者 fundation

    //定义总发行量 _totalSupply

    uint public totalAirDrop; //空投总量

    //定义余额，账户=>余额

    //授权余额，两重map，address=>(address=>uint) owner,spender,value


    //构造函数，发行总量，管理者fundation，管理者持有token比例(用余额) 20%


    function airDrop(address _to,uint _value) public {
        //判断空投人
        //totalAirDrop+ _value + > totalAirDrop 溢出
        // totalAirDrop + _value + _balance[fundation] <= _totalSupply
        // to地址不为空

        //给 to 加钱 ，
        //给totalAirDrop加上这个钱数
    }

    //总量查询
    function totalSupply() constant returns (uint totalSupply){
        return _totalSupply;
    }

    //余额查询
    function balanceOf(address _owner) constant returns (uint balance){
        return _balance[_owner];
    }

    //检查余额，检查溢出
    function transfer(address _to, uint _value) returns (bool success){

        //因为要判断返回两个值，所以用if
        //_balance[_from]>=_value
        // 溢出检查 _balance[_from]+_value > _balance[_from] 既保证了value必须为正，也避免两个超大数加起来成为负值
        //_to!=address(0)

        //减钱
        //加钱
        //触发事件
        //return true

    }

    function transferFrom(address _from, address _to, uint _value) returns (bool success){

        //判余额,to判空
        //溢出检查
        //授权的余额得足够，

        //减去_value, 授权余额和发钱账户
        //加上value

    }

    function approve(address _spender, uint _value) returns (bool success){

        //判余额,spender判空
        //授权数据 的存储
        //触发事件
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining){

    }

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

}
