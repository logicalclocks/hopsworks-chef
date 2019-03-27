ALTER TABLE jupyter_project CHANGE `last_accessed` `expires` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;
