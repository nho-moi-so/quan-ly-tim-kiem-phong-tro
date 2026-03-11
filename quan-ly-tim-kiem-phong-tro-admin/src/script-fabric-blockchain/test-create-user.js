// cd /root/quan-ly-tim-kiem-phong-tro/quan-ly-tim-kiem-phong-tro-admin
// node src/script-fabric-blockchain/test-create-user.js
const path = require('path');

// Setup TypeScript and path aliases for this JS script
const projectRoot = path.resolve(__dirname, '..', '..');
process.chdir(projectRoot);
require('dotenv').config({ path: path.join(projectRoot, '.env') });

process.env.TS_NODE_PROJECT = path.resolve(__dirname, '..', '..', 'tsconfig.server.json');
process.env.TS_NODE_COMPILER_OPTIONS = JSON.stringify({
    module: 'commonjs',
    moduleResolution: 'node'
});
require('ts-node/register/transpile-only');
require('tsconfig-paths/register');

const { UserService } = require('../services/userService');

// Test data
const testUserData = {
    balance: 50000,
    email: `test-user-${Date.now()}@example.com`,
    fullName: "Nguyen Van Test",
    password: "123456789",
    phone: "0987654321",
    role: 'GUEST',
    status: 'active'
};

const testOwnerData = {
    balance: 100000,
    cccd: "123456789012",
    email: `test-owner-${Date.now()}@example.com`,
    fullName: "Tran Thi Test Owner",
    password: "123456789",
    phone: "0912345678",
    role: 'OWNER',
    status: 'pending'
};

async function testCreateUser(testData, testName) {
    console.log(`\n========== ${testName} ==========`);
    console.log('📝 Test data:', JSON.stringify(testData, null, 2));
    console.log('⏰ Started:', new Date().toISOString());
    
    try {
        console.log('\n🔄 Calling UserService.createUser...');
        const startTime = Date.now();
        
        const result = await UserService.createUser(testData);
        
        const duration = Date.now() - startTime;
        
        console.log('\n✅ SUCCESS! User created successfully');
        console.log(`⏱️ Execution time: ${duration}ms`);
        console.log('📄 Created user:');
        console.log({
            userId: result.Id,
            email: result.Email,
            fullName: result.Fullname,
            phone: result.Phone,
            role: result.Role,
            status: result.Status,
            balance: result.Balance
        });
        
        return true;
        
    } catch (error) {
        console.log('\n❌ FAILED! Error occurred:');
        console.error('Error message:', error.message);
        if (error.stack) {
            console.error('Stack trace:');
            console.error(error.stack);
        }
        return false;
    }
}

async function main() {
    console.log('='.repeat(70));
    console.log('🧪 USER CREATE TEST SCRIPT');
    console.log('='.repeat(70));
    
    let passCount = 0;
    let totalTests = 0;
    
    // Test 1: Create GUEST user
    totalTests++;
    console.log('\n📋 Test 1: Creating GUEST user...');
    const test1Success = await testCreateUser(testUserData, 'CREATE GUEST USER');
    if (test1Success) passCount++;
    
    // Wait before next test
    console.log('\n⏳ Waiting 3 seconds before next test...');
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Test 2: Create OWNER user  
    totalTests++;
    console.log('\n📋 Test 2: Creating OWNER user...');
    const test2Success = await testCreateUser(testOwnerData, 'CREATE OWNER USER');
    if (test2Success) passCount++;
    
    // Final results
    console.log('\n' + '='.repeat(70));
    console.log('🎯 FINAL RESULTS');
    console.log('='.repeat(70));
    console.log(`✅ Passed: ${passCount}/${totalTests}`);
    console.log(`❌ Failed: ${totalTests - passCount}/${totalTests}`);
    console.log(`📊 Success rate: ${((passCount/totalTests) * 100).toFixed(2)}%`);
    
    if (passCount === totalTests) {
        console.log('\n🎉 ALL TESTS PASSED!');
        process.exit(0);
    } else {
        console.log('\n⚠️ SOME TESTS FAILED!');
        process.exit(1);
    }
}

// Error handling
process.on('unhandledRejection', (reason, promise) => {
    console.error('🚨 Unhandled Rejection:', reason);
    process.exit(1);
});

process.on('uncaughtException', (error) => {
    console.error('🚨 Uncaught Exception:', error);
    process.exit(1);
});

// Run the test
main().catch(error => {
    console.error('🚨 Unexpected error:', error);
    process.exit(1);
});