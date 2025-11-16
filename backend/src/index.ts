import express from 'express';
import { habitSuggestionsRouter } from './routes/habitSuggestions.js';

const app = express();

app.use(express.json());
app.use('/api/habit-suggestions', habitSuggestionsRouter);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Habit suggestions API listening on port ${PORT}`);
});

export default app;
