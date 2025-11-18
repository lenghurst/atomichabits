import request from 'supertest';
import { app } from '../../server';

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

describe('POST /api/habit-suggestions', () => {
  beforeEach(() => {
    // Reset all mocks before each test
    jest.clearAllMocks();
  });

  describe('Happy path - 200 responses', () => {
    it('should return 200 with suggestions when OpenAI succeeds', async () => {
      // Mock successful OpenAI response
      mockCreate.mockResolvedValueOnce({
        choices: [{
          message: {
            content: JSON.stringify({
              suggestions: [
                'Have a cup of tea while reading',
                'Light a candle',
                'Listen to calm music'
              ]
            })
          }
        }]
      });

      const response = await request(app)
        .post('/api/habit-suggestions')
        .send({
          suggestion_type: 'temptation_bundle',
          habit_name: 'Read for 10 minutes',
          time: '22:00',
          identity: 'a person who reads daily',
          location: 'In bed'
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('suggestions');
      expect(Array.isArray(response.body.suggestions)).toBe(true);
      expect(response.body.suggestions.length).toBeGreaterThan(0);
    });

    it('should return 200 with heuristic fallback when OpenAI is not configured', async () => {
      // Don't set OPENAI_API_KEY - will trigger heuristic path
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/habit-suggestions')
        .send({
          suggestion_type: 'pre_habit_ritual',
          habit_name: 'Meditate for 5 minutes',
          time: '07:00'
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('suggestions');
      expect(Array.isArray(response.body.suggestions)).toBe(true);
      expect(response.body.suggestions.length).toBeGreaterThan(0);

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });

    it('should handle all four suggestion types', async () => {
      const types = ['temptation_bundle', 'pre_habit_ritual', 'environment_cue', 'environment_distraction'];

      for (const type of types) {
        mockCreate.mockResolvedValueOnce({
          choices: [{
            message: {
              content: JSON.stringify({
                suggestions: ['suggestion 1', 'suggestion 2', 'suggestion 3']
              })
            }
          }]
        });

        const response = await request(app)
          .post('/api/habit-suggestions')
          .send({
            suggestion_type: type,
            habit_name: 'Test habit',
            time: '12:00'
          });

        expect(response.status).toBe(200);
        expect(response.body.suggestions).toBeDefined();
      }
    });
  });

  describe('Validation errors - 400 responses', () => {
    it('should return 400 when suggestion_type is missing', async () => {
      const response = await request(app)
        .post('/api/habit-suggestions')
        .send({
          habit_name: 'Read for 10 minutes',
          time: '22:00'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('suggestion_type');
    });

    it('should return 400 when habit_name is missing', async () => {
      const response = await request(app)
        .post('/api/habit-suggestions')
        .send({
          suggestion_type: 'temptation_bundle',
          time: '22:00'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('habit_name');
    });

    it('should return 400 when time is missing', async () => {
      const response = await request(app)
        .post('/api/habit-suggestions')
        .send({
          suggestion_type: 'temptation_bundle',
          habit_name: 'Read for 10 minutes'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('time');
    });

    it('should return 400 when suggestion_type is invalid', async () => {
      const response = await request(app)
        .post('/api/habit-suggestions')
        .send({
          suggestion_type: 'invalid_type',
          habit_name: 'Read for 10 minutes',
          time: '22:00'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('Invalid suggestion_type');
    });
  });

  describe('Response schema validation', () => {
    it('should return suggestions as an array of strings', async () => {
      mockCreate.mockResolvedValueOnce({
        choices: [{
          message: {
            content: JSON.stringify({
              suggestions: ['First suggestion', 'Second suggestion']
            })
          }
        }]
      });

      const response = await request(app)
        .post('/api/habit-suggestions')
        .send({
          suggestion_type: 'temptation_bundle',
          habit_name: 'Write in journal',
          time: '21:00'
        });

      expect(response.status).toBe(200);
      expect(response.body.suggestions).toEqual(
        expect.arrayContaining([expect.any(String)])
      );
    });
  });
});
