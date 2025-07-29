/**
 * Firestore Database Seeding Script
 * Populates the database with sample data for development and testing
 * Following CLAUDE.md Firebase integration patterns
 */

const admin = require('firebase-admin');
const crypto = require('crypto');

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: process.env.FIREBASE_PROJECT_ID || 'quiz-app-dev'
  });
}

const db = admin.firestore();

// Sample data generators
function generateUserId() {
  return crypto.randomUUID();
}

function generateQuizId() {
  return crypto.randomUUID();
}

function generateSessionId() {
  return crypto.randomUUID();
}

function generateGamePin() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Sample users data
const sampleUsers = [
  {
    id: generateUserId(),
    name: 'John Doe',
    email: 'john.doe@example.com',
    createdAt: admin.firestore.Timestamp.now(),
    stats: {
      totalQuizzes: 5,
      totalGamesPlayed: 12,
      totalGamesWon: 3,
      averageScore: 85.5
    }
  },
  {
    id: generateUserId(),
    name: 'Jane Smith',
    email: 'jane.smith@example.com',
    createdAt: admin.firestore.Timestamp.now(),
    stats: {
      totalQuizzes: 8,
      totalGamesPlayed: 20,
      totalGamesWon: 7,
      averageScore: 92.3
    }
  },
  {
    id: generateUserId(),
    name: 'Mike Johnson',
    email: 'mike.johnson@example.com',
    createdAt: admin.firestore.Timestamp.now(),
    stats: {
      totalQuizzes: 3,
      totalGamesPlayed: 8,
      totalGamesWon: 1,
      averageScore: 78.2
    }
  }
];

// Sample quiz questions
const sampleQuestions = [
  {
    question: 'What is the capital of France?',
    options: ['London', 'Berlin', 'Paris', 'Madrid'],
    correctAnswer: 2,
    timeLimit: 30,
    points: 100
  },
  {
    question: 'Which planet is known as the Red Planet?',
    options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
    correctAnswer: 1,
    timeLimit: 25,
    points: 100
  },
  {
    question: 'What is 2 + 2?',
    options: ['3', '4', '5', '6'],
    correctAnswer: 1,
    timeLimit: 15,
    points: 50
  }
];

// Sample quizzes data
const sampleQuizzes = [
  {
    id: generateQuizId(),
    title: 'General Knowledge Quiz',
    description: 'Test your general knowledge with this fun quiz!',
    createdBy: sampleUsers[0].id,
    questions: sampleQuestions,
    isPublic: true,
    category: 'General Knowledge',
    estimatedDuration: 5,
    createdAt: admin.firestore.Timestamp.now()
  },
  {
    id: generateQuizId(),
    title: 'Science Basics',
    description: 'Basic science questions for everyone.',
    createdBy: sampleUsers[1].id,
    questions: [
      {
        question: 'What is H2O?',
        options: ['Hydrogen', 'Water', 'Oxygen', 'Carbon'],
        correctAnswer: 1,
        timeLimit: 20,
        points: 100
      },
      {
        question: 'How many bones are in the human body?',
        options: ['206', '208', '210', '212'],
        correctAnswer: 0,
        timeLimit: 30,
        points: 150
      }
    ],
    isPublic: true,
    category: 'Science',
    estimatedDuration: 3,
    createdAt: admin.firestore.Timestamp.now()
  },
  {
    id: generateQuizId(),
    title: 'Private Math Quiz',
    description: 'Advanced mathematics quiz.',
    createdBy: sampleUsers[2].id,
    questions: [
      {
        question: 'What is the derivative of x²?',
        options: ['x', '2x', 'x²', '2x²'],
        correctAnswer: 1,
        timeLimit: 45,
        points: 200
      }
    ],
    isPublic: false,
    category: 'Mathematics',
    estimatedDuration: 2,
    createdAt: admin.firestore.Timestamp.now()
  }
];

// Sample game sessions data
const sampleGameSessions = [
  {
    id: generateSessionId(),
    quizId: sampleQuizzes[0].id,
    hostId: sampleUsers[0].id,
    pin: generateGamePin(),
    status: 'waiting',
    players: {},
    currentQuestionIndex: 0,
    settings: {
      maxPlayers: 50,
      showCorrectAnswers: true,
      shuffleQuestions: false,
      allowReplay: true
    },
    createdAt: admin.firestore.Timestamp.now()
  },
  {
    id: generateSessionId(),
    quizId: sampleQuizzes[1].id,
    hostId: sampleUsers[1].id,
    pin: generateGamePin(),
    status: 'active',
    players: {
      [sampleUsers[2].id]: {
        name: 'Mike Johnson',
        joinedAt: admin.firestore.Timestamp.now(),
        score: 150,
        answers: [1, 0],
        isReady: true
      }
    },
    currentQuestionIndex: 1,
    settings: {
      maxPlayers: 30,
      showCorrectAnswers: false,
      shuffleQuestions: true,
      allowReplay: false
    },
    startedAt: admin.firestore.Timestamp.now(),
    createdAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 300000)) // 5 minutes ago
  },
  {
    id: generateSessionId(),
    quizId: sampleQuizzes[0].id,
    hostId: sampleUsers[0].id,
    pin: generateGamePin(),
    status: 'completed',
    players: {
      [sampleUsers[1].id]: {
        name: 'Jane Smith',
        joinedAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 900000)),
        score: 250,
        answers: [2, 1, 1],
        isReady: true
      },
      [sampleUsers[2].id]: {
        name: 'Mike Johnson',
        joinedAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 850000)),
        score: 150,
        answers: [2, 1, 0],
        isReady: true
      }
    },
    currentQuestionIndex: 3,
    settings: {
      maxPlayers: 50,
      showCorrectAnswers: true,
      shuffleQuestions: false,
      allowReplay: true
    },
    startedAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 900000)),
    completedAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 600000)),
    createdAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 1000000)) // ~16 minutes ago
  }
];

// Sample leaderboards data
const sampleLeaderboards = [
  {
    sessionId: sampleGameSessions[2].id, // completed session
    scores: [
      {
        playerId: sampleUsers[1].id,
        playerName: 'Jane Smith',
        score: 250,
        correctAnswers: 3,
        totalAnswers: 3,
        rank: 1,
        timeTaken: 120
      },
      {
        playerId: sampleUsers[2].id,
        playerName: 'Mike Johnson',
        score: 150,
        correctAnswers: 2,
        totalAnswers: 3,
        rank: 2,
        timeTaken: 135
      }
    ],
    finalResults: true,
    updatedAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 600000))
  }
];

// Seeding functions
async function seedUsers() {
  console.log('🌱 Seeding users...');
  const batch = db.batch();
  
  for (const user of sampleUsers) {
    const userRef = db.collection('users').doc(user.id);
    const { id, ...userData } = user;
    batch.set(userRef, userData);
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${sampleUsers.length} users`);
}

async function seedQuizzes() {
  console.log('🌱 Seeding quizzes...');
  const batch = db.batch();
  
  for (const quiz of sampleQuizzes) {
    const quizRef = db.collection('quizzes').doc(quiz.id);
    const { id, ...quizData } = quiz;
    batch.set(quizRef, quizData);
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${sampleQuizzes.length} quizzes`);
}

async function seedGameSessions() {
  console.log('🌱 Seeding game sessions...');
  const batch = db.batch();
  
  for (const session of sampleGameSessions) {
    const sessionRef = db.collection('game_sessions').doc(session.id);
    const { id, ...sessionData } = session;
    batch.set(sessionRef, sessionData);
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${sampleGameSessions.length} game sessions`);
}

async function seedLeaderboards() {
  console.log('🌱 Seeding leaderboards...');
  const batch = db.batch();
  
  for (const leaderboard of sampleLeaderboards) {
    const leaderboardRef = db.collection('leaderboards').doc(leaderboard.sessionId);
    const { sessionId, ...leaderboardData } = leaderboard;
    batch.set(leaderboardRef, leaderboardData);
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${sampleLeaderboards.length} leaderboards`);
}

async function clearCollection(collectionName) {
  console.log(`🧹 Clearing ${collectionName} collection...`);
  const snapshot = await db.collection(collectionName).get();
  const batch = db.batch();
  
  snapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  if (!snapshot.empty) {
    await batch.commit();
    console.log(`✅ Cleared ${snapshot.size} documents from ${collectionName}`);
  } else {
    console.log(`📝 ${collectionName} collection was already empty`);
  }
}

async function seedDatabase() {
  try {
    console.log('🚀 Starting Firestore database seeding...');
    console.log(`📊 Project ID: ${admin.app().options.projectId}`);
    
    // Clear existing data
    if (process.argv.includes('--clear')) {
      await clearCollection('leaderboards');
      await clearCollection('game_sessions');
      await clearCollection('quizzes');
      await clearCollection('users');
    }
    
    // Seed new data
    await seedUsers();
    await seedQuizzes();
    await seedGameSessions();
    await seedLeaderboards();
    
    console.log('✅ Database seeding completed successfully!');
    console.log('\n📋 Summary:');
    console.log(`   • Users: ${sampleUsers.length}`);
    console.log(`   • Quizzes: ${sampleQuizzes.length}`);
    console.log(`   • Game Sessions: ${sampleGameSessions.length}`);
    console.log(`   • Leaderboards: ${sampleLeaderboards.length}`);
    console.log('\n🎮 You can now test the application with sample data!');
    
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

// Command line usage
if (require.main === module) {
  seedDatabase().then(() => {
    process.exit(0);
  });
}

module.exports = {
  seedDatabase,
  sampleUsers,
  sampleQuizzes,
  sampleGameSessions,
  sampleLeaderboards
};