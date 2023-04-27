const { ethers, run, network } = require("hardhat")

//async function verify(contractAddress, args) {
const verify = async (contractAddress, args) => {
    console.log("Verifying Contract...")
    try {
        await run("verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already verfied")
        } else {
            console.log(e)
        }
    }
}

module.exports = { verify }

//main()
//.then(() => process.exit(0))
//.catch((error) => {
//console.error(error)
//process.exit(1)
//})
