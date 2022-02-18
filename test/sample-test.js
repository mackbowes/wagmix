const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Wagmix", function () {

  let wagmix;
  let deployer, creator, user;

  this.beforeEach(async function() {
    const Wagmix = await ethers.getContractFactory("Wagmix");
    [deployer, creator, user] = await ethers.getSigners();
    wagmix = await Wagmix.deploy("WAGMIX");
    await wagmix.deployed();
  })

  it("Should Deploy", async () => {
    expect(await wagmix.name()).to.equal("WAGMIX");

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });

  it("Should allow a mint", async () => {
    await wagmix.connect(creator);
    await wagmix.create(creator.address, "ipfs://example");
    expect(await wagmix.tokenSupply(1)).to.equal(1);
  });

  it("Should block transfers", async () => {
    await wagmix.connect(creator);
    await wagmix.create(creator.address, "ipfs://example");
    await expect(wagmix.safeTransferFrom(creator.address, user.address, 1, 1, [])).to.be.reverted;
  });
  
  it("Should allow sharing", async () => {
    await wagmix.connect(creator);
    await wagmix.create(creator.address, "ipfs://example");
    await wagmix.share(user.address, 1);
    expect(await wagmix.tokenSupply(1)).to.equal(2);
  })
});
