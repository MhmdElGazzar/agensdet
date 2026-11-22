#!/usr/bin/env bash
# Makes the workspace an existing Playwright project.
echo "export default {};" > playwright.config.ts
echo "{\"name\":\"existing\"}" > package.json
