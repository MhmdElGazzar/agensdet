import { test, expect } from '@playwright/test';

// Two checks, in order. The second runs only if the first passes,
// so a problem on the website can't hide a problem on this machine.
test.describe.serial('Setup check', () => {
  test('machine check: the browser opens a local page', async ({ page }) => {
    await page.setContent('<h1>Playwright SDET is ready</h1>');
    await expect(page.getByRole('heading', { name: 'Playwright SDET is ready' })).toBeVisible();
  });

  // https://www.automationexercise.com/test_cases — Test Case 7
  test('Test Case 7: Verify Test Cases Page', async ({ page }) => {
    // The demo site shows full-page ads that can cover the menu. Block them; they aren't part of the test.
    await page.route(/googlesyndication|doubleclick|adservice|googleads|google_vignette/, (route) => route.abort());
    await page.goto('/');
    await expect(page).toHaveTitle(/Automation Exercise/);
    await page.locator('header').getByRole('link', { name: 'Test Cases' }).click();
    await expect(page).toHaveURL(/\/test_cases$/);
    await expect(page.getByRole('heading', { name: 'Test Cases', exact: true })).toBeVisible();
  });
});
