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

describe('POST /api/coach/onboarding', () => {
  beforeEach(() => {
    // Reset all mocks before each test
    jest.clearAllMocks();
  });

  describe('Happy path - 200 responses', () => {
    it('should return 200 with habit plan when full context is provided', async () => {
      // Use heuristics for predictable response
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/coach/onboarding')
        .send({
          desired_identity: 'a person who reads daily',
          habit_idea: 'read more books',
          when_in_day: 'before bed around 9pm',
          where_location: 'in bed',
          what_makes_it_enjoyable: 'having herbal tea',
          user_name: 'Alex'
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('habit_plan');
      expect(response.body).toHaveProperty('metadata');
      expect(response.body.habit_plan).toHaveProperty('identity');
      expect(response.body.habit_plan).toHaveProperty('habit_name');
      expect(response.body.habit_plan).toHaveProperty('tiny_version');
      expect(response.body.habit_plan).toHaveProperty('implementation_time');
      expect(response.body.habit_plan).toHaveProperty('implementation_location');

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });

    it('should return 200 with habit plan when OpenAI succeeds', async () => {
      // Mock successful OpenAI response
      mockCreate.mockResolvedValueOnce({
        choices: [{
          message: {
            content: JSON.stringify({
              identity: 'I am a reader',
              habit_name: 'Read every day',
              tiny_version: 'Read one page',
              implementation_time: '21:00',
              implementation_location: 'In bed',
              temptation_bundle: 'Have herbal tea while reading',
              pre_habit_ritual: 'Take 3 deep breaths and open book',
              environment_cue: 'Put book on pillow at 20:45',
              environment_distraction: 'Charge phone in the kitchen',
              confidence: 0.9,
              missing_fields: [],
              notes: 'Generated from your answers'
            })
          }
        }]
      });

      const response = await request(app)
        .post('/api/coach/onboarding')
        .send({
          desired_identity: 'a reader',
          habit_idea: 'read more',
          when_in_day: '9pm',
          where_location: 'in bed'
        });

      expect(response.status).toBe(200);
      expect(response.body.habit_plan.identity).toBeDefined();
      expect(response.body.habit_plan.habit_name).toBeDefined();
      expect(response.body.metadata.confidence).toBeDefined();
    });

    it('should return 200 with sparse context (partial fields)', async () => {
      // Use heuristics
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/coach/onboarding')
        .send({
          habit_idea: 'exercise more',
          when_in_day: 'morning'
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('habit_plan');
      expect(response.body).toHaveProperty('metadata');
      // With sparse context, confidence should be lower
      expect(response.body.metadata.confidence).toBeDefined();

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });

    it('should return 200 when only desired_identity is provided', async () => {
      // Use heuristics
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/coach/onboarding')
        .send({
          desired_identity: 'a healthy person'
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('habit_plan');

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });
  });

  describe('Validation errors - 400 responses', () => {
    it('should return 400 when body contains no valid context fields', async () => {
      const response = await request(app)
        .post('/api/coach/onboarding')
        .send({
          some_random_field: 'value',
          another_field: 123
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('Insufficient context');
    });

    it('should return 400 when body is an array', async () => {
      const response = await request(app)
        .post('/api/coach/onboarding')
        .send([]);

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
    });

    it('should return 400 when no context is provided (empty object)', async () => {
      const response = await request(app)
        .post('/api/coach/onboarding')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('Insufficient context');
    });

    it('should return 400 when all context fields are undefined or irrelevant', async () => {
      const response = await request(app)
        .post('/api/coach/onboarding')
        .send({
          user_name: 'Alex',
          what_makes_it_enjoyable: 'nothing specific'
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('Insufficient context');
    });
  });

  describe('Response schema validation', () => {
    it('should return habit plan with correct snake_case schema', async () => {
      // Use heuristics for predictable structure
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/coach/onboarding')
        .send({
          desired_identity: 'a writer',
          habit_idea: 'write daily',
          when_in_day: 'morning at 8am',
          where_location: 'at my desk'
        });

      expect(response.status).toBe(200);

      // Verify habit_plan schema (snake_case)
      expect(response.body.habit_plan).toEqual(
        expect.objectContaining({
          identity: expect.any(String),
          habit_name: expect.any(String),
          tiny_version: expect.any(String),
          implementation_time: expect.any(String),
          implementation_location: expect.any(String)
        })
      );

      // Check optional fields exist (can be string or null)
      expect(response.body.habit_plan).toHaveProperty('temptation_bundle');
      expect(response.body.habit_plan).toHaveProperty('pre_habit_ritual');
      expect(response.body.habit_plan).toHaveProperty('environment_cue');
      expect(response.body.habit_plan).toHaveProperty('environment_distraction');

      // Verify metadata schema
      expect(response.body.metadata).toHaveProperty('confidence');
      expect(response.body.metadata).toHaveProperty('missing_fields');
      expect(response.body.metadata).toHaveProperty('notes');
      expect(typeof response.body.metadata.confidence).toBe('number');

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });

    it('should return confidence between 0 and 1', async () => {
      // Use heuristics
      const oldApiKey = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;

      const response = await request(app)
        .post('/api/coach/onboarding')
        .send({
          habit_idea: 'meditate'
        });

      expect(response.status).toBe(200);
      expect(response.body.metadata.confidence).toBeGreaterThanOrEqual(0);
      expect(response.body.metadata.confidence).toBeLessThanOrEqual(1);

      // Restore API key
      if (oldApiKey) process.env.OPENAI_API_KEY = oldApiKey;
    });
  });
});
