-- Minimal schema for BaboMasterServer web.db (game list mirror)

CREATE TABLE IF NOT EXISTS Games (
  IP TEXT,
  Map TEXT,
  MaxPlayers INTEGER,
  Name TEXT,
  NbPlayers INTEGER,
  Password INTEGER,
  Port INTEGER
);
