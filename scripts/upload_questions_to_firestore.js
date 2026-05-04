const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const questionsPath = path.join(__dirname, '..', 'questions.json');
const collectionName = process.env.FIRESTORE_COLLECTION || 'questions';
const serviceAccountPath =
  process.env.GOOGLE_APPLICATION_CREDENTIALS ||
  path.join(__dirname, '..', 'serviceAccountKey.json');

function slugify(value) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 80);
}

function loadServiceAccount() {
  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(
      `Missing Firebase service account file.\n` +
        `Expected: ${serviceAccountPath}\n` +
        `Set GOOGLE_APPLICATION_CREDENTIALS or place serviceAccountKey.json in the project root.`
    );
  }

  return require(serviceAccountPath);
}

function loadQuestions() {
  if (!fs.existsSync(questionsPath)) {
    throw new Error(`questions.json was not found at ${questionsPath}`);
  }

  const questions = JSON.parse(fs.readFileSync(questionsPath, 'utf8'));

  if (!Array.isArray(questions)) {
    throw new Error('questions.json must contain an array of question objects.');
  }

  return questions;
}

function validateQuestion(question, index) {
  const location = `Question #${index + 1}`;

  if (typeof question.question !== 'string' || question.question.trim() === '') {
    throw new Error(`${location} is missing a question string.`);
  }

  if (!Array.isArray(question.options) || question.options.length !== 4) {
    throw new Error(`${location} must have exactly 4 options.`);
  }

  if (!Number.isInteger(question.answerIndex)) {
    throw new Error(`${location} must have an integer answerIndex.`);
  }

  if (question.answerIndex < 0 || question.answerIndex >= question.options.length) {
    throw new Error(`${location} has an answerIndex outside the options range.`);
  }

  if (typeof question.category !== 'string' || question.category.trim() === '') {
    throw new Error(`${location} is missing a category string.`);
  }

  if (typeof question.difficulty !== 'string' || question.difficulty.trim() === '') {
    throw new Error(`${location} is missing a difficulty string.`);
  }

  if (typeof question.isActive !== 'boolean') {
    throw new Error(`${location} must have a boolean isActive value.`);
  }
}

async function uploadQuestions() {
  const serviceAccount = loadServiceAccount();

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  const db = admin.firestore();
  const questions = loadQuestions();
  const batchSize = 450;

  let batch = db.batch();
  let operationsInBatch = 0;
  let uploadedCount = 0;

  for (const [index, question] of questions.entries()) {
    validateQuestion(question, index);

    const documentId = `${String(index + 1).padStart(3, '0')}-${slugify(
      question.question
    )}`;
    const documentReference = db.collection(collectionName).doc(documentId);

    batch.set(
      documentReference,
      {
        question: question.question.trim(),
        options: question.options,
        answerIndex: question.answerIndex,
        category: question.category,
        difficulty: question.difficulty.toLowerCase(),
        isActive: question.isActive,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    operationsInBatch++;
    uploadedCount++;

    if (operationsInBatch === batchSize) {
      await batch.commit();
      batch = db.batch();
      operationsInBatch = 0;
    }
  }

  if (operationsInBatch > 0) {
    await batch.commit();
  }

  console.log(
    `Uploaded ${uploadedCount} questions to Firestore collection "${collectionName}".`
  );
}

uploadQuestions()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
