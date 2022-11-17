// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract DogNFT is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter public _tokenIdCounter;

    uint256 public supplyCommon = 6000;
    uint256 public supplyRare = 3000;
    uint256 public supplyLegendary = 990;
    uint256 public supplyMathical = 10;

    uint256 public costCommon = 1 ether;
    uint256 public costRare = 3 ether;
    uint256 public costLegendary = 5 ether;
    uint256 public costMathical = 5 ether;

    uint256 public saleState = 0;

    string uriCommon;
    string uriRare;
    string uriLegendary;
    string uriMathical;

    mapping(uint256 => string) public NFTrarities;
    mapping(uint256 => string) internal uris;

    bytes32 private root =
        0x1ce2e6009842f6535f7fd932f8a2a596843af312357d0c45ad607acff4c86434;

    /** Constructor */

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uriCommon,
        string memory _uriRare,
        string memory _uriLegendary,
        string memory _uriMathical
    ) ERC721(_name, _symbol) {
        setBaseURI(_uriCommon, _uriRare, _uriLegendary, _uriMathical);
    }

    /** Public */
    function mintCommon(bytes32[] memory _proof) public payable {
        require(saleState > 0, "Sale has not started");
        if (saleState == 1) {
            require(
                MerkleProof.verify(
                    _proof,
                    root,
                    keccak256(abi.encodePacked(msg.sender))
                ) == true,
                "Not on whitelist"
            );
        }
        require(msg.value >= costCommon, "Insufficient Price");
        require(supplyCommon > 0, "No Common Remaining");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        NFTrarities[tokenId] = "common";
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uriCommon, supplyCommon);
        --supplyCommon;
    }

    function mintRare(bytes32[] memory _proof) public payable {
        require(saleState > 0, "Sale has not started");
        if (saleState == 1) {
            require(
                MerkleProof.verify(
                    _proof,
                    root,
                    keccak256(abi.encodePacked(msg.sender))
                ) == true,
                "Not on whitelist"
            );
        }
        require(msg.value >= costRare, "Insufficient Price");
        require(supplyRare > 0, "No Rare Remaining");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        NFTrarities[tokenId] = "rare";
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uriRare, supplyRare);
        --supplyRare;
    }

    function mintLegendary(bytes32[] memory _proof) public payable {
        require(saleState > 0, "Sale has not started");
        if (saleState == 1) {
            require(
                MerkleProof.verify(
                    _proof,
                    root,
                    keccak256(abi.encodePacked(msg.sender))
                ) == true,
                "Not on whitelist"
            );
        }
        require(msg.value >= costLegendary, "Insufficient Price");
        require(supplyLegendary + supplyMathical > 0, "No Legendary Remaining");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(msg.sender, tokenId);
        uint256 rand = block.timestamp % (supplyLegendary + supplyMathical);
        if (rand < supplyMathical) {
            NFTrarities[tokenId] = "mathical";
            _setTokenURI(tokenId, uriMathical, supplyMathical);
            --supplyMathical;
        } else {
            NFTrarities[tokenId] = "legendary";
            _setTokenURI(tokenId, uriLegendary, supplyMathical);
            --supplyLegendary;
        }
    }

    function rarityById(uint256 _tokenID) public view returns (string memory) {
        return NFTrarities[_tokenID];
    }

    /** Only owner */

    function setBaseURI(
        string memory _uriCommon,
        string memory _uriRare,
        string memory _uriLegendary,
        string memory _uriMathical
    ) public onlyOwner {
        uriCommon = _uriCommon;
        uriRare = _uriRare;
        uriLegendary = _uriLegendary;
        uriMathical = _uriMathical;
    }

    function startPrivateSale() external onlyOwner {
        saleState = 1;
    }

    function startPublicSale() external onlyOwner {
        saleState = 2;
    }

    function stopSale() external onlyOwner {
        saleState = 0;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        return uris[tokenId];
    }

    function _setTokenURI(
        uint256 tokenId,
        string memory base,
        uint256 id
    ) internal {
        uris[tokenId] = string(abi.encodePacked(base, id.toString()));
    }

    function setRoot(bytes32 _newRoot) external onlyOwner {
        root = _newRoot;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
