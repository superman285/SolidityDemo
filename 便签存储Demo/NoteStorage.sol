pragma solidity >=0.5.0 <0.6;
pragma experimental ABIEncoderV2;

contract NoteStorage {

    struct Note {
        uint uid;
        uint noteid;
        string text;
    }

    //noteid对应text 1个noteid对应1份text
    mapping(uint=>string) public notesContent;
    //noteid对应整个Note结构体 1个noteid对应1个Note
    mapping(uint=>Note) public notesMap;
    //noteid对应uid 1个noteid对应1个uid
    mapping(uint=>uint) public noteidTouid;
    //一个uid对应的Note数组(多个Note)
    //在remix查看时可输两个参数，第一个为uid，第二个为对应数组的索引值，不输入则索引为0
    mapping(uint=>Note[]) public userNotes;

    //uid's noteid=>arrindex
    //!!!神来之笔!!!
    //利用特定用户uid的 找出全局noteid对应的自己的userNotes的数组的索引 两者的对应关系
    //有了这个对应关系，就不用循环来找哪个索引的noteid等于入参noteid了，good!
    mapping(uint=>mapping(uint=>uint)) public noteidToindex;

     //所有note的集合数组
    Note[] public notesArr;

    //实际上是noteNums 即note数量
    uint public noteIdx;
    address public founder;
    uint public founderID;

    //部署时的初始化
    constructor() public{
        noteIdx = 0;
        founder = msg.sender;
        founderID = uint(founder);
    }

    function getAllNotes() public view returns(Note[] memory){
        return notesArr;
        //前端获取到了后判断下 如果都Note中字段都空 就不初始化这个便签
    }

    function getMyNotes() public view returns(Note[] memory){
        uint myuid = uint(msg.sender);
        return userNotes[myuid];
    }

    function getNote(uint noteid) public view returns(Note memory) {
        return notesMap[noteid];
    }

    function addNote(string memory text) public{
        uint myuid = uint(msg.sender);
        uint noteid = ++noteIdx;
        Note memory newNote = Note({
            uid:myuid,
            noteid:noteid,
            text:text
        });
        noteidTouid[noteid] = myuid;
        notesContent[noteid] = text;
        notesMap[noteid] = newNote;
        notesArr.push(newNote);

        uint userNotesLen = userNotes[myuid].push(newNote);
        noteidToindex[myuid][noteid] = userNotesLen - 1;

    }

    function updateNote(uint noteid,string memory newtext) public {
        require(uint(msg.sender) == noteidTouid[noteid],"you can only change the note belong to you!");
        notesContent[noteid] = newtext;
        notesMap[noteid].text = newtext;
        notesArr[noteid-1].text = newtext;

        uint myuid = uint(msg.sender);
        //性能较差，浪费gas的方法，循环
        /*for(uint i=0;i<userNotes[myuid].length;i++){
            if(userNotes[myuid][i].noteid == noteid){
                userNotes[myuid][i].text = newtext;
            }
        }*/
        uint correctIndex = noteidToindex[myuid][noteid];
        userNotes[myuid][correctIndex].text = newtext;
    }

    function deleteNote(uint noteid) public {
        require(uint(msg.sender) == noteidTouid[noteid],"you can only delete the note belong to you!");
        //涉及到noteid的数据都处理下
        delete notesContent[noteid];
        delete notesMap[noteid];
        //notesMap[noteid-1]的内容会被置为''空
        delete noteidTouid[noteid];

        //删除结构体，则把这个Note实例中的三个字段都置为0和空串
        delete notesArr[noteid-1];

        delete noteidTouid[noteid];
        //or noteidTouid[noteid]=0;

        uint myuid = uint(msg.sender);
        //性能较差，浪费gas的方法，循环
        //若user对应的Notes数组中的Note的noteid与参数noteid相等，则删除这个note
        /*for(uint i=0;i<userNotes[myuid].length;i++){
            if(userNotes[myuid][i].noteid == noteid){
                delete userNotes[myuid][i];
            }
        }*/

        uint correctIndex = noteidToindex[myuid][noteid];
        delete userNotes[myuid][correctIndex];
    }
}
