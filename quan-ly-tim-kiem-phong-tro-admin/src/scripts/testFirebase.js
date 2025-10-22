// scripts/testFirebase.js
// Node.js CommonJS script to quickly test Firestore connection using firebase-admin.
// Usage (from project root):
//   node src\\scripts\\testFirebase.js

const fs = require('fs');
const path = require('path');

// Load .env if present
try {
  require('dotenv').config();
} catch (e) {
  // dotenv is optional; if not installed, env vars or service account file must be provided
}

let admin;
try {
  admin = require('firebase-admin');
} catch (e) {
  console.error('Please install firebase-admin: npm install firebase-admin');
  process.exit(1);
}

function loadServiceAccountFromFile() {
  try {
    const file = path.resolve(process.cwd(), 'firebase-service-account.json');
    if (fs.existsSync(file)) {
      const content = fs.readFileSync(file, 'utf8');
      const parsed = JSON.parse(content);
      return {
        projectId: parsed.project_id || parsed.projectId,
        clientEmail: parsed.client_email || parsed.clientEmail,
        privateKey: parsed.private_key || parsed.privateKey,
      };
    }
  } catch (err) {
    // ignore
  }
  return null;
}

const serviceAccountFromFile = loadServiceAccountFromFile();

const projectId = process.env.FIREBASE_PROJECT_ID;
const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
const privateKeyRaw = process.env.FIREBASE_PRIVATE_KEY;

let credentialConfig;
if (serviceAccountFromFile) {
  credentialConfig = serviceAccountFromFile;
} else if (projectId && clientEmail && privateKeyRaw) {
  credentialConfig = {
    projectId,
    clientEmail,
    privateKey: privateKeyRaw.replace(/\\n/g, '\n'),
  };
}

if (!admin.apps.length) {
  if (!credentialConfig) {
    try {
      admin.initializeApp();
      console.log('Initialized firebase-admin using Application Default Credentials');
    } catch (err) {
      console.error("Firebase Admin initialization failed. Provide 'firebase-service-account.json' at project root or set FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY environment variables.");
      console.error(err && err.message ? err.message : err);
      process.exit(1);
    }
  } else {
    admin.initializeApp({
      credential: admin.credential.cert(credentialConfig),
    });
    console.log('Initialized firebase-admin using provided service account credentials');
  }
}

const db = admin.firestore();

async function testFirestoreConnection() {
  try {
    const docRef = await db.collection('message').add({
      message: 'Hello from Node.js + Firebase Admin!',
      createdAt: new Date(),
    });
    console.log('✅ Added document with ID:', docRef.id);

    const doc = await docRef.get();
    console.log('📄 Document data:', doc.data());
    process.exit(0);
  } catch (error) {
    console.error('❌ Firestore connection failed:', error && error.message ? error.message : error);
    console.error('Ensure FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY are set, or place firebase-service-account.json at project root.');
    process.exit(1);
  }
}

testFirestoreConnection();
