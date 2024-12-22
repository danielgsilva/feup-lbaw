DROP SCHEMA IF EXISTS lbaw24141 CASCADE;
CREATE SCHEMA IF NOT EXISTS lbaw24141;
SET search_path TO lbaw24141;

DROP TABLE IF EXISTS password_reset_tokens CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS report CASCADE;
DROP TABLE IF EXISTS tag CASCADE;
DROP TABLE IF EXISTS question CASCADE;
DROP TABLE IF EXISTS Answer CASCADE;
DROP TABLE IF EXISTS Comment CASCADE;
DROP TABLE IF EXISTS notification CASCADE;
DROP TABLE IF EXISTS follow_tag CASCADE;
DROP TABLE IF EXISTS follow_question CASCADE;
DROP TABLE IF EXISTS question_vote CASCADE;
DROP TABLE IF EXISTS answer_vote CASCADE;
DROP TABLE IF EXISTS image CASCADE;
DROP TABLE IF EXISTS question_tag CASCADE;
DROP TRIGGER IF EXISTS question_search_update ON question;
DROP TRIGGER IF EXISTS tag_search_update ON tag;
DROP TRIGGER IF EXISTS question_edited ON question;
DROP TRIGGER IF EXISTS answer_edited ON Answer;
DROP TRIGGER IF EXISTS prevent_self_comment ON Comment;
DROP TRIGGER IF EXISTS prevent_self_answer ON Answer;
DROP TRIGGER IF EXISTS answer_notification ON Answer;
DROP TRIGGER IF EXISTS comment_notification ON Comment;
DROP TRIGGER IF EXISTS update_reports_count ON report;
DROP TRIGGER IF EXISTS update_user_score_on_question_vote ON question_vote;
DROP TRIGGER IF EXISTS update_user_score_on_answer_vote ON answer_vote;
DROP TRIGGER IF EXISTS update_user_score_on_answer_acceptance ON Answer;
DROP TRIGGER IF EXISTS trigger_check_author_accept_answer ON Answer;
DROP TRIGGER IF EXISTS trigger_check_duplicate_report ON report;
DROP TRIGGER IF EXISTS trigger_enforce_single_report_association ON report;
DROP TRIGGER IF EXISTS trigger_enforce_question_tag_limit ON QuestionTag; 
DROP TRIGGER IF EXISTS after_question_vote_insert ON question_vote;
DROP TRIGGER IF EXISTS after_answer_vote_insert ON answer_vote;
DROP TRIGGER IF EXISTS update_question_votes_on_insert ON question_vote;
DROP TRIGGER IF EXISTS update_answer_votes_on_insert ON answer_vote;
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
DROP FUNCTION IF EXISTS update_user_score_question_vote;
DROP FUNCTION IF EXISTS update_user_score_answer_vote;
DROP FUNCTION IF EXISTS update_user_score_answer_acceptance;
DROP FUNCTION IF EXISTS users_search_update;
DROP FUNCTION IF EXISTS notify_question_vote;
DROP FUNCTION IF EXISTS notify_answer_vote;


CREATE TABLE IF NOT EXISTS password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    admin BOOLEAN DEFAULT FALSE NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    bio TEXT,
    birthdate DATE CONSTRAINT valid_birthdate CHECK (birthdate <= CURRENT_DATE),
    password VARCHAR(255),
    google_id VARCHAR,
    github_id VARCHAR,
    signUpDate DATE CONSTRAINT valid_signUpDate CHECK (signUpDate <= CURRENT_DATE),
    ban BOOLEAN DEFAULT FALSE NOT NULL,
    score INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE IF NOT EXISTS tag (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    creation_date DATE DEFAULT CURRENT_DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS question (
    id SERIAL PRIMARY KEY,
    title VARCHAR(1000) NOT NULL,
    content TEXT NOT NULL,
    date DATE DEFAULT CURRENT_DATE NOT NULL,
    reports INTEGER DEFAULT 0 NOT NULL CONSTRAINT valid_reports CHECK (reports >= 0),
    votes INTEGER DEFAULT 0 NOT NULL,
    edited BOOLEAN DEFAULT FALSE NOT NULL,
    id_user INTEGER REFERENCES users(id) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS Answer (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    date DATE DEFAULT CURRENT_DATE NOT NULL,
    reports INTEGER DEFAULT 0 NOT NULL CONSTRAINT valid_reports CHECK (reports >= 0),
    votes INTEGER DEFAULT 0 NOT NULL,
    accepted BOOLEAN DEFAULT FALSE NOT NULL,
    edited BOOLEAN DEFAULT FALSE NOT NULL,
    id_user INTEGER REFERENCES users(id) ON DELETE SET NULL,
    id_question INTEGER REFERENCES question(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Comment (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    date DATE DEFAULT CURRENT_DATE NOT NULL,
    reports INTEGER DEFAULT 0 NOT NULL CONSTRAINT valid_reports CHECK (reports >= 0),
    edited BOOLEAN DEFAULT FALSE NOT NULL,
    id_user INTEGER REFERENCES users(id) ON DELETE SET NULL,
    id_question INTEGER REFERENCES question(id) ON DELETE CASCADE,
    id_answer INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    CONSTRAINT valid_comment CHECK ((id_question IS NOT NULL AND id_answer IS NULL) OR (id_question IS NULL AND id_answer IS NOT NULL))
);

CREATE TABLE IF NOT EXISTS question_vote (
    id SERIAL PRIMARY KEY,
    id_user INTEGER REFERENCES users(id) ON DELETE CASCADE,
    id_question INTEGER REFERENCES question(id) ON DELETE CASCADE,
    value INTEGER CONSTRAINT valid_vote CHECK (value = 1 OR value = -1)
);

CREATE TABLE IF NOT EXISTS answer_vote (
    id SERIAL PRIMARY KEY,
    id_user INTEGER REFERENCES users(id) ON DELETE CASCADE,
    id_answer INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    value INTEGER CONSTRAINT valid_vote CHECK (value = 1 OR value = -1)
);

CREATE TABLE IF NOT EXISTS notification (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    viewed BOOLEAN DEFAULT FALSE NOT NULL,
    id_user INTEGER REFERENCES users(id) ON DELETE CASCADE,
    id_answer INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    id_comment INTEGER REFERENCES Comment(id) ON DELETE CASCADE,
    id_question_vote INTEGER REFERENCES question_vote(id) ON DELETE CASCADE,
    id_answer_vote INTEGER REFERENCES answer_vote(id) ON DELETE CASCADE,
    CONSTRAINT valid_notification CHECK ((id_answer IS NOT NULL AND id_comment IS NULL AND id_question_vote IS NULL AND id_answer_vote IS NULL) 
    OR (id_answer IS NULL AND id_comment IS NOT NULL AND id_question_vote IS NULL AND id_answer_vote IS NULL) 
    OR (id_answer IS NULL AND id_comment IS NULL AND id_question_vote IS NOT NULL AND id_answer_vote IS NULL) 
    OR (id_answer IS NULL AND id_comment IS NULL AND id_question_vote IS NULL AND id_answer_vote IS NOT NULL))
);

CREATE TABLE IF NOT EXISTS report (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    date DATE DEFAULT CURRENT_DATE NOT NULL,
    viewed BOOLEAN DEFAULT FALSE NOT NULL,
    id_user INTEGER REFERENCES users(id) ON DELETE CASCADE,
    id_question INTEGER REFERENCES question(id) ON DELETE CASCADE,
    id_answer INTEGER REFERENCES Answer(id) ON DELETE CASCADE,
    id_comment INTEGER REFERENCES Comment(id) ON DELETE CASCADE,
    CONSTRAINT valid_report CHECK ((id_question IS NOT NULL AND id_answer IS NULL AND id_comment IS NULL) OR (id_question IS NULL AND id_answer IS NOT NULL AND id_comment IS NULL) OR (id_question IS NULL AND id_answer IS NULL AND id_comment IS NOT NULL))
);


CREATE TABLE IF NOT EXISTS follow_tag (
    id_user INTEGER REFERENCES users(id) ON DELETE CASCADE,
    id_tag INTEGER REFERENCES tag(id) ON DELETE CASCADE,
    PRIMARY KEY (id_user, id_tag)
);

CREATE TABLE IF NOT EXISTS follow_question (
    id_user INTEGER REFERENCES users(id) ON DELETE CASCADE,
    id_question INTEGER REFERENCES question(id) ON DELETE CASCADE,
    PRIMARY KEY (id_user, id_question)
);


CREATE TABLE IF NOT EXISTS image (
    id SERIAL PRIMARY KEY,
    image_path VARCHAR(255) NOT NULL,
    id_user INTEGER REFERENCES users(id) ON DELETE CASCADE,
    id_question INTEGER REFERENCES question(id) ON DELETE CASCADE,
    CONSTRAINT valid_image CHECK ((id_question IS NOT NULL AND id_user IS NULL) OR (id_question IS NULL AND id_user IS NOT NULL)) 
);

CREATE TABLE IF NOT EXISTS question_tag (
    id_question INTEGER REFERENCES question(id) ON DELETE CASCADE,
    id_tag INTEGER REFERENCES tag(id) ON DELETE CASCADE,
    PRIMARY KEY (id_question, id_tag)
);


CREATE UNIQUE INDEX idx_user_email ON users (email);

CREATE INDEX idx_question_votes_reports ON question (votes DESC, reports DESC);

CREATE INDEX idx_answer_question ON Answer (id_question, votes DESC);CLUSTER Answer USING idx_answer_question;


-- Add column to the question table to store ts_vectors.
ALTER TABLE question
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

-- Create a trigger before inserting or updating in the question table.
CREATE TRIGGER question_search_update
 BEFORE INSERT OR UPDATE ON question
 FOR EACH ROW
 EXECUTE PROCEDURE question_search_update();

-- Create the GIN index for the ts_vectors.
CREATE INDEX question_search_idx ON question USING GIN (tsvectors); 


ALTER TABLE tag
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

-- Create a trigger before inserting or updating in the tag table.
CREATE TRIGGER tag_search_update
BEFORE INSERT OR UPDATE ON tag
FOR EACH ROW
EXECUTE PROCEDURE tag_search_update();

-- Create the GIN index for the ts_vectors.
CREATE INDEX search_idx ON tag USING GIN (tsvectors);


-- Adicionar coluna para armazenar o vetor de texto para pesquisa.
ALTER TABLE users
ADD COLUMN tsvectors TSVECTOR;

-- Criar função para atualizar automaticamente o vetor de texto.
CREATE FUNCTION users_search_update() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.tsvectors = (
            setweight(to_tsvector('english', NEW.username), 'A') ||
            setweight(to_tsvector('english', NEW.name), 'B')
        );
    ELSIF TG_OP = 'UPDATE' THEN
        IF (NEW.username <> OLD.username OR NEW.name <> OLD.name) THEN
            NEW.tsvectors = (
                setweight(to_tsvector('english', NEW.username), 'A') ||
                setweight(to_tsvector('english', NEW.name), 'B') 
            );
        END IF;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

-- Criar trigger para manter os vetores de texto sincronizados.
CREATE TRIGGER users_search_update
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE users_search_update();

-- Criar índice GIN para a pesquisa eficiente.
CREATE INDEX users_search_idx ON users USING GIN (tsvectors);



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
BEFORE UPDATE ON question
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
        SELECT id_user INTO post_id_user FROM question WHERE id = NEW.id_question;
ELSIF TG_TABLE_NAME = 'Answer' THEN
        SELECT id_user INTO post_id_user FROM question WHERE id = NEW.id_question;
END IF;

IF NEW.id_user = post_id_user THEN
RAISE EXCEPTION 'users cannot review or comment their own posts';
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
    INSERT INTO notification (date, viewed, id_user, id_answer, id_comment, id_question_vote, id_answer_vote)
    VALUES (
        NOW(),                    -- Data da notificação
        FALSE,                    -- Notificação não lida
        (SELECT id_user FROM question WHERE id = NEW.id_question),  -- Autor da pergunta
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
    INSERT INTO notification (date, viewed, id_user, id_answer, id_comment, id_question_vote, id_answer_vote)
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

CREATE FUNCTION notify_question_vote() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notification (date, viewed, id_user, id_answer, id_comment, id_question_vote, id_answer_vote)
    VALUES (
        NOW(),                    -- Data da notificação
        FALSE,                    -- Notificação não lida
        (SELECT id_user FROM question WHERE id = NEW.id_question),  -- Autor da pergunta
        NULL,                     -- id_answer é NULL porque não se aplica
        NULL,                     -- id_comment é NULL porque não se aplica
        NEW.id,                  -- id_question_vote refere-se ao novo voto na pergunta
        NULL                      -- id_answer_vote é NULL porque não se aplica
    );
    RETURN NEW;
END $$ 
LANGUAGE plpgsql;

CREATE TRIGGER after_question_vote_insert
AFTER INSERT ON question_vote
FOR EACH ROW
EXECUTE FUNCTION notify_question_vote();

CREATE FUNCTION notify_answer_vote() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notification (date, viewed, id_user, id_answer, id_comment, id_question_vote, id_answer_vote)
    VALUES (
        NOW(),                    -- Data da notificação
        FALSE,                    -- Notificação não lida
        (SELECT id_user FROM answer WHERE id = NEW.id_answer),  -- Autor da resposta
        NULL,                     -- id_answer é NULL porque não se aplica
        NULL,                     -- id_comment é NULL porque não se aplica
        NULL,                     -- id_question_vote é NULL porque não se aplica
        NEW.id                   -- id_answer_vote refere-se ao novo voto na resposta
    );
    RETURN NEW;
END $$ 
LANGUAGE plpgsql;

CREATE TRIGGER after_answer_vote_insert
AFTER INSERT ON answer_vote
FOR EACH ROW
EXECUTE FUNCTION notify_answer_vote();

CREATE FUNCTION update_reports() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_question IS NOT NULL THEN
        UPDATE question
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
AFTER INSERT ON report
FOR EACH ROW
EXECUTE PROCEDURE update_reports();


CREATE FUNCTION update_user_score_question_vote() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.value <> OLD.value) THEN
        IF NEW.value = 1 THEN
            UPDATE users SET score = score + 10 WHERE id = NEW.id_user;  -- Voto positivo
        ELSIF NEW.value = -1 THEN
            UPDATE users SET score = score - 2 WHERE id = NEW.id_user;  -- Voto negativo
        END IF;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_score_on_question_vote
AFTER INSERT OR UPDATE ON question_vote
FOR EACH ROW
EXECUTE PROCEDURE update_user_score_question_vote();

CREATE FUNCTION update_user_score_answer_vote() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.value <> OLD.value) THEN
        IF NEW.value = 1 THEN
            UPDATE users SET score = score + 10 WHERE id = NEW.id_user;  -- Voto positivo
        ELSIF NEW.value = -1 THEN
            UPDATE users SET score = score - 2 WHERE id = NEW.id_user;  -- Voto negativo
        END IF;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_score_on_answer_vote
AFTER INSERT OR UPDATE ON answer_vote
FOR EACH ROW
EXECUTE PROCEDURE update_user_score_answer_vote();

CREATE FUNCTION update_user_score_answer_acceptance() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.accepted = TRUE AND OLD.accepted = FALSE THEN
        -- Atualiza pontuação do utilizador da resposta aceita
        UPDATE users SET score = score + 15 WHERE id = NEW.id_user;
        -- Atualiza pontuação do autor da pergunta
        UPDATE users SET score = score + 2 WHERE id = (SELECT id_user FROM question WHERE id = NEW.id_question);
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_score_on_answer_acceptance
AFTER UPDATE OF accepted ON Answer
FOR EACH ROW
EXECUTE PROCEDURE update_user_score_answer_acceptance();

CREATE OR REPLACE FUNCTION update_question_votes() RETURNS TRIGGER AS $$
BEGIN
    UPDATE question
    SET votes = votes + NEW.value
    WHERE id = NEW.id_question;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_question_votes_on_insert
AFTER INSERT ON question_vote
FOR EACH ROW
EXECUTE FUNCTION update_question_votes();

CREATE OR REPLACE FUNCTION revert_question_votes() RETURNS TRIGGER AS $$
BEGIN
    UPDATE question
    SET votes = votes - OLD.value
    WHERE id = OLD.id_question;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_question_votes_on_delete
AFTER DELETE ON question_vote
FOR EACH ROW
EXECUTE FUNCTION revert_question_votes();

CREATE OR REPLACE FUNCTION update_answer_votes() RETURNS TRIGGER AS $$
BEGIN
    UPDATE answer
    SET votes = votes + NEW.value
    WHERE id = NEW.id_answer;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_answer_votes_on_insert
AFTER INSERT ON answer_vote
FOR EACH ROW
EXECUTE FUNCTION update_answer_votes();

CREATE OR REPLACE FUNCTION revert_answer_votes() RETURNS TRIGGER AS $$
BEGIN
    UPDATE answer
    SET votes = votes - OLD.value
    WHERE id = OLD.id_answer;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_answer_votes_on_delete
AFTER DELETE ON answer_vote
FOR EACH ROW
EXECUTE FUNCTION revert_answer_votes();


--CREATE OR REPLACE FUNCTION check_author_accept_answer() 
--RETURNS TRIGGER AS $$
--BEGIN
    -- Verificar se o utilizador que tenta marcar a resposta como aceita é o autor da pergunta
--    IF NEW.accepted = TRUE THEN
--        PERFORM 1 
--        FROM question 
--        WHERE id = NEW.id_question AND id_user = NEW.id_user;

--        IF NOT FOUND THEN
--            RAISE EXCEPTION 'Only the author of the question can accept an answer';
--        END IF;
--    END IF;

--    RETURN NEW;
--END;
--$$ LANGUAGE plpgsql;

--CREATE TRIGGER trigger_check_author_accept_answer
--BEFORE UPDATE OF accepted ON Answer
--FOR EACH ROW
--WHEN (OLD.accepted = FALSE AND NEW.accepted = TRUE)
--EXECUTE FUNCTION check_author_accept_answer();


CREATE OR REPLACE FUNCTION check_duplicate_report() 
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar se já existe um report do mesmo utilizador para a mesma entidade
    IF EXISTS (
        SELECT 1
        FROM report
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
BEFORE INSERT ON report
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
BEFORE INSERT OR UPDATE ON report
FOR EACH ROW
EXECUTE FUNCTION enforce_single_report_association();


CREATE OR REPLACE FUNCTION enforce_question_tag_limit() 
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar o número de tags associadas à pergunta
    IF (SELECT COUNT(*) FROM question_tag WHERE id_question = NEW.id_question) >= 5 THEN
        RAISE EXCEPTION 'A question can be associated with a maximum of 5 tags';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_enforce_question_tag_limit
BEFORE INSERT ON question_tag
FOR EACH ROW
EXECUTE FUNCTION enforce_question_tag_limit();

--Database population


INSERT INTO users (id, admin, username, name, email, bio, birthdate, password, signUpDate, ban, score) VALUES
(0, TRUE, 'admin1', 'Admin One', 'admin@example.com', 'Bio of admin one', '1985-01-01', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', '2023-01-01', FALSE, 100);
INSERT INTO users (admin, username, name, email, bio, birthdate, password, google_id, github_id, signUpDate, ban, score) VALUES
(FALSE, 'alicsan', 'Alice Santos', 'alice.santos@example.com', 'Professora de matemática e física.', '1990-01-01', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2022-02-10', FALSE, 120),
(FALSE, 'caper', 'Carlos Pereira', 'carlos.pereira@example.com', 'Desenvolvedor de software.', '1985-02-15', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-03-12', FALSE, 200),
(FALSE, 'beferra', 'Beatriz Ferreira', 'beatriz.ferreira@example.com', 'Estudante de engenharia informática.', '1998-05-30', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2021-07-05', FALSE, 50),
(FALSE, 'mike', 'Miguel Costa', 'miguel.costa@example.com', 'Designer gráfico apaixonado por arte digital.', '1992-11-20', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2020-11-15', FALSE, 150),
(FALSE, 'jumart', 'Joana Martins', 'joana.martins@example.com', 'Consultora de sustentabilidade e energias renováveis.', '1987-03-22', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-05-20', FALSE, 80),
(FALSE, 'RG9', 'Rui Gomes', 'rui.gomes@example.com', 'Jornalista e escritor.', '1994-08-13', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2022-06-01', FALSE, 130),
(FALSE, 'sofs', 'Sofia Almeida', 'sofia.almeida@example.com', 'Professora de história e cultura geral.', '1991-10-11', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2020-08-30', FALSE, 90),
(FALSE, 'lorer', 'Luis Rocha', 'luis.rocha@example.com', 'Engenheiro de software especializado em inteligência artificial.', '1993-04-03', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-07-10', FALSE, 110),
(FALSE, 'Panilhas', 'Pedro Oliveira', 'pedro.oliveira@example.com', 'Arquiteto com foco em design sustentável.', '2004-04-17', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2022-01-10', TRUE, 140),
(FALSE, 'carlsz', 'Carla Souza', 'carla.souza@example.com', 'Psicóloga e terapeuta familiar.', '1995-02-17', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2021-09-12', FALSE, 75),
(FALSE, 'acst', 'Ana Costa', 'ana.costa@example.com', 'Arquiteta urbana apaixonada por cidades inteligentes.', '1997-07-21', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-04-18', FALSE, 60),
(FALSE, 'mistervp', 'Vitor Pereira', 'vitor.pereira@example.com', 'Músico e compositor.', '1993-06-10', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2022-10-30', FALSE, 55),
(FALSE, 'marirodrd', 'Mariana Rodrigues', 'mariana.rodrigues@example.com', 'Gestora de projetos em TI.', '1989-01-22', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-02-05', FALSE, 100),
(FALSE, 'JS58', 'João Silva', 'joao.silva@example.com', 'Desenvolvedor web full-stack.', '1990-09-14', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2021-12-25', FALSE, 95),
(FALSE, 'Ferpint', 'Fernanda Pinto', 'fernanda.pinto@example.com', 'Nutricionista e personal trainer.', '1986-11-05', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-05-15', FALSE, 125),
(FALSE, 'LUSOz', 'Luis Sousa', 'luis.sousa@example.com', 'Software engineer com foco em sistemas embarcados.', '1992-04-22', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2020-02-01', FALSE, 85),
(FALSE, 'Ric Fazeres', 'Ricardo Lima', 'ricardo.lima@example.com', 'Especialista em segurança cibernética.', '1995-03-18', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-07-15', FALSE, 110),
(FALSE, 'Patty', 'Patrícia Duarte', 'patricia.duarte@example.com', 'Consultora de marketing digital.', '1988-05-26', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2022-11-10', FALSE, 75),
(FALSE, 'FerreiraA', 'Andreia Ferreira', 'andreia.ferreira@example.com', 'Advogada especializada em direito digital.', '1994-12-03', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-08-18', FALSE, 140),
(FALSE, 'Silvinha', 'Sílvia Martins', 'silvia.martins@example.com', 'Desenvolvedora de jogos e criadora de conteúdos.', '1997-09-17', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-03-25', FALSE, 60),
(FALSE, 'carlitos', 'Carlos Souza', 'carlos.souza@example.com', 'Analista de dados e especialista em machine learning.', '1991-06-10', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2021-01-22', FALSE, 115),
(FALSE, 'richard', 'Ricardo Oliveira', 'ricardo.oliveira@example.com', 'Engenheiro de redes e infraestrutura.', '1996-04-14', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2022-12-01', FALSE, 95),
(FALSE, 'dailycristina', 'Cristina Ribeiro', 'cristina.ribeiro@example.com', 'Gestora de recursos humanos e coach.', '1989-07-30', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-06-20', FALSE, 85),
(FALSE, 'chicosoares', 'Francisco Almeida', 'francisco.almeida@example.com', 'Artista plástico e ilustrador.', '1992-01-11', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2022-04-18', FALSE, 70),
(FALSE, 'rachelmore', 'Raquel Moreira', 'raquel.moreira@example.com', 'Chef de cozinha e amante de gastronomia.', '1990-02-20', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-01-05', FALSE, 80),
(FALSE, 'TigasSantini', 'Tiago Santos', 'tiago.santos@example.com', 'Especialista em automação industrial e robótica.', '1988-09-12', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2022-07-17', FALSE, 120),
(FALSE, 'PeterPan', 'Pedro Costa', 'pedro.costa@example.com', 'Engenheiro de software com foco em blockchain.', '1993-05-14', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2021-11-30', FALSE, 110),
(FALSE, 'Fersilv', 'Fernanda Silva', 'fernanda.silva@example.com', 'Gestora de TI e especialista em cloud computing.', '1994-08-19', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2023-05-15', FALSE, 90),
(FALSE, 'Raulllllll', 'Raul Oliveira', 'raul.oliveira@example.com', 'Mestre em redes de computadores e segurança digital.', '1990-12-02', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', NULL, NULL, '2022-02-17', FALSE, 105);


INSERT INTO tag (name) VALUES
('java'),
('laravel'),
('python'),
('javascript'),
('c#'),
('c++'),
('php'),
('html'),
('css'),
('sql'),
('react'),
('nodejs'),
('mongodb'),
('mysql'),
('postgresql'),
('docker'),
('kubernetes'),
('git'),
('github'),
('gitlab'),
('linux'),
('windows'),
('macos'),
('android'),
('ios'),
('flutter');




-- Question with id = 0
INSERT INTO question (id, title, content, date, reports, votes, edited, id_user) VALUES
(0, 'What tools and frameworks should I study for Python web development?', 'I am planning to use Python for web development. What are the essential tools and frameworks to focus on?', '2024-12-22', 0, 20, FALSE, 0);

-- Additional questions
INSERT INTO question (title, content, date, reports, votes, edited, id_user) VALUES
('How can I implement a sorting algorithm in Java?', 'I am looking for guidance on how to implement a sorting algorithm in Java. Any tips or approaches?', '2024-12-21', 1, 50, FALSE, 0),
('What are effective debugging techniques for React?', 'Are there specific techniques that can help debug React applications efficiently?', '2024-12-20', 0, 40, FALSE, 1),
('What distinguishes C from C++ in terms of memory management?', 'I want to understand how memory management differs between C and C++. Can someone explain?', '2024-12-19', 0, 30, FALSE, 2),
('How do I create a REST API in Node.js step by step?', 'Could someone guide me on creating a REST API using Node.js?', '2024-12-18', 1, 20, FALSE, 3),
('What trends are reshaping machine learning in 2024?', 'What are some trends in machine learning that could shape its future?', '2024-12-17', 0, 29, FALSE, 3),
('What’s the best roadmap for learning data science?', 'Can someone outline a roadmap for learning data science effectively?', '2024-12-16', 1, 49, FALSE, 4),
('What are the highlights of React 18 for developers?', 'Which features of React 18 are most beneficial for developers?', '2024-12-15', 0, 51, FALSE, 4),
('How do I start developing Blockchain applications?', 'Are there beginner-friendly guides for getting started with Blockchain development?', '2024-12-14', 1, 40, FALSE, 5),
('What are best practices for secure user authentication?', 'Could someone elaborate on best practices for implementing secure user authentication?', '2024-12-13', 0, 31, FALSE, 5),
('How can I write optimized SQL queries?', 'What are some proven techniques for writing optimized SQL queries?', '2024-12-12', 0, 2, FALSE, 6),
('SQL vs NoSQL: When to use each?', 'In what scenarios should I prefer SQL over NoSQL or vice versa?', '2024-12-11', 0, 5, FALSE, 6),
('How do I integrate Google Analytics with a CMS?', 'What steps are required to integrate Google Analytics with a CMS?', '2024-12-10', 0, 0, FALSE, 7),
('What libraries are best for web scraping in Python?', 'Can someone recommend Python libraries for web scraping?', '2024-12-09', 0, 4, FALSE, 7),
('What are advanced debugging tools for Node.js?', 'Could someone share insights on debugging tools for advanced Node.js projects?', '2024-12-08', 1, 6, FALSE, 8),
('Why is Python preferred for big data analysis?', 'What makes Python a popular choice for big data analysis?', '2024-12-07', 0, 9, FALSE, 8),
('How do I deploy a Django project on AWS?', 'Can anyone explain how to deploy Django projects on AWS?', '2024-12-06', 1, 8, FALSE, 9),
('What are the leading JavaScript frameworks for beginners?', 'What JavaScript frameworks should beginners start with in 2024?', '2024-12-05', 0, 7, FALSE, 9),
('How do I implement a quicksort algorithm in Java?', 'What are the steps to write a quicksort algorithm in Java?', '2024-12-21', 1, 30, FALSE, 10),
('What’s the latest in React development for 2024?', 'What are some exciting updates in React development for 2024?', '2024-12-20', 0, 50, FALSE, 11),
('What are the key distinctions between C++ and Python?', 'Can someone compare C++ and Python in terms of performance and usability?', '2024-12-19', 0, 10, FALSE, 11),
('How do I design scalable REST APIs in Node.js?', 'What are best practices for designing scalable REST APIs with Node.js?', '2024-12-18', 1, 5, FALSE, 12),
('What recent breakthroughs are driving AI innovation?', 'Can someone share insights into recent breakthroughs in artificial intelligence?', '2024-12-17', 0, 8, FALSE, 12),
('How do I transition to a career in data science?', 'What steps can I take to switch to a data science career?', '2024-12-16', 1, 7, FALSE, 13),
('What are the game-changing features in React 18?', 'Which features of React 18 significantly impact web development?', '2024-12-15', 0, 6, FALSE, 13),
('What’s a beginner’s guide to Blockchain?', 'Are there any comprehensive beginner guides to Blockchain development?', '2024-12-14', 1, 9, FALSE, 14),
('How do I secure web app authentication with OAuth?', 'Can someone explain how to implement OAuth for secure authentication?', '2024-12-13', 0, 4, FALSE, 14),
('How to optimize joins in SQL for large datasets?', 'What techniques can I use to optimize SQL joins for large datasets?', '2024-12-12', 0, 2, FALSE, 15),
('What’s the best use case for NoSQL databases?', 'Can someone provide examples of when NoSQL databases are more suitable than SQL?', '2024-12-11', 0, 5, FALSE, 15),
('How do I set up Google Analytics 4?', 'Could someone guide me on setting up Google Analytics 4?', '2024-12-10', 0, 0, FALSE, 16),
('What frameworks simplify web scraping tasks?', 'What frameworks or libraries are best for simplifying web scraping tasks?', '2024-12-09', 0, 3, FALSE, 16),
('What are common pitfalls in Node.js debugging?', 'What pitfalls should I avoid when debugging Node.js applications?', '2024-12-08', 1, 6, FALSE, 17),
('Why choose Python for machine learning?', 'What makes Python a better choice for machine learning compared to other languages?', '2024-12-07', 0, 7, FALSE, 17),
('How do I host Django apps on Azure?', 'Could someone explain the steps to host Django apps on Microsoft Azure?', '2024-12-06', 1, 8, FALSE, 18),
('What’s trending in JavaScript frameworks for 2024?', 'What are the latest JavaScript frameworks gaining popularity in 2024?', '2024-12-05', 0, 5, FALSE, 18),
('What techniques improve sorting algorithms?', 'Are there any advanced techniques to enhance sorting algorithms?', '2024-12-21', 0, 10, FALSE, 19),
('What new libraries are available for React in 2024?', 'Could someone share the latest libraries for improving React development?', '2024-12-20', 0, 15, FALSE, 20),
('How do I handle memory leaks in C++?', 'What are effective ways to detect and fix memory leaks in C++?', '2024-12-19', 1, 10, FALSE, 21),
('What’s the best tool for API testing in Node.js?', 'Could someone recommend tools for testing APIs developed in Node.js?', '2024-12-18', 0, 8, FALSE, 22),
('What’s the role of transformers in machine learning?', 'Can someone explain the significance of transformers in modern machine learning?', '2024-12-17', 1, 10, FALSE, 23),
('What are the best text editors for developers?', 'Could someone recommend the most efficient text editors for developers and explain their advantages?', '2024-12-04', 0, 3, FALSE, 19),
('How do I structure a backend application with microservices?', 'What are the best practices for structuring a backend application using microservices?', '2024-12-03', 0, 5, FALSE, 19),
('What is the difference between authentication and authorization?', 'Can someone explain the fundamental differences between authentication and authorization?', '2024-12-02', 0, 4, FALSE, 20),
('How can I create a responsive design for websites?', 'I want to learn how to create fully responsive websites. Any suggestions?', '2024-12-01', 1, 6, FALSE, 20),
('What are the benefits of TypeScript over JavaScript?', 'Why should I consider using TypeScript instead of JavaScript? What are its main advantages?', '2024-11-30', 0, 7, FALSE, 21),
('How can I implement automated testing in web projects?', 'What are the recommended tools for implementing automated testing in web applications?', '2024-11-29', 1, 5, FALSE, 21),
('How can I optimize image loading on websites?', 'Could someone share strategies for improving image loading performance on websites?', '2024-11-28', 0, 6, FALSE, 22),
('What are the key differences between functional and object-oriented programming?', 'Can someone explain the main distinctions between functional programming and object-oriented programming?', '2024-11-27', 0, 5, FALSE, 22),
('How do I set up continuous integration for my project?', 'What are the steps required to set up continuous integration, and what tools should I use?', '2024-11-26', 0, 4, FALSE, 23),
('What are the best practices for securing REST APIs?', 'Could someone provide an overview of the best practices for securing REST APIs?', '2024-11-25', 1, 8, FALSE, 23);



INSERT INTO Answer (id, content, date, reports, votes, accepted, edited, id_user, id_question) VALUES
(0, 'You can implement a sorting algorithm in Java using the Arrays.sort() method for simple cases.', '2024-12-23', 0, 5, FALSE, FALSE, 0, 1);
INSERT INTO Answer (content, date, reports, votes, accepted, edited, id_user, id_question) VALUES

('Consider using the Collections.sort() method for sorting lists in Java.', '2024-12-24', 0, 3, FALSE, FALSE, 1, 1),
('For custom sorting, you can implement the Comparator interface in Java.', '2024-12-25', 0, 4, FALSE, FALSE, 4, 1),

('Use functional components and hooks in React for better performance and readability.', '2024-12-21', 0, 6, FALSE, FALSE, 5, 2),
('Keep your components small and focused on a single task in React.', '2024-12-22', 0, 7, FALSE, FALSE, 0, 2),
('Use PropTypes for type checking in React components.', '2024-12-23', 0, 5, FALSE, FALSE, 7, 2),

('C is a procedural programming language, while C++ supports both procedural and object-oriented programming.', '2024-12-20', 0, 8, FALSE, FALSE, 0, 3),
('C++ has features like classes, inheritance, and polymorphism which are not present in C.', '2024-12-21', 0, 9, FALSE, FALSE, 0, 3),
('Memory management in C++ is more flexible with the use of constructors and destructors.', '2024-12-22', 0, 7, FALSE, FALSE, 10, 3),

('You can use Express.js to create a REST API in Node.js.', '2024-12-19', 0, 6, FALSE, FALSE, 11, 4),
('Use the body-parser middleware to handle JSON requests in your Node.js REST API.', '2024-12-20', 0, 5, FALSE, FALSE, 12, 4),
('Consider using Mongoose for MongoDB integration in your Node.js REST API.', '2024-12-21', 0, 4, FALSE, FALSE, 13, 4),

('One of the latest trends in machine learning is the use of transformers in natural language processing.', '2024-12-18', 0, 10, FALSE, FALSE, 14, 5),
('Reinforcement learning is gaining popularity in machine learning for training models in dynamic environments.', '2024-12-19', 0, 9, FALSE, FALSE, 15, 5),
('AutoML is becoming a trend, allowing non-experts to build machine learning models.', '2024-12-20', 0, 8, FALSE, FALSE, 16, 5),

('Start with learning Python and its libraries like NumPy and pandas for data science.', '2024-12-17', 0, 6, FALSE, FALSE, 17, 6),
('Take online courses on platforms like Coursera and edX to learn data science.', '2024-12-18', 0, 7, FALSE, FALSE, 18, 6),
('Practice by working on real-world data science projects and participating in competitions on Kaggle.', '2024-12-19', 0, 8, FALSE, FALSE, 19, 6),

('React 18 introduces concurrent rendering for improved performance.', '2024-12-16', 0, 7, FALSE, FALSE, 20, 7),
('The new automatic batching feature in React 18 helps reduce unnecessary re-renders.', '2024-12-17', 0, 6, FALSE, FALSE, 21, 7),
('React 18 includes a new startTransition API for managing UI transitions.', '2024-12-18', 0, 5, FALSE, FALSE, 22, 7),

('Start with learning the basics of blockchain technology and its underlying principles.', '2024-12-15', 0, 9, FALSE, FALSE, 23, 8),
('Learn about popular blockchain platforms like Ethereum and Hyperledger.', '2024-12-16', 0, 8, FALSE, FALSE, 24, 8),
('Practice by building simple blockchain applications and smart contracts.', '2024-12-17', 0, 7, FALSE, FALSE, 25, 8),

('Use libraries like Passport.js for implementing authentication in a web app.', '2024-12-14', 0, 4, FALSE, FALSE, 26, 9),
('Consider using JWT (JSON Web Tokens) for stateless authentication.', '2024-12-15', 0, 5, FALSE, FALSE, 27, 9),
('Implement multi-factor authentication for enhanced security.', '2024-12-16', 0, 6, FALSE, FALSE, 28, 9),

('Use indexes to speed up query performance in SQL.', '2024-12-13', 0, 2, FALSE, FALSE, 29, 10),
('Avoid using SELECT * in your SQL queries to reduce the amount of data processed.', '2024-12-14', 0, 3, FALSE, FALSE, 28, 10),
('Use query execution plans to identify and optimize slow queries.', '2024-12-15', 0, 4, FALSE, FALSE, 29, 10),

('SQL databases are relational, while NoSQL databases are non-relational.', '2024-12-12', 0, 5, FALSE, FALSE, 27, 11),
('NoSQL databases are more flexible and can handle unstructured data.', '2024-12-13', 0, 6, FALSE, FALSE, 26, 11),
('SQL databases use structured query language, whereas NoSQL databases use various query languages.', '2024-12-14', 0, 7, FALSE, FALSE, 25, 11),

('To integrate Google Analytics, add the tracking code to your websites HTML.', '2024-12-11', 0, 0, FALSE, FALSE, 24, 12),
('Use Google Tag Manager to manage and deploy Google Analytics tags.', '2024-12-12', 0, 1, FALSE, FALSE, 23, 12),
('Verify the integration using the Google Analytics real-time reports.', '2024-12-13', 0, 2, FALSE, FALSE, 22, 12),

('BeautifulSoup and Scrapy are popular tools for web scraping in Python.', '2024-12-10', 0, 4, FALSE, FALSE, 21, 13),
('Use Puppeteer for web scraping with JavaScript.', '2024-12-11', 0, 3, FALSE, FALSE, 20, 13),
('Selenium is a powerful tool for web scraping and browser automation.', '2024-12-12', 0, 5, FALSE, FALSE, 19, 13),

('Use the built-in Node.js debugger for debugging applications.', '2024-12-09', 0, 6, FALSE, FALSE, 18, 14),
('Consider using VS Code with the Node.js extension for an enhanced debugging experience.', '2024-12-10', 0, 5, FALSE, FALSE, 17, 14),
('Use logging libraries like Winston to track and debug issues in Node.js applications.', '2024-12-11', 0, 4, FALSE, FALSE, 16, 14),

('Python is popular for data analysis due to its simplicity and readability.', '2024-12-08', 0, 9, FALSE, FALSE, 15, 15),
('Libraries like pandas and NumPy make data manipulation and analysis easy in Python.', '2024-12-09', 0, 8, FALSE, FALSE, 14, 15),
('Python has a large community and extensive documentation for data analysis.', '2024-12-10', 0, 7, FALSE, FALSE, 13, 15),

('To deploy a Django app on Heroku, start by creating a Procfile.', '2024-12-07', 0, 8, FALSE, FALSE, 12, 16),
('Use the Heroku CLI to deploy your Django application.', '2024-12-08', 0, 7, FALSE, FALSE, 11, 16),
('Configure your Django settings for Heroku deployment, including the database and static files.', '2024-12-09', 0, 6, FALSE, FALSE, 10, 16),

('React, Angular, and Vue.js are among the top JavaScript frameworks in 2024.', '2024-12-06', 0, 7, FALSE, FALSE, 9, 17),
('Svelte is gaining popularity as a lightweight JavaScript framework.', '2024-12-07', 0, 6, FALSE, FALSE, 8, 17),
('Next.js is a popular framework for server-side rendering in React applications.', '2024-12-08', 0, 5, FALSE, FALSE, 7, 17);

INSERT INTO Comment (content, date, reports, edited, id_user, id_question, id_answer) VALUES
('Try using the Arrays.sort() method for sorting in Java.', '2024-12-22', 0, FALSE, 3, 1, NULL),
('Use functional components and hooks for better performance in React.', '2024-12-21', 0, FALSE, 4, 2, NULL),
('C++ supports object-oriented programming, unlike C.', '2024-12-20', 0, FALSE, 5, 3, NULL),
('Express.js is a great framework for creating REST APIs with Node.js.', '2024-12-19', 0, FALSE, 6, 4, NULL),
('Transformers are a significant trend in NLP within machine learning.', '2024-12-18', 0, FALSE, 7, 5, NULL),
('Start with Python and libraries like NumPy and pandas for data science.', '2024-12-17', 0, FALSE, 8, 6, NULL),
( 'React 18 introduces concurrent rendering for better performance.', '2024-12-16', 0, FALSE, 9, 7, NULL),
( 'Learn the basics of blockchain technology and platforms like Ethereum.', '2024-12-15', 0, FALSE, 10, 8, NULL),
( 'Use Passport.js for implementing authentication in web apps.', '2024-12-14', 0, FALSE, 11, 9, NULL),
( 'Use indexes to optimize SQL query performance.', '2024-12-13', 0, FALSE, 12, 10, NULL),
( 'SQL databases are relational, while NoSQL databases are non-relational.', '2024-12-12', 0, FALSE, 13, 11, NULL),
( 'Add the Google Analytics tracking code to your website.', '2024-12-11', 0, FALSE, 14, 12, NULL),
( 'BeautifulSoup and Scrapy are popular tools for web scraping in Python.', '2024-12-10', 0, FALSE, 15, 13, NULL),
( 'Use the built-in Node.js debugger for debugging applications.', '2024-12-09', 0, FALSE, 16, 14, NULL);


INSERT INTO Comment ( content, date, reports, edited, id_user, id_question, id_answer) VALUES
( 'Arrays.sort() is indeed very useful for simple cases.', '2024-12-24', 0, FALSE, 1, NULL, 0),
( 'I agree, Collections.sort() is great for lists.', '2024-12-25', 0, FALSE, 2, NULL, 1),
( 'Implementing Comparator gives you more control over sorting.', '2024-12-26', 0, FALSE, 3, NULL, 2),

('Functional components and hooks have made my React code much cleaner.', '2024-12-22', 0, FALSE, 4, NULL, 3),
('Keeping components small definitely helps with maintainability.', '2024-12-23', 0, FALSE, 5, NULL, 4),
( 'PropTypes have saved me from many bugs.', '2024-12-24', 0, FALSE, 6, NULL, 5),

( 'C++ also has better support for object-oriented programming.', '2024-12-21', 0, FALSE, 7, NULL, 6),
( 'Classes and inheritance in C++ make it more powerful.', '2024-12-22', 0, FALSE, 8, NULL, 7),
( 'Constructors and destructors in C++ are very handy.', '2024-12-23', 0, FALSE, 9, NULL, 8),

( 'Express.js is my go-to framework for REST APIs.', '2024-12-20', 0, FALSE, 10, NULL, 9),
( 'body-parser makes handling JSON so much easier.', '2024-12-21', 0, FALSE, 11, NULL, 10),
( 'Mongoose simplifies MongoDB integration a lot.', '2024-12-22', 0, FALSE, 12, NULL, 11),

( 'Transformers have revolutionized NLP.', '2024-12-19', 0, FALSE, 13, NULL, 12),
( 'Reinforcement learning is indeed very promising.', '2024-12-20', 0, FALSE, 14, NULL, 13),
( 'AutoML is making machine learning more accessible.', '2024-12-21', 0, FALSE, 15, NULL, 14),

( 'Python and its libraries are essential for data science.', '2024-12-18', 0, FALSE, 16, NULL, 15),
( 'Online courses are a great way to start learning data science.', '2024-12-19', 0, FALSE, 17, NULL, 16),
( 'Kaggle competitions are excellent for hands-on experience.', '2024-12-20', 0, FALSE, 18, NULL, 17),

( 'Concurrent rendering in React 18 is a game-changer.', '2024-12-17', 0, FALSE, 19, NULL, 18),
( 'Automatic batching in React 18 has improved performance.', '2024-12-18', 0, FALSE, 20, NULL, 19),
( 'startTransition API is very useful for managing transitions.', '2024-12-19', 0, FALSE, 21, NULL, 20);



INSERT INTO follow_tag (id_user, id_tag) VALUES
(1, 3),
(1, 5),
(2, 7),
(2, 9),
(3, 11),
(3, 13),
(4, 15),
(4, 17),
(5, 19),
(5, 21),
(6, 23),
(6, 25),
(7, 2),
(7, 4),
(8, 6),
(8, 8),
(9, 10),
(9, 12),
(10, 14),
(10, 16);



INSERT INTO report (content, date, viewed, id_user, id_question, id_answer, id_comment) VALUES
('This question is unclear.', '2024-12-23', FALSE, 1, 1, NULL, NULL),
('This question is a duplicate.', '2024-12-24', FALSE, 2, 2, NULL, NULL),
('This answer is incorrect.', '2024-12-25', FALSE, 3, NULL, 1, NULL),
('This answer is not helpful.', '2024-12-26', FALSE, 4, NULL, 2, NULL),
('This comment is offensive.', '2024-12-27', FALSE, 5, NULL, NULL, 1),
('This comment is spam.', '2024-12-28', FALSE, 6, NULL, NULL, 2);



INSERT INTO question_tag (id_question, id_tag) VALUES
(0, 3),
(0, 10),
(1, 1),
(1, 10),
(2, 11),
(2, 10),
(3, 5),
(3, 6),
(4, 12),
(4, 10),
(5, 13),
(5, 14),
(6, 15),
(6, 16),
(7, 17),
(7, 18),
(8, 19),
(8, 20),
(9, 10),
(9, 11),
(10, 10),
(10, 11),
(11, 10),
(11, 14),
(12, 21),
(12, 22),
(13, 3),
(13, 10),
(14, 12),
(14, 10),
(15, 3),
(15, 10),
(16, 17),
(16, 18),
(17, 19),
(17, 20),
(18, 10),
(18, 11),
(19, 5),
(19, 6),
(20, 12),
(20, 10),
(21, 13),
(21, 14),
(22, 15),
(22, 16),
(23, 17),
(23, 18),
(24, 19),
(24, 20),
(25, 10),
(25, 11),
(26, 10),
(26, 11),
(27, 21),
(27, 22),
(28, 3),
(28, 10),
(29, 12),
(29, 10),
(30, 3),
(30, 10),
(31, 17),
(31, 18),
(32, 19),
(32, 20),
(33, 10),
(33, 11),
(34, 10),
(34, 11);