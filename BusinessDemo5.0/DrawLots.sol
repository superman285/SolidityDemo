pragma solidity >=0.5.0 <0.6;
pragma experimental ABIEncoderV2;

contract DrawLots {

    /* constructor(string[6] _teamNames,address[6] _teamAddrs) payable{

         for (uint ind=0;ind<6;ind++) {

         teams[_teamAddrs[ind]].teamName = _teamNames[ind];
         teams[_teamAddrs[ind]].teamAddr = _teamAddrs[ind];

        }

     }*/

    struct Team {
        string teamName;    //队伍名
        address teamAddr;   //队伍账户地址
        string inGroup;     //在哪个组
        bool hasCreated;   //已经创建过队伍，一个地址只能建一个队伍
        bool hasBalloted;   //已经抽过签分组，就不能再抽
    }

    mapping(address => Team) public teams;

    //用于判断队伍数量
    Team[] teamsNum;
    //存队伍名字的各小组数组
    string[] groupA;
    string[] groupB;
    string[] groupC;


    //初始化队伍方式，自己创建队伍，只能创建一次，也可用一次性填入6个地址的方式初始化、此处没用
    function createTeam(string memory _name) public {
        require(!teams[msg.sender].hasCreated,"你已经创建过队伍了，别贪心");
        teams[msg.sender].teamName = _name;
        teams[msg.sender].teamAddr = msg.sender;
        teams[msg.sender].hasCreated = true;
        teamsNum.push(teams[msg.sender]);
    }

    //索引0到5元素对应队伍如下，
    string[] public randArr = ["A", "A", "B", "B", "C", "C"];
    //抽签分组，每次抽完一签干掉这个号，下次再从剩下的里头随机，保证不会超过组人数上限
    function subgroup() public{
        require(teamsNum.length == 6,"凑够6组才可以开始分组");
        require(!teams[msg.sender].hasBalloted,"你抽过签了，不能再抽了");
        uint seed = randArr.length;
        require(seed>0,"没签了，甭抽了");
        uint random = uint(keccak256(abi.encodePacked(msg.sender, now, block.number))) % seed;
        if (keccak256(abi.encodePacked(randArr[random])) == keccak256("A")) {
            groupA.push(teams[msg.sender].teamName);
            teams[msg.sender].inGroup = "groupA";
        } else if (keccak256(abi.encodePacked(randArr[random])) == keccak256("B")) {
            groupB.push(teams[msg.sender].teamName);
            teams[msg.sender].inGroup = "groupB";
        } else {
            groupC.push(teams[msg.sender].teamName);
            teams[msg.sender].inGroup = "groupC";
        }
        teams[msg.sender].hasBalloted = true;//抽签标记置为真
        
        
        //or deleteArrAt(random)
        deleteArrAt2(random,randArr);
    }

    modifier groupFull() {
        require(groupA.length == 2&&groupB.length == 2&&groupC.length == 2,"6队全分完组才可以看");
        _;
    }

    //只是为了看某个组里头的人，要在控制台看，debug的decoded output字段看
    //带view修饰符的直接在界面上可以看到
    function showGroupA() public view groupFull returns (string[] memory){
        return groupA;
    }
    function showGroupB() public view groupFull returns (string[] memory){
        return groupB;
    }
    function showGroupC() public view groupFull returns (string[] memory){
        return groupC;
    }

    //删除指定索引数组元素
    function deleteArrAt(uint _index) private{
        uint len = randArr.length;
        require(_index < len, "错误！索引超限了！");
        for (uint i = _index; i < len - 1; i++) {
            randArr[i] = randArr[i + 1];
        }
        //删除末尾元素，但是实际只是置0，还需要改变长度
        delete randArr[len - 1];
        randArr.length--;
    }
    
    //删除指定索引数组元素
    //此处要为storage，否则修改不会影响到原数组
    function deleteArrAt2(uint _index,string[] storage _arr) private{
        uint len = _arr.length;
        require(_index < len, "错误！索引超限了！");
        for (uint i = _index; i < len - 1; i++) {
            _arr[i] = _arr[i + 1];
        }
        //删除末尾元素，但是实际只是置0，还需要改变长度
        delete _arr[len - 1];
        _arr.length--;
    }

}