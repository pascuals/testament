// Version de solidity del Smart Contract
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

// Smart Contract Information
// Name: Testament

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";

// Smart Contract - Testament
contract Testament is Ownable, Pausable {

    // Relation of assets with wallets
    mapping(bytes32 => mapping(address => uint256)) public assetsPercents;

    // true if user will donate its organs
    bool public isDonor;

    // Url of the video to be seen by the heirs
    string public videoUrl;
    string public videoPassword;

    // Death certificate id
    string public deathCertificateId;

    // Notary can update a death certificate and execute the testament
    address public notary;

    bool public isExecuted;

    event Executed();

    event Deceased(
        string deathCertificateId
    );

    event UpdatedVideo(
        string videoUrl,
        string oldVideoUrl
    );

    event UpdatedNotary(
        address notaryAddress,
        address oldNotaryAddress
    );

    event UpdatedIsDonor(
        bool isDonor
    );

    event UpdatedAsset(
        string assetId,
        address heir,
        uint256 newPercent,
        uint256 oldPercent
    );

    function getAssetPercent(string calldata assetId, address heir) public view returns (uint256) {
        return assetsPercents[secureHash(assetId)][heir];
    }

    function registerAsset(string calldata assetId, address heir, uint256 percent) public onlyOwner whenNotPaused {
        require(!isExecuted);
        requireValidString(assetId, 'Invalid asset id');

        bytes32 secureAssetId = secureHash(assetId);

        uint256 oldPercent = assetsPercents[secureAssetId][heir];

        require(oldPercent != percent, 'Percent already set for the heir asset');

        assetsPercents[secureAssetId][heir] = percent;

        emit UpdatedAsset(assetId, heir, percent, oldPercent);
    }

    function setIsDonor(bool _isDonor) public onlyOwner whenNotPaused {
        checkIsNotDeath();
        checkIsNotExecuted();
        require(isDonor != _isDonor, 'Donor value is already set');

        isDonor = _isDonor;

        emit UpdatedIsDonor(isDonor);
    }

    function setVideoUrl(string calldata _videoUrl, string calldata _videoPassword) public onlyOwner whenNotPaused {
        checkIsNotDeath();
        checkIsNotExecuted();
        require(hash(videoUrl) != hash(_videoUrl) && hash(videoPassword) != hash(_videoPassword), 'Url already stored, try a different video url');

        string memory oldVideoUrl = videoUrl;

        videoUrl = _videoUrl;
        videoPassword = _videoPassword;

        emit UpdatedVideo(videoUrl, oldVideoUrl);
    }

    function setNotary(address _notary) public onlyOwner whenNotPaused {
        checkIsNotDeath();
        checkIsNotExecuted();
        require(notary != _notary, 'Notary already stored, try a different notary address');

        address oldNotary = notary;

        notary = _notary;

        emit UpdatedNotary(notary, oldNotary);
    }

    function executeTestament() public whenNotPaused {
        require(msg.sender == notary, 'Not enough permissions to execute the testament');
        checkIsDeath('Death certificate required');
        checkIsNotExecuted();

        isExecuted = true;

        emit Executed();
    }

    function setDeathCertificate(string calldata _deathCertificateId) public whenNotPaused {
        require(msg.sender == notary, 'Not enough permissions to add a death certificate');
        checkIsNotExecuted();
        checkIsDeath('Owner is already death');
        requireValidString(_deathCertificateId, 'Invalid death certificate');

        deathCertificateId = _deathCertificateId;

        // Owner deceased
        renounceOwnership();

        emit Deceased(deathCertificateId);
    }

    function requireValidString(string memory str, string memory errorMessage) private pure {
        require(bytes(str).length > 0, errorMessage);
    }

    function hash(string memory _text) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text));
    }

    function secureHash(string memory _text) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(_text))));
    }

    function checkIsNotDeath() private view {
        require(bytes(deathCertificateId).length == 0, 'Testament owner is already death');
    }

    function checkIsDeath(string memory errorMessage) private view {
        requireValidString(deathCertificateId, errorMessage);
    }

    function checkIsNotExecuted() private view {
        require(!isExecuted, 'Testament already executed');
    }
}
