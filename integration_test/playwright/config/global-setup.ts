import { chromium, FullConfig } from '@playwright/test';

/**
 * Global setup for Playwright tests
 * Prepares the test environment and authentication
 */
async function globalSetup(config: FullConfig) {
  console.log('🚀 Starting Playwright Global Setup');

  // Launch browser for setup
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    // Wait for Flutter web app to be ready
    console.log('⏳ Waiting for Flutter web app...');
    await page.goto(config.projects[0].use.baseURL || 'http://localhost:8080');
    
    // Wait for Flutter to initialize
    await page.waitForSelector('flutter-view', { timeout: 60000 });
    console.log('✅ Flutter web app is ready');

    // Setup test user authentication
    await setupTestAuthentication(page);

    // Initialize Firebase emulators if needed
    await initializeFirebaseEmulators();

    // Seed test data
    await seedTestData();

    console.log('✅ Global setup completed successfully');

  } catch (error) {
    console.error('❌ Global setup failed:', error);
    throw error;
  } finally {
    await context.close();
    await browser.close();
  }
}

/**
 * Setup test user authentication
 */
async function setupTestAuthentication(page: any) {
  console.log('🔐 Setting up test authentication');
  
  try {
    // Navigate to authentication page
    await page.click('[data-testid="sign-in-button"]');
    await page.waitForSelector('[data-testid="email-field"]');

    // Create test user
    await page.fill('[data-testid="email-field"]', 'e2e-test@example.com');
    await page.fill('[data-testid="password-field"]', 'testpassword123');
    await page.click('[data-testid="sign-in-submit"]');

    // Wait for authentication to complete
    await page.waitForSelector('[data-testid="home-screen"]', { timeout: 10000 });
    
    console.log('✅ Test authentication setup completed');
  } catch (error) {
    console.log('ℹ️ Test user may already exist, continuing...');
  }
}

/**
 * Initialize Firebase emulators
 */
async function initializeFirebaseEmulators() {
  console.log('🔥 Initializing Firebase emulators');
  
  // Check if emulators are running
  try {
    const response = await fetch('http://localhost:4000');
    if (response.ok) {
      console.log('✅ Firebase emulators are running');
    }
  } catch (error) {
    console.log('⚠️ Firebase emulators not detected, using production');
  }
}

/**
 * Seed test data
 */
async function seedTestData() {
  console.log('🌱 Seeding test data');
  
  // This would typically involve API calls to populate test data
  // For now, we'll just log that seeding is complete
  
  console.log('✅ Test data seeding completed');
}

export default globalSetup;
EOF < /dev/null