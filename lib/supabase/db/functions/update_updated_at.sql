CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  -- If there is no substantive change to the row (ignoring updated_at), do nothing.
  IF to_jsonb(NEW) - 'updated_at' = to_jsonb(OLD) - 'updated_at' THEN
    RETURN NEW;
  END IF;

  -- If the caller explicitly set/changed updated_at, preserve it.
  IF NEW.updated_at IS DISTINCT FROM OLD.updated_at THEN
    RETURN NEW;
  END IF;

  -- Otherwise stamp with the current wall-clock time (not transaction start).
  NEW.updated_at := clock_timestamp();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers attached by migration (run after tables exist)
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_tutor_profiles_updated_at ON tutor_profiles;
CREATE TRIGGER update_tutor_profiles_updated_at BEFORE UPDATE ON tutor_profiles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_tutor_bookings_updated_at ON tutor_bookings;
CREATE TRIGGER update_tutor_bookings_updated_at BEFORE UPDATE ON tutor_bookings FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();