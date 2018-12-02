pragma solidity ^0.4.25;

import "./ERC721.sol";
import "./pxcToken.sol";
import "./AddressUtils.sol";
import "./ERC721Receiver.sol";
//补充safeMath安全四则运算

contract pxcAsset is ERC721 {

    using AddressUtils for address;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    address public foundation; //基金会
    pxcToken pxctoken;


    //ownerTokenCount mapping ownerAddr->token uint
    //tokenOwner mapping tokenId->ownerAddr
    //tokenApprovals tokenId->approvedAddr
    //operatorApprovals owner->operator->bool

    mapping(address => uint256) private ownerTokenCount;
    mapping(uint256 => address) private tokenOwner;
    mapping(uint256 => address) private tokenApprovals;
    mapping(address => mapping(address => bool)) private operatorApprovals;


    struct Asset {
        string contentHash;
        uint256 price;
        uint256 weight; //占的权重(份数)
        string originData;
    }

    Asset[] public assets;

    constructor() public{
        foundation = msg.sender;
        pxctoken = new pxcToken(msg.sender, 210000);
    }

    //是否可以转账
    modifier canTransfer(uint256 _tokenId) {
        address TokenOwner = tokenOwner[_tokenId];
        require(msg.sender == TokenOwner ||
        msg.sender == this.getApproved(_tokenId) ||
        operatorApprovals[TokenOwner][msg.sender]);
        _;
    }

    //是否可以操作
    modifier canOperate(uint256 _tokenId){

        address TokenOwner = tokenOwner[_tokenId];
        require(msg.sender == TokenOwner ||
        operatorApprovals[TokenOwner][msg.sender]);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == foundation);
        _;
    }

    modifier validToken(uint _tokenId){
        require(tokenOwner[_tokenId] != address(0));
        _;
    }

    //封装一些方法方便调用
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        //清除授权
        _clearApproval(_tokenId);
        //改变token-owner对应关系
        _removeTokenFrom(_from, _tokenId);
        _addTokenTo(_to, _tokenId);
    }

    function _clearApproval(uint256 _tokenId) private {
        //不为地址0 说明存在
        if (tokenApprovals[_tokenId] != address(0)) {
            delete tokenApprovals[_tokenId];
            //或 tokenApprovals[_tokenId] = address(0);
        }
    }

    function _removeTokenFrom(address _from, uint256 _tokenId) private {
        require(tokenOwner[_tokenId] == _from);
        require(ownerTokenCount[_from] > 0);
        ownerTokenCount[_from] -= 1;
        delete tokenOwner[_tokenId];
    }

    function _addTokenTo(address _to, uint256 _tokenId) private {
        //tokenId无主才行
        require(tokenOwner[_tokenId] == address(0));
        tokenOwner[_tokenId] = _to;
        ownerTokenCount[_to] += 1;
    }

    //新增资产
    function _newAsset(string _hash, uint256 _price, uint256 _weight, string _data) private returns (uint256){
        Asset memory ass = Asset(_hash, _price, _weight, _data);
        uint256 tokenId = assets.push(ass) - 1;
        return tokenId;
    }
    function splitAsset(uint256 _tokenId,uint256 _weight,address _buyer) onlyOwner validToken(_tokenId) external returns(uint256){
        //一次切分必须小于100，
        require(_weight<100);
        require(address(0)!=_buyer);
        //此处必须为storage，因为需要为指针操作，变量的改变要影响原值，若为memory则原资产和分出来的资产份额都为100
        Asset storage ass = assets[_tokenId];
        require(_weight<ass.weight); //分割出来的份数不可能大于等于被分割的资产原有权重份数的
        //新创建一个asset，这个asset是老的asset分割出来的一部分，占有_weight份权重，
        uint256 tokenId = assets.push(ass) - 1;
        ass = assets[tokenId];
        ass.weight = _weight;
        _addTokenTo(_buyer,tokenId);

        //更新老的asset，占有的权重为原有权重减去被分掉的权重
        ass = assets[_tokenId];
        ass.weight -= _weight;
        return tokenId;
    }

    //挖矿函数
    function mint(string _hash, uint256 _price, uint256 _weight, string _data) external {
        //new asset
        uint256 tokenId = _newAsset(_hash, _price, _weight, _data);
        //add mapping
        ownerTokenCount[msg.sender] += 1;
        tokenOwner[tokenId] = msg.sender;
        //pxc transfer，此处先定死上传一个画作获得100pxc，之后可以再改造
        pxctoken.transfer(msg.sender,100); //此处msg.sender是pxAsset的合约地址，能否成功要看合约有没权限，有没余额

    }

    //erc721中的方法实现
    //获取数量
    function balanceOf(address _owner) external view returns (uint256){
        require(_owner != address(0));
        return ownerTokenCount[_owner];
    }
    //获取tokenId的owner
    function ownerOf(uint256 _tokenId) external view returns (address){
        address TokenOwner = tokenOwner[_tokenId];
        require(TokenOwner != address(0));
        return tokenOwner[_tokenId];
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external payable {
        require(_to != address(0));
        _transfer(_from, _to, _tokenId);
        if (_to.isContract()) {
            bytes4 value = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
            require(value == _ERC721_RECEIVED);
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(_to != address(0));
        _transfer(_from, _to, _tokenId);
        if (_to.isContract()) {
            bytes4 value = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, "");
            require(value == _ERC721_RECEIVED);
        }
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) canTransfer(_tokenId) validToken(_tokenId) external payable {
        //判断
        //tokenId有效 修饰符
        //地址有效
        //from和授权了的人都可以有效 修饰符

        //操作
        //解除授权
        //改变token-owner对应关系
        //事件通知

        require(_to != address(0));

        //资产转移
        _transfer(_from, _to, _tokenId);
        emit Transfer(_from, _to, _tokenId);

    }

    function approve(address _approved, uint256 _tokenId) canOperate(_tokenId) validToken(_tokenId) external payable {
        //address TokenOwner = tokenOwner[_tokenId];
        require(_approved != address(0));
        tokenApprovals[_tokenId] = _approved;
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != address(0));
        require(ownerTokenCount[msg.sender] > 0);
        operatorApprovals[msg.sender][_operator] = _approved;
    }
    //获取tokenId授权给了谁
    function getApproved(uint256 _tokenId) external view returns (address){
        return tokenApprovals[_tokenId];
    }
    //查看owner是否将所有资产都授权给了operator
    function isApprovedForAll(address _owner, address _operator) external view returns (bool){
        return operatorApprovals[_owner][_operator];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);



    //get pxc余额
    function getPXCBalance(address _owner) public view returns (uint256) {
        return pxctoken.balanceOf(_owner);
    }
    //get pxc合约地址
    function getPXCAddr() public view returns (address) {
        return address(pxctoken);
    }
}
