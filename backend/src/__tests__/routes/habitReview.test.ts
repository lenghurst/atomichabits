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

describe('POST /api/habit-review', () => {
  beforeEach(() => {
    // Reset all mocks before each test
    jest.clearAllMocks();
  });

  describe('Happy path - 200 responses', () => {
    it('should return 200 with review when OpenAI succeeds', async () => {
      // Mock successful OpenAI response
      mockCreate.mockResolvedValueOnce({
        choices: [{
          message: {
            content: JSON.stringify({
              summary: 'You completed your habit 5 out of 7 days this week (71%). Good progress!',
              insights: [
                'Your longest streak was 3 days',
                'Weekdays are stronger than weekends'
              ],
              suggested_adjustments: [
                'Make it obvious: Set up a clear visual cue',
                'Make it attractive: Pair with something enjoyable'
              ]
            })
          }
        }]
      });

      const response = await request(app)
        .post('/api/habit-review')
        .send({
          habit: {
            identity: 'a person who reads daily',
            habit_name: 'Read for 10 minutes',
            time: '22:00',
            location: 'In bed'
          },
          history: [
            { date: '2025-01-10', completed: true },
            { date: '2025-01-09', completed: true },
            { date: '2025-01-08', completed: false },
            { date: '2025-01-07', completed: true },
            { date: '2025-01-06', completed: true },
            { date: '2025-01-05', completed: true },
            { date: '2025-01-04', completed: false }
          ]
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('summary');
      expect(response.body).toHaveProperty('insights');
      expect(response.body).toHaveProperty('suggestedAdjustments');
      expect(typeof response.body.summary).toBe('string');
      expect(Array.isArray(response.body.insights)).toBe(true);
      expect(Array.isArray(response.body.suggestedAdjustments)).toBe(true);
    });

    it('should return 200 with heuristic fallback when OpenAI is not configured', async () => {
      // Don't set OPENAI_API_KEY - will trigger heuristic path
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/habit-review')
        .send({
          habit: {
            habit_name: 'Meditate for 5 minutes',
            time: '07:00'
          },
          history: [
            { date: '2025-01-10', completed: true },
            { date: '2025-01-09', completed: false },
            { date: '2025-01-08', completed: true },
            { date: '2025-01-07', completed: false },
            { date: '2025-01-06', completed: true },
            { date: '2025-01-05', completed: true },
            { date: '2025-01-04', completed: true }
          ]
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('summary');
      expect(response.body).toHaveProperty('insights');
      expect(response.body).toHaveProperty('suggestedAdjustments');
      expect(response.body.insights.length).toBeGreaterThan(0);
      expect(response.body.suggestedAdjustments.length).toBeGreaterThan(0);

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });

    it('should handle minimal habit info with only required field', async () => {
      // Don't set OPENAI_API_KEY to use heuristics
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/habit-review')
        .send({
          habit: {
            habit_name: 'Exercise'
          },
          history: [
            { date: '2025-01-10', completed: true },
            { date: '2025-01-09', completed: true },
            { date: '2025-01-08', completed: true }
          ]
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('summary');
      expect(response.body.summary).toContain('Exercise');

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });
  });

  describe('Validation errors - 400 responses', () => {
    it('should return 400 when habit is missing', async () => {
      const response = await request(app)
        .post('/api/habit-review')
        .send({
          history: [
            { date: '2025-01-10', completed: true }
          ]
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('habit');
    });

    it('should return 400 when habit.habit_name is missing', async () => {
      const response = await request(app)
        .post('/api/habit-review')
        .send({
          habit: {
            identity: 'a person who exercises',
            time: '07:00'
          },
          history: [
            { date: '2025-01-10', completed: true }
          ]
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('habit_name');
    });

    it('should return 400 when history is missing', async () => {
      const response = await request(app)
        .post('/api/habit-review')
        .send({
          habit: {
            habit_name: 'Read for 10 minutes'
          }
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('history');
    });

    it('should return 400 when history is not an array', async () => {
      const response = await request(app)
        .post('/api/habit-review')
        .send({
          habit: {
            habit_name: 'Read for 10 minutes'
          },
          history: 'not an array'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('history');
      expect(response.body.error).toContain('array');
    });
  });

  describe('Response schema validation', () => {
    it('should return review with correct schema', async () => {
      // Use heuristics for predictable response
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/habit-review')
        .send({
          habit: {
            habit_name: 'Write in journal',
            time: '21:00',
            location: 'Desk'
          },
          history: [
            { date: '2025-01-10', completed: true },
            { date: '2025-01-09', completed: true },
            { date: '2025-01-08', completed: true },
            { date: '2025-01-07', completed: true },
            { date: '2025-01-06', completed: true },
            { date: '2025-01-05', completed: true },
            { date: '2025-01-04', completed: true }
          ]
        });

      expect(response.status).toBe(200);

      // Verify schema structure
      expect(response.body).toEqual({
        summary: expect.any(String),
        insights: expect.arrayContaining([expect.any(String)]),
        suggestedAdjustments: expect.arrayContaining([expect.any(String)])
      });

      // Verify summary is not empty
      expect(response.body.summary.length).toBeGreaterThan(0);

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });
  });
});
