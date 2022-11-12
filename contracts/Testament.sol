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
    string videoPassword;
    string deathCertificateUrl;
    address notary;

    bool isExecuted;

    function getAssetPercent(string memory assetId, address person) public view returns (uint256) {
        return assetsPercents[hash(assetId)][person];
    }

    function registerAsset(string memory assetId, address person, uint256 percent) public onlyOwner {
        require(!isExecuted);
        require(assetId != '' && bytes(assetId).length > 0);
        assetsPercents[hash(assetId)][person] = percent;
    }

    function hash(string memory _text) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text));
    }

    function setIsDonor(bool _isDonor) public onlyOwner {
        checkIsNotDeath();
        checkIsNotExecuted();
        isDonor = _isDonor;
    }

    function setVideoUrl(string _videoUrl, string _videoPassword) public onlyOwner {
        checkIsNotDeath();
        checkIsNotExecuted();
        videoUrl = _videoUrl;
        videoPassword = _videoPassword;
    }

    function setNotary(address _notary) public onlyOwner {
        checkIsNotDeath();
        checkIsNotExecuted();
        notary = _notary;
    }

    function executeTestament() public {
        require(msg.sender == notary);
        checkIsDeath();
        checkIsNotExecuted();
        isExecuted = true;
    }

    function setDeathCertificate(string _deathCertificateUrl) public onlyOwner {
        require(msg.sender == notary);
        checkIsNotExecuted();
        requireValidString(_deathCertificateUrl);

        deathCertificateUrl = _deathCertificateUrl;
    }

    function checkIsNotDeath() public {
        require(deathCertificateUrl == '');
    }

    function checkIsDeath() public {
        require(deathCertificateUrl != '');
    }

    function checkIsNotExecuted() public {
        require(!isExecuted);
    }

    function requireValidString(string str) private {
        require(str != '' && bytes(str).length > 0);
    }

    constructor() {
    }
}
