package TestMe::Accounts::Accounts;

use strict;

use Digest::SHA qw{sha256_hex};

use ErrorHandle::Error::Compact;
use TestMe::Security::Security;

sub getAccountDetails($)
{
    my ($app) = @_;

    my $params = $$app{cgi};

    ASSERT_USER(
        TestMe::Security::Security::verifySession($app, $$params{account_id}, $$params{session_token}),
        "Authentication Problem, please Log in Again", 
        "TMU001"
    );

    ASSERT_PEER(defined $$params{account_id}, "Missing Param");

    my $sth = $$app{dbh}->prepare(
    q{
        SELECT *
        FROM accounts_vw 
        WHERE account_id = ?
    });
    $sth->execute($$params{account_id});
    ASSERT($sth->rows <= 1);
    my $account_row = $sth->fetchrow_hashref;

    my $result = {
	username    => $$account_row{username},
        account_id  => $$account_row{account_id},
        email       => $$account_row{email},
        first_name  => $$account_row{first_name},
        last_name   => $$account_row{last_name},
        rank_id     => $$account_row{rank_id},
        rank__name  => $$account_row{rank__name}
    };

    return $result;
                                                                                                                                                }

sub createAccount($)
{
    my ($app) = @_;

    my $params = $$app{cgi};
    
    ASSERT_USER(length($$params{username}) >= 6, "Username should be at least 6 characters", "TM002");		
    ASSERT_USER(length($$params{password}) >= 6, "Password should be at least 6 characters", "TM003");
    my $password = sha256_hex($$params{password});
    my $sth = $$app{dbh}->prepare(
        q{
            INSERT INTO accounts 
            VALUES(default, ?, ?, default, ?, ?, ?, 1)
    });
    $sth->execute($$params{username}, $password, $$params{first_name}, $$params{last_name}, $$params{email});

    return {};
}

1;
