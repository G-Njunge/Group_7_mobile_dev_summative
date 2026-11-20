// Firestore security rules tests. Run from backend/: `npm test`
// (starts the emulator, runs these, shuts it down).
import { after, before, beforeEach, describe, test } from 'node:test';
import { readFile } from 'node:fs/promises';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

const ALICE = 'alice';
const BOB = 'bob';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-hakikisha',
    firestore: {
      rules: await readFile(new URL('../../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(() => env.cleanup());
beforeEach(() => env.clearFirestore());

const dbAs = (uid) => env.authenticatedContext(uid).firestore();
const anonDb = () => env.unauthenticatedContext().firestore();

/** Writes test fixtures with rules disabled. */
const seed = (path, data) =>
  env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));

const newUser = (uid, overrides = {}) => ({
  uid,
  fullName: 'Amina Wanjiru',
  email: `${uid}@example.com`,
  phone: '+254700000000',
  authProvider: 'password',
  photoUrl: null,
  createdAt: serverTimestamp(),
  ...overrides,
});

const newScan = (userId, overrides = {}) => ({
  userId,
  batchId: 'bat_pa24_1150',
  result: 'genuine',
  method: 'camera',
  scannedAt: serverTimestamp(),
  ...overrides,
});

const newReport = (userId, overrides = {}) => ({
  userId,
  scanId: null,
  pharmacyId: 'ph_goodlife_westlands',
  description: 'Seal was broken and the colour looked wrong.',
  photoUrls: [],
  status: 'pending',
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...overrides,
});

describe('users', () => {
  test('a user can create their own profile with the contract fields', async () => {
    await assertSucceeds(setDoc(doc(dbAs(ALICE), 'users', ALICE), newUser(ALICE)));
  });

  test('a Google user without a phone can register', async () => {
    const { phone, ...noPhone } = newUser(ALICE, { authProvider: 'google' });
    await assertSucceeds(setDoc(doc(dbAs(ALICE), 'users', ALICE), noPhone));
  });

  test('nobody can create a profile for someone else', async () => {
    await assertFails(setDoc(doc(dbAs(BOB), 'users', ALICE), newUser(ALICE)));
  });

  test('the uid field must match the document id', async () => {
    await assertFails(setDoc(doc(dbAs(ALICE), 'users', ALICE), newUser(BOB)));
  });

  test('extra fields, bad enums and client timestamps are rejected', async () => {
    const ref = doc(dbAs(ALICE), 'users', ALICE);
    await assertFails(setDoc(ref, newUser(ALICE, { isAdmin: true })));
    await assertFails(setDoc(ref, newUser(ALICE, { authProvider: 'facebook' })));
    await assertFails(setDoc(ref, newUser(ALICE, { fullName: '' })));
    await assertFails(setDoc(ref, newUser(ALICE, { createdAt: new Date(0) })));
  });

  test('owner can read, update and delete; others cannot read', async () => {
    await seed(`users/${ALICE}`, { ...newUser(ALICE), createdAt: new Date() });
    await assertSucceeds(getDoc(doc(dbAs(ALICE), 'users', ALICE)));
    await assertFails(getDoc(doc(dbAs(BOB), 'users', ALICE)));
    await assertFails(getDoc(doc(anonDb(), 'users', ALICE)));
    await assertSucceeds(
      updateDoc(doc(dbAs(ALICE), 'users', ALICE), { fullName: 'Amina W.', phone: null }),
    );
    await assertFails(updateDoc(doc(dbAs(BOB), 'users', ALICE), { fullName: 'Hacked' }));
    await assertSucceeds(deleteDoc(doc(dbAs(ALICE), 'users', ALICE)));
  });

  test('email, provider and createdAt cannot be changed', async () => {
    await seed(`users/${ALICE}`, { ...newUser(ALICE), createdAt: new Date() });
    const ref = doc(dbAs(ALICE), 'users', ALICE);
    await assertFails(updateDoc(ref, { email: 'new@example.com' }));
    await assertFails(updateDoc(ref, { authProvider: 'google' }));
    await assertFails(updateDoc(ref, { createdAt: new Date() }));
  });
});

describe('reference data (medicines, batches, pharmacies)', () => {
  for (const name of ['medicines', 'batches', 'pharmacies']) {
    test(`${name}: signed-in read only, no client writes`, async () => {
      await seed(`${name}/x`, { name: 'seeded' });
      await assertSucceeds(getDoc(doc(dbAs(ALICE), name, 'x')));
      await assertFails(getDoc(doc(anonDb(), name, 'x')));
      await assertFails(setDoc(doc(dbAs(ALICE), name, 'y'), { name: 'fake' }));
      await assertFails(updateDoc(doc(dbAs(ALICE), name, 'x'), { name: 'fake' }));
      await assertFails(deleteDoc(doc(dbAs(ALICE), name, 'x')));
    });
  }
});

describe('scans', () => {
  test('a user can log their own scan, including "not found"', async () => {
    const scans = collection(dbAs(ALICE), 'scans');
    await assertSucceeds(addDoc(scans, newScan(ALICE)));
    await assertSucceeds(addDoc(scans, newScan(ALICE, { batchId: null, result: 'notFound' })));
    const { batchId, ...noBatch } = newScan(ALICE, { result: 'notFound', method: 'manual' });
    await assertSucceeds(addDoc(scans, noBatch));
  });

  test('cannot log a scan as someone else or with invalid values', async () => {
    const scans = collection(dbAs(ALICE), 'scans');
    await assertFails(addDoc(scans, newScan(BOB)));
    await assertFails(addDoc(scans, newScan(ALICE, { result: 'fake' })));
    await assertFails(addDoc(scans, newScan(ALICE, { method: 'telepathy' })));
    await assertFails(addDoc(scans, newScan(ALICE, { scannedAt: new Date(0) })));
    await assertFails(addDoc(scans, newScan(ALICE, { medicineName: 'duplicated data' })));
  });

  test('read and delete own only; never update', async () => {
    await seed('scans/s1', { ...newScan(ALICE), scannedAt: new Date() });
    await assertSucceeds(getDoc(doc(dbAs(ALICE), 'scans', 's1')));
    await assertFails(getDoc(doc(dbAs(BOB), 'scans', 's1')));
    await assertFails(updateDoc(doc(dbAs(ALICE), 'scans', 's1'), { result: 'flagged' }));
    await assertFails(deleteDoc(doc(dbAs(BOB), 'scans', 's1')));
    await assertSucceeds(deleteDoc(doc(dbAs(ALICE), 'scans', 's1')));
  });

  test('history query must be scoped to the signed-in user', async () => {
    const scans = collection(dbAs(ALICE), 'scans');
    await assertSucceeds(getDocs(query(scans, where('userId', '==', ALICE))));
    await assertFails(getDocs(query(scans, where('userId', '==', BOB))));
    await assertFails(getDocs(scans));
  });
});

describe('reports', () => {
  test('a user can file a pending report with up to 3 photos', async () => {
    const reports = collection(dbAs(ALICE), 'reports');
    await assertSucceeds(addDoc(reports, newReport(ALICE)));
    await assertSucceeds(
      addDoc(reports, newReport(ALICE, { photoUrls: ['a', 'b', 'c'], pharmacyId: null })),
    );
  });

  test('rejects reports for others, pre-reviewed, empty, or with too many photos', async () => {
    const reports = collection(dbAs(ALICE), 'reports');
    await assertFails(addDoc(reports, newReport(BOB)));
    await assertFails(addDoc(reports, newReport(ALICE, { status: 'reviewed' })));
    await assertFails(addDoc(reports, newReport(ALICE, { description: '' })));
    await assertFails(addDoc(reports, newReport(ALICE, { photoUrls: ['1', '2', '3', '4'] })));
  });

  const pending = () => ({
    ...newReport(ALICE),
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  test('owner can edit and withdraw while pending', async () => {
    await seed('reports/r1', pending());
    const ref = doc(dbAs(ALICE), 'reports', 'r1');
    await assertSucceeds(
      updateDoc(ref, { description: 'Updated details about the pack.', updatedAt: serverTimestamp() }),
    );
    await assertSucceeds(deleteDoc(ref));
  });

  test('edits must refresh updatedAt and keep owner, createdAt and status', async () => {
    await seed('reports/r1', pending());
    const ref = doc(dbAs(ALICE), 'reports', 'r1');
    await assertFails(updateDoc(ref, { description: 'No timestamp bump' }));
    await assertFails(updateDoc(ref, { userId: BOB, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { status: 'reviewed', updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { createdAt: new Date(0), updatedAt: serverTimestamp() }));
  });

  test('a reviewed report is locked', async () => {
    await seed('reports/r1', { ...pending(), status: 'reviewed' });
    const ref = doc(dbAs(ALICE), 'reports', 'r1');
    await assertSucceeds(getDoc(ref));
    await assertFails(updateDoc(ref, { description: 'Too late', updatedAt: serverTimestamp() }));
    await assertFails(deleteDoc(ref));
  });

  test("other users cannot see or touch someone's report", async () => {
    await seed('reports/r1', pending());
    const ref = doc(dbAs(BOB), 'reports', 'r1');
    await assertFails(getDoc(ref));
    await assertFails(deleteDoc(ref));
  });
});

describe('everything else', () => {
  test('unknown collections are locked', async () => {
    await assertFails(setDoc(doc(dbAs(ALICE), 'admin', 'config'), { open: true }));
    await assertFails(getDoc(doc(dbAs(ALICE), 'admin', 'config')));
  });
});
