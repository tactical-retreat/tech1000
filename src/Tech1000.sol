// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Tech1000 is ERC721Enumerable, ERC2981, Ownable {
    using Strings for uint256;

    uint256 private constant WHITELIST_PHASE_LIMIT = 250;
    uint256 private constant MAX_SUPPLY = 1000;
    uint256 private constant WL_PRICE = 1 ether;
    uint256 private constant PUBLIC_PRICE = 2 ether;
    uint256 private constant OWNER_RESERVE = 10;

    enum Phase {
        Closed,
        Whitelist,
        Public
    }

    Phase public currentPhase = Phase.Closed;

    string private _baseURIString = "ipfs://bafybeiddshgyfz2qzcyvmm3bsfqixxwoqybamjppqz4y2rcjmedmk6syda/metadata/";
    address private _creator;
    mapping(address => uint256) private _userMints;
    mapping(address => uint256) private _allowedMints;

    constructor() Ownable(msg.sender) ERC721("Tech 1000", "T1000") {
        _creator = msg.sender;
        _setDefaultRoyalty(_creator, 500);

        for (uint256 i = 1; i <= OWNER_RESERVE; i++) {
            _mint(msg.sender, i);
        }
    }

    function setPhase(Phase phase) external onlyOwner {
        currentPhase = phase;
    }

    function addToWhitelist(address[] calldata users, uint256 allowedMints) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            require(users[i] != address(0), "Invalid address");
            _allowedMints[users[i]] = allowedMints;
        }
    }

    function mint(uint256 quantity) public payable {
        require(currentPhase != Phase.Closed, "Minting not active");
        require(quantity > 0, "Invalid quantity");

        uint256 supply = totalSupply();
        uint256 remaining = MAX_SUPPLY - supply;
        require(remaining > 0, "Collection is minted out");
        require(quantity <= remaining, string(abi.encodePacked("Only ", remaining.toString(), " tokens remaining")));

        uint256 price = currentPhase == Phase.Whitelist ? WL_PRICE : PUBLIC_PRICE;
        require(msg.value == quantity * price, "Wrong payment amount");

        if (currentPhase == Phase.Whitelist) {
            require(_allowedMints[msg.sender] > 0, "Not whitelisted or no mints left");
            require(_userMints[msg.sender] + quantity <= _allowedMints[msg.sender], "Exceeds allowed mint limit");
        }

        for (uint256 i = 0; i < quantity; i++) {
            _mint(msg.sender, supply + i + 1);
        }

        _userMints[msg.sender] += quantity;
    }

    function setCreator(address creator_, uint96 feeNumerator_) public onlyOwner {
        require(creator_ != address(0), "Invalid creator address");
        _creator = creator_;
        _setDefaultRoyalty(creator_, feeNumerator_);
    }

    function setBaseURI(string calldata baseURI_) external onlyOwner {
        _baseURIString = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIString;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function rescueERC20(address tokenAddress) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function rescueERC721(address tokenAddress, uint256 tokenId) public onlyOwner {
        IERC721 token = IERC721(tokenAddress);
        token.transferFrom(address(this), msg.sender, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
