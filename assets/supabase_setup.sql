-- =========================================================================
-- Supabase Setup: Profiles Table & Auth Trigger
-- Execute this script in your Supabase SQL Editor (Dashboard > SQL Editor)
-- =========================================================================

-- 1. Create profiles table in the public schema
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL DEFAULT '',
  role TEXT NOT NULL DEFAULT 'customer',
  date_of_birth TEXT,
  mobile_number TEXT,
  email_address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS Policies
-- Allow anyone to read profiles (or restrict as needed)
CREATE POLICY "Allow public read access" 
  ON public.profiles 
  FOR SELECT 
  USING (true);

-- Allow users to update their own profile
CREATE POLICY "Allow individual update access" 
  ON public.profiles 
  FOR UPDATE 
  USING (auth.uid() = id);

-- 4. Create trigger function to sync new users from auth.users to public.profiles
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role, date_of_birth, mobile_number, email_address)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    COALESCE(new.raw_user_meta_data->>'role', 'customer'),
    new.raw_user_meta_data->>'date_of_birth',
    new.phone,
    new.email
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Bind the trigger to auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();
