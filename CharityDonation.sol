// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharityContract {
    struct CharityCorparation {
        string name;
        address payable wallet;
        uint256 totalCharity;
    }

    address private owner;
    CharityCorparation[] private charityAddresses;
    address[] private charityWallets;

    event CharitySent(address indexed sender, address indexed wallet, uint256 indexed amount);
    event CharityAddressSet(string name, address indexed wallet);
    event FallbackCalled(address indexed sender, bytes data);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract deployer is allowed to do this!");
        _;
    }

    function checkCharityCorparation(address payable wallet) private view returns (bool) {
        for (uint256 i = 0; i < charityAddresses.length; i++) {
            if (charityAddresses[i].wallet == wallet) {
                return false;
            }
        }

        return true;
    }

    function setCharityAddress(string memory name, address payable wallet) public onlyOwner {
        require(wallet != address(0), "Invalid wallet address!");
        require(bytes(name).length > 0, "Name cannot be empty!");
        require(checkCharityCorparation(wallet), "Wallet already exists !");

        charityAddresses.push(CharityCorparation(name, wallet, 0));

        emit CharityAddressSet(name, wallet);
    }

    function getCharityAddresses() public view returns (CharityCorparation[] memory) {
        CharityCorparation[] memory addresses = new CharityCorparation[](charityAddresses.length);
        for (uint256 i = 0; i < charityAddresses.length; i++) {
            addresses[i] = charityAddresses[i];
        }

        return addresses;
    }

    function getTotalCharity(address payable wallet) public view returns (uint256) {
        require(!checkCharityCorparation(wallet), "Wallet does not exists !");
        
        for (uint256 i = 0; i < charityAddresses.length; i++) {
           if (charityAddresses[i].wallet == wallet) {
                return charityAddresses[i].totalCharity / 1 ether;
           }
        }
    }

    function sendCharity(address payable wallet) public payable {
        require(msg.value > 0, "You should send some ether to donate!");
        require(!checkCharityCorparation(wallet), "Wallet does not exists !");
        
        for (uint256 i = 0; i < charityAddresses.length; i++) {
            if (charityAddresses[i].wallet == wallet) {
                (bool success, ) = charityAddresses[i].wallet.call{value: msg.value}("");
                require(success, "Failed to send Ether");

                charityAddresses[i].totalCharity += msg.value;

                emit CharitySent(msg.sender, wallet, msg.value);
            }
        }
        
    }

    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.data);
    }

    receive() external payable {
        emit FallbackCalled(msg.sender, "");
    }
}
