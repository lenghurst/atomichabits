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

describe('POST /api/coach/daily-reflection', () => {
  beforeEach(() => {
    // Reset all mocks before each test
    jest.clearAllMocks();
  });

  describe('Happy path - 200 responses', () => {
    it('should return 200 with reflection when status is "completed"', async () => {
      // Use heuristics for predictable response
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            habit_name: 'Read for 10 minutes',
            identity: 'I am a reader',
            two_minute_version: 'Read one page',
            time: '22:00',
            location: 'In bed'
          },
          date: '2025-11-17',
          status: 'completed',
          reflection: {
            what_happened: 'I finished my reading goal today',
            what_helped_or_blocked: 'Having my book on my pillow reminded me',
            what_might_help_tomorrow: 'Keep doing the same'
          }
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('coach_message');
      expect(response.body).toHaveProperty('insights');
      expect(response.body).toHaveProperty('suggested_adjustments');
      expect(response.body).toHaveProperty('suggested_tomorrow_experiment');
      expect(Array.isArray(response.body.insights)).toBe(true);
      expect(Array.isArray(response.body.suggested_adjustments)).toBe(true);

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });

    it('should return 200 with reflection when status is "missed"', async () => {
      // Use heuristics
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            habit_name: 'Exercise for 30 minutes',
            identity: 'I am an athlete'
          },
          date: '2025-11-17',
          status: 'missed',
          reflection: {
            what_happened: 'I was too tired after work',
            what_helped_or_blocked: 'Long meeting ran late',
            what_might_help_tomorrow: 'Exercise in the morning instead'
          }
        });

      expect(response.status).toBe(200);
      expect(response.body.coach_message).toBeDefined();
      expect(typeof response.body.coach_message).toBe('string');

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });

    it('should return 200 with reflection when status is "partial"', async () => {
      // Use heuristics
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            habit_name: 'Meditate for 10 minutes'
          },
          date: '2025-11-17',
          status: 'partial'
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('coach_message');

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });

    it('should return 200 when OpenAI succeeds', async () => {
      // Mock successful OpenAI response
      mockCreate.mockResolvedValueOnce({
        choices: [{
          message: {
            content: JSON.stringify({
              coach_message: 'Great job completing your habit today!',
              insights: [
                'You are building consistency',
                'Environmental cues are working well'
              ],
              suggested_adjustments: [
                'Keep your book visible',
                'Maintain your evening routine'
              ],
              suggested_tomorrow_experiment: 'Try reading 2 pages tomorrow'
            })
          }
        }]
      });

      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            habit_name: 'Read for 10 minutes',
            identity: 'I am a reader'
          },
          date: '2025-11-17',
          status: 'completed'
        });

      expect(response.status).toBe(200);
      expect(response.body.coach_message).toBeDefined();
      expect(response.body.insights.length).toBeGreaterThan(0);
    });

    it('should handle minimal request with only required fields', async () => {
      // Use heuristics
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            habit_name: 'Write in journal'
          },
          date: '2025-11-17',
          status: 'completed'
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('coach_message');

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });
  });

  describe('Validation errors - 400 responses', () => {
    it('should return 400 when habit is missing', async () => {
      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          date: '2025-11-17',
          status: 'completed'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.message).toContain('habit');
    });

    it('should return 400 when habit is not an object', async () => {
      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: 'not an object',
          date: '2025-11-17',
          status: 'completed'
        });

      expect(response.status).toBe(400);
      expect(response.body.message).toContain('habit');
    });

    it('should return 400 when habit.habit_name is missing', async () => {
      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            identity: 'I am a reader'
          },
          date: '2025-11-17',
          status: 'completed'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.message).toContain('habit_name');
    });

    it('should return 400 when date is missing', async () => {
      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            habit_name: 'Read for 10 minutes'
          },
          status: 'completed'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.message).toContain('date');
    });

    it('should return 400 when date format is invalid', async () => {
      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            habit_name: 'Read for 10 minutes'
          },
          date: '11/17/2025',  // Wrong format
          status: 'completed'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.message).toContain('date format');
    });

    it('should return 400 when status is missing', async () => {
      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            habit_name: 'Read for 10 minutes'
          },
          date: '2025-11-17'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.message).toContain('status');
    });

    it('should return 400 when status is invalid', async () => {
      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            habit_name: 'Read for 10 minutes'
          },
          date: '2025-11-17',
          status: 'invalid_status'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.message).toContain('completed, missed, partial');
    });
  });

  describe('Response schema validation', () => {
    it('should return reflection with correct snake_case schema', async () => {
      // Use heuristics for predictable structure
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/coach/daily-reflection')
        .send({
          habit: {
            habit_name: 'Write in journal',
            identity: 'I am a writer',
            time: '08:00',
            location: 'At my desk'
          },
          date: '2025-11-17',
          status: 'completed',
          reflection: {
            what_happened: 'I wrote 3 pages today',
            what_helped_or_blocked: 'Morning coffee helped me focus',
            what_might_help_tomorrow: 'Start 15 minutes earlier'
          }
        });

      expect(response.status).toBe(200);

      // Verify response schema (snake_case)
      expect(response.body).toHaveProperty('coach_message');
      expect(response.body).toHaveProperty('insights');
      expect(response.body).toHaveProperty('suggested_adjustments');
      expect(response.body).toHaveProperty('suggested_tomorrow_experiment');

      // Verify types
      expect(typeof response.body.coach_message).toBe('string');
      expect(Array.isArray(response.body.insights)).toBe(true);
      expect(Array.isArray(response.body.suggested_adjustments)).toBe(true);
      expect(typeof response.body.suggested_tomorrow_experiment).toBe('string');

      // Verify non-empty
      expect(response.body.coach_message.length).toBeGreaterThan(0);
      expect(response.body.insights.length).toBeGreaterThan(0);

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });
  });
});
