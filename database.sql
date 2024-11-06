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
    CONSTRAINT valid_image CHECK ((id_question IS NOT NULL AND id_user IS NULL) OR (id_question IS NULL AND id_user IS NOT NULL)) 
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
