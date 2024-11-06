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
DROP TABLE IF EXISTS Image CASCADE;
DROP TABLE IF EXISTS QuestionTag CASCADE;
DROP TRIGGER IF EXISTS question_search_update ON Question;
DROP TRIGGER IF EXISTS tag_search_update ON Tag;
DROP TRIGGER IF EXISTS question_edited ON Question;
DROP TRIGGER IF EXISTS answer_edited ON Answer;
DROP TRIGGER IF EXISTS prevent_self_comment ON Comment;
DROP TRIGGER IF EXISTS prevent_self_answer ON Answer;
DROP TRIGGER IF EXISTS answer_notification ON Answer;
DROP TRIGGER IF EXISTS comment_notification ON Comment;
DROP TRIGGER IF EXISTS update_reports_count ON Report;
DROP TRIGGER IF EXISTS update_user_score_on_vote ON QuestionVote;
DROP TRIGGER IF EXISTS update_user_score_on_answer_vote ON AnswerVote;
DROP TRIGGER IF EXISTS update_user_score_on_acceptance ON Answer;
DROP TRIGGER IF EXISTS trigger_check_author_accept_answer ON Answer;
DROP TRIGGER IF EXISTS trigger_check_duplicate_report ON Report;
DROP TRIGGER IF EXISTS trigger_enforce_single_report_association ON Report;
DROP TRIGGER IF EXISTS trigger_enforce_question_tag_limit ON QuestionTag;
DROP FUNCTION IF EXISTS question_search_update;
DROP FUNCTION IF EXISTS tag_search_update;
DROP FUNCTION IF EXISTS mark_as_edited;
DROP FUNCTION IF EXISTS prevent_self_interaction;
DROP FUNCTION IF EXISTS notify_question_author;
DROP FUNCTION IF EXISTS notify_answer_author;
DROP FUNCTION IF EXISTS update_reports;
DROP FUNCTION IF EXISTS update_user_score;
DROP FUNCTION IF EXISTS check_author_accept_answer;
DROP FUNCTION IF EXISTS check_duplicate_report;
DROP FUNCTION IF EXISTS enforce_single_report_association;
DROP FUNCTION IF EXISTS enforce_question_tag_limit;
DROP FUNCTION IF EXISTS mark_answer_comment_as_edited;
DROP FUNCTION IF EXISTS mark_question_as_edited;



CREATE TABLE IF NOT EXISTS Users (
    id SERIAL PRIMARY KEY,
    admin BOOLEAN DEFAULT FALSE NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    bio TEXT,
    birthdate DATE CONSTRAINT valid_birthdate CHECK (birthdate <= CURRENT_DATE),
    password VARCHAR(255) NOT NULL,
    signUpDate DATE CONSTRAINT valid_signUpDate CHECK (signUpDate <= CURRENT_DATE),
    ban BOOLEAN DEFAULT FALSE NOT NULL,
    score INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE IF NOT EXISTS Tag (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    creation_date DATE DEFAULT CURRENT_DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS Question (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    date DATE DEFAULT CURRENT_DATE NOT NULL,
    reports INTEGER DEFAULT 0 NOT NULL CONSTRAINT valid_reports CHECK (reports >= 0),
    votes INTEGER DEFAULT 0 NOT NULL,
    edited BOOLEAN DEFAULT FALSE NOT NULL,
    id_user INTEGER REFERENCES Users(id) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS Answer (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    date DATE DEFAULT CURRENT_DATE NOT NULL,
    reports INTEGER DEFAULT 0 NOT NULL CONSTRAINT valid_reports CHECK (reports >= 0),
    votes INTEGER DEFAULT 0 NOT NULL,
    accepted BOOLEAN DEFAULT FALSE NOT NULL,
    edited BOOLEAN DEFAULT FALSE NOT NULL,
    id_user INTEGER REFERENCES Users(id) ON DELETE SET NULL,
    id_question INTEGER REFERENCES Question(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Comment (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    date DATE DEFAULT CURRENT_DATE NOT NULL,
    reports INTEGER DEFAULT 0 NOT NULL CONSTRAINT valid_reports CHECK (reports >= 0),
    edited BOOLEAN DEFAULT FALSE NOT NULL,
    id_user INTEGER REFERENCES Users(id) ON DELETE SET NULL,
    id_question INTEGER REFERENCES Question(id) ON DELETE CASCADE,
    id_answer INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    CONSTRAINT valid_comment CHECK ((id_question IS NOT NULL AND id_answer IS NULL) OR (id_question IS NULL AND id_answer IS NOT NULL))
);

CREATE TABLE IF NOT EXISTS QuestionVote (
    id SERIAL PRIMARY KEY,
    id_user INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    id_question INTEGER REFERENCES Question(id) ON DELETE CASCADE,
    value INTEGER CONSTRAINT valid_vote CHECK (value = 1 OR value = -1)
);

CREATE TABLE IF NOT EXISTS AnswerVote (
    id SERIAL PRIMARY KEY,
    id_user INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    id_answer INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    value INTEGER CONSTRAINT valid_vote CHECK (value = 1 OR value = -1)
);

CREATE TABLE IF NOT EXISTS Notification (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    viewed BOOLEAN DEFAULT FALSE NOT NULL,
    id_user INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    id_answer INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    id_comment INTEGER REFERENCES Comment(id) ON DELETE CASCADE,
    id_question_vote INTEGER REFERENCES QuestionVote(id) ON DELETE CASCADE,
    id_answer_vote INTEGER REFERENCES AnswerVote(id) ON DELETE CASCADE,
    CONSTRAINT valid_notification CHECK ((id_answer IS NOT NULL AND id_comment IS NULL AND id_question_vote IS NULL AND id_answer_vote IS NULL) 
    OR (id_answer IS NULL AND id_comment IS NOT NULL AND id_question_vote IS NULL AND id_answer_vote IS NULL) 
    OR (id_answer IS NULL AND id_comment IS NULL AND id_question_vote IS NOT NULL AND id_answer_vote IS NULL) 
    OR (id_answer IS NULL AND id_comment IS NULL AND id_question_vote IS NULL AND id_answer_vote IS NOT NULL))
);

CREATE TABLE IF NOT EXISTS Report (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    date DATE DEFAULT CURRENT_DATE NOT NULL,
    viewed BOOLEAN DEFAULT FALSE NOT NULL,
    id_user INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    id_question INTEGER REFERENCES Question(id) ON DELETE CASCADE,
    id_answer INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    id_comment INTEGER REFERENCES Comment(id) ON DELETE CASCADE,
    CONSTRAINT valid_report CHECK ((id_question IS NOT NULL AND id_answer IS NULL AND id_comment IS NULL) OR (id_question IS NULL AND id_answer IS NOT NULL AND id_comment IS NULL) OR (id_question IS NULL AND id_answer IS NULL AND id_comment IS NOT NULL))
);


CREATE TABLE IF NOT EXISTS FollowTag (
    id_user INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    id_tag INTEGER REFERENCES Tag(id) ON DELETE CASCADE,
    PRIMARY KEY (id_user, id_tag)
);

CREATE TABLE IF NOT EXISTS FollowQuestion (
    id_user INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    id_question INTEGER REFERENCES Question(id) ON DELETE CASCADE,
    PRIMARY KEY (id_user, id_question)
);


CREATE TABLE IF NOT EXISTS Image (
    id SERIAL PRIMARY KEY,
    imagePath VARCHAR(255) NOT NULL,
    id_user INTEGER REFERENCES Users(id) ON DELETE CASCADE,
    id_question INTEGER REFERENCES Question(id) ON DELETE CASCADE,
    CONSTRAINT valid_image CHECK ((id_question IS NOT NULL AND id_user IS NULL) OR (id_question IS NULL AND id_user IS NOT NULL)) --This not in the relational schema (either remove or add to relational schema)
);

CREATE TABLE IF NOT EXISTS QuestionTag (
    id_question INTEGER REFERENCES Question(id) ON DELETE CASCADE,
    id_tag INTEGER REFERENCES Tag(id) ON DELETE CASCADE,
    PRIMARY KEY (id_question, id_tag)
);


CREATE UNIQUE INDEX idx_user_email ON Users (email);

CREATE INDEX idx_question_votes_reports ON Question (votes DESC, reports DESC);

CREATE INDEX idx_answer_question ON Answer (id_question, votes DESC);CLUSTER Answer USING idx_answer_question;


-- Add column to the Question table to store ts_vectors.
ALTER TABLE Question
ADD COLUMN tsvectors TSVECTOR;

-- Create a function to automatically update the ts_vectors.
CREATE FUNCTION question_search_update() RETURNS TRIGGER AS $$
BEGIN
 IF TG_OP = 'INSERT' THEN
        NEW.tsvectors = (
         setweight(to_tsvector('english', NEW.title), 'A') ||
         setweight(to_tsvector('english', NEW.content), 'B')
        );
 END IF;
 IF TG_OP = 'UPDATE' THEN
         IF (NEW.title <> OLD.title OR NEW.content <> OLD.content) THEN
           NEW.tsvectors = (
             setweight(to_tsvector('english', NEW.title), 'A') ||
             setweight(to_tsvector('english', NEW.content), 'B')
           );
         END IF;
 END IF;
 RETURN NEW;
END $$
LANGUAGE plpgsql;

-- Create a trigger before inserting or updating in the Question table.
CREATE TRIGGER question_search_update
 BEFORE INSERT OR UPDATE ON Question
 FOR EACH ROW
 EXECUTE PROCEDURE question_search_update();

-- Create the GIN index for the ts_vectors.
CREATE INDEX question_search_idx ON Question USING GIN (tsvectors); 


ALTER TABLE Tag
ADD COLUMN tsvectors TSVECTOR;

-- Create a function to automatically update the ts_vectors.
CREATE FUNCTION tag_search_update() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.tsvectors = (
            setweight(to_tsvector('english', NEW.name), 'A') ||
            setweight(to_tsvector('english', NEW.creation_date::text), 'B')
        );
    END IF;
    IF TG_OP = 'UPDATE' THEN
        IF (NEW.name <> OLD.name OR NEW.creation_date <> OLD.creation_date) THEN
            NEW.tsvectors = (
                setweight(to_tsvector('english', NEW.name), 'A') ||
                setweight(to_tsvector('english', NEW.creation_date::text), 'B')
            );
        END IF;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

-- Create a trigger before inserting or updating in the Tag table.
CREATE TRIGGER tag_search_update
BEFORE INSERT OR UPDATE ON tag
FOR EACH ROW
EXECUTE PROCEDURE tag_search_update();

-- Create the GIN index for the ts_vectors.
CREATE INDEX search_idx ON Tag USING GIN (tsvectors);


CREATE FUNCTION mark_question_as_edited() RETURNS TRIGGER AS $$
BEGIN
IF TG_OP = 'UPDATE' THEN
IF (NEW.content <> OLD.content OR NEW.title <> OLD.title) THEN
NEW.edited = TRUE;
NEW.date = NOW(); -- Atualizar a data de edição
END IF;
END IF;
RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER question_edited
BEFORE UPDATE ON Question
FOR EACH ROW
EXECUTE PROCEDURE mark_question_as_edited();


CREATE FUNCTION mark_answer_comment_as_edited() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF (NEW.content <> OLD.content) THEN
            NEW.edited = TRUE;
            NEW.date = NOW(); -- Update the edit date
        END IF;
    END IF;
    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER answer_edited
BEFORE UPDATE ON Answer
FOR EACH ROW
EXECUTE PROCEDURE mark_answer_comment_as_edited();

CREATE TRIGGER comment_edited
BEFORE UPDATE ON Comment
FOR EACH ROW
EXECUTE PROCEDURE mark_answer_comment_as_edited();


CREATE FUNCTION prevent_self_interaction() RETURNS TRIGGER AS $$
DECLARE
    post_id_user INTEGER;
BEGIN
IF TG_TABLE_NAME = 'Comment' THEN
        SELECT id_user INTO post_id_user FROM Question WHERE id = NEW.id_question;
ELSIF TG_TABLE_NAME = 'Answer' THEN
        SELECT id_user INTO post_id_user FROM Question WHERE id = NEW.id_question;
END IF;

IF NEW.id_user = post_id_user THEN
RAISE EXCEPTION 'Users cannot review or comment their own posts';
END IF;
RETURN NEW;
END $$
LANGUAGE plpgsql;
  
CREATE TRIGGER prevent_self_comment
BEFORE INSERT ON Comment
FOR EACH ROW
EXECUTE PROCEDURE prevent_self_interaction();
  
CREATE TRIGGER prevent_self_answer
BEFORE INSERT ON Answer
FOR EACH ROW
EXECUTE PROCEDURE prevent_self_interaction();


CREATE FUNCTION notify_question_author() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Notification (date, viewed, id_user, id_answer, id_comment, id_question_vote, id_answer_vote)
    VALUES (
        NOW(),                    -- Data da notificação
        FALSE,                    -- Notificação não lida
        (SELECT id_user FROM Question WHERE id = NEW.id_question),  -- Autor da pergunta
        NEW.id,                   -- id_answer refere-se à nova resposta
        NULL,                     -- id_comment é NULL porque não se aplica
        NULL,                     -- id_question_vote é NULL porque não se aplica
        NULL                      -- id_answer_vote é NULL porque não se aplica
    );
    RETURN NEW;
END $$ 
LANGUAGE plpgsql;

CREATE TRIGGER answer_notification
AFTER INSERT ON Answer
FOR EACH ROW
EXECUTE FUNCTION notify_question_author();


CREATE FUNCTION notify_answer_author() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Notification (date, viewed, id_user, id_answer, id_comment, id_question_vote, id_answer_vote)
    VALUES (
        NOW(),                    -- Data da notificação
        FALSE,                    -- Notificação não lida
        (SELECT id_user FROM Answer WHERE id = NEW.id_answer),  -- Autor da resposta
        NULL,                     -- id_answer é NULL porque não se aplica
        NEW.id,                   -- id_comment refere-se ao novo comentário
        NULL,                     -- id_question_vote é NULL porque não se aplica
        NULL                      -- id_answer_vote é NULL porque não se aplica
    );
    RETURN NEW;
END $$ 
LANGUAGE plpgsql;

CREATE TRIGGER comment_notification
AFTER INSERT ON Comment
FOR EACH ROW
EXECUTE FUNCTION notify_answer_author();


CREATE FUNCTION update_reports() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_question IS NOT NULL THEN
        UPDATE Question
        SET reports = reports + 1
        WHERE id = NEW.id_question;
    ELSIF NEW.id_answer IS NOT NULL THEN
        UPDATE Answer
        SET reports = reports + 1
        WHERE id = NEW.id_answer;
    ELSIF NEW.id_comment IS NOT NULL THEN
        UPDATE Comment
        SET reports = reports + 1
        WHERE id = NEW.id_comment;
    END IF;
    RETURN NEW;
END $$ 
LANGUAGE plpgsql;

CREATE TRIGGER update_reports_count
AFTER INSERT ON Report
FOR EACH ROW
EXECUTE PROCEDURE update_reports();


CREATE FUNCTION update_user_score() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.votes > OLD.votes THEN
        IF NEW.votes - OLD.votes > 0 THEN
            UPDATE Users SET score = score + 10 WHERE id = NEW.id_user;  -- Voto positivo
        ELSE
            UPDATE Users SET score = score - 2 WHERE id = NEW.id_user;   -- Voto negativo
        END IF;
    ELSIF NEW.accepted = TRUE THEN
        UPDATE Users SET score = score + 15 WHERE id = NEW.id_user;  -- Resposta aceita
        UPDATE Users SET score = score + 2 WHERE id = (SELECT id_user FROM Question WHERE id = NEW.id_question);  -- Usuário que fez a pergunta
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE Users SET score = score - 100 WHERE id = OLD.id_user;  -- Penalização
    END IF;
    RETURN NEW;
END $$ 
LANGUAGE plpgsql;

CREATE TRIGGER update_user_score_on_vote
AFTER INSERT OR UPDATE ON QuestionVote
FOR EACH ROW
EXECUTE PROCEDURE update_user_score();

CREATE TRIGGER update_user_score_on_answer_vote
AFTER INSERT OR UPDATE ON AnswerVote
FOR EACH ROW
EXECUTE PROCEDURE update_user_score();

CREATE TRIGGER update_user_score_on_acceptance
AFTER UPDATE ON Answer
FOR EACH ROW
WHEN (NEW.accepted = TRUE)
EXECUTE PROCEDURE update_user_score();


CREATE OR REPLACE FUNCTION check_author_accept_answer() 
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar se o utilizador que tenta marcar a resposta como aceita é o autor da pergunta
    IF NEW.accepted = TRUE THEN
        PERFORM 1 
        FROM Question 
        WHERE id = NEW.id_question AND id_user = NEW.id_user;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Only the author of the question can accept an answer';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_author_accept_answer
BEFORE UPDATE OF accepted ON Answer
FOR EACH ROW
WHEN (OLD.accepted = FALSE AND NEW.accepted = TRUE)
EXECUTE FUNCTION check_author_accept_answer();


CREATE OR REPLACE FUNCTION check_duplicate_report() 
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar se já existe um report do mesmo utilizador para a mesma entidade
    IF EXISTS (
        SELECT 1
        FROM Report
        WHERE id_user = NEW.id_user 
        AND (
            (id_question IS NOT NULL AND id_question = NEW.id_question) OR 
            (id_answer IS NOT NULL AND id_answer = NEW.id_answer) OR 
            (id_comment IS NOT NULL AND id_comment = NEW.id_comment)
        )
    ) THEN
        RAISE EXCEPTION 'User cannot report the same entity more than once';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_duplicate_report
BEFORE INSERT ON Report
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_report();


CREATE OR REPLACE FUNCTION enforce_single_report_association() 
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar se o report está associado a apenas uma entidade
    IF (NEW.id_answer IS NOT NULL)::int + (NEW.id_comment IS NOT NULL)::int + (NEW.id_question IS NOT NULL)::int <> 1 THEN
        RAISE EXCEPTION 'A report must be associated with only one of: answer, comment, or question';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_enforce_single_report_association
BEFORE INSERT OR UPDATE ON Report
FOR EACH ROW
EXECUTE FUNCTION enforce_single_report_association();


CREATE OR REPLACE FUNCTION enforce_question_tag_limit() 
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar o número de tags associadas à pergunta
    IF (SELECT COUNT(*) FROM QuestionTag WHERE id_question = NEW.id_question) >= 5 THEN
        RAISE EXCEPTION 'A question can be associated with a maximum of 5 tags';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_enforce_question_tag_limit
BEFORE INSERT ON QuestionTag
FOR EACH ROW
EXECUTE FUNCTION enforce_question_tag_limit();



INSERT INTO Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) VALUES
(FALSE, 'user_with_questions', 'User One', 'user_with_questions@example.com', 'Bio of user one', '1990-01-01', 'password1', '2023-01-01', FALSE, 10), -- User with questions
(FALSE, 'user_with_answers', 'User Two', 'user_with_answers@example.com', 'Bio of user two', '1991-02-02', 'password2', '2023-02-02', FALSE, 20), -- User with answers
(FALSE, 'user_with_both', 'User Three', 'user_with_both@example.com', 'Bio of user three', '1992-03-03', 'password3', '2023-03-03', FALSE, 30), -- User with both questions and answers
(FALSE, 'user_with_notifications', 'User Four', 'user_with_notifications@example.com', 'Bio of user four', '1993-04-04', 'password4', '2023-04-04', FALSE, 40), -- User with notifications
(FALSE, 'user_follow_tags', 'User Five', 'user_follow_tags@example.com', 'Bio of user five', '1994-05-05', 'password5', '2023-05-05', FALSE, 50), -- User following tags
(FALSE, 'user_with_reports', 'User Six', 'user_with_reports@example.com', 'Bio of user six', '1995-06-06', 'password6', '2023-06-06', FALSE, 60), -- User with reports
(FALSE, 'banned_user', 'User Seven', 'banned_user@example.com', 'Bio of user seven', '1996-07-07', 'password7', '2023-07-07', TRUE, 70), -- Banned user with multiple reports
(TRUE, 'admin1', 'Admin One', 'admin1@example.com', 'Bio of admin one', '1985-01-01', 'adminpassword', '2023-01-01', FALSE, 100); -- Admin user

INSERT INTO Tag (name) VALUES
('tag1'),
('tag2'),
('tag3');

INSERT INTO Question (title, content, date, reports, votes, edited, id_user) VALUES
('Question 1', 'Content of question 1', '2023-01-01', 0, 5, FALSE, 1), -- Question by user_with_questions
('Question 2', 'Content of question 2', '2023-02-02', 0, 3, FALSE, 3), -- Question by user_with_both
('Edited Question', 'Content of edited question', '2023-03-01', 0, 10, TRUE, 1), -- Edited question by user_with_questions
('Question by banned_user', 'Content of question by banned_user', '2023-04-01', 3, -2, FALSE, 7); -- Question by banned_user with multiple reports

INSERT INTO Answer (content, date, reports, votes, accepted, edited, id_user, id_question) VALUES
('Answer 1 to question 1', '2023-01-02', 0, 2, FALSE, FALSE, 2, 1), -- Answer by user_with_answers
('Answer 2 to question 2', '2023-02-03', 0, 4, TRUE, FALSE, 3, 2), -- Answer by user_with_both
('Edited Answer', '2023-03-02', 0, 8, FALSE, TRUE, 2, 1); -- Edited answer by user_with_answers

INSERT INTO Comment (content, date, reports, edited, id_user, id_question, id_answer) VALUES
('Comment on question 1', '2023-01-03', 0, FALSE, 3, 1, NULL), -- Comment by user_with_both on question 1
('Comment on answer 1', '2023-01-04', 0, FALSE, 1, NULL, 1); -- Comment by user_with_questions on answer 1

INSERT INTO Notification (date, viewed, id_user, id_answer, id_comment, id_question_vote, id_answer_vote) VALUES
('2023-01-05 10:00:00', FALSE, 4, 1, NULL, NULL, NULL), -- Notification for user_with_notifications
('2023-01-06 11:00:00', TRUE, 4, 1, NULL, NULL, NULL); -- Notification for user_with_notifications related to answer 1

INSERT INTO FollowTag (id_user, id_tag) VALUES
(5, 1), -- user_follow_tags following tag1
(5, 2); -- user_follow_tags following tag2

INSERT INTO Report (content, date, viewed, id_user, id_question, id_answer, id_comment) VALUES
('Report on question 1', '2023-01-07', FALSE, 6, 1, NULL, NULL), -- Report by user_with_reports on question 1
('Report on answer 1', '2023-01-08', FALSE, 6, NULL, 1, NULL), -- Report by user_with_reports on answer 1
('Report on comment 1', '2023-01-09', FALSE, 6, NULL, NULL, 1), -- Report by user_with_reports on comment 1
('Report on question 2', '2023-01-10', FALSE, 7, 2, NULL, NULL), -- Report by banned_user on question 2
('Report on answer 2', '2023-01-11', FALSE, 7, NULL, 2, NULL), -- Report by banned_user on answer 2
('Report on question by banned_user', '2023-04-02', FALSE, 1, 4, NULL, NULL), -- Report by user_with_questions on question by banned_user
('Report on question by banned_user', '2023-04-03', FALSE, 2, 4, NULL, NULL), -- Report by user_with_answers on question by banned_user
('Report on question by banned_user', '2023-04-04', FALSE, 3, 4, NULL, NULL); -- Report by user_with_both on question by banned_user

--mockaroo data
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'tgeke8', 'Tybi Geke', 'tgeke8@wikimedia.org', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', '1947-07-02', 'gF0)3W\={1<H.b?a', '2024-11-02', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'jwiffler9', 'Jess Wiffler', 'jwiffler9@plala.or.jp', 'Phasellus sit amet erat.', '1937-07-17', 'xX0,6v~#=zI6I"O', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'gvarnalsa', 'Garry Varnals', 'gvarnalsa@blogtalkradio.com', 'Duis consequat dui nec nisi volutpat eleifend.', '1950-08-23', 'tD6$bYzhWp?', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'hduchatelb', 'Hamnet Duchatel', 'hduchatelb@clickbank.net', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', '2024-10-20', 'zW6=Y)r`/dt', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'ebritianc', 'Everett Britian', 'ebritianc@bizjournals.com', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', '1931-04-03', 'yI4&*Lr>i', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'cmateud', 'Clyve Mateu', 'cmateud@cdc.gov', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', '1910-11-14', 'fB6/3vYdG', '2024-11-02', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'garnholze', 'Gilbert Arnholz', 'garnholze@1und1.de', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '1987-01-05', 'lA9|Lf01z6z', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'imcauslandf', 'Ingeberg McAusland', 'imcauslandf@elpais.com', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.', '1980-11-06', 'pW6{yq,!', '2024-11-03', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'lbadrockg', 'Lilah Badrock', 'lbadrockg@nba.com', 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', '1966-07-22', 'qN8"EG4m&)', '2024-11-03', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'whyamh', 'Wanids Hyam', 'whyamh@biglobe.ne.jp', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '1940-07-31', 'rU4@58aRJV', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'ljocklei', 'Lucas Jockle', 'ljocklei@mit.edu', 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '1936-02-01', 'kK4~9y@a', '2024-11-03', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'rduligalj', 'Ruthy Duligal', 'rduligalj@imgur.com', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', '1961-04-18', 'iF2/X)SzkK)k', '2024-11-03', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'cklemencick', 'Chloe Klemencic', 'cklemencick@youtu.be', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '1901-03-30', 'zW4*PAO9TXEv', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'snorwichl', 'Skipton Norwich', 'snorwichl@acquirethisname.com', 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', '1924-04-06', 'hV0%1DT&!b''', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'lcankettm', 'Lem Cankett', 'lcankettm@delicious.com', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.', '1942-01-28', 'yX1.2t$"MJ', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'lfathersn', 'Lonna Fathers', 'lfathersn@walmart.com', 'Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '1940-11-17', 'iA3?VP=N`C%', '2024-11-02', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'acamingso', 'Arther Camings', 'acamingso@youtu.be', 'Fusce consequat.', '1947-07-20', 'hN0!Y@@aV', '2024-11-03', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'tfleethamp', 'Thibaud Fleetham', 'tfleethamp@altervista.org', 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', '1920-05-07', 'lO2_tw97', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'ecolloughq', 'Elset Collough', 'ecolloughq@exblog.jp', 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '1993-06-24', 'fK7|uG=dY3d$KY4''', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'mkonzelmannr', 'Mercedes Konzelmann', 'mkonzelmannr@businessweek.com', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.', '1981-10-01', 'sA0>p`qihU6`d%6q', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'azohrers', 'Aeriell Zohrer', 'azohrers@geocities.jp', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', '1983-07-05', 'jQ7|d1.u', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'rorablet', 'Risa Orable', 'rorablet@wikispaces.com', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', '1903-01-29', 'mD7=JFs7}V', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'nkingettu', 'Nils Kingett', 'nkingettu@cocolog-nifty.com', 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', '1905-11-23', 'bD5@HdmkpFY', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'kkingsnoadv', 'Kalindi Kingsnoad', 'kkingsnoadv@dailymail.co.uk', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '1929-03-14', 'cL7=z6H|+A', '2024-11-03', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'jcudmorew', 'Jorrie Cudmore', 'jcudmorew@taobao.com', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', '1908-06-11', 'vQ2,(obrI6{"W2tz', '2024-11-03', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'fpaxefordx', 'Farlay Paxeford', 'fpaxefordx@live.com', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', '1923-07-06', 'gD7|GM.Z7*t#K)D~', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'kpizeyy', 'Kaylyn Pizey', 'kpizeyy@forbes.com', 'Nulla ut erat id mauris vulputate elementum. Nullam varius.', '1916-07-05', 'wP0$#O~))nHu*}', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'thallgatez', 'Tamera Hallgate', 'thallgatez@sfgate.com', 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', '1904-10-11', 'fS0=DL>?', '2024-11-03', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'gsurcomb10', 'Giovanna Surcomb', 'gsurcomb10@boston.com', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor.', '1990-05-18', 'nI0?Fmsps', '2024-11-02', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'swickins11', 'Shandee Wickins', 'swickins11@g.co', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', '1980-11-26', 'eC4~2=4Pgb#~q', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'agrass12', 'Ashly Grass', 'agrass12@nytimes.com', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '1942-02-15', 'cQ0#Q9IT2<FYk8', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'nmacilurick13', 'Niles MacIlurick', 'nmacilurick13@chicagotribune.com', 'Morbi a ipsum.', '1963-05-05', 'xZ4!_`,Z}*X4o', '2024-11-02', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'binsworth14', 'Byrom Insworth', 'binsworth14@mtv.com', 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', '1990-10-08', 'gG2)vv?J<Ah(K', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'efessions15', 'Ernesta Fessions', 'efessions15@hugedomains.com', 'Proin at turpis a pede posuere nonummy.', '1945-07-31', 'wE6~|v6m', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'abaford16', 'Anica Baford', 'abaford16@hubpages.com', 'Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '1985-11-18', 'tY0$8_!kx}d=', '2024-11-02', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'esayle17', 'Eleen Sayle', 'esayle17@facebook.com', 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', '1929-09-10', 'lB8?*mKb)H', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'svaladez18', 'Sid Valadez', 'svaladez18@shop-pro.jp', 'Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', '2016-07-10', 'hH8*v3ttQh0ir!', '2024-11-03', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'fryding19', 'Florence Ryding', 'fryding19@upenn.edu', 'In eleifend quam a odio.', '1925-10-28', 'fH0~nFWH', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'fgrishmanov1a', 'Fayina Grishmanov', 'fgrishmanov1a@nsw.gov.au', 'In hac habitasse platea dictumst.', '2013-03-04', 'fK3@}uQtt`+', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'fjoan1b', 'Farrah Joan', 'fjoan1b@hugedomains.com', 'Duis consequat dui nec nisi volutpat eleifend.', '2001-10-29', 'bI6}Pg>H7', '2024-11-03', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'ahuggons1c', 'Aloise Huggons', 'ahuggons1c@epa.gov', 'In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '2022-09-07', 'oC1"BD}''sswOu+g', '2024-11-03', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'rclaw1d', 'Ramon Claw', 'rclaw1d@behance.net', 'Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2008-12-18', 'lB2&+RnTsljYi', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'oboston1e', 'Olva Boston', 'oboston1e@baidu.com', 'Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', '1981-04-08', 'zD5{V`11', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'cfluger1f', 'Colene Fluger', 'cfluger1f@smh.com.au', 'Duis aliquam convallis nunc.', '1942-02-26', 'nU1_$@j7j2', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'spetrashkov1g', 'Sharity Petrashkov', 'spetrashkov1g@blogs.com', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', '1924-03-28', 'oT0~jVG/}F7ZJ+u', '2024-11-02', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'mbaude1h', 'Marlo Baude', 'mbaude1h@ftc.gov', 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.', '2008-07-12', 'gR9@~4{#i|y$Eg12', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'jmacvanamy1i', 'Jaymee MacVanamy', 'jmacvanamy1i@ycombinator.com', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui.', '1993-11-14', 'gV3.04PP', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'jjeger1j', 'Jilli Jeger', 'jjeger1j@illinois.edu', 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', '1972-05-06', 'vW0\k{,7M', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'sarchambault1k', 'Skyler Archambault', 'sarchambault1k@bloomberg.com', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', '1993-08-07', 'tY9<5MG>', '2024-11-02', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'agorvette1l', 'Arron Gorvette', 'agorvette1l@amazon.com', 'Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '1957-05-25', 'dR4$#I3utsk', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'agrantham1m', 'Aidan Grantham', 'agrantham1m@vistaprint.com', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', '1904-10-15', 'eD8&K{HN', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'sogborne1n', 'Sean Ogborne', 'sogborne1n@bloglines.com', 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', '1958-08-10', 'yY8\L,o=H&A6jU', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'cgreen1o', 'Caddric Green', 'cgreen1o@smh.com.au', 'Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '1996-06-06', 'pZ0.>{d&CQ{F>', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'omckomb1p', 'Octavia McKomb', 'omckomb1p@cbc.ca', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', '1938-04-30', 'rD0\TZ%szhI_yg&', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'fdundridge1q', 'Florina Dundridge', 'fdundridge1q@unesco.org', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo.', '1955-02-19', 'zR5>Df$Z', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'shuffy1r', 'Skipton Huffy', 'shuffy1r@ibm.com', 'Mauris sit amet eros.', '2001-09-11', 'iE5~,\\}=r=N9', '2024-11-03', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'kmaccafferty1s', 'Katharyn MacCafferty', 'kmaccafferty1s@ezinearticles.com', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', '2023-03-31', 'uN8#@tW`gJo', '2024-11-02', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'ccalyton1t', 'Crosby Calyton', 'ccalyton1t@wikipedia.org', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', '2005-09-21', 'vY2*smy1/qqi7g>', '2024-11-02', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'genstone1u', 'Gracia Enstone', 'genstone1u@nifty.com', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', '1918-08-09', 'jY2{<qan\4So', '2024-11-03', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'dduckett1v', 'Darbee Duckett', 'dduckett1v@hibu.com', 'Nullam molestie nibh in lectus. Pellentesque at nulla.', '1926-07-12', 'qE2)>HBxYl7qM4', '2024-11-03', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'jmccree1w', 'Jervis McCree', 'jmccree1w@sciencedaily.com', 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.', '2004-07-14', 'pM6.pq!d"', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'pgonsalo1x', 'Paxton Gonsalo', 'pgonsalo1x@alexa.com', 'In hac habitasse platea dictumst.', '1941-07-21', 'tA9*_W9gH~6', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'mpeniman1y', 'Marina Peniman', 'mpeniman1y@gravatar.com', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst.', '2017-01-06', 'yD3~C98p', '2024-11-02', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'dreiach1z', 'Ddene Reiach', 'dreiach1z@java.com', 'Fusce consequat.', '2011-12-24', 'aZ7}Y>px0s@P,', '2024-11-02', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'smein20', 'Sauveur Mein', 'smein20@yandex.ru', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', '1963-09-16', 'bH8''x''y/vu', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'cclawsley21', 'Carolyn Clawsley', 'cclawsley21@odnoklassniki.ru', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '1935-09-01', 'wP6*gxs\A5vK(', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'cyankov22', 'Consuelo Yankov', 'cyankov22@intel.com', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.', '1985-03-28', 'eM8/MHv&rDX5W"7', '2024-11-02', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'csliney23', 'Carena Sliney', 'csliney23@amazon.co.jp', 'Nam nulla.', '2014-08-02', 'mY7%m@(r.)', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'cballston24', 'Conn Ballston', 'cballston24@apache.org', 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', '1968-11-04', 'nX7}J|cY<\I9h_v', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'nhaighton25', 'Nickola Haighton', 'nhaighton25@nhs.uk', 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.', '1975-02-13', 'aE9$wu,z3o3cPCgL', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'jlotze26', 'Janessa Lotze', 'jlotze26@github.io', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', '1949-07-12', 'rK2#t''fYusa?hc_', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'mfrede27', 'Mariam Frede', 'mfrede27@unc.edu', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', '1952-03-23', 'rJ6(du+{', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'srenals28', 'Sol Renals', 'srenals28@cnn.com', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor.', '1987-02-11', 'qI1~jT4zzmytel>&', '2024-11-03', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'jkubat29', 'Job Kubat', 'jkubat29@github.io', 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', '1901-01-04', 'tE4#3V.4g`', '2024-11-03', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'ranthony2a', 'Ronny Anthony', 'ranthony2a@slate.com', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '1918-08-01', 'fE6,V2EQ"', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'fkime2b', 'Fernando Kime', 'fkime2b@istockphoto.com', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', '1901-04-10', 'fP9%IvE<)f', '2024-11-02', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'rbothen2c', 'Ricki Bothen', 'rbothen2c@bigcartel.com', 'Maecenas pulvinar lobortis est.', '2015-06-17', 'cY7==($`n{', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'nsaket2d', 'Nadeen Saket', 'nsaket2d@blog.com', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.', '1929-01-10', 'rQ6,vkljtdb7', '2024-11-02', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'bgrinaway2e', 'Bethina Grinaway', 'bgrinaway2e@networksolutions.com', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', '1913-07-02', 'lJ4*UNJm*Z*b2s8.', '2024-11-02', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'mgronous2f', 'Miriam Gronous', 'mgronous2f@lulu.com', 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', '1927-12-08', 'oP2<0"n+M<O', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'lgalway2g', 'Lindon Galway', 'lgalway2g@cam.ac.uk', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', '1960-10-08', 'hO5`=5A+,b49e', '2024-11-04', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'mcarayol2h', 'Maryanna Carayol', 'mcarayol2h@unc.edu', 'Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', '1951-11-18', 'sX3&(\Fd{GiP%8m', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'pbrian2i', 'Pryce Brian', 'pbrian2i@theatlantic.com', 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', '1962-08-18', 'dA6?($1N5z$1', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'lmabon2j', 'Leroy Mabon', 'lmabon2j@wiley.com', 'Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend.', '1969-12-15', 'nX2&.+F~%k/SrU1', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'ktrusler2k', 'Katusha Trusler', 'ktrusler2k@washingtonpost.com', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', '1951-03-05', 'tS1=s2Glc''Sy', '2024-11-01', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'ktreneman2l', 'Kort Treneman', 'ktreneman2l@wsj.com', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', '1978-09-27', 'eR8~$4uGZA_Y!`', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'achampniss2m', 'Alasteir Champniss', 'achampniss2m@godaddy.com', 'Donec vitae nisi.', '1996-03-11', 'iA6=*/.,~evn_', '2024-11-01', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'qtebbe2n', 'Quincey Tebbe', 'qtebbe2n@latimes.com', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.', '1997-04-04', 'cY4{vT)i>l2,', '2024-11-04', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'lswepstone2o', 'Lester Swepstone', 'lswepstone2o@gnu.org', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '2019-06-07', 'oH3&ADM9=kq', '2024-11-03', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'ncracknell2p', 'Natividad Cracknell', 'ncracknell2p@google.cn', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', '1901-10-02', 'cN4%yIARZ', '2024-11-03', true, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (false, 'wbartosiak2q', 'Weidar Bartosiak', 'wbartosiak2q@yellowpages.com', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', '1943-09-06', 'uW2*5H6"', '2024-11-03', false, 0);
insert into Users (admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) values (true, 'cgerbi2r', 'Celestine Gerbi', 'cgerbi2r@bluehost.com', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus.', '1925-06-11', 'kR5.1zn8B}T', '2024-11-02', true, 0);


insert into Question (title, content, date, reports, votes, edited, id_user) values ('Phasellus in felis.', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '2024-11-03', 29, -44, false, 4);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.', '2024-11-04', 44, 190, false, 53);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', 'Nulla ut erat id mauris vulputate elementum. Nullam varius.', '2024-11-04', 75, -301, true, 80);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '2024-11-04', 59, 292, true, 72);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('In eleifend quam a odio.', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', '2024-11-01', 54, 359, true, 2);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Duis aliquam convallis nunc.', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio.', '2024-11-04', 43, 198, true, 45);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', '2024-11-02', 8, 966, true, 11);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Donec quis orci eget orci vehicula condimentum.', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', '2024-11-04', 59, 50, false, 26);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', 'In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', '2024-11-01', 27, -699, false, 37);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', '2024-11-02', 94, -659, true, 99);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Praesent id massa id nisl venenatis lacinia.', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue.', '2024-11-03', 65, 576, true, 98);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 'Nunc rhoncus dui vel sem. Sed sagittis.', '2024-11-04', 94, 447, true, 57);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend.', '2024-11-04', 29, 882, false, 8);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('In eleifend quam a odio.', 'Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', '2024-11-02', 92, -891, false, 39);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nam nulla.', 'Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', '2024-11-04', 94, -817, false, 60);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Morbi quis tortor id nulla ultrices aliquet.', 'Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '2024-11-04', 68, -713, true, 50);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Vivamus vel nulla eget eros elementum pellentesque.', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat.', '2024-11-03', 24, 45, false, 94);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('In hac habitasse platea dictumst.', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', '2024-11-03', 39, 757, false, 49);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Pellentesque ultrices mattis odio.', 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', '2024-11-04', 56, 629, true, 98);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Cras in purus eu magna vulputate luctus.', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '2024-11-04', 96, -635, true, 87);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', '2024-11-04', 43, -987, false, 52);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', '2024-11-03', 78, -635, true, 98);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Suspendisse potenti.', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', '2024-11-04', 94, -716, true, 83);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('In hac habitasse platea dictumst.', 'In blandit ultrices enim.', '2024-11-02', 80, -502, true, 37);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Praesent id massa id nisl venenatis lacinia.', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', '2024-11-02', 63, 748, true, 54);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nam tristique tortor eu pede.', 'Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', '2024-11-02', 55, -231, true, 91);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Vestibulum ac est lacinia nisi venenatis tristique.', 'Nulla tellus. In sagittis dui vel nisl.', '2024-11-01', 91, -503, false, 85);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2024-11-03', 29, -112, true, 14);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Morbi a ipsum.', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', '2024-11-02', 47, -28, true, 35);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', '2024-11-01', 12, -385, false, 27);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Praesent blandit.', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', '2024-11-03', 3, -953, true, 75);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '2024-11-01', 25, 46, false, 5);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.', '2024-11-02', 1, -855, false, 68);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Suspendisse potenti.', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', '2024-11-03', 79, 695, false, 98);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Mauris sit amet eros.', 'In congue.', '2024-11-02', 42, 22, false, 5);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nam dui.', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', '2024-11-01', 16, -603, false, 96);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Quisque id justo sit amet sapien dignissim vestibulum.', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', '2024-11-02', 69, -383, false, 94);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', '2024-11-02', 1, 110, false, 6);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Suspendisse accumsan tortor quis turpis.', 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', '2024-11-04', 72, -661, false, 44);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Donec ut dolor.', 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '2024-11-03', 18, 241, false, 1);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Suspendisse ornare consequat lectus.', 'Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', '2024-11-03', 95, -932, false, 8);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nulla ut erat id mauris vulputate elementum.', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue.', '2024-11-03', 33, 315, false, 23);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Phasellus sit amet erat.', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '2024-11-01', 7, -180, true, 75);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Mauris lacinia sapien quis libero.', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui.', '2024-11-03', 83, -983, false, 21);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nam dui.', 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', '2024-11-01', 85, 436, true, 52);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', '2024-11-02', 49, 215, true, 41);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('In blandit ultrices enim.', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.', '2024-11-01', 74, -307, true, 72);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Pellentesque at nulla.', 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '2024-11-01', 46, 444, false, 14);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Aliquam quis turpis eget elit sodales scelerisque.', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', '2024-11-02', 65, 843, false, 14);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('In hac habitasse platea dictumst.', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', '2024-11-01', 6, -301, false, 56);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', 'Suspendisse potenti.', '2024-11-01', 56, 803, true, 90);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', '2024-11-04', 4, -18, false, 86);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nam tristique tortor eu pede.', 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', '2024-11-03', 19, 348, true, 77);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', '2024-11-02', 78, 263, false, 86);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Praesent blandit.', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '2024-11-03', 99, -955, true, 42);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Aliquam quis turpis eget elit sodales scelerisque.', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', '2024-11-04', 7, 357, false, 52);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Cras pellentesque volutpat dui.', 'In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.', '2024-11-01', 99, 74, true, 19);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '2024-11-04', 21, 140, false, 45);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Donec vitae nisi.', 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '2024-11-03', 45, -657, true, 37);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Cras in purus eu magna vulputate luctus.', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', '2024-11-03', 27, 808, false, 88);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', '2024-11-02', 47, 917, true, 85);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Sed vel enim sit amet nunc viverra dapibus.', 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.', '2024-11-03', 24, -583, true, 32);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Pellentesque eget nunc.', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', '2024-11-01', 75, 829, false, 69);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nulla mollis molestie lorem.', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '2024-11-01', 77, 661, true, 18);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Vivamus vestibulum sagittis sapien.', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', '2024-11-02', 13, -168, false, 25);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Proin at turpis a pede posuere nonummy.', 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', '2024-11-02', 80, -116, false, 12);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', '2024-11-02', 47, -613, true, 51);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Quisque porta volutpat erat.', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio.', '2024-11-02', 91, -192, true, 15);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', '2024-11-04', 5, 473, false, 94);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', '2024-11-04', 51, 459, true, 85);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nullam porttitor lacus at turpis.', 'Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst.', '2024-11-01', 47, 707, false, 66);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Maecenas pulvinar lobortis est.', 'Cras pellentesque volutpat dui.', '2024-11-01', 82, -942, false, 20);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Duis bibendum.', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '2024-11-02', 76, -595, true, 58);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('In sagittis dui vel nisl.', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '2024-11-04', 1, -75, false, 59);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nulla ut erat id mauris vulputate elementum.', 'Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.', '2024-11-04', 50, 594, false, 39);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nullam varius.', 'Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', '2024-11-01', 15, 249, true, 39);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nullam sit amet turpis elementum ligula vehicula consequat.', 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh.', '2024-11-02', 80, 818, true, 38);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', 'Suspendisse accumsan tortor quis turpis. Sed ante.', '2024-11-04', 47, -450, false, 94);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Etiam justo.', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '2024-11-03', 54, -837, true, 80);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Duis bibendum.', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', '2024-11-02', 46, -91, true, 56);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Vivamus vel nulla eget eros elementum pellentesque.', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', '2024-11-02', 19, 973, true, 5);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('In hac habitasse platea dictumst.', 'Duis ac nibh.', '2024-11-01', 81, -743, true, 79);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Fusce consequat.', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', '2024-11-02', 60, -359, false, 84);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.', '2024-11-01', 44, 184, true, 85);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', '2024-11-04', 39, -61, true, 54);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero.', '2024-11-02', 36, 52, false, 49);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', 'Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '2024-11-02', 31, -550, true, 53);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 'Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo.', '2024-11-03', 92, -663, true, 78);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Pellentesque eget nunc.', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', '2024-11-01', 14, 890, true, 73);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Suspendisse potenti.', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', '2024-11-04', 53, 490, true, 32);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', '2024-11-03', 80, -393, true, 28);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Donec dapibus.', 'Nulla tellus. In sagittis dui vel nisl.', '2024-11-04', 98, 542, true, 97);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Curabitur gravida nisi at nibh.', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '2024-11-04', 5, -193, true, 19);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Integer non velit.', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '2024-11-04', 97, -285, true, 21);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nulla mollis molestie lorem.', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti.', '2024-11-03', 35, 336, true, 35);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Aenean auctor gravida sem.', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '2024-11-01', 39, 518, true, 31);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Duis consequat dui nec nisi volutpat eleifend.', 'Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', '2024-11-02', 60, 942, true, 9);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Etiam pretium iaculis justo.', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', '2024-11-02', 77, -801, false, 15);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Nullam molestie nibh in lectus.', 'Quisque ut erat.', '2024-11-01', 26, -305, true, 90);
insert into Question (title, content, date, reports, votes, edited, id_user) values ('Praesent blandit lacinia erat.', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', '2024-11-03', 75, 895, true, 85);


insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', '2024-11-01', 41, -925, false, true, 54, 39);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '2024-11-01', 7, -961, true, false, 73, 7);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.', '2024-11-04', 40, 361, false, true, 68, 42);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.', '2024-11-03', 27, -516, false, false, 13, 54);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '2024-11-01', 22, 503, false, false, 62, 51);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.', '2024-11-02', 74, -755, false, true, 70, 24);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', '2024-11-04', 52, 251, true, true, 96, 44);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nullam varius.', '2024-11-04', 50, -589, false, false, 56, 87);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', '2024-11-04', 4, -729, false, true, 82, 7);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', '2024-11-04', 91, 618, true, true, 36, 52);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', '2024-11-04', 65, 984, false, true, 21, 56);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.', '2024-11-04', 93, 485, false, false, 59, 87);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.', '2024-11-02', 34, -92, false, false, 59, 58);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', '2024-11-04', 71, 82, true, false, 25, 28);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', '2024-11-02', 11, 575, true, false, 53, 79);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2024-11-03', 67, 557, false, true, 19, 14);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', '2024-11-02', 77, -61, false, true, 27, 59);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl.', '2024-11-01', 47, -689, false, false, 72, 69);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.', '2024-11-03', 47, 652, false, false, 87, 8);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', '2024-11-01', 78, 231, false, true, 73, 91);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat.', '2024-11-03', 69, -902, true, true, 82, 91);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', '2024-11-02', 2, 437, false, true, 36, 12);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Proin eu mi. Nulla ac enim.', '2024-11-04', 31, 102, false, true, 51, 1);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '2024-11-04', 48, 835, false, true, 93, 51);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Integer a nibh.', '2024-11-01', 90, 388, true, true, 15, 99);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', '2024-11-03', 94, -423, true, false, 73, 53);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', '2024-11-02', 67, 6, false, true, 44, 4);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis.', '2024-11-01', 40, -10, true, false, 47, 4);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque.', '2024-11-03', 27, -193, true, false, 25, 65);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nullam molestie nibh in lectus. Pellentesque at nulla.', '2024-11-03', 31, 377, false, true, 18, 27);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '2024-11-04', 85, 74, true, true, 43, 96);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nam nulla.', '2024-11-01', 78, -458, true, true, 61, 67);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Duis bibendum. Morbi non quam nec dui luctus rutrum.', '2024-11-04', 20, -956, false, false, 51, 87);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', '2024-11-04', 94, -891, false, true, 49, 49);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '2024-11-03', 68, -364, true, true, 26, 57);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', '2024-11-02', 73, 90, false, true, 6, 2);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', '2024-11-01', 75, 98, false, true, 8, 37);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '2024-11-03', 52, -723, true, false, 19, 24);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', '2024-11-01', 44, -84, false, false, 51, 39);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.', '2024-11-04', 2, -972, false, false, 18, 50);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.', '2024-11-01', 48, -637, true, true, 45, 8);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', '2024-11-01', 11, 951, true, true, 47, 47);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', '2024-11-01', 35, 137, false, true, 40, 83);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis.', '2024-11-01', 76, 842, false, true, 96, 62);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', '2024-11-04', 20, 701, false, true, 91, 68);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '2024-11-03', 87, 835, false, true, 56, 38);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis.', '2024-11-04', 15, -607, false, false, 29, 31);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', '2024-11-03', 14, 32, true, false, 32, 87);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl.', '2024-11-04', 34, -637, false, false, 54, 80);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '2024-11-04', 100, -712, false, true, 23, 37);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.', '2024-11-01', 10, 938, true, true, 47, 87);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.', '2024-11-02', 78, 193, false, true, 30, 15);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', '2024-11-01', 11, 270, false, false, 85, 78);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla tempus.', '2024-11-01', 79, -830, false, false, 81, 61);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', '2024-11-03', 12, -634, true, true, 4, 17);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', '2024-11-04', 76, -294, false, true, 45, 15);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh.', '2024-11-04', 24, 344, true, true, 64, 69);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '2024-11-03', 43, -936, true, true, 6, 8);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', '2024-11-02', 62, 421, false, false, 73, 40);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Curabitur gravida nisi at nibh.', '2024-11-03', 94, -177, false, true, 30, 31);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', '2024-11-04', 87, 182, true, true, 7, 41);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', '2024-11-03', 17, -141, true, false, 85, 14);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '2024-11-01', 48, -532, true, false, 96, 56);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', '2024-11-04', 4, 101, true, true, 36, 100);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', '2024-11-01', 60, -65, true, true, 45, 81);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '2024-11-04', 18, 781, false, false, 62, 70);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '2024-11-02', 74, -409, true, false, 17, 2);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', '2024-11-01', 61, 62, false, false, 17, 13);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', '2024-11-04', 43, -569, true, false, 21, 33);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.', '2024-11-03', 70, -422, false, false, 87, 46);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In sagittis dui vel nisl.', '2024-11-02', 53, -192, false, true, 79, 75);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', '2024-11-03', 23, 283, false, false, 89, 80);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '2024-11-02', 49, 186, true, false, 100, 88);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', '2024-11-03', 41, -51, true, false, 97, 60);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.', '2024-11-02', 77, -338, false, true, 15, 92);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '2024-11-04', 12, 925, true, false, 90, 47);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', '2024-11-01', 13, 524, true, false, 4, 96);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Aliquam erat volutpat.', '2024-11-01', 95, 532, false, true, 11, 29);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', '2024-11-01', 65, -444, true, true, 69, 60);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Duis ac nibh.', '2024-11-04', 22, 812, false, false, 19, 25);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', '2024-11-03', 45, 198, false, false, 3, 48);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', '2024-11-01', 43, 577, true, true, 56, 71);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', '2024-11-01', 50, -717, true, false, 23, 58);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', '2024-11-02', 97, 249, false, true, 11, 92);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue.', '2024-11-02', 3, -495, false, true, 74, 9);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', '2024-11-04', 76, -314, false, true, 89, 65);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', '2024-11-04', 100, -699, true, false, 87, 21);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Proin interdum mauris non ligula pellentesque ultrices.', '2024-11-02', 49, 144, false, false, 1, 95);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', '2024-11-02', 69, -735, true, true, 50, 11);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', '2024-11-04', 74, -189, true, true, 17, 19);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Curabitur in libero ut massa volutpat convallis.', '2024-11-04', 61, -958, false, true, 91, 70);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue.', '2024-11-02', 70, 462, false, true, 59, 75);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', '2024-11-04', 57, 148, false, false, 75, 5);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.', '2024-11-03', 68, 753, false, true, 82, 96);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', '2024-11-02', 16, 152, true, true, 12, 42);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '2024-11-01', 31, -732, false, true, 65, 38);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.', '2024-11-01', 10, -824, false, true, 88, 28);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', '2024-11-01', 2, 636, false, true, 99, 61);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('In sagittis dui vel nisl.', '2024-11-02', 10, -176, true, false, 34, 36);
insert into Answer (content, date, reports, votes, accepted, edited, id_user, id_question) values ('Donec ut dolor.', '2024-11-03', 32, 221, true, true, 55, 25);

