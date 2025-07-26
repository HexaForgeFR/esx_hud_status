ALTER TABLE users
ADD COLUMN status LONGTEXT DEFAULT '{"hunger": 100, "thirst": 100, "alcohol": 0}';
