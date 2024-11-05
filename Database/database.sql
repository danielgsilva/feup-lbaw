DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Badge CASCADE;
DROP TABLE IF EXISTS Report CASCADE;
DROP TABLE IF EXISTS Tag CASCADE;
DROP TABLE IF EXISTS Question CASCADE;
DROP TABLE IF EXISTS Answer CASCADE;
DROP TABLE IF EXISTS Comment CASCADE;
DROP TABLE IF EXISTS Notification CASCADE;
DROP TABLE IF EXISTS FollowTag CASCADE;
DROP TABLE IF EXISTS FollowQuestion CASCADE;
DROP TABLE IF EXISTS User_Badge CASCADE;
DROP TABLE IF EXISTS QuestionVote CASCADE;
DROP TABLE IF EXISTS AnswerVote CASCADE;


CREATE TABLE IF NOT EXISTS Users (
    id SERIAL PRIMARY KEY,
    admin BOOLEAN DEFAULT FALSE NOT NULL,
    name VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL,
    bio TEXT,
    password VARCHAR(255) NOT NULL,
    score INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE IF NOT EXISTS Badge (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);


CREATE TABLE IF NOT EXISTS Tag (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Question (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reports INTEGER DEFAULT 0,
    votes INTEGER DEFAULT 0,
    edited BOOLEAN DEFAULT FALSE NOT NULL,
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE
);
    
CREATE TABLE IF NOT EXISTS Answer (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    votes INTEGER DEFAULT 0,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reports INTEGER DEFAULT 0,
    accepted BOOLEAN DEFAULT FALSE NOT NULL,
    edited BOOLEAN DEFAULT FALSE NOT NULL,
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    question_id INTEGER REFERENCES Question(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Comment (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reports INTEGER DEFAULT 0,
    edited BOOLEAN DEFAULT FALSE NOT NULL,
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    question_id INTEGER REFERENCES Question(id) ON DELETE CASCADE,
    answer_id INTEGER REFERENCES Answer(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Notification (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    read BOOLEAN DEFAULT FALSE NOT NULL,
    type VARCHAR(255) NOT NULL,
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    answer_id INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    comment_id INTEGER REFERENCES Comment(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Report (
    id SERIAL PRIMARY KEY,
    content TEXT,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    viewed BOOLEAN DEFAULT FALSE NOT NULL,
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    question_id INTEGER REFERENCES Question(id) ON DELETE CASCADE,
    answer_id INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    comment_id INTEGER REFERENCES Comment(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS FollowTag (
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    tag_name VARCHAR(255) REFERENCES Tag(name) ON DELETE CASCADE,
    PRIMARY KEY (user_id, tag_name)
);

CREATE TABLE IF NOT EXISTS FollowQuestion (
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    question_id INTEGER REFERENCES Question(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, question_id)
);

CREATE TABLE IF NOT EXISTS User_Badge (
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    badge_id INTEGER REFERENCES Badge(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, badge_id)
);

CREATE TABLE IF NOT EXISTS QuestionVote (
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    question_id INTEGER REFERENCES Question(id) ON DELETE CASCADE,
    value INTEGER,
    PRIMARY KEY (user_id, question_id)
);

CREATE TABLE IF NOT EXISTS AnswerVote (
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    answer_id INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    value INTEGER,
    PRIMARY KEY (user_id, answer_id)
);

INSERT INTO Users (name, email, bio, password, score) VALUES 
('Alice', 'alice@example.com', 'Bio of Alice', 'password123', 10),
('Bob', 'bob@example.com', 'Bio of Bob', 'password456', 20),
('Charlie', 'charlie@example.com', 'Bio of Charlie', 'password789', 30);

INSERT INTO Badge (name) VALUES 
('Beginner'),
('Intermediate'),
('Expert');

INSERT INTO Tag (name) VALUES 
('Python'),
('JavaScript'),
('SQL');

INSERT INTO Question (title, content, user_id) VALUES 
('How to learn Python?', 'I am new to programming and want to learn Python. Any suggestions?', 1),
('Best practices for JavaScript?', 'What are some best practices for writing clean and efficient JavaScript code?', 2),
('SQL query optimization tips?', 'How can I optimize my SQL queries for better performance?', 3);

INSERT INTO Answer (content, user_id, question_id) VALUES 
('Start with the official Python documentation and tutorials.', 2, 1),
('Use meaningful variable names and avoid global variables.', 3, 2),
('Use indexes and avoid unnecessary columns in SELECT statements.', 1, 3);

INSERT INTO Comment (content, user_id, question_id) VALUES 
('I agree with this answer.', 3, 1),
('This is very helpful, thanks!', 1, 2);

INSERT INTO Notification (title, content, type, user_id) VALUES 
('Welcome!', 'Welcome to our platform, Alice!', 'welcome', 1),
('New badge earned!', 'Congratulations Bob, you have earned the Intermediate badge!', 'badge', 2);

INSERT INTO FollowTag (user_id, tag_name) VALUES 
(1, 'Python'),
(2, 'JavaScript'),
(3, 'SQL');

INSERT INTO FollowQuestion (user_id, question_id) VALUES 
(1, 1),
(2, 2),
(3, 3);

INSERT INTO User_Badge (user_id, badge_id) VALUES 
(1, 1),
(2, 2),
(3, 3);

INSERT INTO QuestionVote (user_id, question_id, value) VALUES 
(1, 1, 1),
(2, 2, 1),
(3, 3, 1);

INSERT INTO AnswerVote (user_id, answer_id, value) VALUES 
(1, 1, 1),
(2, 2, 1),
(3, 3, 1);