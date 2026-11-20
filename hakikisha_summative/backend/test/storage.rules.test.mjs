// Cloud Storage security rules tests. Run from backend/: `npm test`.
import { after, before, beforeEach, describe, test } from 'node:test';
import { readFile } from 'node:fs/promises';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-hakikisha',
    storage: {
      rules: await readFile(new URL('../../storage.rules', import.meta.url), 'utf8'),
    },
  });
});

after(() => env.cleanup());
beforeEach(() => env.clearStorage());

const storageAs = (uid) => env.authenticatedContext(uid).storage();
const image = (bytes = 1024) => [new Uint8Array(bytes), { contentType: 'image/jpeg' }];

describe('report photos', () => {
  const path = 'reports/alice/r1/front.jpg';

  test('owner can upload, read and delete', async () => {
    const file = ref(storageAs('alice'), path);
    await assertSucceeds(uploadBytes(file, ...image()));
    await assertSucceeds(getBytes(file));
    await assertSucceeds(deleteObject(file));
  });

  test("others cannot read or write someone's photos", async () => {
    await assertSucceeds(uploadBytes(ref(storageAs('alice'), path), ...image()));
    await assertFails(getBytes(ref(storageAs('bob'), path)));
    await assertFails(uploadBytes(ref(storageAs('bob'), path), ...image()));
    await assertFails(getBytes(ref(env.unauthenticatedContext().storage(), path)));
  });

  test('only images under 5 MB are accepted', async () => {
    const file = ref(storageAs('alice'), path);
    await assertFails(uploadBytes(file, new Uint8Array(10), { contentType: 'application/pdf' }));
    await assertFails(uploadBytes(file, ...image(6 * 1024 * 1024)));
  });
});

describe('profile photos', () => {
  test('only the owner can set their avatar', async () => {
    const path = 'users/alice/avatar/me.jpg';
    await assertSucceeds(uploadBytes(ref(storageAs('alice'), path), ...image()));
    await assertFails(uploadBytes(ref(storageAs('bob'), path), ...image()));
  });
});

test('paths outside the contract are locked', async () => {
  await assertFails(uploadBytes(ref(storageAs('alice'), 'public/anything.jpg'), ...image()));
});
