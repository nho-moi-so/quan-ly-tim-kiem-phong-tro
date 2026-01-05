// npm test test/bookingChainRepository.test.ts

import { bookingChainRepository } from "@/repositories/bookingChainRepository";
import { describe, expect } from '@jest/globals';
import * as dotenv from "dotenv";

dotenv.config();

// ==================== Test Configuration ====================
const TEST_CONTRACT_HASH = "test_contract_" + Date.now();
const TEST_CHECKIN = Math.floor(Date.now() / 1000) + 86400; // Tomorrow
const TEST_CHECKOUT = Math.floor(Date.now() / 1000) + 86400 * 7; // 7 days later

// Delay helper for waiting between transactions
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

// ==================== Test Suite ====================

describe("BookingChainRepository Tests", () => {
    console.log("\n🚀 Starting BookingChain Repository Tests\n");

    // ==================== Read Functions Tests ====================

    describe("Read Functions", () => {
        test("Should get contract info", async () => {
            console.log("\n📖 Test: Get Contract Info");
            try {
                const info = await bookingChainRepository.getContractInfo();
                
                console.log("✅ Contract Info:");
                console.log(`   - Address: ${info.address}`);
                console.log(`   - Owner: ${info.owner}`);
                console.log(`   - Current Account: ${info.currentAccount}`);
                console.log(`   - Is Admin: ${info.isCurrentAccountAdmin}`);
                
                expect(info.address).toBeDefined();
                expect(info.owner).toBeDefined();
                expect(info.currentAccount).toBeDefined();
                expect(typeof info.isCurrentAccountAdmin).toBe("boolean");
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 30000);

        test("Should get owner address", async () => {
            console.log("\n📖 Test: Get Owner");
            try {
                const owner = await bookingChainRepository.getOwner();
                
                console.log(`✅ Owner Address: ${owner}`);
                expect(owner).toBeDefined();
                expect(owner.startsWith("0x")).toBe(true);
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 30000);

        test("Should get admin address", async () => {
            console.log("\n📖 Test: Get Admin Address");
            try {
                const admin = await bookingChainRepository.getAdminAddress();
                
                console.log(`✅ Admin Address: ${admin}`);
                expect(admin).toBeDefined();
                expect(admin.startsWith("0x")).toBe(true);
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 30000);

        test("Should check if address is admin", async () => {
            console.log("\n📖 Test: Check Is Admin");
            try {
                const admin = await bookingChainRepository.getAdminAddress();
                const isAdmin = await bookingChainRepository.isAdmin(admin);
                
                console.log(`✅ Address ${admin} is admin: ${isAdmin}`);
                expect(typeof isAdmin).toBe("boolean");
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 30000);
    });

    // ==================== Write Functions Tests ====================

    describe("Write Functions - Confirm Contract", () => {
        test("Should confirm a new contract and verify", async () => {
            console.log("\n✍️ Test: Confirm Contract");
            try {
                console.log(`📝 Contract Hash: ${TEST_CONTRACT_HASH}`);
                console.log(`📅 Check-in: ${new Date(TEST_CHECKIN * 1000).toLocaleString()}`);
                console.log(`📅 Check-out: ${new Date(TEST_CHECKOUT * 1000).toLocaleString()}`);

                // Confirm contract
                const result = await bookingChainRepository.confirmContractAndWait({
                    contractHash: TEST_CONTRACT_HASH,
                    checkin: TEST_CHECKIN,
                    checkout: TEST_CHECKOUT,
                });

                console.log(`✅ Transaction Hash: ${result.hash}`);
                console.log(`✅ Block Number: ${result.receipt.blockNumber}`);
                console.log(`✅ Status: ${result.receipt.status}`);

                expect(result.hash).toBeDefined();
                expect(result.receipt.status).toBe("success");

                // Wait a bit before reading
                await delay(3000);

                // Verify contract exists
                const contract = await bookingChainRepository.getContract(TEST_CONTRACT_HASH);
                console.log("\n📋 Contract Details:");
                console.log(`   - Valid: ${contract.isValid}`);
                console.log(`   - Status: ${contract.status}`);
                console.log(`   - Check-in: ${new Date(Number(contract.checkin) * 1000).toLocaleString()}`);
                console.log(`   - Check-out: ${new Date(Number(contract.checkout) * 1000).toLocaleString()}`);

                expect(contract.isValid).toBe(true);
                expect(Number(contract.checkin)).toBe(TEST_CHECKIN);
                expect(Number(contract.checkout)).toBe(TEST_CHECKOUT);
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 60000);

        test("Should get contract details with formatted dates", async () => {
            console.log("\n📖 Test: Get Contract Details");
            try {
                await delay(2000);
                
                const details = await bookingChainRepository.getContractDetails(TEST_CONTRACT_HASH);
                
                console.log("✅ Contract Details:");
                console.log(`   - Hash: ${details.contractHash}`);
                console.log(`   - Status: ${details.status}`);
                console.log(`   - Valid: ${details.isValid}`);
                console.log(`   - Check-in: ${details.checkin.toLocaleString()}`);
                console.log(`   - Check-out: ${details.checkout.toLocaleString()}`);
                console.log(`   - Created: ${details.timestamp.toLocaleString()}`);

                expect(details.contractHash).toBe(TEST_CONTRACT_HASH);
                expect(details.isValid).toBe(true);
                expect(details.checkin instanceof Date).toBe(true);
                expect(details.checkout instanceof Date).toBe(true);
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 30000);

        test("Should check if contract is valid", async () => {
            console.log("\n📖 Test: Check Contract Valid");
            try {
                await delay(2000);
                
                const isValid = await bookingChainRepository.isContractValid(TEST_CONTRACT_HASH);
                
                console.log(`✅ Contract ${TEST_CONTRACT_HASH} is valid: ${isValid}`);
                expect(isValid).toBe(true);
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 30000);

        test("Should get contract status", async () => {
            console.log("\n📖 Test: Get Contract Status");
            try {
                await delay(2000);
                
                const status = await bookingChainRepository.getContractStatus(TEST_CONTRACT_HASH);
                
                console.log(`✅ Contract Status: ${status === 0 ? "Pending" : "Confirmed"}`);
                expect([0, 1]).toContain(status);
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 30000);
    });

    describe("Write Functions - Contract Verification", () => {
        test("Should verify contract", async () => {
            console.log("\n✍️ Test: Verify Contract");
            try {
                await delay(3000);

                const result = await bookingChainRepository.verifyAndWait({
                    contractHash: TEST_CONTRACT_HASH,
                });

                console.log(`✅ Transaction Hash: ${result.hash}`);
                console.log(`✅ Status: ${result.receipt.status}`);

                expect(result.hash).toBeDefined();
                expect(result.receipt.status).toBe("success");

                // Verify the contract is still valid
                await delay(2000);
                const isValid = await bookingChainRepository.isContractValid(TEST_CONTRACT_HASH);
                console.log(`✅ Contract is valid after verification: ${isValid}`);
                expect(isValid).toBe(true);
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 60000);
    });

    describe("Write Functions - Cancel Contract", () => {
        test("Should cancel contract", async () => {
            console.log("\n✍️ Test: Cancel Contract");
            try {
                await delay(3000);

                const result = await bookingChainRepository.cancelContractAndWait({
                    contractHash: TEST_CONTRACT_HASH,
                });

                console.log(`✅ Transaction Hash: ${result.hash}`);
                console.log(`✅ Status: ${result.receipt.status}`);

                expect(result.hash).toBeDefined();
                expect(result.receipt.status).toBe("success");

                // Verify contract status changed
                await delay(2000);
                const status = await bookingChainRepository.getContractStatus(TEST_CONTRACT_HASH);
                console.log(`✅ Contract Status after cancel: ${status === 0 ? "Pending" : "Confirmed"}`);
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 60000);
    });

    describe("Write Functions - Void Contract", () => {
        test("Should void contract", async () => {
            console.log("\n✍️ Test: Void Contract");
            try {
                await delay(3000);

                const result = await bookingChainRepository.voidContractAndWait({
                    contractHash: TEST_CONTRACT_HASH,
                });

                console.log(`✅ Transaction Hash: ${result.hash}`);
                console.log(`✅ Status: ${result.receipt.status}`);

                expect(result.hash).toBeDefined();
                expect(result.receipt.status).toBe("success");

                // Verify contract is no longer valid
                await delay(2000);
                const isValid = await bookingChainRepository.isContractValid(TEST_CONTRACT_HASH);
                console.log(`✅ Contract is valid after void: ${isValid}`);
                expect(isValid).toBe(false);
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 60000);
    });

    // ==================== Event Parsing Tests ====================

    describe("Event Parsing", () => {
        test("Should verify confirm transaction", async () => {
            console.log("\n📖 Test: Verify Confirm Transaction");
            
            // Create a new contract for this test
            const newContractHash = "verify_test_" + Date.now();
            const checkin = Math.floor(Date.now() / 1000) + 86400;
            const checkout = Math.floor(Date.now() / 1000) + 86400 * 7;

            try {
                await delay(3000);

                // Confirm contract
                const result = await bookingChainRepository.confirmContractAndWait({
                    contractHash: newContractHash,
                    checkin,
                    checkout,
                });

                console.log(`✅ Contract confirmed with hash: ${result.hash}`);

                // Verify transaction
                await delay(2000);
                const verification = await bookingChainRepository.verifyConfirmTransaction(
                    result.hash,
                    newContractHash
                );

                console.log(`✅ Verification Success: ${verification.success}`);
                console.log(`✅ Message: ${verification.message}`);
                if (verification.checkin) {
                    console.log(`✅ Check-in: ${verification.checkin.toLocaleString()}`);
                }
                if (verification.checkout) {
                    console.log(`✅ Check-out: ${verification.checkout.toLocaleString()}`);
                }

                expect(verification.success).toBe(true);
                expect(verification.checkin).toBeDefined();
                expect(verification.checkout).toBeDefined();
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 90000);
    });

    // ==================== Error Handling Tests ====================

    describe("Error Handling", () => {
        test("Should handle non-existent contract gracefully", async () => {
            console.log("\n📖 Test: Non-existent Contract");
            try {
                const nonExistentHash = "non_existent_contract_12345";
                const contract = await bookingChainRepository.getContract(nonExistentHash);
                
                console.log(`✅ Contract isValid: ${contract.isValid}`);
                expect(contract.isValid).toBe(false);
                expect(Number(contract.checkin)).toBe(0);
                expect(Number(contract.checkout)).toBe(0);
            } catch (error) {
                console.error("❌ Error:", error);
                throw error;
            }
        }, 30000);
    });

    // ==================== Summary ====================
    
    afterAll(() => {
        console.log("\n" + "=".repeat(60));
        console.log("✅ All tests completed!");
        console.log("=".repeat(60) + "\n");
    });
});

// ==================== Manual Test Runner ====================

/**
 * Chạy test thủ công nếu file được execute trực tiếp
 */
async function runManualTests() {
    console.log("\n" + "=".repeat(60));
    console.log("🧪 Manual Test Runner for BookingChain Repository");
    console.log("=".repeat(60) + "\n");

    try {
        // Test 1: Get Contract Info
        console.log("1️⃣ Getting contract info...");
        const info = await bookingChainRepository.getContractInfo();
        console.log("✅ Contract Info:", info);
        console.log("");

        // Test 2: Create and Confirm Contract
        console.log("2️⃣ Creating and confirming a test contract...");
        const testHash = "manual_test_" + Date.now();
        const checkin = Math.floor(Date.now() / 1000) + 86400;
        const checkout = Math.floor(Date.now() / 1000) + 86400 * 7;
        
        const confirmResult = await bookingChainRepository.confirmContractAndWait({
            contractHash: testHash,
            checkin,
            checkout,
        });
        console.log("✅ Contract Confirmed:", confirmResult.hash);
        console.log("");

        // Test 3: Get Contract Details
        await delay(3000);
        console.log("3️⃣ Getting contract details...");
        const details = await bookingChainRepository.getContractDetails(testHash);
        console.log("✅ Contract Details:", details);
        console.log("");

        // Test 4: Verify Contract
        await delay(3000);
        console.log("4️⃣ Verifying contract...");
        const verifyResult = await bookingChainRepository.verifyAndWait({
            contractHash: testHash,
        });
        console.log("✅ Contract Verified:", verifyResult.hash);
        console.log("");

        console.log("=".repeat(60));
        console.log("✅ All manual tests passed!");
        console.log("=".repeat(60) + "\n");
    } catch (error) {
        console.error("❌ Manual test failed:", error);
        process.exit(1);
    }
}

// Uncomment để chạy manual tests
// runManualTests();
