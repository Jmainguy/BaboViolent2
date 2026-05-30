-- Minimal schema for BaboMasterServer master.db
-- Used when Content/master.db is missing or empty.

CREATE TABLE IF NOT EXISTS Settings (
  Name TEXT PRIMARY KEY,
  Value TEXT
);

INSERT OR REPLACE INTO Settings (Name, Value) VALUES ('DBVersion', '0');
INSERT OR REPLACE INTO Settings (Name, Value) VALUES ('AccountURL', 'http://127.0.0.1/');

CREATE TABLE IF NOT EXISTS BanList (
  Date INTEGER,
  Duration INTEGER,
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  IP TEXT,
  MAC TEXT,
  Nick TEXT
);
