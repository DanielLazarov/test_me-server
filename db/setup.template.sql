--AS t_usr

INSERT INTO account_ranks(name)
    VALUES('Bronze'),
    ('Silver'),
    ('Gold'),
    ('Platinum'),
    ('Diamond');
    
INSERT INTO difficulties(name) 
    VALUES  ('Beginner'), 
            ('Novice'), 
            ('Intermediate'),
            ('Advanced'),
            ('Expert');

INSERT INTO topics(name)
    VALUES  ('Mathematics'),
            ('History'),
            ('Geography'),
            ('Physics'),
            ('Chemistry');

INSERT INTO tests(name,topic_id,difficulty_id,inserted_by,updated_by,is_timed, time_minutes, points)
    VALUES('Test1', 1,3,'danieltest','danieltest', true, 1, 60),
            ('Test2', 2,4,'daniel', 'daniel', true, 2, 50),
            ('Test3', 3,2,'daniel', 'daniel', false, null, 5),
            ('Test4', 4,1,'daniel', 'daniel', false, null, 5);

INSERT INTO questions(text, points, test_id, type_id)
    VALUES('Pi equals?', 5, 1, 1),
    ('Which are true?', 10, 1,2),
    ('Figure with 3 sides?', 15, 1, 3),
    ('35 + 28 = ?', 5, 1, 1),
    ('Which are true?', 10, 1, 2),
    ('Figure with 4 90 degrese angles',15, 1, 3),
    
    ('World War I starts when?', 5, 2, 1),
    ('Founder of America?', 5, 2, 1),
    ('Who cracked Enigma?', 10, 2, 2),
    ('Creator of the lightbulb?', 15, 2, 3),
    ('First black president of America?', 15, 2,3),

    ('Highest mountain', 5, 3, 1),
    
    ('F = m * ?', 5, 4, 1);

INSERT INTO answers(text, question_id)
    VALUES('5', 1),
        ('3.41', 1),
        ('3.14', 1),

        ('-38 + 32 > -14', 2),
        ('1234 + 22 < -333 + 2333', 2),
        ('-1 + 13 < 12 + 135 -3 -132', 2),

        ('63', 4),
        ('62', 4),
        ('73', 4),
        ('53', 4),

        ('2^1 = 1', 5),
        ('2^2 = 4', 5),
        ('2*2 = 4', 5),
        ('2^0 = 0', 5),


        ('28 July 1914', 7),
        ('23 July 1914', 7),
    
        ('Christopher Columbus', 8),
        ('Gosho ot pochivka', 8),

        ('Benedict Cumberbatch', 9),
        ('John Atanasov', 9),
        ('Alan Turing', 9),

        ('Himalayas', 12),
        ('Alps', 12),

        ('d', 13),
        ('c', 13),
        ('a', 13),
        ('b', 13);

INSERT INTO correct_answers(question_id, single, multiple, free)
    VALUES
        (1, 3, null, null),
        (2, null, ARRAY[4,5], null),
        (3, null, null, 'triangle'),
        (4, 7, null, null),
        (5, null, ARRAY[12,13], null),
        (6, null, null, 'rectangle'),

        (7, 15, null, null),
        (8, 17, null, null),
        (9, null, ARRAY[19,21], null),
        (10, null, null, 'Edison'),
        (11, null, null, 'Obama'),
        (12, 22, null, null),
        (13, 26, null, null);
                
