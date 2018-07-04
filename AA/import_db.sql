DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;



PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
  
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  parent_id INTEGER,
  question_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (parent_id) REFERENCES replies(id)
  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE question_likes (
  id PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
    users (fname, lname)
VALUES
  ('Jose', 'Martinez'),
  ('Amy', 'Hurtado');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('Why is this a thing?', 'Help me understand why I am doing this thing', (SELECT id FROM users WHERE fname = 'Jose')),
  ('Name of the lead actor in "300"?', 'What is the name of the actor who starred in "300"?', (SELECT id FROM users WHERE fname = 'Amy'));

INSERT INTO
  question_follows (question_id, user_id)
VALUES
    ((SELECT id FROM questions WHERE title LIKE 'Why%'), (SELECT id FROM users WHERE fname = 'Jose')),
    ((SELECT id FROM questions WHERE title LIKE 'Name%'), (SELECT id FROM users WHERE fname ='Amy'));


INSERT INTO
  replies (parent_id, question_id, body, user_id)
VALUES
  ((SELECT id FROM replies), (SELECT id FROM questions WHERE id = 1), 'No one knows', (SELECT id FROM users WHERE id = 1)),
  ((SELECT id FROM replies), (SELECT id FROM questions WHERE id = 2), 'Gerald Butler', (SELECT id FROM users WHERE id = 2));










