pragma solidity 0.5.17;

contract Gallery {
    address public owner;
    address public resolver; 
    uint256 public totalSupply;
    uint256 public totalSupplyCap;
    string public baseURI;
    string public name;
    string public symbol;
    bool public transferable; 

    event Approval(address indexed approver, address indexed spender, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public getApproved;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => string) public tokenURI;
    mapping(bytes4 => bool) public supportsInterface; // eip-165 
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    modifier onlyOwner {
        require(msg.sender == owner, "!owner");
        _;
    }

    constructor (
        string memory _name, 
        string memory _symbol, 
        address _owner, 
        address _resolver, 
        uint256 _totalSupplyCap, 
        string memory _baseURI,
        string memory _tokenURI,
        bool _transferable
    ) public {
        name = _name; 
        symbol = _symbol; 
        owner = _owner; 
        resolver = _resolver;
        totalSupplyCap = _totalSupplyCap; 
        baseURI = _baseURI; 
        transferable = _transferable; 
        
        balanceOf[owner] = 1;
        totalSupply = 1;
        ownerOf[1] = owner;
        tokenURI[1] = _tokenURI;
        supportsInterface[0x80ac58cd] = true; // ERC721 
        supportsInterface[0x5b5e139f] = true; // METADATA
        
        emit Transfer(address(0), owner, 1);
    }

    /************
    TKN FUNCTIONS
    ************/
    function approve(address spender, uint256 tokenId) external returns (bool) {
        address tokenOwner = ownerOf[tokenId];
        require(msg.sender == tokenOwner || isApprovedForAll[tokenOwner][msg.sender], "!owner/operator");
        
        getApproved[tokenId] = spender;
        
        emit Approval(msg.sender, spender, tokenId); 
        
        return true;
    }
    
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function balanceResolution(address from, address to, uint256 tokenId) external {
        require(msg.sender == resolver, "!resolver");
        require(sender == ownerOf[tokenId], "!owner");
        
        _transfer(from, to, tokenId); 
    }
    
    function burn(uint256 tokenId) public {
        address tokenOwner = ownerOf[tokenId];
        require(msg.sender == tokenOwner || getApproved[tokenId] == msg.sender || isApprovedForAll[tokenOwner][msg.sender], "!owner/spender/approvedForAll");
        
        balanceOf[tokenOwner] -= 1;
        totalSupply -= 1; 
        ownerOf[tokenId] = address(0);
        getApproved[tokenId] = address(0);
        tokenURI[tokenId] = "";
        
        emit Transfer(msg.sender, address(0), tokenId);
    }
    
    function burnBatch(uint256[] calldata tokenId) external {
        for (uint256 i = 0; i < tokenId.length; i++) {
            burn(tokenId[i]);
        }
    }
    
    function _transfer(address from, address to, uint256 tokenId) internal {
        balanceOf[sender] -= 1; 
        balanceOf[to] += 1; 
        getApproved[tokenId] = address(0);
        ownerOf[tokenId] = to;
        
        emit Transfer(from, to, tokenId); 
    }
    
    function transfer(address to, uint256 tokenId) external returns (bool) {
        require(msg.sender == ownerOf[tokenId], "!owner");
        require(transferable, "!transferable"); 
        
        _transfer(msg.sender, to, tokenId);
        
        return true;
    }
    
    function transferBatch(address[] calldata to, uint256[] calldata tokenId) external {
        require(transferable, "!transferable"); 
        require(to.length == tokenId.length, "to != index");
        
        for (uint256 i = 0; i < to.length; i++) {
            require(msg.sender == ownerOf[tokenId[i]], "!owner");
            _transfer(msg.sender, to[i], tokenId[i]);
        }
    }

    function transferFrom(address from, address to, uint256 tokenId) public returns (bool) {
        address tokenOwner = ownerOf[tokenId];
        require(msg.sender == tokenOwner || getApproved[tokenId] == msg.sender || isApprovedForAll[tokenOwner][msg.sender], "!owner/spender/operator");
        require(transferable, "!transferable");

        getApproved[tokenId] = address(0);
        ownerOf[tokenId] = to;
        
        _transfer(from, to, tokenId);
        
        return true;
    }
    
    function mint(address to, string calldata tokenURI) external { // "open mint" - anyone can call new NFT to anyone
        totalSupply += 1;
        require(totalSupply <= totalSupplyCap, "capped");
        
        balanceOf[to] += 1;
        tokenId = totalSupply;
        ownerOf[tokenId] = to;
        tokenURI[tokenId] = tokenURI;
        
        emit Transfer(address(0), to, tokenId); 
    }
    
    /**************
    OWNER FUNCTIONS
    **************/
    function updateBaseURI(string calldata _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }
    
    function updateOwner(address _owner) external onlyOwner {
        owner = _owner;
    }
    
    function updateResolver(address _resolver) external onlyOwner {
        resolver = _resolver;
    }
    
    function updateTokenURI(uint256 tokenId, string calldata _tokenURI) external onlyOwner {
        tokenURI[tokenId] = _tokenURI;
    }
    
    function updateTransferability(bool _transferable) external onlyOwner {
        transferable = _transferable;
    }
}
