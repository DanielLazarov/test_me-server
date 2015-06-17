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
    difficulty_id INTEGER NOT NULL REFERENCES difficulties(id),
    points INT NOT NULL DEFAULT 0
);
GRANT ALL ON tests TO t_usr;
GRANT ALL ON tests_id_seq TO t_usr;


CREATE TABLE question_types(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);
GRANT ALL ON question_types TO t_usr;
GRANT ALL ON question_types_id_seq TO t_usr;
INSERT INTO question_types(name) VALUES('Single Answer'), ('Multiple Answer'), ('Free Answer');

CREATE TABLE questions(
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    points INTEGER NOT NULL,
    test_id INTEGER NOT NULL REFERENCES tests(id),
    type_id INTEGER NOT NULL REFERENCES question_types(id)
);
GRANT ALL ON questions TO t_usr;
GRANT ALL ON questions_id_seq TO t_usr;

CREATE TABLE answers(
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    question_id INTEGER NOT NULL REFERENCES questions(id)
);
GRANT ALL ON answers TO t_usr;
GRANT ALL ON answers_id_seq TO t_usr;

CREATE TABLE correct_answers(
    id SERIAL PRIMARY KEY,
    question_id INTEGER REFERENCES questions(id),
    single INTEGER,
    multiple INTEGER[],
    free TEXT
);
GRANT ALL ON correct_answers TO t_usr;
GRANT ALL ON correct_answers_id_seq TO t_usr;

CREATE TABLE account_ranks(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);
GRANT ALL ON account_ranks TO t_usr;
GRANT ALL ON account_ranks_id_seq TO t_usr;

CREATE TABLE accounts(
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    account_id TEXT NOT NULL UNIQUE DEFAULT md5(now()::text || random()::text),
    first_name TEXT,
    last_name TEXT,
    email TEXT NOT NULL UNIQUE,
    points INTEGER NOT NULL DEFAULT 0,
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

CREATE TABLE test_sessions(
    id SERIAL PRIMARY KEY,
    questions_id INTEGER[],
    test_id INTEGER NOT NULL REFERENCES tests(id),
    account_id INTEGER NOT NULL REFERENCES accounts(id),
    begin_timestamp TIMESTAMP NOT NULL DEFAULT now(),
    end_timestamp TIMESTAMP,
    expires_at TIMESTAMP,
    session_token TEXT NOT NULL UNIQUE DEFAULT md5(now()::text || random()::text),
    is_finished BOOLEAN DEFAULT FALSE
);
GRANT ALL ON test_sessions TO t_usr;
GRANT ALL ON test_sessions_id_seq TO t_usr;

CREATE TABLE test_session_answers(
    id SERIAL PRIMARY KEY,
    test_session_id INTEGER NOT NULL REFERENCES test_sessions(id),
    answered_at TIMESTAMP NOT NULL DEFAULT now(),
    question_id INTEGER NOT NULL REFERENCES questions(id),
    is_true BOOLEAN,
    single_answer_question_answered INTEGER,
    multiple_answer_question_answered INTEGER[],
    free_answer_question_answered TEXT
);
GRANT ALL ON test_session_answers TO t_usr;
GRANT ALL ON test_session_answers_id_seq TO t_usr;

CREATE VIEW available_tests_vw AS (
    SELECT DISTINCT T.* 
    FROM tests T JOIN questions Q ON Q.test_id = T.id
);
GRANT ALL ON available_tests_vw TO t_usr;

CREATE VIEW test_results_vw AS (
    SELECT TSA.*,
        ROW(TS.*)::test_sessions AS row__test_session_id,
        ROW(T.*)::tests AS row__test_id,
        ROW(A.*)::accounts AS row__account_id,
        ROW(Q.*)::questions AS row__question_id,
        ROW(CA.*)::correct_answers AS row__correct_answer
    FROM test_session_answers TSA 
        JOIN test_sessions TS ON TSA.test_session_id = TS.id
            JOIN tests T ON TS.test_id = T.id
            JOIN accounts A ON TS.account_id = A.id
        JOIN questions Q ON TSA.question_id = Q.id
            JOIN correct_answers CA ON CA.question_id = Q.id
);
GRANT ALL ON test_results_vw TO t_usr;

CREATE VIEW tests_vw AS(
    SELECT T.*, 
        TOP.name AS topic__name, 
        D.name AS difficulty__name,
        A.account_id AS account_id
    FROM tests T
        JOIN topics TOP ON T.topic_id = TOP.id
        JOIN difficulties D ON T.difficulty_id = D.id
            LEFT JOIN accounts A ON T.inserted_by = A.username
);
GRANT ALL ON tests_vw TO t_usr;

