// Jest configuration for Atomic Habits backend tests
// Uses ts-jest to run TypeScript tests without pre-compilation

module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.test.ts'],
  moduleFileExtensions: ['ts', 'js', 'json'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.test.ts',
    '!src/**/__tests__/**',
  ],
  // Map .js imports to .ts source files (for TypeScript ESM compatibility)
  moduleNameMapper: {
    '^(\\.{1,2}/.*)\\.js$': '$1',
  },
  // Clear mocks between tests to prevent leakage
  clearMocks: true,
  resetMocks: true,
  restoreMocks: true,
};
