package TestMe::WebHandle::WebHandle;

use strict;

use CGI qw(:standart);
use JSON;
use DBI;
use Try::Tiny;
use Data::Dumper;

use ErrorHandle::Error::Compact;

use TestMe::Tests::Tests;
use TestMe::Security::Security;
use TestMe::Accounts::Accounts;

sub handle($)
{
    my ($class) = @_;

    #dbh
    my $dbh = DBI->connect("DBI:Pg:dbname=test_me;host=localhost", "t_usr", "123", {RaiseError => 1, AutoCommit => 0});
    $dbh->{pg_enable_utf8} = 1;    
    
    #cgi
    my $cgi = handleCGIParams();

    Handler(bless {dbh => $dbh, cgi => $cgi}, $class)
}

sub handleCGIParams()
{
    my $params;

    my $cgi = CGI->new();                    
    my @param_names = $cgi->param; 

    foreach my $p_name(@param_names)
    {
        if($cgi->param($p_name) eq "")
        {
            $$params{$p_name} = undef;
        }
        else
        {
            $$params{$p_name} = $cgi->param($p_name);
        }
    }
    TRACE("Request Params", Dumper $params);

    return $params;
}

sub Handler($)
{
    my($self) = @_;
    
    print CGI::header('application/json; charset=utf-8');
    
    try
    {
        my $result = {
            status => "OK",
            message => "",
            error_code => ""  
        };
        
        $$result{result} = $self->Action();
        
        $$self{dbh}->commit;

        print to_json($result);
    }
    catch
    {
        my $err = shift;

        my $result = {
            status => "Error"
        };

        if($err->isa("userError"))
        {
            TRACE("UserError", $$err{msg} . " " . $$err{code});
            $$result{message} = $$err{msg};
            $$result{error_code} = $$err{code};
        }
        elsif($err->isa("peerError"))
        {
            TRACE("PeerError", $$err{msg} . " " . $$err{code});
            $$result{message} = "Operation Failed"; 
        }
        elsif($err->isa("sysError"))
        {
            TRACE("SystemError", $$err{msg} . " " . $$err{code});
            $$result{message} = "Application Error";
        }
        else
        {
            TRACE("UnknownError", Dumper $err);
            $$result{message} = "Application Error";
        }

        print to_json($result);

        $$self{dbh}->rollback;
    };
}

sub Action($)
{
    my($self)= @_;

    my $actions_map = {
        get_tests           => \&TestMe::Tests::Tests::getTests,
        create_account      => \&TestMe::Accounts::Accounts::createAccount,
        login               => \&TestMe::Security::Security::logIn,
        get_account_details => \&TestMe::Accounts::Accounts::getAccountDetails,
        begin_test          => \&TestMe::Tests::Tests::beginTest,
        get_question        => \&TestMe::Tests::Tests::getQuestion,
        submit_answer       => \&TestMe::Tests::Tests::submitAnswer,
        get_result          => \&TestMe::Tests::Tests::getResult
    };

    if(defined $$self{cgi}{action} && exists $$actions_map{$$self{cgi}{action}})
    {
       return $$actions_map{$$self{cgi}{action}}->($self);
    }
    else
    {
        ASSERT_PEER(0, "Action not specified", "TM001");
    }
}

1;
