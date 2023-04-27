const { ethers, getNamedAccounts, deployments, network } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")
const { assert, expect } = require("chai")

//let variable = true
//let someVar = variable ? "yes": "no"
//if (variable) {someVar = "yes"} else {someVar = "no"}

developmentChains.includes(network.name)
    ? describe.skip
    : describe("FundMe", function () {
          let fundMe, deployer
          const sendValue = ethers.utils.parseEther("0.3")
          beforeEach(async function () {
              deployer = (await getNamedAccounts()).deployer
              //any fixtures because in our staging we're assuming it's deployed and don't need a mock because we are going to use a testnet.
              fundMe = await ethers.getContract("FundMe", deployer)
          })
          it("allow people to fund and withdraw", async function () {
              await fundMe.fund({ value: sendValue })
              await fundMe.withdraw()
              const endingFundMeBalance = await fundMe.provider.getBalance(
                  fundMe.address
              )

              assert.equal(endingFundMeBalance.toString(), 0)
          })
      })
