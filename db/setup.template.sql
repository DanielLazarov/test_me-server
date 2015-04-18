--AS t_usr
INSERT INTO difficulties(name) 
    VALUES  ('Beginner'), 
            ('Novice'), 
            ('Intermediate'),
            ('Advanced'),
            ('Expert');

INSERT INTO topics(name)
    VALUES  ('Математика'),
            ('Езици');

INSERT INTO tests(name,topic_id,difficulty_id,inserted_by,updated_by)
    VALUES('Тест1', 1,1,'daniel','daniel'),
            ('Тест2', 1,2,'daniel', 'daniel'),
            ('Тест3', 2,1,'daniel', 'daniel'),
            ('Тест4', 2,1,'daniel', 'daniel');
