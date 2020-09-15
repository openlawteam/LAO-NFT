pragma solidity 0.5.17;

contract GAMMA { // Γ - mv-NFT-mkt
    uint256 public totalSupply;
    uint256 public constant GAMMA_MAX = 5772156649015328606065120900824024310421; 
    string public name = "✨";
    string public symbol = "GAMMA";
    
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public getApproved;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => string) public tokenURI;
    mapping(uint256 => Sale) public sale;
    mapping(bytes4 => bool) public supportsInterface; // eip-165 
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    event Approval(address indexed approver, address indexed spender, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    struct Sale {
        uint256 ethPrice;
        bool forSale;
    }
    
    constructor () public {
        balanceOf[msg.sender] = 1;
        totalSupply = 1;
        ownerOf[1] = msg.sender;
        tokenURI[1] = "Γ";
        supportsInterface[0x80ac58cd] = true; // ERC721 
        supportsInterface[0x5b5e139f] = true; // METADATA
        emit Transfer(address(0), msg.sender, 1);
    }
    
    function approve(address spender, uint256 tokenId) external {
        address owner = ownerOf[tokenId];
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "!owner/operator");
        getApproved[tokenId] = spender;
        emit Approval(msg.sender, spender, tokenId); 
    }
    
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    function mint(string calldata _tokenURI) external { 
        balanceOf[msg.sender]++;
        totalSupply++;
        require(totalSupply <= GAMMA_MAX, "maxed");
        uint256 tokenId = totalSupply;
        ownerOf[tokenId] = msg.sender;
        tokenURI[tokenId] = _tokenURI;
        emit Transfer(address(0), msg.sender, tokenId); 
    }
    
    function purchase(uint256 tokenId) payable external {
        require(msg.value == sale[tokenId].ethPrice, "!ethPrice");
        require(sale[tokenId].forSale == true, "!forSale");
        address owner = ownerOf[tokenId];
        (bool success, ) = owner.call.value(msg.value)("");
        require(success, "!transfer");
        sale[tokenId].forSale = false;
        _transfer(owner, msg.sender, tokenId);
    }
    
    function _transfer(address from, address to, uint256 tokenId) internal {
        balanceOf[from]--; 
        balanceOf[to]++; 
        getApproved[tokenId] = address(0);
        ownerOf[tokenId] = to;
        emit Transfer(from, to, tokenId); 
    }
    
    function transfer(address to, uint256 tokenId) external {
        require(msg.sender == ownerOf[tokenId], "!owner");
        _transfer(msg.sender, to, tokenId);
    }
    
    function transferFrom(address from, address to, uint256 tokenId) external {
        address owner = ownerOf[tokenId];
        require(msg.sender == owner || getApproved[tokenId] == msg.sender || isApprovedForAll[owner][msg.sender], "!owner/spender/operator");
        getApproved[tokenId] = address(0);
        ownerOf[tokenId] = to;
        _transfer(from, to, tokenId);
    }
    
    function updateSale(uint256 ethPrice, uint256 tokenId, bool forSale) external {
        require(msg.sender == ownerOf[tokenId], "!owner");
        sale[tokenId].ethPrice = ethPrice;
        sale[tokenId].forSale = forSale;
    }
}
