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

INSERT INTO questions(text, test_id, type_id)
    VALUES('Where have you been all this time?', 1, 1),
    ('What were you thinking?', 1,2),
    ('What is my Name?', 1, 3),
    ('Yall wanna buy some pot?', 1, 1),
    ('Sleeping is for?', 1, 2),
    ('Say my Name!',1,3),

    ('Why is this question so boring?', 2, 1),
    ('Why you so dumb?', 2, 1),
    ('Why give up now?', 2, 2),
    ('Who suscks?', 2, 3),
    ('Give up already you are not going to win unless you write "I am Gay!"', 2,3),

    ('Why is there only 1 question here?', 3, 1),
    
    ('I am the one who knocks!', 4, 1);

INSERT INTO answers(text, is_correct, question_id)
    VALUES('Away', false, 1),
        ('I Won''t tell', false, 1),
        ('Here!, Are you blind or something?', true, 1),

        ('Shit', true, 2),
        ('Stuff', true, 2),
        ('You Shall Not PASS', false, 2),

        ('Sure!', true, 4),
        ('Are you a cop?', false, 4),
        ('No, Thank you', false, 4),
        ('My Mom won''t let me', false, 4),

        ('Dogs', false, 5),
        ('The weak', true, 5),
        ('Nerds', true, 5),
        ('Old peaople', false, 5),

        ('Because reasons', true, 7),
        ('Because the author is stupid', false, 7),
    
        ('Shoto neam mozuk v glavata', true, 8),
        ('Who says that???', false, 8),

        ('I''m tired of your shit', true, 9),
        ('I have a life you know...', false, 9),
        ('I''m too stupid for this quiz', true, 9),

        ('I was too lazy', true, 12),
        ('Because It was said so by the Old Gods', false, 12),

        ('I don''t really care', false, 13),
        ('Go away already', false, 13),
        ('Breaking Bad FTW', true, 13),
        ('Baking Bread FTW', false, 13);

        
