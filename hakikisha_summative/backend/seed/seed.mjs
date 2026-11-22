// Seeds the read-only reference collections (medicines, batches, pharmacies).
//
// Clients can't write these collections (see firestore.rules), so seeding
// uses the Admin SDK, which bypasses rules.
//
//   Emulator:  npm run seed:emulator
//   Real project (needs a service-account key, never commit it):
//     GOOGLE_APPLICATION_CREDENTIALS=path/to/key.json npm run seed
//
// Safe to re-run: documents use fixed IDs, so a second run overwrites rather
// than duplicates.
import { readFile } from 'node:fs/promises';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';

const projectId = process.env.GCLOUD_PROJECT ?? 'hakikisha-acd9a';
const data = JSON.parse(
  await readFile(new URL('./seed-data.json', import.meta.url), 'utf8'),
);

initializeApp({ projectId });
const db = getFirestore();

// Collection name -> field holding the document ID.
const collections = {
  medicines: 'medicineId',
  batches: 'batchId',
  pharmacies: 'pharmacyId',
};

const batch = db.batch();
for (const [collection, idField] of Object.entries(collections)) {
  for (const doc of data[collection]) {
    const fields = { ...doc };
    if (fields.expiryDate) {
      fields.expiryDate = Timestamp.fromDate(new Date(`${fields.expiryDate}T23:59:59Z`));
    }
    batch.set(db.collection(collection).doc(doc[idField]), fields);
  }
  console.log(`${collection}: ${data[collection].length} docs`);
}
await batch.commit();
console.log(`Seeded project "${projectId}".`);
