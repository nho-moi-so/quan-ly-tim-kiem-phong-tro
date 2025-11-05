// lib/firebase/admin.ts
import dotenv from "dotenv";
import admin from "firebase-admin";
import fs from "fs";
import path from "path";

// Load .env for local development
dotenv.config();

function loadServiceAccountFromFile(): admin.ServiceAccount | null {
  try {
    const file = path.resolve(process.cwd(), "firebase-service-account.json");
    if (fs.existsSync(file)) {
      const content = fs.readFileSync(file, "utf8");
      const parsed = JSON.parse(content);
      return {
        projectId: parsed.project_id || parsed.projectId,
        clientEmail: parsed.client_email || parsed.clientEmail,
        privateKey: parsed.private_key || parsed.privateKey,
      } as admin.ServiceAccount;
    }
  } catch (e) {
    // ignore and fallback to env
  }
  return null;
}

const serviceAccountFromFile = loadServiceAccountFromFile();

if (!admin.apps.length) {
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKeyRaw = process.env.FIREBASE_PRIVATE_KEY;

  let credentialConfig: admin.ServiceAccount | undefined;

  if (serviceAccountFromFile) {
    credentialConfig = serviceAccountFromFile;
  } else if (projectId && clientEmail && privateKeyRaw) {
    credentialConfig = {
      projectId,
      clientEmail,
      privateKey: privateKeyRaw.replace(/\\n/g, "\n"),
    } as admin.ServiceAccount;
  }

  if (!credentialConfig) {
    try {
      // Try to initialize with Application Default Credentials / environment (if available)
      admin.initializeApp();
    } catch (err) {
      console.error(
        "Firebase Admin initialization failed. Provide a service account file 'firebase-service-account.json' at project root or set FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY environment variables."
      );
      throw err;
    }
  } else {
    admin.initializeApp({
      credential: admin.credential.cert(credentialConfig),
    });
  }
}

export const db = admin.firestore();
