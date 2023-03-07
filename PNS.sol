// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import './Base64.sol';

contract PNS is ERC721, Ownable {

    event DomainRegistered(string domain, address owner);
    event DomainTransferred(string domain, address oldOwner, address newOwner);

    mapping(string => address) private _domainOwners;
    mapping(address => string[]) private _ownedDomains;
    mapping(uint256 => bytes) private tokenIdToDomain;
    mapping(address => string) private primaryDomain;

    using Strings for uint256;

    constructor() ERC721("Pub Naming Service", "PUB") {}

    function registerDomain(string memory domain) public {
       string memory domainWithPub = string(abi.encodePacked(domain, ".pub"));
       require(_isDomainAvailable(domainWithPub), "Domain taken!");
       uint256 tokenId = _tokenIdOf(domainWithPub);
       _mint(msg.sender, tokenId);
      _domainOwners[domainWithPub] = msg.sender;
       _ownedDomains[msg.sender].push(domainWithPub);
      tokenIdToDomain[tokenId] = bytes(domainWithPub);
       emit DomainRegistered(domainWithPub, msg.sender);
}

    function transferDomain(string memory domain, address newOwner) public {
        require(_isApprovedOrOwner(_msgSender(), _tokenIdOf(domain)), "No PNS for you!");
        address oldOwner = _domainOwners[domain];
        _transfer(oldOwner, newOwner, _tokenIdOf(domain));
        _domainOwners[domain] = newOwner;
        _updateOwnedDomains(oldOwner, newOwner, domain);
        emit DomainTransferred(domain, oldOwner, newOwner);
    }

    function _updateOwnedDomains(address oldOwner, address newOwner, string memory domain) private {
        uint256 index;
        string[] storage ownedDomains = _ownedDomains[oldOwner];
        for (uint256 i = 0; i < ownedDomains.length; i++) {
            if (keccak256(abi.encodePacked(ownedDomains[i])) == keccak256(abi.encodePacked(domain))) {
                index = i;
                break;
            }
        }
        require(index < ownedDomains.length, "Domain not found for old owner");
        ownedDomains[index] = ownedDomains[ownedDomains.length - 1];
        ownedDomains.pop();
        _ownedDomains[newOwner].push(domain);
    }

    function setPrimaryDomain(string memory domain) public {
        require(_domainOwners[domain] == msg.sender, "Domain is not owned by the caller");
        primaryDomain[msg.sender] = domain;
    }

function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
      uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
  }

function generateRandomColor1() internal view returns (string memory) {
    uint256 randomNum1 = randomNum(360, 3, 3);
    string memory color = string(abi.encodePacked("hsl(", Strings.toString(randomNum1), ", 50%, 85%)"));
    return color;
}


function generateRandomColor2() internal view returns (string memory) {
    uint256 randomNum2 = randomNum(360, 3, 9);
    string memory color = string(abi.encodePacked("hsl(", Strings.toString(randomNum2), ", 50%, 15%)"));
    return color;
}

function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), "Token does not exist");
    string memory name = string(abi.encodePacked("PNS #", tokenId.toString()));
    string memory description = "Pub Naming Service";
    string memory svg = generateSVGofTokenById(tokenId);
    string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', name, '", "description": "', description, '", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'))));
    return string(abi.encodePacked("data:application/json;base64,", json));
}


function generateSVGofTokenById(uint256 tokenId) internal view returns (string memory) {
    string memory domain = string(tokenIdToDomain[tokenId]);
    string memory svg = string(abi.encodePacked(
      '<svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">',
        renderTokenById(domain),
      '</svg>'
    ));
    return svg;
}

function renderTokenById(string memory domain) internal view returns (string memory) {
    string memory color1 = generateRandomColor1();
    string memory color2 = generateRandomColor2();
    string memory render = string(abi.encodePacked(
        '<rect fill="', color1, '" x="0" y="104.52146" width="512" height="512"/>',
        '<text transform="matrix(1 0 0 1 0 0)" xml:space="preserve" text-anchor="start" font-family="monospace" font-size="48" id="svg_1" y="270.99999" x="208.96801" fill="',color2,'">',domain,'</text>'
    ));
    return render;
}


    function getPrimaryDomain(address addr) public view returns (string memory) {
        return primaryDomain[addr];
    }

    function getOwnedDomains(address owner) public view returns (string[] memory) {
        return _ownedDomains[owner];
    }

    function domainOwner(string memory domain) public view returns (address) {
        return _domainOwners[domain];
    }

    function _isDomainAvailable(string memory domain) private view returns (bool) {
        return _domainOwners[domain] == address(0);
    }

    function _tokenIdOf(string memory domain) private pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(domain)));
    }

    function getTokenId(string memory domain) public pure returns (uint256) {
        return _tokenIdOf(domain);
    }
}
