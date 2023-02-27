import React, { useState, useEffect } from "react";
import { ethers } from "ethers";
import PNS_ABI from "./PNS.json";
import './App.css';

const PNS_ADDRESS = "0x0d5c70a93Cce712473AEe6BcBfb7CDbb5daa8D9b";

function App() {

  const [domainName, setDomainName] = useState("");
  const [primaryName, setPrimary] = useState("");
  const [connected, setConnected] = useState(false);
  const [pubName, setPubName] = useState("");


  const connect = async () => {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      setConnected(true)
      const signer = await provider.getSigner();
      const address = await signer.getAddress()
      const pnsContract = new ethers.Contract(PNS_ADDRESS, PNS_ABI, signer);
      const name = await pnsContract.getPrimaryDomain(address);
      console.log(name)
      setPubName(name)
    } catch (error) {
      console.log(error.message)
    }}

  async function registerDomain(domainName) {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();
      const pnsContract = new ethers.Contract(PNS_ADDRESS, PNS_ABI, signer);
      const transaction = await pnsContract.registerDomain(domainName);
      await transaction.wait();
    } catch (error) {
      console.error(error);
    }
  }

  const handleRegisterDomain = async (event) => {
    event.preventDefault();
    await registerDomain(domainName);
  };


  async function setPrimaryDomain(primaryName) {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();
      const pnsContract = new ethers.Contract(PNS_ADDRESS, PNS_ABI, signer);
      const transaction = await pnsContract.setPrimaryDomain(primaryName);
      await transaction.wait();
      setPubName(transaction)
    } catch (error) {
      console.error(error);
    }
  }

  async function handleSetPrimaryDomain(event) {
    event.preventDefault();
    await setPrimaryDomain(primaryName);
    setPubName(primaryName)
  }

  return (
    <div className="App">
      <header className="App-header">

      <h1>Pub Namine Service</h1>
      
      {connected && (
        <>
        <p>welcome back...{pubName}</p>
        
          <div>
          <form onSubmit={handleRegisterDomain}>
            <input
              type="text"
              placeholder="domain name"
              value={domainName}
              onChange={(event) => setDomainName(event.target.value)} />
            <br/>
            <button className="registerButtons" type="submit">Register domain</button>
          </form>
          </div>

          <br/>

          <div>
            <form onSubmit={handleSetPrimaryDomain}>
              <input
                type="text"
                placeholder="me.pub"
                value={primaryName}
                onChange={(event) => setPrimary(event.target.value)}
              />
           <br/>
          <button className="registerButtons" type="submit">Set primary domain</button>
        </form>
      </div>
      <p>register and set a primary .pub domain</p>
          </>
      )}

      {!connected && (
        <button className="connect" onClick={connect}>connect</button>
      )}

      </header>
    </div>
  );
}

export default App;
