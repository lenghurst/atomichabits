# Backend Testing Guide

This document covers how to run and maintain the test suite for the Atomic Habits backend.

## Running Tests

### Install Dependencies (First Time Only)

```bash
cd backend
npm install
```

### Run All Tests

```bash
npm test
```

### Watch Mode (Re-runs on File Changes)

```bash
npm run test:watch
```

### Coverage Report

```bash
npm run test:coverage
```

## What Is Tested

The test suite provides comprehensive coverage of all 4 API endpoints:

### 1. POST /api/habit-suggestions
- **File**: `src/__tests__/routes/habitSuggestions.test.ts`
- **Tests**: 8
- **Coverage**:
  - Happy paths (200): OpenAI success, heuristic fallback
  - All 4 suggestion types: temptation_bundle, pre_habit_ritual, environment_cue, environment_distraction
  - Validation errors (400): Missing required fields, invalid suggestion type
  - Response schema validation

### 2. POST /api/habit-review
- **File**: `src/__tests__/routes/habitReview.test.ts`
- **Tests**: 8
- **Coverage**:
  - Happy paths (200): OpenAI success, heuristic fallback, minimal habit info
  - Validation errors (400): Missing habit, missing habit_name, missing/invalid history
  - Response schema validation

### 3. POST /api/coach/onboarding
- **File**: `src/__tests__/routes/coachOnboarding.test.ts`
- **Tests**: 10
- **Coverage**:
  - Happy paths (200): Full context, sparse context, OpenAI success
  - Validation errors (400): Empty context, invalid body types
  - Response schema validation (snake_case habit_plan fields)
  - Confidence score validation (0-1 range)

### 4. POST /api/coach/daily-reflection
- **File**: `src/__tests__/routes/dailyCoach.test.ts`
- **Tests**: 13
- **Coverage**:
  - Happy paths (200): All 3 statuses (completed/partial/missed), OpenAI success
  - Validation errors (400): Missing fields, invalid date format, invalid status
  - Response schema validation (snake_case fields)

**Total: 39 tests, all passing**

## Test Architecture

### Test Framework

- **Jest**: JavaScript testing framework
- **ts-jest**: TypeScript preprocessor for Jest
- **supertest**: HTTP assertion library for testing Express apps

### Configuration

Tests are configured in `jest.config.cjs`:

```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.test.ts'],
  moduleNameMapper: {
    '^(\\.{1,2}/.*)\\.js$': '$1',  // Maps .js imports to .ts source files
  },
};
```

### OpenAI Mocking

All tests mock the OpenAI module to ensure:

1. **Deterministic**: Tests never call the real OpenAI API
2. **Fast**: No network delays
3. **Reliable**: Tests pass even when offline or when OpenAI is down

Example mocking pattern used in all test files:

```typescript
// Create mock function that we can control in tests
const mockCreate = jest.fn();

// Mock OpenAI at the module level
jest.mock('openai', () => {
  return {
    default: jest.fn().mockImplementation(() => ({
      chat: {
        completions: {
          create: mockCreate
        }
      }
    }))
  };
});

describe('POST /api/some-endpoint', () => {
  beforeEach(() => {
    // Reset all mocks before each test
    jest.clearAllMocks();
  });

  it('should return 200 when OpenAI succeeds', async () => {
    // Mock successful OpenAI response
    mockCreate.mockResolvedValueOnce({
      choices: [{
        message: {
          content: JSON.stringify({ /* response data */ })
        }
      }]
    });

    // Test the endpoint
    const response = await request(app)
      .post('/api/some-endpoint')
      .send({ /* test data */ });

    expect(response.status).toBe(200);
  });
});
```

## Test Guarantees

### No Real Network Calls

- All OpenAI calls are mocked
- Tests run entirely offline
- No `OPENAI_API_KEY` required for testing

### No API Contract Changes

The test suite validates that API contracts remain stable:

- Request validation logic unchanged
- Response schemas unchanged
- Endpoint paths unchanged
- HTTP status codes match existing behaviour

### Backwards Compatibility

Tests ensure that:

- Missing optional fields don't break endpoints
- New fields can be added without breaking old clients
- Heuristic fallbacks work when OpenAI is unavailable

## Troubleshooting

### TypeScript Errors in Tests

If you see errors like `Cannot find name 'jest'` or `Cannot find name 'describe'`:

**Solution**: Ensure `"jest"` is in the `types` array in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "types": ["node", "jest"]
  }
}
```

### Module Resolution Errors

If you see errors like `Cannot find module '../services/foo.js'`:

**Solution**: The `moduleNameMapper` in `jest.config.cjs` should map `.js` imports to `.ts` source files:

```javascript
moduleNameMapper: {
  '^(\\.{1,2}/.*)\\.js$': '$1',
}
```

### Tests Passing Locally But Failing in CI

**Possible causes**:

1. **Time-dependent tests**: Avoid using `DateTime.now()` in assertions
2. **File system differences**: Use cross-platform path separators
3. **Environment variables**: Ensure CI doesn't have `OPENAI_API_KEY` set

## Adding New Tests

When adding a new endpoint or feature:

1. **Create test file**: `src/__tests__/routes/yourEndpoint.test.ts`
2. **Mock OpenAI**: Use the pattern shown above
3. **Test happy paths**: At least one 200 response test
4. **Test validation**: All required field validations (400 responses)
5. **Test schema**: Verify response structure matches API docs
6. **Run tests**: `npm test` to ensure all pass

## Best Practices

1. **Keep tests deterministic**: No random data, no real network calls
2. **Test behaviour, not implementation**: Focus on API contracts
3. **Use descriptive test names**: Clearly state what is being tested
4. **Clean up after each test**: Use `beforeEach` to reset mocks
5. **Test edge cases**: Missing fields, empty arrays, null values

## Additional Resources

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Supertest Documentation](https://github.com/visionmedia/supertest)
- [Backend API Docs](./README.md) - Full API reference
- [E2E Testing Guide](../E2E_TESTING_AND_DEBUGGING.md) - End-to-end testing with Flutter app
