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

INSERT INTO tests(name,topic_id,difficulty_id,inserted_by,updated_by)
    VALUES('Test1', 1,3,'daniel','daniel'),
            ('Test2', 2,4,'daniel', 'daniel'),
            ('Test3', 3,2,'daniel', 'daniel'),
            ('Test4', 4,1,'daniel', 'daniel');

INSERT INTO questions(text, points, test_id, type_id)
    VALUES('Where have you been all this time?', 5, 1, 1),
    ('What were you thinking?', 10, 1,2),
    ('What is my Name?', 15, 1, 3),
    ('Yall wanna buy some pot?', 5, 1, 1),
    ('Sleeping is for?', 10, 1, 2),
    ('Say my Name!',15, 1, 3),

    ('Why is this question so boring?', 5, 2, 1),
    ('Why you so dumb?', 5, 2, 1),
    ('Why give up now?', 10, 2, 2),
    ('Who suscks?', 15, 2, 3),
    ('Give up already you are not going to win unless you write "I am Gay!"', 15, 2,3),

    ('Why is there only 1 question here?', 5, 3, 1),
    
    ('I am the one who knocks!', 5, 4, 1);

INSERT INTO answers(text, question_id)
    VALUES('Away', 1),
        ('I Won''t tell', 1),
        ('Here!, Are you blind or something?', 1),

        ('Shit', 2),
        ('Stuff', 2),
        ('You Shall Not PASS', 2),

        ('Sure!', 4),
        ('Are you a cop?', 4),
        ('No, Thank you', 4),
        ('My Mom won''t let me', 4),

        ('Dogs', 5),
        ('The weak', 5),
        ('Nerds', 5),
        ('Old peaople', 5),

        ('Because reasons', 7),
        ('Because the author is stupid', 7),
    
        ('Shoto neam mozuk v glavata', 8),
        ('Who says that???', 8),

        ('I''m tired of your shit', 9),
        ('I have a life you know...', 9),
        ('I''m too stupid for this quiz', 9),

        ('I was too lazy', 12),
        ('Because It was said so by the Old Gods', 12),

        ('I don''t really care', 13),
        ('Go away already', 13),
        ('Breaking Bad FTW', 13),
        ('Baking Bread FTW', 13);

INSERT INTO correct_answers(question_id, single, multiple, free)
    VALUES
        (1, 3, null, null),
        (2, null, ARRAY[4,5], null),
        (3, null, null, 'Daniel'),
        (4, 7, null, null),
        (5, null, ARRAY[12,13], null),
        (6, null, null, 'Daniel'),
        (7, 15, null, null),
        (8, 17, null, null),
        (9, null, ARRAY[19,21], null),
        (10, null, null, 'I do'),
        (11, null, null, 'I am Gay'),
        (12, 22, null, null),
        (13, 26, null, null);
                
