//imports
//main function
//calling main function

const { getNamedAccounts, deployments, network } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")
//const helperConfig = require("../helper-hardhat-config")
//const networkConfig = helperConfig.networkConfig
//const {network} = require ("hardhat")

//async function deployFunc(hre) {
//console.log("Hi!")
//}
//module.exports.default = deployFunc

//module.exports = async (hre) => {
//const { getNamedAccounts, deployments } = hre

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    //const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    let ethUsdPriceFeedAddress
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    //if the contract doesn't exist, we deploy a minimal version for our local testing.
    //when going for localhost or hardhat network we'll use a mock

    const args = [ethUsdPriceFeedAddress]
    //Instead of using the contractFactory....
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, //put price feed address
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, args)
    }
    //verify

    log("________________________________________________________________")
}
//hre.getNamedAccounts
//hre.deployments

module.exports.tags = ["all", "fundme"]
