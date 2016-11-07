use strict;
use Test::More;
use Test::Fatal;
use ZMQ::Constants qw(ZMQ_REP ZMQ_REQ ZMQ_NOBLOCK ZMQ_POLLIN);
use Time::HiRes qw(usleep);
BEGIN {
  use_ok "ZMQ::LibZMQ3";
}

subtest 'poll with zmq sockets and return scalar' => sub {
  my $ctxt = zmq_init();
  my $req = zmq_socket( $ctxt, ZMQ_REQ);
  my $rep = zmq_socket( $ctxt, ZMQ_REP);
  my $msgs = 0;
  zmq_bind($rep, "inproc://polltest");
  zmq_connect($req, "inproc://polltest");
  is exception {
    for (1..20){
      my $msg = "Test$_";
      my $expected_result = $msg;
      my @results;
      zmq_send($req, $msg);
      my $called;
      my $rv = zmq_poll([
                         {
                          socket => $rep,
                          events => ZMQ_POLLIN,
                          callback => sub {
                            $called = 1;
                            while(my $msg = zmq_recvmsg($rep, ZMQ_NOBLOCK)){
                              push @result , zmq_msg_data($msg);
                              zmq_msg_close($msg);
                            }
                          },
                         }
                        ]);
      ok($called, "callback is called");
      ok(defined($rv), "get true value in scalar environment");
      #is($result, $expected_result, "results correct");

      usleep 0.5 * 1000000;
    }
  }, undef, "PollItem correctly handles callback";

};

done_testing;
