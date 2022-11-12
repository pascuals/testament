// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// These files are dynamically created at test time
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Testament.sol";

contract TestTestament {

    function testInitialBalanceUsingDeployedContract() public {
        Testament meta = Testament(DeployedAddresses.Testament());

        uint expected = 10000;

        Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 Testament initially");
    }

    function testInitialBalanceWithNewTestament() public {
        Testament meta = new Testament();

        uint expected = 10000;

        Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 Testament initially");
    }

}
