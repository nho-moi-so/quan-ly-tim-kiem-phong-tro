const path = require('path');

// Setup environment giống như trong API route
const projectRoot = path.resolve(__dirname, '..', '..');
process.chdir(projectRoot);
require('dotenv').config({ path: path.join(projectRoot, '.env') });

// Setup TypeScript cho Next.js API
process.env.TS_NODE_PROJECT = path.resolve(__dirname, '..', '..', 'tsconfig.json'); // Dùng tsconfig.json thay vì tsconfig.server.json
process.env.TS_NODE_COMPILER_OPTIONS = JSON.stringify({
    module: 'commonjs',
    moduleResolution: 'node',
    allowSyntheticDefaultImports: true,
    esModuleInterop: true
});
require('ts-node/register/transpile-only');
require('tsconfig-paths/register');

// Test data giống hệt API request
const apiTestData = {
    balance: 100000,
    cccd: "123456789012",
    email: "guest32131@example.com",
    fullName: "Nguyen Van B", 
    password: "123456",
    phone: "0901234567",
    role: "GUEST",
    status: "ACTIVE"
};

async function debugAPIContext() {
    console.log('🔍 DEBUG: API Context Test');
    console.log('='.repeat(50));
    
    try {
        // Test 1: Environment variables
        console.log('\n📦 Step 1: Checking environment...');
        console.log('NODE_ENV:', process.env.NODE_ENV || 'undefined');
        console.log('FIREBASE_PROJECT_ID:', process.env.FIREBASE_PROJECT_ID ? 'SET' : 'MISSING');
        console.log('PWD:', process.cwd());
        
        // Test 2: Import UserService (như API route)
        console.log('\n📦 Step 2: Importing UserService...');
        const { UserService } = require('../services/userService');
        console.log('✅ UserService imported successfully');
        
        // Test 3: Schema validation (như API route)
        console.log('\n📦 Step 3: Testing Zod validation...');
        const z = require('zod');
        const CreateUserSchema = z.object({
            balance: z.number().min(0).default(0),
            cccd: z.string().min(9).max(12).optional(),
            email: z.string().email(),
            fullName: z.string().min(1),
            password: z.string().min(6),
            phone: z.string().min(10).max(15),
            role: z.enum(['GUEST', 'OWNER', 'ADMIN']),
            status: z.string().default("ACTIVE")
        });
        
        const parsedData = CreateUserSchema.parse(apiTestData);
        console.log('✅ Schema validation passed');
        console.log('📄 Parsed data:', JSON.stringify(parsedData, null, 2));
        
        // Test 4: Call UserService (như API route)
        console.log('\n📦 Step 4: Calling UserService.createUser...');
        const startTime = Date.now();
        
        const result = await UserService.createUser(parsedData);
        
        const duration = Date.now() - startTime;
        console.log('✅ UserService.createUser succeeded!');
        console.log(`⏱️ Duration: ${duration}ms`);
        console.log('📄 Result:', {
            userId: result.Id,
            email: result.Email,
            fullName: result.Fullname,
            role: result.Role,
            status: result.Status
        });
        
        return true;
        
    } catch (error) {
        console.log('\n❌ ERROR in API context test:');
        console.error('Message:', error.message);
        if (error.stack) {
            console.error('\nStack trace:');
            console.error(error.stack);
        }
        return false;
    }
}

async function main() {
    console.log('🧪 API CONTEXT DEBUG TEST');
    console.log('Testing the exact same flow as Next.js API route');
    console.log('='.repeat(60));
    
    const success = await debugAPIContext();
    
    console.log('\n' + '='.repeat(60));
    if (success) {
        console.log('✅ API context works! Problem might be elsewhere.');
    } else {
        console.log('❌ Found issue in API context!');
    }
}

// Error handling
process.on('unhandledRejection', (reason, promise) => {
    console.error('🚨 Unhandled Rejection:', reason);
    process.exit(1);
});

main().catch(console.error);