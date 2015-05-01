--As postgres

CREATE USER t_usr WITH PASSWORD '123';
GRANT ALL PRIVILEGES ON DATABASE "test_me" to t_usr;

CREATE TABLE topics(
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);
GRANT ALL ON topics TO t_usr;
GRANT ALL ON topics_id_seq TO t_usr;

CREATE TABLE difficulties(
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);
GRANT ALL ON difficulties TO t_usr;
GRANT ALL ON difficulties_id_seq TO t_usr;

CREATE TABLE tests(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    inserted_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now(),
    inserted_by TEXT NOT NULL DEFAULT '',
    updated_by TEXT NOT NULL DEFAULT '',
    is_timed BOOLEAN NOT NULL DEFAULT false,
    time_minutes INTEGER,
    upvote_count INTEGER NOT NULL DEFAULT 0,
    downvote_count INTEGER NOT NULL DEFAULT 0,
    question_count INTEGER NOT NULL DEFAULT 0,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    difficulty_id INTEGER NOT NULL REFERENCES difficulties(id)
);
GRANT ALL ON tests TO t_usr;
GRANT ALL ON tests_id_seq TO t_usr;

CREATE VIEW tests_vw AS(
    SELECT T.*, 
        TOP.name AS topic__name, 
        D.name AS difficulty__name
    FROM tests T
        JOIN topics TOP ON T.topic_id = TOP.id
        JOIN difficulties D ON T.difficulty_id = D.id
);
GRANT ALL ON tests_vw TO t_usr;

CREATE TABLE single_answer_questions(
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL
);
GRANT ALL ON single_answer_questions TO t_usr;
GRANT ALL ON single_answer_questions_id_seq TO t_usr;

CREATE TABLE single_answer_questions_answers(
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT false,
    question_id INTEGER REFERENCES single_answer_questions(id)
);
GRANT ALL ON single_answer_questions_answers TO t_usr;
GRANT ALL ON single_answer_questions_answers_id_seq TO t_usr;

CREATE TABLE questions(
    id SERIAL PRIMARY KEY,
    test_id INTEGER NOT NULL REFERENCES tests(id),
    single_answer_question_id INTEGER REFERENCES single_answer_questions(id)
);
GRANT ALL ON questions TO t_usr;
GRANT ALL ON questions_id_seq TO t_usr;

CREATE TABLE account_ranks(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);
GRANT ALL ON account_ranks TO t_usr;
GRANT ALL ON account_ranks_id_seq TO t_usr;

CREATE TABLE accounts(
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    account_id TEXT NOT NULL UNIQUE DEFAULT md5(now()::text),
    first_name TEXT,
    last_name TEXT,
    rank_id INTEGER REFERENCES account_ranks(id)
);
GRANT ALL ON accounts TO t_usr;
GRANT ALL ON accounts_id_seq TO t_usr;

CREATE VIEW accounts_vw AS(
    SELECT A.*, AR.name AS rank__name
    FROM accounts A 
    JOIN account_ranks AR ON A.rank_id = AR.id  
);
GRANT ALL ON accounts_vw TO t_usr;

CREATE TABLE account_sessions(
    id SERIAL PRIMARY KEY,
    session_token TEXT NOT NULL UNIQUE DEFAULT md5(now()::text),
    account_id TEXT NOT NULL
);
GRANT ALL ON account_sessions TO t_usr;
GRANT ALL ON account_sessions_id_seq TO t_usr;

