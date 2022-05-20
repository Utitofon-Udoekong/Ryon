require("dotenv").config()
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.10",
  networks: {
    mumbai: {
      url: process.env.URL,
      accounts: [process.env.KEY]
    }
  }
}