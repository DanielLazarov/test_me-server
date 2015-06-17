package TestMe::Tests::Tests;

use strict;

use DBI;
use Data::Dumper;

use ErrorHandle::Error::Compact;
use TestMe::Security::Security;

sub getTests($)
{
    my ($app) = @_;

    my $params = $$app{cgi};
     
    ASSERT_USER(
        TestMe::Security::Security::verifySession($app, $$params{account_id}, $$params{session_token}),
        "Authentication Problem, please Log in Again",
        "TMU001"
    );


    my $all_difficulties = 1;
    my $all_topics = 1;
    my $all_authors = 1;
    my $all_ids = 1;

    if($$params{difficulty})
    {
        $all_difficulties = 0;
    }

    if($$params{topic})
    {
        $all_topics = 0;
    }

    if($$params{search_account_id})
    {
        $all_authors = 0;
    }
    
    if($$params{test_id})
    {
        $all_ids = 0;
    }


    my $sth = $$app{dbh}->prepare(
        q{
            SELECT *
            FROM tests_vw
            WHERE (difficulty_id = ? OR ?)
            AND (topic_id = ? OR ?)
            AND (account_id = ? OR ?)
            AND (id = ? OR ?)
        }
    );
    $sth->execute($$params{difficulty}, $all_difficulties, $$params{topic}, $all_topics, $$params{search_account_id}, $all_authors, $$params{test_id}, $all_ids);

    my $result = {};
    
    my @arr;
    while(my $row = $sth->fetchrow_hashref)
    {
        push @arr, $row;
    }
    $$result{tests} = \@arr;
    TRACE("RESULT", Dumper $result);
    return $result;
}

sub beginTest($)
{
    my ($app) = @_;
    
    my $params = $$app{cgi};
    
    ASSERT($$params{random_test} || $$params{test_id}, "Missing Param");

    ASSERT_USER(
        TestMe::Security::Security::verifySession($app, $$params{account_id}, $$params{session_token}),
        "Authentication Problem, please Log in Again",
        "TMU001"
    );

    my $test_row;
    my $sth;
    if($$params{random_test} && !$$params{test_id})#Random Test
    {
        $sth = $$app{dbh}->prepare("
            SELECT * FROM available_tests_vw OFFSET random() * (select count(*) - 1 from available_tests_vw) LIMIT 1"
        );
        $sth->execute();   
    }
    else
    {
        $sth = $$app{dbh}->prepare("
            SELECT * FROM tests WHERE id = ?
        ");
        $sth->execute($$params{test_id});
    }
    ASSERT($sth->rows == 1, "No rows selected from tests");
    $test_row = $sth->fetchrow_hashref;
     
    my $expires_at = "NULL";  
    
    my $hours_left = -1;
    my $minutes_left = -1;
    my $seconds_left = -1;
    if($$test_row{is_timed})
    {
        $expires_at = " now() + " . $$app{dbh}->quote($$test_row{time_minutes} . " minutes") . "::interval "; 
        my $time = $$test_row{time_minutes};

        $minutes_left = $time % 60;
        $hours_left = int($time/60);
        $seconds_left = 0;
    }

    my @questions;
    
    my $sth = $$app{dbh}->prepare("
        SELECT * FROM questions where test_id = ?
    ");
    $sth->execute($$test_row{id});
    ASSERT_USER($sth->rows > 0, "The selected test has 0 questions");#TODO add err code
    
    while(my $row = $sth->fetchrow_hashref)
    {
        push @questions, $$row{id};
    }

    #TODO question order may be shuflled
    $sth = $$app{dbh}->prepare("
        SELECT * 
        FROM accounts
        WHERE account_id = ? 
        ");
    $sth->execute($$params{account_id});
    ASSERT($sth->rows == 1, "no rows selected from accounts");
    my $account_row = $sth->fetchrow_hashref;

    $sth = $$app{dbh}->prepare("
        INSERT INTO test_sessions
        VALUES(default, ?, ?, ?, default, ?, $expires_at, default, default) 
        RETURNING *
    ");
    $sth->execute(\@questions, $$test_row{id}, $$account_row{id}, undef);
    ASSERT($sth->rows == 1, "Insert into test_sessions failed");
    my $test_session_row = $sth->fetchrow_hashref;

  
    my $result = {
        test_session_token => $$test_session_row{session_token},
        test_hours_left => $hours_left,
        test_minutes_left => $minutes_left,
        test_seconds_left => $seconds_left
    };

    TRACE("Tests::Tests::beginTest::result", Dumper $result);
    return $result;
}

sub getQuestion($)
{
    my ($app) = @_;

    my $question_types = { #TODO sync with DB
        1 => "single_answer",
        2 => "multiple_answers",
        3 => "free_answer",
    };

    my $params = $$app{cgi};

    ASSERT(defined $$params{account_id} && defined $$params{session_token} && $$params{test_session_token}, "Missing Param");
    
    ASSERT_USER(
        TestMe::Security::Security::verifySession($app, $$params{account_id}, $$params{session_token}),
        "Authentication Problem, please Log in Again",
        "TMU001"
    );

    if(!defined $$params{question_number})
    {
        $$params{question_number} = 0;
    }

    my $sth = $$app{dbh}->prepare("
        SELECT *,
        CASE 
            WHEN expires_at IS NULL 
                THEN NULL 
            ELSE
                (select extract('epoch' from expires_at) - extract('epoch' from now()::timestamp))
        end seconds_left
        FROM test_sessions
        WHERE session_token = ?
    ");
    $sth->execute($$params{test_session_token});
    ASSERT($sth->rows == 1, "Incorrect session token");
    my $test_session_row = $sth->fetchrow_hashref;
    
    TRACE("TIME LEFT", $$test_session_row{seconds_left});
    
    my $seconds_left = -1;
    my $hours_left = -1;
    my $minutes_left = -1;
    
    if($$test_session_row{seconds_left})
    {
        $hours_left = int($$test_session_row{seconds_left}/3600);
        $minutes_left = int(($$test_session_row{seconds_left}%3600)/60);
        $seconds_left = int(($$test_session_row{seconds_left}%3600)%60);
    }

    if(scalar @{$$test_session_row{questions_id}} <= $$params{question_number})
    {
        return {answers => undef, type => undef, text => undef, question_number => -1};
    }
    $sth = $$app{dbh}->prepare("SELECT * FROM questions where id = ?");
    $sth->execute($$test_session_row{questions_id}[$$params{question_number}]);
    my $question_row = $sth->fetchrow_hashref;
     
     

    $sth = $$app{dbh}->prepare("
        SELECT text, id
        FROM answers WHERE question_id = ?
    ");
    $sth->execute($$question_row{id});
    
    my @answers; 
    while(my $row = $sth->fetchrow_hashref)
    {
        push @answers, $row;
        TRACE("Question Answer", Dumper $row)
    }    
   
    my $result = {
        test_hours_left => $hours_left,
        test_minutes_left => $minutes_left,
        test_seconds_left => $seconds_left,
        answers => \@answers,
        type => $$question_types{$$question_row{type_id}},
        text => $$question_row{text},
        question_number => $$params{question_number}
    };    

    return $result;

}

sub submitAnswer($)
{
    my ($app) = @_;
    
    my $params = $$app{cgi};

    ASSERT_USER(
        TestMe::Security::Security::verifySession($app, $$params{account_id}, $$params{session_token}),
        "Authentication Problem, please Log in Again",
        "TMU001"
    );

    my $single_answer = $$params{single_answer};

    my @multiple_answers;
    if(defined $$params{multiple_answers})
    {
        @multiple_answers = split(",", $$params{multiple_answers});
    }
    my $free_answer = $$params{free_answer};

    my $sth = $$app{dbh}->prepare("
        SELECT * FROM test_sessions WHERE session_token = ?
    ");
    $sth->execute($$params{test_session_token});
    ASSERT($sth->rows == 1);
    my $test_session_row = $sth->fetchrow_hashref;
    
    
    my $sth = $$app{dbh}->prepare("
        INSERT INTO test_session_answers
        VALUES(default, ?, default, ?, null, ?, ?, ?)
    ");
    $sth->execute($$test_session_row{id}, $$test_session_row{questions_id}[$$params{question_number}], $single_answer, (scalar @multiple_answers ? \@multiple_answers : undef), $free_answer);
    ASSERT($sth->rows == 1);
    $$app{cgi}{question_number}++;
    return getQuestion($app);
}

sub getResult($)
{
    my ($app) = @_;

    my $params = $$app{cgi};

    ASSERT_USER(
        TestMe::Security::Security::verifySession($app, $$params{account_id}, $$params{session_token}),
        "Authentication Problem, please Log in Again",
        "TMU001"
    );

    my $sth = $$app{dbh}->prepare("
        SELECT points FROM tests T JOIN test_sessions TS ON TS.test_id = T.id
        WHERE TS.session_token = ?
    ");
    $sth->execute($$params{test_session_token});
    ASSERT($sth->rows == 1);
    my $total_points_row = $sth->fetchrow_hashref;

    my $total_points = $$total_points_row{points};

    $sth = $$app{dbh}->prepare("
        SELECT *, 
            (row__question_id).points AS points,
            (row__account_id).id AS account_id,
            (row__account_id).points AS account_points,
            (row__correct_answer).single AS single,
            (row__correct_answer).multiple AS multiple,
            (row__correct_answer).free AS free
        FROM test_results_vw WHERE (row__test_session_id).session_token = ?");
    $sth->execute($$params{test_session_token});
    my $account_points;   
    my $account_id;    

    my $earned_points = 0;
    while(my $row = $sth->fetchrow_hashref)
    {
        $account_points = $$row{account_points};
        $account_id = $$row{account_id};

        if(defined $$row{single})
        {
            if($$row{single} == $$row{single_answer_question_answered})
            {
                $earned_points += $$row{points};
            }
        }
        elsif(defined $$row{free})
        {
            if($$row{free} eq $$row{free_answer_question_answered})
            {
                $earned_points += $$row{points};
            }
        }
        elsif(defined $$row{multiple})
        {
            my @answered_arr = @{$$row{multiple_answer_question_answered}};
            my @correct_arr = @{$$row{multiple}};

            my $eq = 1;
            foreach my $answer (@answered_arr)
            {
                my $contains = 0;
                foreach my $correct (@correct_arr)
                {
                    if($correct == $answer)
                    {
                        $contains = 1;
                        last;
                    }
                }
                if(!$contains)
                {
                    $eq = 0;
                    last;
                }
            }

            if($eq)
            {
                $earned_points += $$row{points};
            }
        }

    }
    
    $account_points = $account_points + $earned_points - $total_points/2;
    if($account_points < 0)
    {
        $account_points = 0;
    }    

    my $rank_id;
    if($account_points <= 100 )
    {
        $rank_id = 1;
    }
    elsif($account_points > 100 && $account_points <= 500)
    {
        $rank_id = 2;
    }
    elsif($account_points > 500 && $account_points <= 2500)
    {
        $rank_id = 3;
    }
    elsif($account_points > 2500 && $account_points <= 10000)
    {
        $rank_id = 4;
    }
    else
    {
        $rank_id = 5;
    }
    if(!$$params{nograde})
    {
        $sth = $$app{dbh}->prepare("UPDATE accounts SET points = ?, rank_id = ? WHERE id = ? RETURNING *" );
        $sth->execute(int($account_points), $rank_id, $account_id);
        TRACE("Result row: ", Dumper $sth->fetchrow_hashref);
        TRACE("Updated rows: ", $sth->rows);
        ASSERT($sth->rows == 1);
        
        $sth = $$app{dbh}->prepare("UPDATE test_sessions SET end_timestamp = now(), is_finished = true WHERE session_token = ?");
        $sth->execute($$params{test_session_token});
        ASSERT($sth->rows == 1);
    }
    return {earned => $earned_points, total => $total_points}; 
}

sub getResults($)
{
    my ($app) = @_;
    
    my $params = $$app{cgi};

    ASSERT_USER(
        TestMe::Security::Security::verifySession($app, $$params{account_id}, $$params{session_token}),
        "Authentication Problem, please Log in Again",
        "TMU001"
    );

    my @test_results;

    my $sth = $$app{dbh}->prepare("
        SELECT TS.*,
            TS.begin_timestamp::date AS test_date, 
            T.name AS row__test_id_name,
            T.id AS row__test_id_id 
        FROM test_sessions TS 
            JOIN accounts A ON TS.account_id = A.id
            JOIN tests T ON TS.test_id = T.id
        WHERE A.account_id = ?
            AND TS.is_finished = true
    ");
    $sth->execute($$params{"account_id"});

    while(my $row = $sth->fetchrow_hashref)
    {
        $$app{cgi}{nograde} = 1;
        $$app{cgi}{test_session_token} = $$row{session_token};
        
        my $results = getResult($app);
        $$results{test_id} = $$row{row__test_id_id};
        $$results{test__name} = $$row{row__test_id_name};
        $$results{test_date} = $$row{test_date};
        
        push @test_results, $results;
    }
    return {results => \@test_results};
    
}
1;
