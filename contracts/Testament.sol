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
    bool public isDonor;
    // Url of the video to be seen by the heirs
    string public videoUrl;
    string public videoPassword;


    string public deathCertificateId;

    // Notary can update a death certificate and execute the testament
    address public notary;

    bool public isExecuted;

    function getAssetPercent(string memory assetId, address person) public view returns (uint256) {
        return assetsPercents[hash(assetId)][person];
    }

    function registerAsset(string memory assetId, address person, uint256 percent) public onlyOwner {
        require(!isExecuted);
        requireValidString(assetId);
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

    function setVideoUrl(string memory _videoUrl, string memory _videoPassword) public onlyOwner {
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

    function setDeathCertificate(string memory _deathCertificateId) public onlyOwner {
        require(msg.sender == notary);
        checkIsNotExecuted();
        requireValidString(_deathCertificateUrl);

        deathCertificateId = _deathCertificateId;
    }

    function checkIsNotDeath() private pure  {
        require(bytes(deathCertificateUrl).length == 0);
    }

    function checkIsDeath() private pure {
        requireValidString(deathCertificateUrl);
    }

    function checkIsNotExecuted() private pure {
        require(!isExecuted);
    }

    function requireValidString(string memory str) private pure {
        require(bytes(str).length > 0);
    }

    constructor() {
    }
}
