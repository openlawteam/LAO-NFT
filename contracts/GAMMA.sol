pragma solidity 0.5.17;

contract GAMMA { // Γ - lo-code, lo-cost NFT
    uint256 public totalSupply;
    string public name = "GAMMA";
    string public symbol = "GAMMA";
    event Approval(address indexed approver, address indexed spender, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public getApproved;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => string) public tokenURI;
    mapping(bytes4 => bool) public supportsInterface; // eip-165 
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    constructor () public {
        balanceOf[msg.sender] = 1;
        totalSupply = 1;
        ownerOf[1] = msg.sender;
        tokenURI[1] = "Γ";
        supportsInterface[0x80ac58cd] = true; // ERC721 
        supportsInterface[0x5b5e139f] = true; // METADATA
        emit Transfer(address(0), msg.sender, 1);
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

    function burn(uint256 tokenId) external {
        address tokenOwner = ownerOf[tokenId];
        require(msg.sender == tokenOwner || getApproved[tokenId] == msg.sender || isApprovedForAll[tokenOwner][msg.sender], "!owner/spender/approvedForAll");
        balanceOf[tokenOwner] -= 1;
        totalSupply -= 1; 
        ownerOf[tokenId] = address(0);
        getApproved[tokenId] = address(0);
        tokenURI[tokenId] = "";
        emit Transfer(msg.sender, address(0), tokenId);
    }
    
    function mint(address to, string calldata _tokenURI) external { // "open mint" - anyone can call new NFT to anyone
        totalSupply += 1;
        balanceOf[to] += 1;
        uint256 tokenId = totalSupply;
        ownerOf[tokenId] = to;
        tokenURI[tokenId] = _tokenURI;
        emit Transfer(address(0), to, tokenId); 
    }
    
    function _transfer(address from, address to, uint256 tokenId) internal {
        balanceOf[from] -= 1; 
        balanceOf[to] += 1; 
        getApproved[tokenId] = address(0);
        ownerOf[tokenId] = to;
        emit Transfer(from, to, tokenId); 
    }
    
    function transfer(address to, uint256 tokenId) external returns (bool) {
        require(msg.sender == ownerOf[tokenId], "!owner");
        _transfer(msg.sender, to, tokenId);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 tokenId) external returns (bool) {
        address tokenOwner = ownerOf[tokenId];
        require(msg.sender == tokenOwner || getApproved[tokenId] == msg.sender || isApprovedForAll[tokenOwner][msg.sender], "!owner/spender/operator");
        getApproved[tokenId] = address(0);
        ownerOf[tokenId] = to;
        _transfer(from, to, tokenId);
        return true;
    }
}
