const ConvertLib = artifacts.require('ConvertLib');
const Testament = artifacts.require('Testament');

module.exports = function(deployer) {
    deployer.deploy(ConvertLib);
    deployer.link(ConvertLib, Testament);
    deployer.deploy(Testament);
};
