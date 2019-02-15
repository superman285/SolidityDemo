pragma solidity >=0.5.0 <0.6;
pragma experimental ABIEncoderV2;

contract DataSave {

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
     //所有note的集合数组
    Note[] public notesArr;
    
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
    
    function checkNote(uint noteid) public view returns(Note memory) {
        
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
        userNotes[myuid].push(newNote);
    }
    
    function updateNote(uint noteid,string memory newtext) public {
        require(uint(msg.sender) == noteidTouid[noteid],"you can only change the note belong to you!");
        notesContent[noteid] = newtext;
        notesMap[noteid].text = newtext;
        notesArr[noteid-1].text = newtext;
        
        uint myuid = uint(msg.sender);
        for(uint i=0;i<userNotes[myuid].length;i++){
            if(userNotes[myuid][i].noteid == noteid){
                userNotes[myuid][i].text = newtext;
            }
        }
        
    }
    
    function deleteNote(uint noteid) private {
        //涉及到noteid的数据都处理下
        delete notesContent[noteid-1];
        delete notesMap[noteid-1];
        //notesMap[noteid-1]的内容会被置为''空
        delete noteidTouid[noteid-1];

        //删除结构体，则把这个Note实例中的三个字段都置为0和空串
        delete notesArr[noteid-1];
        
        delete noteidTouid[noteid];
        //or noteidTouid[noteid]=0;
        
        uint myuid = uint(msg.sender);
        //若user对应的Notes数组中的Note的noteid与参数noteid相等，则删除这个note
        for(uint i=0;i<userNotes[myuid].length;i++){
            if(userNotes[myuid][i].noteid == noteid){
                delete userNotes[myuid][i];
            }
        }
        
    }

}
