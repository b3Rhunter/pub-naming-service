# pub-naming-service

This application is a simple frontend for interacting with a smart contract that provides a service for registering and setting a primary .pub domain. It is built using the React framework and uses the Ethereum blockchain for interacting with the smart contract.

## Installation
To install and run the application, follow these steps:

Clone the repository to your local machine.
Navigate to the project directory.
Install the dependencies using the command npm install.
Start the application using the command npm start.
## Usage
To use the application, follow these steps:

Connect to an Ethereum-enabled browser such as Metamask.
Click the "Connect" button to connect to the blockchain.
Enter a domain name in the "Register domain" field and click the "Register domain" button to register the domain.
Enter a primary domain name in the "Set primary domain" field and click the "Set primary domain" button to set the primary domain.
The current primary domain will be displayed at the top of the page.
## Smart Contract
The smart contract used by the application is defined in the PNS.json file, which contains the ABI (Application Binary Interface) for the contract. The contract address is defined in the PNS_ADDRESS constant. The smart contract provides the following functions:

registerDomain(domainName): Registers a new domain with the given name.
setPrimaryDomain(domainName): Sets the primary domain to the domain with the given name.
getPrimaryDomain(address): Returns the primary domain for the given address.
## License
This project is licensed under the MIT License.

## DEMO: https://pub-naming-service.vercel.app/
