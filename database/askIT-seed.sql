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



-- Questão com id = 0
INSERT INTO question (id, title, content, date, reports, votes, edited, id_user) VALUES
(0, 'How to use Python for web development?', 'I want to use Python for web development. Can someone guide me on the tools and frameworks I should learn?', '2024-12-22', 0, 0, FALSE, 0);

-- Perguntas para os outros utilizadores
INSERT INTO question (title, content, date, reports, votes, edited, id_user) VALUES
('How to implement a sorting algorithm in Java?', 'I need help implementing a sorting algorithm in Java. Any suggestions?', '2024-12-21', 1, 3, FALSE, 0),
('What are the best practices in React development?', 'Can anyone share some best practices when working with React?', '2024-12-20', 0, 5, FALSE, 1),
('What is the difference between C and C++?', 'I am learning programming and would like to understand the key differences between C and C++.', '2024-12-19', 0, 8, FALSE, 2),
('How to create a REST API using Node.js?', 'I am trying to create a REST API with Node.js. Can someone provide an example?', '2024-12-18', 1, 4, FALSE, 3),
('What are the latest trends in machine learning?', 'Can anyone discuss the latest trends and advancements in machine learning?', '2024-12-17', 0, 10, FALSE, 3),
('What is the best way to learn data science?', 'Can anyone recommend the best approach to learn data science from scratch?', '2024-12-16', 1, 6, FALSE, 4),
('What are the top features of React 18?', 'What are the new features introduced in React 18? How do they impact development?', '2024-12-15', 0, 7, FALSE, 4),
('How do I start with Blockchain development?', 'I am interested in learning Blockchain development. Where should I start?', '2024-12-14', 1, 9, FALSE, 5),
('What is the best way to implement authentication in a web app?', 'Can someone explain the best approach to implement secure user authentication in a web application?', '2024-12-13', 0, 3, FALSE, 5),
('How to optimize SQL queries?', 'What are some tips for optimizing SQL queries and improving performance?', '2024-12-12', 0, 2, FALSE, 6),
('What are the main differences between SQL and NoSQL databases?', 'Can anyone explain the key differences between SQL and NoSQL databases?', '2024-12-11', 0, 5, FALSE, 6),
('How to integrate Google Analytics in a website?', 'Can anyone explain how to integrate Google Analytics into a website?', '2024-12-10', 0, 0, FALSE, 7),
('What are the best tools for web scraping?', 'Can anyone suggest the best tools and frameworks for web scraping?', '2024-12-09', 0, 4, FALSE, 7),
('How to debug a Node.js application?', 'What are the best practices and tools for debugging a Node.js application?', '2024-12-08', 1, 6, FALSE, 8),
('What are the advantages of using Python for data analysis?', 'Can anyone discuss why Python is popular for data analysis and the libraries to use?', '2024-12-07', 0, 9, FALSE, 8),
('How to deploy a Django app on Heroku?', 'Can someone provide a step-by-step guide to deploying a Django application on Heroku?', '2024-12-06', 1, 8, FALSE, 9),
('What are the top JavaScript frameworks in 2024?', 'Can anyone list the most popular JavaScript frameworks for 2024?', '2024-12-05', 0, 7, FALSE, 9),
('How to use Python for web development?', 'I want to use Python for web development. Can someone guide me on the tools and frameworks I should learn?', '2024-12-22', 0, 20, FALSE, 10),
('How to implement a sorting algorithm in Java?', 'I need help implementing a sorting algorithm in Java. Any suggestions?', '2024-12-21', 1, 30, FALSE, 10),
('What are the best practices in React development?', 'Can anyone share some best practices when working with React?', '2024-12-20', 0, 50, FALSE, 11),
('What is the difference between C and C++?', 'I am learning programming and would like to understand the key differences between C and C++.', '2024-12-19', 0, 10, FALSE, 11),
('How to create a REST API using Node.js?', 'I am trying to create a REST API with Node.js. Can someone provide an example?', '2024-12-18', 1, 5, FALSE, 12),
('What are the latest trends in machine learning?', 'Can anyone discuss the latest trends and advancements in machine learning?', '2024-12-17', 0, 8, FALSE, 12),
('What is the best way to learn data science?', 'Can anyone recommend the best approach to learn data science from scratch?', '2024-12-16', 1, 7, FALSE, 13),
('What are the top features of React 18?', 'What are the new features introduced in React 18? How do they impact development?', '2024-12-15', 0, 6, FALSE, 13),
('How do I start with Blockchain development?', 'I am interested in learning Blockchain development. Where should I start?', '2024-12-14', 1, 9, FALSE, 14),
('What is the best way to implement authentication in a web app?', 'Can someone explain the best approach to implement secure user authentication in a web application?', '2024-12-13', 0, 4, FALSE, 14),
('How to optimize SQL queries?', 'What are some tips for optimizing SQL queries and improving performance?', '2024-12-12', 0, 2, FALSE, 15),
('What are the main differences between SQL and NoSQL databases?', 'Can anyone explain the key differences between SQL and NoSQL databases?', '2024-12-11', 0, 5, FALSE, 15),
('How to integrate Google Analytics in a website?', 'Can anyone explain how to integrate Google Analytics into a website?', '2024-12-10', 0, 0, FALSE, 16),
('What are the best tools for web scraping?', 'Can anyone suggest the best tools and frameworks for web scraping?', '2024-12-09', 0, 3, FALSE, 16),
('How to debug a Node.js application?', 'What are the best practices and tools for debugging a Node.js application?', '2024-12-08', 1, 6, FALSE, 17),
('What are the advantages of using Python for data analysis?', 'Can anyone discuss why Python is popular for data analysis and the libraries to use?', '2024-12-07', 0, 7, FALSE, 17),
('How to deploy a Django app on Heroku?', 'Can someone provide a step-by-step guide to deploying a Django application on Heroku?', '2024-12-06', 1, 8, FALSE, 18),
('What are the top JavaScript frameworks in 2024?', 'Can anyone list the most popular JavaScript frameworks for 2024?', '2024-12-05', 0, 5, FALSE, 18),
('How to use Python for web development?', 'I want to use Python for web development. Can someone guide me on the tools and frameworks I should learn?', '2024-12-22', 0, 20, FALSE, 19),
('How to implement a sorting algorithm in Java?', 'I need help implementing a sorting algorithm in Java. Any suggestions?', '2024-12-21', 1, 30, FALSE, 19),
('What are the best practices in React development?', 'Can anyone share some best practices when working with React?', '2024-12-20', 0, 50, FALSE, 20),
('What is the difference between C and C++?', 'I am learning programming and would like to understand the key differences between C and C++.', '2024-12-19', 0, 10, FALSE, 20),
('How to create a REST API using Node.js?', 'I am trying to create a REST API with Node.js. Can someone provide an example?', '2024-12-18', 1, 5, FALSE, 21),
('What are the latest trends in machine learning?', 'Can anyone discuss the latest trends and advancements in machine learning?', '2024-12-17', 0, 8, FALSE, 21),
('What is the best way to learn data science?', 'Can anyone recommend the best approach to learn data science from scratch?', '2024-12-16', 1, 7, FALSE, 22),
('What are the top features of React 18?', 'What are the new features introduced in React 18? How do they impact development?', '2024-12-15', 0, 6, FALSE, 22),
('How do I start with Blockchain development?', 'I am interested in learning Blockchain development. Where should I start?', '2024-12-14', 1, 9, FALSE, 23),
('What is the best way to implement authentication in a web app?', 'Can someone explain the best approach to implement secure user authentication in a web application?', '2024-12-13', 0, 4, FALSE, 23),
('How to optimize SQL queries?', 'What are some tips for optimizing SQL queries and improving performance?', '2024-12-12', 0, 2, FALSE, 24),
('What are the main differences between SQL and NoSQL databases?', 'Can anyone explain the key differences between SQL and NoSQL databases?', '2024-12-11', 0, 5, FALSE, 24),
('How to integrate Google Analytics in a website?', 'Can anyone explain how to integrate Google Analytics into a website?', '2024-12-10', 0, 0, FALSE, 25),
('What are the best tools for web scraping?', 'Can anyone suggest the best tools and frameworks for web scraping?', '2024-12-09', 0, 3, FALSE, 25),
('How to debug a Node.js application?', 'What are the best practices and tools for debugging a Node.js application?', '2024-12-08', 1, 6, FALSE, 26),
('What are the advantages of using Python for data analysis?', 'Can anyone discuss why Python is popular for data analysis and the libraries to use?', '2024-12-07', 0, 7, FALSE, 26),
('How to deploy a Django app on Heroku?', 'Can someone provide a step-by-step guide to deploying a Django application on Heroku?', '2024-12-06', 1, 8, FALSE, 27),
('What are the top JavaScript frameworks in 2024?', 'Can anyone list the most popular JavaScript frameworks for 2024?', '2024-12-05', 0, 5, FALSE, 27);



INSERT INTO Answer (id, content, date, reports, votes, accepted, edited, id_user, id_question) VALUES
(0, 'You can implement a sorting algorithm in Java using the Arrays.sort() method for simple cases.', '2024-12-23', 0, 5, FALSE, FALSE, 0, 1),
(1, 'Consider using the Collections.sort() method for sorting lists in Java.', '2024-12-24', 0, 3, FALSE, FALSE, 1, 1),
(2, 'For custom sorting, you can implement the Comparator interface in Java.', '2024-12-25', 0, 4, FALSE, FALSE, 4, 1),

(3, 'Use functional components and hooks in React for better performance and readability.', '2024-12-21', 0, 6, FALSE, FALSE, 5, 2),
(4, 'Keep your components small and focused on a single task in React.', '2024-12-22', 0, 7, FALSE, FALSE, 0, 2),
(5, 'Use PropTypes for type checking in React components.', '2024-12-23', 0, 5, FALSE, FALSE, 7, 2),

(6, 'C is a procedural programming language, while C++ supports both procedural and object-oriented programming.', '2024-12-20', 0, 8, FALSE, FALSE, 0, 3),
(7, 'C++ has features like classes, inheritance, and polymorphism which are not present in C.', '2024-12-21', 0, 9, FALSE, FALSE, 0, 3),
(8, 'Memory management in C++ is more flexible with the use of constructors and destructors.', '2024-12-22', 0, 7, FALSE, FALSE, 10, 3),

(9, 'You can use Express.js to create a REST API in Node.js.', '2024-12-19', 0, 6, FALSE, FALSE, 11, 4),
(10, 'Use the body-parser middleware to handle JSON requests in your Node.js REST API.', '2024-12-20', 0, 5, FALSE, FALSE, 12, 4),
(11, 'Consider using Mongoose for MongoDB integration in your Node.js REST API.', '2024-12-21', 0, 4, FALSE, FALSE, 13, 4),

(12, 'One of the latest trends in machine learning is the use of transformers in natural language processing.', '2024-12-18', 0, 10, FALSE, FALSE, 14, 5),
(13, 'Reinforcement learning is gaining popularity in machine learning for training models in dynamic environments.', '2024-12-19', 0, 9, FALSE, FALSE, 15, 5),
(14, 'AutoML is becoming a trend, allowing non-experts to build machine learning models.', '2024-12-20', 0, 8, FALSE, FALSE, 16, 5),

(15, 'Start with learning Python and its libraries like NumPy and pandas for data science.', '2024-12-17', 0, 6, FALSE, FALSE, 17, 6),
(16, 'Take online courses on platforms like Coursera and edX to learn data science.', '2024-12-18', 0, 7, FALSE, FALSE, 18, 6),
(17, 'Practice by working on real-world data science projects and participating in competitions on Kaggle.', '2024-12-19', 0, 8, FALSE, FALSE, 19, 6),

(18, 'React 18 introduces concurrent rendering for improved performance.', '2024-12-16', 0, 7, FALSE, FALSE, 20, 7),
(19, 'The new automatic batching feature in React 18 helps reduce unnecessary re-renders.', '2024-12-17', 0, 6, FALSE, FALSE, 21, 7),
(20, 'React 18 includes a new startTransition API for managing UI transitions.', '2024-12-18', 0, 5, FALSE, FALSE, 22, 7),

(21, 'Start with learning the basics of blockchain technology and its underlying principles.', '2024-12-15', 0, 9, FALSE, FALSE, 23, 8),
(22, 'Learn about popular blockchain platforms like Ethereum and Hyperledger.', '2024-12-16', 0, 8, FALSE, FALSE, 24, 8),
(23, 'Practice by building simple blockchain applications and smart contracts.', '2024-12-17', 0, 7, FALSE, FALSE, 25, 8),

(24, 'Use libraries like Passport.js for implementing authentication in a web app.', '2024-12-14', 0, 4, FALSE, FALSE, 26, 9),
(25, 'Consider using JWT (JSON Web Tokens) for stateless authentication.', '2024-12-15', 0, 5, FALSE, FALSE, 27, 9),
(26, 'Implement multi-factor authentication for enhanced security.', '2024-12-16', 0, 6, FALSE, FALSE, 28, 9),

(27, 'Use indexes to speed up query performance in SQL.', '2024-12-13', 0, 2, FALSE, FALSE, 29, 10),
(28, 'Avoid using SELECT * in your SQL queries to reduce the amount of data processed.', '2024-12-14', 0, 3, FALSE, FALSE, 28, 10),
(29, 'Use query execution plans to identify and optimize slow queries.', '2024-12-15', 0, 4, FALSE, FALSE, 29, 10),

(30, 'SQL databases are relational, while NoSQL databases are non-relational.', '2024-12-12', 0, 5, FALSE, FALSE, 27, 11),
(31, 'NoSQL databases are more flexible and can handle unstructured data.', '2024-12-13', 0, 6, FALSE, FALSE, 26, 11),
(32, 'SQL databases use structured query language, whereas NoSQL databases use various query languages.', '2024-12-14', 0, 7, FALSE, FALSE, 25, 11),

(33, 'To integrate Google Analytics, add the tracking code to your websites HTML.', '2024-12-11', 0, 0, FALSE, FALSE, 24, 12),
(34, 'Use Google Tag Manager to manage and deploy Google Analytics tags.', '2024-12-12', 0, 1, FALSE, FALSE, 23, 12),
(35, 'Verify the integration using the Google Analytics real-time reports.', '2024-12-13', 0, 2, FALSE, FALSE, 22, 12),

(36, 'BeautifulSoup and Scrapy are popular tools for web scraping in Python.', '2024-12-10', 0, 4, FALSE, FALSE, 21, 13),
(37, 'Use Puppeteer for web scraping with JavaScript.', '2024-12-11', 0, 3, FALSE, FALSE, 20, 13),
(38, 'Selenium is a powerful tool for web scraping and browser automation.', '2024-12-12', 0, 5, FALSE, FALSE, 19, 13),

(39, 'Use the built-in Node.js debugger for debugging applications.', '2024-12-09', 0, 6, FALSE, FALSE, 18, 14),
(40, 'Consider using VS Code with the Node.js extension for an enhanced debugging experience.', '2024-12-10', 0, 5, FALSE, FALSE, 17, 14),
(41, 'Use logging libraries like Winston to track and debug issues in Node.js applications.', '2024-12-11', 0, 4, FALSE, FALSE, 16, 14),

(42, 'Python is popular for data analysis due to its simplicity and readability.', '2024-12-08', 0, 9, FALSE, FALSE, 15, 15),
(43, 'Libraries like pandas and NumPy make data manipulation and analysis easy in Python.', '2024-12-09', 0, 8, FALSE, FALSE, 14, 15),
(44, 'Python has a large community and extensive documentation for data analysis.', '2024-12-10', 0, 7, FALSE, FALSE, 13, 15),

(45, 'To deploy a Django app on Heroku, start by creating a Procfile.', '2024-12-07', 0, 8, FALSE, FALSE, 12, 16),
(46, 'Use the Heroku CLI to deploy your Django application.', '2024-12-08', 0, 7, FALSE, FALSE, 11, 16),
(47, 'Configure your Django settings for Heroku deployment, including the database and static files.', '2024-12-09', 0, 6, FALSE, FALSE, 10, 16),

(48, 'React, Angular, and Vue.js are among the top JavaScript frameworks in 2024.', '2024-12-06', 0, 7, FALSE, FALSE, 9, 17),
(49, 'Svelte is gaining popularity as a lightweight JavaScript framework.', '2024-12-07', 0, 6, FALSE, FALSE, 8, 17),
(50, 'Next.js is a popular framework for server-side rendering in React applications.', '2024-12-08', 0, 5, FALSE, FALSE, 7, 17);

