import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://lwzvvaqgvcmsxblcglxo.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx3enZ2YXFndmNtc3hibGNnbHhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4NjU4NjYsImV4cCI6MjA4MTQ0MTg2Nn0.o0H0HRFurb-JAMmWrKZA9LWDeIjNxgefuh3pXC5VuUc';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
