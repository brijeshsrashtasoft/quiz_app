import { test, expect } from '@playwright/test';

/**
 * Web-specific E2E tests using Playwright MCP
 * Tests complete user flows in the web browser
 */

test.describe('Quiz App Web Flows', () => {
  
  test.beforeEach(async ({ page }) => {
    // Navigate to the app
    await page.goto('/');
    
    // Wait for Flutter to load
    await page.waitForSelector('flutter-view', { timeout: 30000 });
    
    // Wait for app to be ready
    await page.waitForFunction(() => {
      return (window as any).flutterCanvasKit \!== undefined;
    }, { timeout: 30000 });
  });

  test('App loads and displays home screen', async ({ page }) => {
    // Verify app title
    await expect(page).toHaveTitle(/Quiz App/);
    
    // Verify main navigation elements
    await expect(page.locator('[data-testid="home-screen"]')).toBeVisible();
    await expect(page.locator('[data-testid="create-quiz-button"]')).toBeVisible();
    await expect(page.locator('[data-testid="join-game-button"]')).toBeVisible();
    
    console.log('✅ Home screen loaded successfully');
  });

  test('Complete user authentication flow', async ({ page }) => {
    // Click sign in button
    await page.click('[data-testid="sign-in-button"]');
    
    // Wait for auth form
    await page.waitForSelector('[data-testid="auth-form"]');
    
    // Fill in credentials
    await page.fill('[data-testid="email-field"]', 'playwright-test@example.com');
    await page.fill('[data-testid="password-field"]', 'testpassword123');
    
    // Submit form
    await page.click('[data-testid="sign-in-submit"]');
    
    // Wait for successful authentication
    await page.waitForSelector('[data-testid="user-profile"]', { timeout: 10000 });
    
    // Verify authenticated state
    await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
    
    console.log('✅ Authentication flow completed');
  });

  test('Performance benchmarks on web', async ({ page }) => {
    // Measure page load time
    const startTime = Date.now();
    await page.goto('/');
    await page.waitForSelector('flutter-view');
    const loadTime = Date.now() - startTime;
    
    // Assert load time is under 3 seconds
    expect(loadTime).toBeLessThan(3000);
    console.log(`Page load time: ${loadTime}ms`);
    
    // Measure navigation performance
    await authenticateUser(page);
    
    const navStartTime = Date.now();
    await page.click('[data-testid="create-quiz-button"]');
    await page.waitForSelector('[data-testid="quiz-creation-form"]');
    const navTime = Date.now() - navStartTime;
    
    // Assert navigation is under 200ms
    expect(navTime).toBeLessThan(200);
    console.log(`Navigation time: ${navTime}ms`);
    
    console.log('✅ Performance benchmarks completed');
  });

  // Helper functions
  async function authenticateUser(page: any, email = 'playwright-test@example.com') {
    await page.click('[data-testid="sign-in-button"]');
    await page.waitForSelector('[data-testid="auth-form"]');
    await page.fill('[data-testid="email-field"]', email);
    await page.fill('[data-testid="password-field"]', 'testpassword123');
    await page.click('[data-testid="sign-in-submit"]');
    await page.waitForSelector('[data-testid="user-profile"]');
  }
});
EOF < /dev/null