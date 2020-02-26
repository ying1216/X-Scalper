pragma solidity ^0.4.25;

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
    }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

  /**
  * @dev The Ownable constructor sets the original `owner` of the contract to the sender
  * account.
  */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
  * @return the address of the owner.
  */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
  * @return true if `msg.sender` is the owner of the contract.
  */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
  * @dev Allows the current owner to relinquish control of the contract.
  * @notice Renouncing to ownership will leave the contract without an owner.
  * It will not be possible to call the functions with the `onlyOwner`
  * modifier anymore.
  */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
  * @dev Transfers control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
}


contract StructTicket is ERC721, Ownable{
    
    struct TicketStruct{
        string Area;
        uint256 endDate;
        address owner;    
        uint256 price;
        uint256 supplyAmount;
    }
    

    using SafeMath for uint256;

    uint256 public constant decimals = 18;

    mapping (uint256 => address) ticketIdToOwner;
    mapping (address => uint256) ownerTicketCount;
    mapping (uint256 => address) ticketIdToApproved;
    mapping (address => uint256) private etherBalance;
    mapping (uint256 => TicketStruct) TicketArea;
    mapping (address => uint256) ownerToTicket;
    mapping (address => uint256) approveToTicket;
    
    TicketStruct[] public Tstructs;
    
    uint256 totalSupplyAccounts;
    
    event approveEvent(address indexed from, address indexed to, uint256 ticketId);
    event transferFromEvent(address indexed from, address indexed to, uint256 ticketId);
    event buyTicketEvent(uint256 ticketId);
    event batchMintTicketEvent(address _owner, uint256 _amount, uint256 _date, string _area, uint256 _price);
    event mintEvent(address minter, uint256 ticketId);
    event buyOthersTicketEvent(uint _ticketId);
    event refundEvent(uint _ticketId);
    event withdrawEvent(uint256 etherValue);
    event setDateEvent(uint256 _index,uint256 _date);
    event setAreaEvent(uint256 _index, string area);
    
    function _approve(address _to, uint256 _ticketId) internal{
        ticketIdToApproved[_ticketId] = _to;
        approveToTicket[_to] = _ticketId;
    }
    
    function _transfer(address _from, address _to, uint256 _ticketId) internal{
        ownerTicketCount[_from] = ownerTicketCount[_from].sub(1);
        ownerTicketCount[_to] = ownerTicketCount[_to].add(1);
        ticketIdToOwner[_ticketId] = _to;
        ownerToTicket[_to] = _ticketId;
        ownerToTicket[_from] = 0;
        
        
    }
    
    //有幾張Ticket
    function balanceOf(address _owner) external view returns(uint256){
        return ownerTicketCount[_owner];
        
    }
    
    //Ticket 主人
    function ownerOf(uint256 _ticketId)external view returns(address){
        return ticketIdToOwner[_ticketId];
    }

    
    function _mintTicket(address owner, uint256 ticketId) internal   {
        ticketIdToOwner[ticketId] = owner;
        ownerTicketCount[msg.sender] = ownerTicketCount[msg.sender].add(1);
        emit mintEvent(owner, ticketId);
    }
    
    function batchMintTicket(address _owner, uint256 _amount, uint256 _date, string _area, uint256 _price) public onlyOwner {
        Tstructs.push(TicketStruct(_area, _date, _owner, _price, _amount)); 
        
        uint256 hasminted = ownerTicketCount[_owner];
        for(uint i = ownerTicketCount[_owner]; i <  hasminted + _amount; i++){
            _mintTicket(_owner, i);
            TicketArea[i] = Tstructs[Tstructs.length - 1];
        }
        totalSupplyAccounts = totalSupplyAccounts.add(_amount);
        emit batchMintTicketEvent(_owner, _amount, _date, _area, _price);

    }
    
    function setDate(uint256 _index, uint256 _date) public onlyOwner{
        Tstructs[_index].endDate = _date;
        emit setDateEvent(_index,_date);
    }
    
    function setArea(uint256 _index, string area) public onlyOwner{
       Tstructs[_index].Area = area;
       emit setAreaEvent(_index, area);
    }
    
    function totalSupply() public view returns(uint256){
        return totalSupplyAccounts;
    }
    
    function transferFrom(address _from, address _to, uint256 _ticketId)external payable{
        require(_to != _from);
        require(ticketIdToApproved[_ticketId] == _to);
        require(ticketIdToOwner[_ticketId] == _from);
        require(msg.sender == owner());
        
        _transfer(_from, _to, _ticketId);
        emit transferFromEvent(_from, _to, _ticketId);
    }
    
    function approve(address _to, uint256 _ticketId) external payable{
        require(_to != msg.sender);
        require(ticketIdToOwner[_ticketId] == msg.sender);
        require(saleActive(_ticketId));
        _approve(_to, _ticketId);
        emit approveEvent(msg.sender, _to, _ticketId);
    }
    
    function buyTicket(uint256 _ticketId)public payable{
        require(saleActive(_ticketId), "Too Late");
        require(ticketIdToOwner[_ticketId] == owner(), "The ticket you want is sold out");
        require(msg.value == 0.01 ether * TicketArea[_ticketId].price, "Money amount incorrect");
        require(msg.sender != owner(), "Minter avoid buying from oneself");
        
        etherBalance[owner()] += msg.value;
        _transfer(owner(), msg.sender, _ticketId);
        
        emit buyTicketEvent(_ticketId);
    }
    
    function getEtherBalance()public view returns (uint256){
        return etherBalance[msg.sender];
    }
    
    function getTicketArea(uint256 _ticketId)public view returns (string){
        return TicketArea[_ticketId].Area;
    }
 
    function getTicketPrice(uint256 _ticketId)public view returns(uint256){
        return TicketArea[_ticketId].price;
    }
   
    function checkIsApproved(uint256 _ticketId, address _to)public view returns(bool){
        return ticketIdToApproved[_ticketId] == _to;
    }
    
    function buyOthersTicket(uint _ticketId)public payable{
        address originOwner = ticketIdToOwner[_ticketId];
        
        require(saleActive(_ticketId), "Too late!");
        require(ticketIdToOwner[_ticketId] != msg.sender, "You already own the ticket!");
        require(ticketIdToOwner[_ticketId] == originOwner, "Whoops!Seller doesnt own this ticket");
        require(msg.value == 0.01 ether * TicketArea[_ticketId].price,"Price is incorrect" );
        require(msg.sender != originOwner, "You already own this ticket!");
        require(ticketIdToApproved[_ticketId] == msg.sender, "You don't have approval!");
        
        etherBalance[originOwner] += msg.value;
        _transfer(originOwner, msg.sender, _ticketId);
        emit buyOthersTicketEvent(_ticketId);
    }
    
    function refund(uint _ticketId)public payable{
        require(saleActive(_ticketId), "Too late for refund!");
        require(ticketIdToOwner[_ticketId] == msg.sender, "You don't own this ticket!");
        uint256 refundAmount = getTicketPrice(_ticketId) * 0.008 ether;
        etherBalance[owner()] -= refundAmount;
        etherBalance[msg.sender] += refundAmount;
        _transfer(msg.sender, owner(), _ticketId);
        emit refundEvent(_ticketId);
    }
    
    function withdraw(uint256 etherValue) public {
        uint256 weiValue = etherValue * 0.01 ether;
        require(etherBalance[msg.sender] >= weiValue, "Your balances are not enough");
        msg.sender.transfer(weiValue);
        etherBalance[msg.sender] -= weiValue;
        emit withdrawEvent(etherValue);
    }
    
    function getCurrentTimestamp() internal view returns (uint256) {
        return now;
    }
    
    function saleActive(uint256 _ticketId)public view returns(bool){
        return (getCurrentTimestamp() < TicketArea[_ticketId].endDate);
        
    }
    
    function getOwnerTicketId(address _owner)public view returns(uint256){
        return ownerToTicket[_owner];
    }
    
    function getApproveTicketId(address _owner)public view returns(uint256){
        return approveToTicket[_owner];
    }
    
    
   
   //"0x95a58a6b0b3e44daeda77a4b6855d544911327d3",50,1573401600,"A",10
   
   
}