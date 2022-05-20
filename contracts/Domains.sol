// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {StringUtils} from "./libraries/StringUtils.sol";
// We import another help function
import {Base64} from "./libraries/Base64.sol";

import "hardhat/console.sol";

contract Domains is ERC721URIStorage {
    // Here's our domain TLD!

    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public tld;

    // We'll be storing our NFT images on chain as SVGs
    string svgPartOne =
        '<svg width="256px" height="425px" viewBox="0 0 256 425" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" preserveAspectRatio="xMidYMid"> <defs> <linearGradient x1="50%" y1="-352.925786%" x2="50%" y2="96.7175267%" id="linearGradient-1"> <stop stop-color="#002E3B" offset="0%"></stop> <stop stop-color="#002639" offset="100%"></stop> </linearGradient> <linearGradient x1="50%" y1="-2.80786187%" x2="50%" y2="428.758892%" id="linearGradient-2"> <stop stop-color="#002E3B" offset="0%"></stop> <stop stop-color="#002639" offset="100%"></stop> </linearGradient> <radialGradient cx="16.4234038%" cy="142.999709%" fx="16.4234038%" fy="142.999709%" r="295.57111%" id="radialGradient-3"> <stop stop-color="#00BC85" offset="0%"></stop> <stop stop-color="#149D91" offset="100%"></stop> </radialGradient> <radialGradient cx="16.423338%" cy="-42.999755%" fx="16.423338%" fy="-42.999755%" r="357.003966%" id="radialGradient-4"> <stop stop-color="#00BC85" offset="0%"></stop> <stop stop-color="#149D91" offset="100%"></stop> </radialGradient> <radialGradient cx="11.4670327%" cy="-40.4580495%" fx="11.4670327%" fy="-40.4580495%" r="343.189366%" id="radialGradient-5"> <stop stop-color="#004473" offset="0%"></stop> <stop stop-color="#00345F" offset="100%"></stop> </radialGradient> </defs> <g> <path d="M65.6992339,330.300644 L0.107733463,362.384436 L127.400289,424.384842 L255.039336,362.18981 L189.28052,329.651265 L127.352045,360.40471 L65.6992339,330.300644 Z" fill="url(#linearGradient-1)"></path> <path d="M57.6019991,98.1748765 L57.6019991,98.1541795 L127.531267,64.0476413 L197.46571,98.1541795 L255.003891,62.1986373 L127.484698,0 L0,62.1796642 L0,62.2348584 L57.5537042,98.1990237 L57.6019991,98.1748765 L57.6019991,98.1748765 Z" fill="url(#linearGradient-2)"></path> <path d="M0.15618046,298.428426 L63.071162,267.624645 L127.784793,299.667263 L0.15618046,362.461971 L0.15618046,298.428426 Z" fill="url(#radialGradient-3)"></path> <path d="M196.677541,99.4103235 C196.67754,132.999495 196.677539,200.177839 196.677539,200.177839 L126.336262,234.601641 L191.022434,266.940614 L254.000917,236.143726 L254.00091,62.1907831 L196.677541,98.1665853 L196.677541,99.4103235 Z" fill="url(#radialGradient-4)"></path> <path d="M255.003891,298.216498 L57.5889764,199.96591 L57.5889774,98.1815418 L1.42108547e-14,62.2302408 L1.42108547e-14,63.1375243 L1.42108547e-14,235.931797 L255.003891,362.253488 L255.003891,298.216498 Z" fill="url(#radialGradient-5)"></path>';
    string svgPartTwo = "</g> </svg>";

    mapping(string => address) public domains;
    mapping(string => string) public records;

    address payable public owner;

    constructor(string memory _tld)
        payable
        ERC721("Ryon Name Service", "NNS")
    {
        owner = payable(msg.sender);
        tld = _tld;
        console.log("%s name service deployed", _tld);
    }

    function register(string calldata name) public payable {
        require(domains[name] == address(0));

        uint256 _price = price(name);
        require(msg.value >= _price, "Not enough Matic paid");

        // Combine the name passed into the function  with the TLD
        string memory _name = string(abi.encodePacked(name, ".", tld));
        // Create the SVG (image) for the NFT with the name
        string memory finalSvg = string(
            abi.encodePacked(svgPartOne, _name, svgPartTwo)
        );
        uint256 newRecordId = _tokenIds.current();
        uint256 length = StringUtils.strlen(name);
        string memory strLen = Strings.toString(length);

        console.log(
            "Registering %s.%s on the contract with tokenID %d",
            name,
            tld,
            newRecordId
        );

        // Create the JSON metadata of our NFT. We do this by combining strings and encoding as base64
        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                _name,
                '", "description": "A domain on the Ryon name service", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(finalSvg)),
                '","length":"',
                strLen,
                '"}'
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log(
            "\n--------------------------------------------------------"
        );
        console.log("Final tokenURI", finalTokenUri);
        console.log(
            "--------------------------------------------------------\n"
        );

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);
        domains[name] = msg.sender;

        _tokenIds.increment();
    }

    // This function will give us the price of a domain based on length
    function price(string calldata name) public pure returns (uint256) {
        uint256 len = StringUtils.strlen(name);
        require(len > 0);
        if (len == 3) {
            return 5 * 10**17; // 5 MATIC = 5 000 000 000 000 000 000 (18 decimals). We're going with 0.5 Matic cause the faucets don't give a lot
        } else if (len == 4) {
            return 3 * 10**17; // To charge smaller amounts, reduce the decimals. This is 0.3
        } else {
            return 1 * 10**17;
        }
    }

    // Other functions unchanged

    function getAddress(string calldata name) public view returns (address) {
        // Check that the owner is the transaction sender
        return domains[name];
    }

    function setRecord(string calldata name, string calldata record) public {
        // Check that the owner is the transaction sender
        require(domains[name] == msg.sender);
        records[name] = record;
    }

    function getRecord(string calldata name)
        public
        view
        returns (string memory)
    {
        return records[name];
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw Matic");
    }
}