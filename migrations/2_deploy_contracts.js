const Escrow = artifacts.require("Escrow");
const Lease = artifacts.require("Lease");

module.exports = function (deployer) {
  deployer.deploy(Escrow);
  deployer.deploy(Lease);
};
