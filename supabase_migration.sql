-- Stratify: Activity Logs Table
-- Run this in your Supabase SQL Editor (https://supabase.com/dashboard → SQL Editor)

CREATE TABLE activity_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  time_segment TEXT NOT NULL CHECK (time_segment IN ('Morning', 'Afternoon', 'Evening', 'Night')),
  category TEXT NOT NULL CHECK (category IN ('Study', 'Gym', 'Social', 'Entertainment', 'Other')),
  activity_name TEXT NOT NULL,
  time_spent NUMERIC NOT NULL CHECK (time_spent > 0),
  money_spent NUMERIC NOT NULL DEFAULT 0,
  satisfaction INTEGER NOT NULL CHECK (satisfaction BETWEEN 1 AND 5),
  energy_impact INTEGER NOT NULL CHECK (energy_impact BETWEEN -2 AND 2),
  stress_impact INTEGER NOT NULL CHECK (stress_impact BETWEEN -2 AND 2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security with public access (no auth)
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read" ON activity_logs
  FOR SELECT USING (true);

CREATE POLICY "Allow public insert" ON activity_logs
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update" ON activity_logs
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow public delete" ON activity_logs
  FOR DELETE USING (true);

-- Performance indexes
CREATE INDEX idx_activity_time_segment ON activity_logs(time_segment);
CREATE INDEX idx_activity_category ON activity_logs(category);
CREATE INDEX idx_activity_date ON activity_logs(date);
