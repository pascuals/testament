// Version de solidity del Smart Contract
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

// Smart Contract Information
// Name: Testament

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

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

    // Notary, able to update a death certificate and execute the testament
    address public notary;

    // Check if the testament has been executed (testator deceased)
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

    function getAssetPercent(string calldata _assetId, address _heir) public view returns (uint256) {
        return assetsPercents[secureHash(_assetId)][_heir];
    }

    function registerAsset(string calldata _assetId, address _heir, uint256 _percent) public onlyOwner whenNotPaused {
        require(!isExecuted);
        require(_heir != owner(), 'Owner of the testament cannot be a heir');
        requireValidString(_assetId, 'Invalid asset id');

        bytes32 secureAssetId = secureHash(_assetId);

        uint256 oldPercent = assetsPercents[secureAssetId][_heir];

        require(oldPercent != _percent, 'Percent already set for the heir asset');

        assetsPercents[secureAssetId][_heir] = _percent;

        emit UpdatedAsset(_assetId, _heir, _percent, oldPercent);
    }

    function setIsDonor(bool _isDonor) public onlyOwner whenNotPaused notDeathOrExecuted {
        require(_isDonor != isDonor, 'Donor value is already set');

        isDonor = _isDonor;

        emit UpdatedIsDonor(isDonor);
    }

    function setVideoUrl(string calldata _videoUrl, string calldata _videoPassword) public onlyOwner whenNotPaused notDeathOrExecuted {
        require(hash(videoUrl) != hash(_videoUrl) && hash(videoPassword) != hash(_videoPassword), 'Url already stored, try a different video url');

        string memory oldVideoUrl = videoUrl;

        videoUrl = _videoUrl;
        videoPassword = _videoPassword;

        emit UpdatedVideo(videoUrl, oldVideoUrl);
    }

    function setNotary(address _notary) public onlyOwner whenNotPaused notDeathOrExecuted {
        require(_notary != owner(), 'Owner of the testament cannot be the notary');
        require(_notary != notary, 'Notary already stored, try a different notary address');

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
        checkIsNotDeath('Owner is already death');
        checkIsNotExecuted();
        requireValidString(_deathCertificateId, 'Invalid death certificate');

        deathCertificateId = _deathCertificateId;

        // Owner deceased
        renounceOwnership();

        emit Deceased(deathCertificateId);
    }

    // PRIVATE FUNCTIONS

    function requireValidString(string memory str, string memory errorMessage) private pure {
        require(bytes(str).length > 0, errorMessage);
    }

    function hash(string memory text) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(text));
    }

    function secureHash(string memory text) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(text))));
    }

    function checkIsNotDeath(string memory errorMessage) private view {
        require(bytes(deathCertificateId).length == 0, errorMessage);
    }

    function checkIsDeath(string memory errorMessage) private view {
        requireValidString(deathCertificateId, errorMessage);
    }

    function checkIsNotExecuted() private view {
        require(!isExecuted, 'Testament already executed');
    }

    modifier notDeathOrExecuted() {
        checkIsNotDeath('Testament owner is already death');
        checkIsNotExecuted();
        _;
    }
}
