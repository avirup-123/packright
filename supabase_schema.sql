-- Run this script in your Supabase SQL Editor to set up the database.

-- Create the trips table
CREATE TABLE IF NOT EXISTS public.trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    trip_name TEXT NOT NULL,
    categories JSONB,
    saved_items_state JSONB,
    custom_added_items JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS) on the trips table
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;

-- Create Policies so each person only sees their own data
-- Policy 1: Users can view their own trips
CREATE POLICY "Users can view their own trips" 
ON public.trips FOR SELECT 
USING (auth.uid() = user_id);

-- Policy 2: Users can insert their own trips
CREATE POLICY "Users can insert their own trips" 
ON public.trips FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Policy 3: Users can update their own trips
CREATE POLICY "Users can update their own trips" 
ON public.trips FOR UPDATE 
USING (auth.uid() = user_id);

-- Policy 4: Users can delete their own trips
CREATE POLICY "Users can delete their own trips" 
ON public.trips FOR DELETE 
USING (auth.uid() = user_id);
