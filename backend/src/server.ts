import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import habitSuggestionsRouter from './routes/habitSuggestions';
import habitReviewRouter from './routes/habitReview';
import coachOnboardingRouter from './routes/coachOnboarding';
import dailyCoachRouter from './routes/dailyCoach';

// Load environment variables from .env file
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors()); // Enable CORS for Flutter app
app.use(express.json()); // Parse JSON bodies

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    openai_configured: !!process.env.OPENAI_API_KEY
  });
});

// Mount routes
app.use(habitSuggestionsRouter);
app.use(habitReviewRouter);
app.use(coachOnboardingRouter);
app.use(dailyCoachRouter);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not found',
    path: req.path
  });
});

// Export app for testing
export { app };

// Only start server when run directly (not when imported by tests)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log('='.repeat(60));
    console.log('🚀 Atomic Habits Backend Server');
    console.log('='.repeat(60));
    console.log(`📍 Server running on: http://localhost:${PORT}`);
    console.log(`🔑 OpenAI API Key: ${process.env.OPENAI_API_KEY ? '✅ Configured' : '❌ Not set (will use heuristics only)'}`);
    console.log(`💡 Health check: http://localhost:${PORT}/health`);
    console.log(`📡 Suggestions API: http://localhost:${PORT}/api/habit-suggestions`);
    console.log(`📊 Review API: http://localhost:${PORT}/api/habit-review`);
    console.log(`🎯 Coach Onboarding API: http://localhost:${PORT}/api/coach/onboarding`);
    console.log(`📘 Daily Coach API: http://localhost:${PORT}/api/coach/daily-reflection`);
    console.log('='.repeat(60));
  });
}
