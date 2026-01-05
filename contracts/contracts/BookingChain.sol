//thong tin hop dong cho 4 chỗ:
	// 1. sau khi thanh toán, sau khi hủy (owner và guest)
	// 2. lưu trên database off-chain (admin) 
	// 3. lưu trên on-chain (blockchain)
	// => if owner AND admin ADJUST => owner == admin != guest == blockchain => blockchain alway tell the truth
	// => if owner AND admin AND guest WRONG => database offchain is attacked, refund back for guest

//tham số contract_hash sẽ dùng api/blockchain/hash để hash để cho trùng khớp với toàn bộ


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BookingChain {
    // ======================Modifiers======================
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Only admin can call this function");
        _;
    }
    
    
    // Enums
    enum ContractStatus { PAID, CANCELLED }
    // ======================Struct for Contract======================
    struct Contract {
        uint256 checkin;
        uint256 checkout;
        uint256 timestamp;
        ContractStatus status;
        bool isValid;
    }
    
    // ======================State variables======================
    address public owner;
    mapping(address => bool) public isAdmin;
    mapping(string => Contract) public contracts;
    
    // Events
    event AdminGranted(address indexed admin);
    event AdminRevoked(address indexed admin);
    event ContractConfirmed(string indexed contractHash, uint256 checkin, uint256 checkout);
    event ContractCancelled(string indexed contractHash);
    event ContractVoided(string indexed contractHash);
    event ContractVerified(string indexed contractHash, bool isValid);
    
    
    // ======================Constructor======================
    constructor() {
        owner = msg.sender;
        isAdmin[owner] = true;
        emit AdminGranted(owner);
    }
    
    // ======================Owner functions======================
    function grantRoleAdmin(address admin) external onlyOwner {
        require(admin != address(0), "Invalid address");
        isAdmin[admin] = true;
        emit AdminGranted(admin);
    }
    
    function revokeRoleAdmin(address admin) external onlyOwner {
        require(admin != address(0), "Invalid address");
        isAdmin[admin] = false;
        emit AdminRevoked(admin);
    }
    
    // ======================Admin functions======================
    function confirmContract(
        string calldata contractHash,
        uint256 checkin,
        uint256 checkout
    ) external onlyAdmin {
        require(checkin < checkout, "Invalid dates");
        require(!contracts[contractHash].isValid, "Contract already exists");
        
        contracts[contractHash] = Contract({
            checkin: checkin,
            checkout: checkout,
            timestamp: block.timestamp,
            status: ContractStatus.PAID,
            isValid: true
        });
        
        emit ContractConfirmed(contractHash, checkin, checkout);
    }
    
    function cancelContract(string calldata contractHash) external onlyAdmin {
        require(contracts[contractHash].isValid, "Contract not found");
        contracts[contractHash].status = ContractStatus.CANCELLED;
        emit ContractCancelled(contractHash);
    }
    
    function voidContract(string calldata contractHash) external onlyAdmin {
        require(contracts[contractHash].isValid, "Contract not found");
        contracts[contractHash].isValid = false;
        emit ContractVoided(contractHash);
    }
    
    // ======================Public functions======================
    function verify(string calldata contractHash) external {
        bool isValidContract = contracts[contractHash].isValid;
        emit ContractVerified(contractHash, isValidContract);
    }
    
    function getContract(string calldata contractHash) 
        external 
        view 
        returns (Contract memory) 
    {
        require(contracts[contractHash].isValid, "Contract not found");
        return contracts[contractHash];
    }
}