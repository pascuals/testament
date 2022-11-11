// Version de solidity del Smart Contract
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

// Informacion del Smart Contract
// Nombre: Testament
// Logica: Implementa subasta de productos entre varios participantes

import "@openzeppelin/contracts/access/Ownable.sol";

// Declaracion del Smart Contract - Auction
contract Testament is Ownable {

    mapping (bytes32 => mapping(address => uint256)) public assetsPercents;
    bool isDonor;

    function registerAsset(string memory assetId, address person, uint256 percent) public onlyOwner {
        assetsPercents[hash(assetId)][person] = percent;
    }

    function hash(string memory _text) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text));
    }

    function registerIsDonor(bool _isDonor) public onlyOwner {
        isDonor = _isDonor;
    }

    // ----------- Constructor -----------
    // Uso: Inicializa el Smart Contract - Auction con: description, precio y tiempo
    constructor() {
    }
    
}
