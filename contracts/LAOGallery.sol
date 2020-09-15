pragma solidity 0.5.17;

contract LAOGallery {
    address public owner;
    address public resolver;
    uint256 public totalSupply;
    uint256 public totalSupplyCap;
    string public baseURI;
    string public name;
    string public symbol;
    bool private initialized;
    bool public transferable; 

    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);
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
        string calldata _name, 
        string calldata _symbol, 
        address _owner, 
        address _resolver, 
        uint256 _totalSupplyCap, 
        string calldata _baseURI,
        string calldata _tokenURI,
        bool _transferable
    ) public {
        require(!initialized, "initialized"); 

        name = _name; 
        symbol = _symbol; 
        owner = _owner; 
        resolver = _resolver;
        totalSupplyCap = _totalSupplyCap; 
        baseURI = _baseURI; 
        initialized = true; 
        transferable = _transferable; 
        
        balanceOf[owner] += 1;
        totalSupply += 1;
        ownerOf[totalSupply] = owner;
        tokenURI[totalSupply] = _tokenURI;
        supportsInterface[0x80ac58cd] = true; // ERC721 
        supportsInterface[0x5b5e139f] = true; // METADATA
        
        emit Transfer(address(0), owner, totalSupply);
    }

    /************
    TKN FUNCTIONS
    ************/
    function approve(address spender, uint256 tokenId) external returns (bool) {
        address tokenOwner = ownerOf[tokenId];
        require(msg.sender == tokenOwner || isApprovedForAll[tokenOwner][msg.sender], "!owner/approvedForAll");
        
        getApproved[tokenId] = spender;
        
        emit Approval(msg.sender, spender, tokenId); 
        
        return true;
    }
    
    function setApprovalForAll(address spender, bool approved) external returns (bool) {
        isApprovedForAll[msg.sender][spender] = approved;
        
        emit ApprovalForAll(msg.sender, spender, approved);
        
        return true;
    }

    function balanceResolution(address sender, address recipient, uint256 tokenId) external {
        require(msg.sender == resolver, "!resolver");
        require(sender == ownerOf[tokenId], "!owner");
        
        _transfer(sender, recipient, tokenId); 
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
    
    function _transfer(address sender, address recipient, uint256 tokenId) internal {
        balanceOf[sender] -= 1; 
        balanceOf[recipient] += 1; 
        getApproved[tokenId] = address(0);
        ownerOf[tokenId] = recipient;
        
        emit Transfer(sender, recipient, tokenId); 
    }
    
    function transfer(address recipient, uint256 tokenId) external returns (bool) {
        require(msg.sender == ownerOf[tokenId], "!owner");
        require(transferable, "!transferable"); 
        
        _transfer(msg.sender, recipient, tokenId);
        
        return true;
    }
    
    function transferBatch(address[] calldata recipient, uint256[] calldata tokenId) external {
        require(transferable, "!transferable"); 
        require(recipient.length == tokenId.length, "!recipient/index");
        
        for (uint256 i = 0; i < recipient.length; i++) {
            require(msg.sender == ownerOf[tokenId[i]], "!owner");
            _transfer(msg.sender, recipient[i], tokenId[i]);
        }
    }

    function transferFrom(address sender, address recipient, uint256 tokenId) public returns (bool) {
        address tokenOwner = ownerOf[tokenId];
        require(msg.sender == tokenOwner || getApproved[tokenId] == msg.sender || isApprovedForAll[tokenOwner][msg.sender], "!owner/spender/approvedForAll");
        require(transferable, "!transferable");

        getApproved[tokenId] = address(0);
        ownerOf[tokenId] = recipient;
        
        _transfer(sender, recipient, tokenId);
        
        return true;
    }
    
    function mint(address recipient, string calldata tokenURI) external { // "open mint" - anyone can call for any recipient
        totalSupply += 1; 
        require(totalSupply <= totalSupplyCap, "capped");
        
        balanceOf[recipient] += 1;
        ownerOf[totalSupply] = recipient;
        tokenURI[totalSupply] = tokenURI;
        
        emit Transfer(address(0), recipient, totalSupply); 
    }
    
    /**************
    OWNER FUNCTIONS
    **************/
    function updateBaseURI(string calldata _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }
    
    function updateOwner(address payable _owner) external onlyOwner {
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
