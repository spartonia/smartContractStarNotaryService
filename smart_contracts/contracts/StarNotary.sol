pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

contract StarNotary is ERC721 { 

    struct Star { 
        string name;
        string story;
        string ra;
        string dec;
        string mag;
        // string cent;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo; 
    mapping(uint256 => uint256) public starsForSale;
    mapping(uint256 => bool) public registeredStarCoords;
    

    function checkIfStarExist(string _ra, string _dec, string _mag /*, string _cent*/) public view returns(bool) {
        return registeredStarCoords[uint256(keccak256(abi.encodePacked(_ra, _dec, _mag/*, _cent*/)))];
    }
    

    function createStar(string _name, string _story, string _ra, string _dec, string _mag, /*string _cent,*/ uint256 _tokenId) public { 
        
        require (checkIfStarExist(_ra, _dec, _mag) == false, "A star is already registered in the coordinates");
        require (keccak256(abi.encodePacked(tokenIdToStarInfo[_tokenId].name)) == keccak256(""), "TokenId is already used");
        require (_tokenId > 0, "Tokenid cannot be empty");
        require (keccak256(abi.encodePacked(_name)) != keccak256(""), '"name" cannot be empty string');
        require (keccak256(abi.encodePacked(_story)) != keccak256(""), '"story" cannot be empty string');
        require (keccak256(abi.encodePacked(_ra)) != keccak256(""), '"ra" cannot be empty string');
        require (keccak256(abi.encodePacked(_dec)) != keccak256(""), '"dec" cannot be empty string');
        require (keccak256(abi.encodePacked(_mag)) != keccak256(""), '"mag" cannot be empty string');
        // require (keccak256(abi.encodePacked(_cent)) != keccak256(""), '"cent" cannot be empty string');
        
        
        Star memory newStar = Star(_name, _story, _ra, _dec, _mag /*, _cent*/);

        tokenIdToStarInfo[_tokenId] = newStar;
        registeredStarCoords[uint256(keccak256(abi.encodePacked(_ra, _dec, _mag/*, _cent*/)))] = true;

        _mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        require(this.ownerOf(_tokenId) == msg.sender);

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        require(starsForSale[_tokenId] > 0);
        
        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost);

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);
        
        starOwner.transfer(starCost);

        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }
    }

    function tokenIdToStarInfo(uint256 _tokenId) public view returns(string, string, string, string, string) {
        return (tokenIdToStarInfo[_tokenId].name, tokenIdToStarInfo[_tokenId].story, tokenIdToStarInfo[_tokenId].ra, tokenIdToStarInfo[_tokenId].dec, tokenIdToStarInfo[_tokenId].mag);
    }
    
}
