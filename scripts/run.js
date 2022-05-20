const main = async () => {
    const domainContractFactory = await hre.ethers.getContractFactory("Domains");
    // We pass in "Ryon" to the constructor when deploying
    const domainContract = await domainContractFactory.deploy("Ryon");
    await domainContract.deployed();
  
    console.log("Contract deployed to:", domainContract.address);
  
    // We're passing in a second variable - value. This is the moneyyyyyyyyyy
    let txn = await domainContract.register("Vega", {
      value: hre.ethers.utils.parseEther("0.5")
    });
    await txn.wait();
  
    const address = await domainContract.getAddress("Vega");
    console.log("Owner of domain Ryon:", address);
  
    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();
  