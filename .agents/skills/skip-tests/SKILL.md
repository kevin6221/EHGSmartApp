---
name: skip-tests
description: >-
  Enforces skipping automated test execution and test cases. Use whenever implementing features,
  debugging, or verifying code in this project to prevent running `flutter test`.
---

# Skip Automated Tests Skill

## Overview
The user explicitly requested to never run automated test cases or spend time executing test suites during development.

## Guidelines
1. **Never Run Test Commands**:
   - Do NOT run `flutter test` or any test runners.
   - Do NOT create or run background tasks for unit/widget tests.

2. **Verification Without Tests**:
   - Run `flutter analyze` to guarantee zero syntax or lint errors.
   - Perform direct code review against architectural patterns.
   - Visually verify UI layout against Figma designs and device screenshots.
