// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// interface ILiquiswap {
//     function getNumNFTsAwarded(address) external view returns (uint);
// }


contract LiquiswapNFT is ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address public liquiswapContract;
    string public baseUri;
    
    // user address => number of NFTs they've been awarded by the Liquiswap contract
    mapping(address => uint) public userNumAwarded;

    
    constructor(address _liquiswapContract) ERC721("LiquiswapNFT", "LQS") {
        liquiswapContract = _liquiswapContract;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, 0xa01C18793c1d8b94849DA884FDBcda857af463Ab); // testAccount2
        _grantRole(DEFAULT_ADMIN_ROLE, 0xf9739cF1B992E62a1C5c18C33cacb2a27a91F888); // itachi
    }


    modifier liquiswapOrOwner {
        require(msg.sender == liquiswapContract ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "only liquiswap or admin");
        _;
    }


    // currently, the Liquiswap contract control
    function setLiquiswapContract(address _addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        liquiswapContract = _addr;
    }

    
    // award an NFT to user
    function awardNFT(address _user) external liquiswapOrOwner {
        safeMint(_user, baseUri);
    }

    
    // set/change the token base uri
    function setBaseUri(string memory _baseUri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseUri = _baseUri;
    }


    /// @dev mint called by the Liquiswap contract via awardNFT
    function safeMint(address to, string memory uri) private {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }


    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
