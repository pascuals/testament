// Version de solidity del Smart Contract
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

// Smart Contract Information
// Name: Testament

import "@openzeppelin/contracts/access/Ownable.sol";

// Smart Contract - Testament
contract Testament is Ownable {

    // Relation of assets with wallets
    mapping(bytes32 => mapping(address => uint256)) public assetsPercents;
    // true if user will donate its organs
    bool isDonor;
    // Url of the video to be seen by the heirs
    string videoUrl;
    string deathCertificateUrl;
    address notary;

    function getAssetPercent(string memory assetId, address person) public view returns (uint256) {
        return assetsPercents[hash(assetId)][person];
    }

    function registerAsset(string memory assetId, address person, uint256 percent) public onlyOwner {
        assetsPercents[hash(assetId)][person] = percent;
    }

    function hash(string memory _text) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text));
    }

    function setIsDonor(bool _isDonor) public onlyOwner {
        isDonor = _isDonor;
    }

    function setVideoUrl(string _videoUrl) public onlyOwner {
        videoUrl = _videoUrl;
    }

    function setNotary(address _notary) public onlyOwner {
        notary = _notary;
    }

    function setDeathCertificate(string _deathCertificateUrl) public onlyOwner {
        require(msg.sender == notary);
        deathCertificateUrl = _deathCertificateUrl;
    }

    constructor() {
    }
}
