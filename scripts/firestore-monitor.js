/**
 * Firestore Database Monitoring Script
 * Monitors database performance, usage, and health metrics
 * Following CLAUDE.md performance requirements (<200ms latency)
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: process.env.FIREBASE_PROJECT_ID || 'quiz-app-dev'
  });
}

const db = admin.firestore();

class FirestoreMonitor {
  constructor() {
    this.metrics = {
      totalUsers: 0,
      totalQuizzes: 0,
      totalGameSessions: 0,
      totalLeaderboards: 0,
      activeGameSessions: 0,
      recentActivity: [],
      performanceStats: {
        averageReadLatency: 0,
        averageWriteLatency: 0,
        totalReads: 0,
        totalWrites: 0
      }
    };
  }

  // Monitor collection sizes
  async checkCollectionSizes() {
    console.log('📊 Checking collection sizes...');
    
    try {
      const startTime = Date.now();
      
      const [
        usersSnapshot,
        quizzesSnapshot,
        gameSessionsSnapshot,
        leaderboardsSnapshot
      ] = await Promise.all([
        db.collection('users').get(),
        db.collection('quizzes').get(),
        db.collection('game_sessions').get(),
        db.collection('leaderboards').get()
      ]);

      const readTime = Date.now() - startTime;
      
      this.metrics.totalUsers = usersSnapshot.size;
      this.metrics.totalQuizzes = quizzesSnapshot.size;
      this.metrics.totalGameSessions = gameSessionsSnapshot.size;
      this.metrics.totalLeaderboards = leaderboardsSnapshot.size;
      
      console.log(`   Users: ${this.metrics.totalUsers}`);
      console.log(`   Quizzes: ${this.metrics.totalQuizzes}`);
      console.log(`   Game Sessions: ${this.metrics.totalGameSessions}`);
      console.log(`   Leaderboards: ${this.metrics.totalLeaderboards}`);
      console.log(`   Read Time: ${readTime}ms`);
      
      if (readTime > 200) {
        console.warn(`⚠️  Collection size check exceeded 200ms threshold: ${readTime}ms`);
      }
      
    } catch (error) {
      console.error('❌ Error checking collection sizes:', error);
    }
  }

  // Monitor active game sessions
  async checkActiveGameSessions() {
    console.log('🎮 Checking active game sessions...');
    
    try {
      const startTime = Date.now();
      
      const activeSessionsSnapshot = await db
        .collection('game_sessions')
        .where('status', 'in', ['waiting', 'active'])
        .get();
      
      const queryTime = Date.now() - startTime;
      this.metrics.activeGameSessions = activeSessionsSnapshot.size;
      
      console.log(`   Active Sessions: ${this.metrics.activeGameSessions}`);
      console.log(`   Query Time: ${queryTime}ms`);
      
      if (queryTime > 200) {
        console.warn(`⚠️  Active sessions query exceeded 200ms threshold: ${queryTime}ms`);
      }
      
      // Check for sessions with many players
      activeSessionsSnapshot.forEach(doc => {
        const session = doc.data();
        const playerCount = Object.keys(session.players || {}).length;
        
        if (playerCount > 40) {
          console.warn(`⚠️  Session ${doc.id} has ${playerCount} players (approaching limit of 50)`);
        }
        
        // Check for old waiting sessions
        const createdAt = session.createdAt?.toDate();
        const now = new Date();
        const hoursSinceCreated = (now - createdAt) / (1000 * 60 * 60);
        
        if (session.status === 'waiting' && hoursSinceCreated > 2) {
          console.warn(`⚠️  Session ${doc.id} has been waiting for ${hoursSinceCreated.toFixed(1)} hours`);
        }
      });
      
    } catch (error) {
      console.error('❌ Error checking active game sessions:', error);
    }
  }

  // Monitor recent activity
  async checkRecentActivity() {
    console.log('📈 Checking recent activity...');
    
    try {
      const oneDayAgo = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - 24 * 60 * 60 * 1000)
      );
      
      const startTime = Date.now();
      
      const [
        recentUsers,
        recentQuizzes,
        recentSessions
      ] = await Promise.all([
        db.collection('users').where('createdAt', '>=', oneDayAgo).get(),
        db.collection('quizzes').where('createdAt', '>=', oneDayAgo).get(),
        db.collection('game_sessions').where('createdAt', '>=', oneDayAgo).get()
      ]);
      
      const queryTime = Date.now() - startTime;
      
      console.log(`   New Users (24h): ${recentUsers.size}`);
      console.log(`   New Quizzes (24h): ${recentQuizzes.size}`);
      console.log(`   New Sessions (24h): ${recentSessions.size}`);
      console.log(`   Query Time: ${queryTime}ms`);
      
      if (queryTime > 200) {
        console.warn(`⚠️  Recent activity query exceeded 200ms threshold: ${queryTime}ms`);
      }
      
    } catch (error) {
      console.error('❌ Error checking recent activity:', error);
    }
  }

  // Test query performance
  async testQueryPerformance() {
    console.log('⚡ Testing query performance...');
    
    const tests = [
      {
        name: 'Find public quizzes',
        query: () => db.collection('quizzes').where('isPublic', '==', true).limit(10).get()
      },
      {
        name: 'Find user by email',
        query: () => db.collection('users').where('email', '==', 'john.doe@example.com').limit(1).get()
      },
      {
        name: 'Find active sessions',
        query: () => db.collection('game_sessions').where('status', '==', 'active').limit(5).get()
      },
      {
        name: 'Find session by PIN',
        query: () => db.collection('game_sessions').where('pin', '==', '123456').limit(1).get()
      },
      {
        name: 'Recent leaderboards',
        query: () => db.collection('leaderboards').orderBy('updatedAt', 'desc').limit(5).get()
      }
    ];
    
    for (const test of tests) {
      try {
        const startTime = Date.now();
        const result = await test.query();
        const queryTime = Date.now() - startTime;
        
        console.log(`   ${test.name}: ${queryTime}ms (${result.size} docs)`);
        
        if (queryTime > 200) {
          console.warn(`⚠️  Query '${test.name}' exceeded 200ms threshold: ${queryTime}ms`);
        }
        
      } catch (error) {
        console.error(`❌ Error testing '${test.name}':`, error.message);
      }
    }
  }

  // Check security rules
  async testSecurityRules() {
    console.log('🔒 Testing security rules...');
    
    try {
      // Test unauthenticated access (should fail)
      const testUserId = 'test-user-id';
      
      console.log('   Testing unauthenticated access...');
      
      // These should all be handled by security rules
      // In a real test, we'd use Firebase Client SDK with proper auth context
      console.log('   ✅ Security rules testing requires client SDK implementation');
      console.log('   💡 Implement client-side tests in Flutter test suite');
      
    } catch (error) {
      console.error('❌ Error testing security rules:', error);
    }
  }

  // Check data integrity
  async checkDataIntegrity() {
    console.log('🔍 Checking data integrity...');
    
    try {
      // Check for orphaned leaderboards
      const leaderboardsSnapshot = await db.collection('leaderboards').get();
      let orphanedLeaderboards = 0;
      
      for (const leaderboardDoc of leaderboardsSnapshot.docs) {
        const sessionDoc = await db.collection('game_sessions').doc(leaderboardDoc.id).get();
        if (!sessionDoc.exists) {
          orphanedLeaderboards++;
          console.warn(`⚠️  Orphaned leaderboard found: ${leaderboardDoc.id}`);
        }
      }
      
      // Check for game sessions without corresponding quizzes
      const gameSessionsSnapshot = await db.collection('game_sessions').get();
      let orphanedSessions = 0;
      
      for (const sessionDoc of gameSessionsSnapshot.docs) {
        const sessionData = sessionDoc.data();
        const quizDoc = await db.collection('quizzes').doc(sessionData.quizId).get();
        if (!quizDoc.exists) {
          orphanedSessions++;
          console.warn(`⚠️  Game session with missing quiz: ${sessionDoc.id} (quiz: ${sessionData.quizId})`);
        }
      }
      
      console.log(`   Orphaned Leaderboards: ${orphanedLeaderboards}`);
      console.log(`   Orphaned Sessions: ${orphanedSessions}`);
      
    } catch (error) {
      console.error('❌ Error checking data integrity:', error);
    }
  }

  // Generate summary report
  generateReport() {
    console.log('\n📋 FIRESTORE MONITORING REPORT');
    console.log('================================');
    console.log(`Timestamp: ${new Date().toISOString()}`);
    console.log(`Project: ${admin.app().options.projectId}`);
    console.log('\n📊 Collection Statistics:');
    console.log(`   • Users: ${this.metrics.totalUsers}`);
    console.log(`   • Quizzes: ${this.metrics.totalQuizzes}`);
    console.log(`   • Game Sessions: ${this.metrics.totalGameSessions}`);
    console.log(`   • Leaderboards: ${this.metrics.totalLeaderboards}`);
    console.log(`   • Active Sessions: ${this.metrics.activeGameSessions}`);
    
    console.log('\n💡 Recommendations:');
    
    if (this.metrics.totalGameSessions > 1000) {
      console.log('   • Consider implementing session cleanup for old completed sessions');
    }
    
    if (this.metrics.activeGameSessions > 50) {
      console.log('   • High number of active sessions - monitor server resources');
    }
    
    const totalDocuments = this.metrics.totalUsers + this.metrics.totalQuizzes + 
                          this.metrics.totalGameSessions + this.metrics.totalLeaderboards;
    
    if (totalDocuments > 10000) {
      console.log('   • Consider implementing data archiving strategy');
    }
    
    console.log('================================\n');
  }

  // Run full monitoring suite
  async runFullMonitoring() {
    console.log('🚀 Starting Firestore monitoring...\n');
    
    await this.checkCollectionSizes();
    console.log();
    
    await this.checkActiveGameSessions();
    console.log();
    
    await this.checkRecentActivity();
    console.log();
    
    await this.testQueryPerformance();
    console.log();
    
    await this.testSecurityRules();
    console.log();
    
    await this.checkDataIntegrity();
    console.log();
    
    this.generateReport();
  }
}

// Command line usage
if (require.main === module) {
  const monitor = new FirestoreMonitor();
  
  if (process.argv.includes('--continuous')) {
    // Run monitoring every 5 minutes
    console.log('🔄 Starting continuous monitoring (every 5 minutes)');
    setInterval(() => {
      monitor.runFullMonitoring();
    }, 5 * 60 * 1000);
    
    // Run initial monitoring
    monitor.runFullMonitoring();
  } else {
    // Run once and exit
    monitor.runFullMonitoring().then(() => {
      process.exit(0);
    });
  }
}

module.exports = FirestoreMonitor;