-- Add the `fitbit_credentials` column to the `study` table
ALTER TABLE public.study
ADD COLUMN IF NOT EXISTS fitbit_credentials jsonb;
