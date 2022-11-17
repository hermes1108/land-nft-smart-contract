// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract LandNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {

    using SafeMath for uint;

    IERC20 token;

    uint256 public limit = 1000;

    struct allocatedNFT{
        bool isAllocated;
        uint256 common;
        uint256 rare;
        uint256 legend;
    }

    struct mintedNFT{
        uint256 common;
        uint256 rare;
        uint256 legend;
    }

    mapping(address => allocatedNFT) private _allocatedNFT;
    mapping(address => mintedNFT) private _mintedNFT;

    mapping(address => bool) public _whiteListed;

    mapping(address => uint256) public remainlimit;

    mapping(address => bool) private isManager;

    mapping(string => bool) public isAlreadyListed;

    using Counters for Counters.Counter;

    Counters.Counter public _tokenIdCounter;

    uint256 public totCommon;
    uint256 public totLegend;
    uint256 public totRare;

    uint256 public minCommon;
    uint256 public minLegend;
    uint256 public minRare;

    uint256 public priceCommon;
    uint256 public priceRare;
    uint256 public priceLegend;

    struct NFTforSale{
        uint256 tokenid;
        address owner;
        uint256 amount;
        bool isForSale;
    }

    mapping(uint256 => NFTforSale) private _nftforSale;

    event MINTNFT(address owner, uint256 token_id, uint256 reaminNFT);

    constructor(address _tok) ERC721("Zomfi Land", "ZOMFIL") {
        token = IERC20(_tok);
        totCommon = 4600;
        totRare = 1600;
        totLegend = 800;

        priceCommon = 300000000000000000;
        priceRare = 600000000000000000;
        priceLegend = 900000000000000000;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function MintCommonLand() public {
        require(_whiteListed[msg.sender] == true, "You are Not WhiteListed");
        require(_allocatedNFT[msg.sender].common != 0, "No NFT remaining");
        require(totCommon > 0, "No NFT remaing for minting");

        uint256 approvedamount = token.allowance(msg.sender, address(this));
        require(priceCommon == approvedamount, "ERC20: Not yet Approved");

        bool suc = token.transferFrom(msg.sender, address(this), priceCommon);

        if(suc){
            string memory uri = "QmZxHBXSZT4fNc6z8Q2ARmDui8D2kkPv9bdNccxHNisfzq";

            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();

            _safeMint(msg.sender, tokenId);
            _setTokenURI(tokenId, uri);

            totCommon = totCommon.sub(1);
            minCommon = minCommon.add(1);


            _allocatedNFT[msg.sender].common = _allocatedNFT[msg.sender].common.sub(1);

            _mintedNFT[msg.sender].common = _mintedNFT[msg.sender].common.add(1);

            emit MINTNFT(msg.sender, tokenId, _allocatedNFT[msg.sender].common);
        }
    }

    function MintRareLand() public {
        require(_whiteListed[msg.sender] == true, "You are Not WhiteListed");
        require(_allocatedNFT[msg.sender].rare != 0, "No NFT remaining");
        require(totRare > 0, "No NFT remaing for minting");

        uint256 approvedamount = token.allowance(msg.sender, address(this));
        require(priceRare == approvedamount, "ERC20: Not yet Approved");

        bool suc = token.transferFrom(msg.sender, address(this), priceRare);

        if(suc){
            string memory uri = "QmZVMdthbH8QuKHPLNJJLZFdKNfJXT8wKGQ9e8iJ8pbkj9";

            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();

            _safeMint(msg.sender, tokenId);
            _setTokenURI(tokenId, uri);

            totRare = totRare.sub(1);
            minRare = minRare.add(1);

            _allocatedNFT[msg.sender].rare = _allocatedNFT[msg.sender].rare.sub(1);

            _mintedNFT[msg.sender].rare = _mintedNFT[msg.sender].rare.add(1);

            emit MINTNFT(msg.sender, tokenId, _allocatedNFT[msg.sender].rare);
        }
    }

    function MintLegendLand() public {
        require(_whiteListed[msg.sender] == true, "You are Not WhiteListed");
        require(_allocatedNFT[msg.sender].legend != 0, "No NFT remaining");
        require(totLegend > 0, "No NFT remaing for minting");

        uint256 approvedamount = token.allowance(msg.sender, address(this));
        require(priceLegend == approvedamount, "ERC20: Not yet Approved");

        bool suc = token.transferFrom(msg.sender, address(this), priceLegend);

        if(suc){
            string memory uri = "QmQfzCHUVzymeQcAiP7WxZC5ezVFXfFhAd3ASoPvANjgfZ";

            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();

            _safeMint(msg.sender, tokenId);
            _setTokenURI(tokenId, uri);

            totLegend = totLegend.sub(1);
            minLegend = minLegend.add(1);

            _allocatedNFT[msg.sender].legend = _allocatedNFT[msg.sender].legend.sub(1);

            _mintedNFT[msg.sender].legend = _mintedNFT[msg.sender].legend.add(1);

            emit MINTNFT(msg.sender, tokenId, _allocatedNFT[msg.sender].legend);
        }
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        require(msg.sender == ownerOf(tokenId), "You are not the Owner");
        super._burn(tokenId);
    }

    // function getTheListedNFTs(uint256 tokenid) public view returns (address, uint256, uint256, string memory){
    //     require(_nftforSale[tokenid].isForSale == true, "Not for Sale");
    //     return (_nftforSale[tokenid].owner, tokenid, _nftforSale[tokenid].amount, tokenURI(tokenid));
    // }

    function getTotalNFTs() public view returns (uint256){
        return _tokenIdCounter.current();
    }

    function getMyNFTCount() public view returns(uint256, uint256 , uint256){
        return (_mintedNFT[msg.sender].common, _mintedNFT[msg.sender].rare, _mintedNFT[msg.sender].legend);
    }

    // function isNFTisForSale(uint256 tokenId) public view returns(bool){
    //     return _nftforSale[tokenId].isForSale;
    // }

    function getAllocatedAmount() public view returns(uint256, uint256, uint256){
        return(_allocatedNFT[msg.sender].common, _allocatedNFT[msg.sender].rare, _allocatedNFT[msg.sender].legend);
    }

    function isManagerOfCon(address _addr) public view returns(bool){
        return (isManager[_addr]);
    }

    function whiteListNFTByManager(address _addr, uint256 _com, uint256 _rare, uint256 _legend) public {
        require(isManager[msg.sender] == true, "You are not the Manager!");

        _allocatedNFT[_addr].common = _com;
        _allocatedNFT[_addr].rare = _rare;
        _allocatedNFT[_addr].legend = _legend;

        _allocatedNFT[_addr].isAllocated = true;
        _whiteListed[_addr] = true;
    }

    function BulkwhiteListNFTByManager(address[] calldata _addr, uint256[] calldata _com, uint256[] calldata _rare, uint256[] calldata _legend) public {
        require(isManager[msg.sender] == true, "You are not the Manager!");
        for(uint256 i =0; i<_addr.length; i++)
        {
            require(_whiteListed[_addr[i]] == false, "ERC10: Already White Listed!");

            _allocatedNFT[_addr[i]].common = _com[i];
            _allocatedNFT[_addr[i]].rare = _rare[i];
            _allocatedNFT[_addr[i]].legend = _legend[i];

            _allocatedNFT[_addr[i]].isAllocated = true;
            _whiteListed[_addr[i]] = true;
        }
    }
    //---------------------------------------------Owner Functions----------------------------------------
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function whiteListNFT(address _addr, uint256 _com, uint256 _rare, uint256 _legend) public onlyOwner {
        require(_whiteListed[_addr] == false, "ERC10: Already White Listed!");

        _allocatedNFT[_addr].common = _com;
        _allocatedNFT[_addr].rare = _rare;
        _allocatedNFT[_addr].legend = _legend;

        _allocatedNFT[_addr].isAllocated = true;
        _whiteListed[_addr] = true;
    }

    function withdrawAmount(address _adr) public onlyOwner {
        token.transfer(_adr, token.balanceOf(address(this)));
    }

    function addManager(address _addr) public onlyOwner {
        isManager[_addr] = true;
    }

    function revokeManager(address _addr) public onlyOwner{
        isManager[_addr] = false;
    }

}