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

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
      require(_exists(tokenId), "not exist");
      string memory image = Base64.encode(bytes(generateSVGofTokenById(tokenId)));

      return
          string(
              abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                          abi.encodePacked(
                              '", "image": "',
                              'data:image/svg+xml;base64,',
                              image,
                              '"}'
                          )
                        )
                    )
              )
          );
  }

function generateSVGofTokenById(uint256 tokenId) internal view returns (string memory) {
    string memory domainWithPub = string(tokenIdToDomain[tokenId]);
    string memory svg = string(abi.encodePacked(
      '<svg width="400" height="400" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">',
        renderTokenById(domainWithPub),
      '</svg>'
    ));

    return svg;
  }

  function renderTokenById(string memory domainWithPub) public view returns (string memory) {
    string memory render = string(abi.encodePacked(
      '<g id="text">',
        '<rect id="svg_1" height="543.99454" width="543.99454" y="-15.99728" x="-15.99728" stroke="#000" fill="hsl(',randomNum(361,3,3).toString(),',90%,25%)"/>',
        '<text style="width: 80%" x="50%" y="50%" dominant-baseline="middle" fill="hsl(',randomNum(361,3,3).toString(),',90%,75%)" text-anchor="middle" font-size="3.5vw">',domainWithPub,'</text>',
       '</g>'
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
