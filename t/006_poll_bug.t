use strict;
use Test::More;
use Test::Fatal;
use ZMQ::Constants qw(ZMQ_SUB ZMQ_SUBSCRIBE ZMQ_NOBLOCK ZMQ_POLLIN);
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
      my $result;
      zmq_send($req, $msg);
      my $rv = zmq_poll([
                         {
                          socket => $rep,
                          events => ZMQ_POLLIN,
                          callback => sub {
                            my $msg_= recvmsg($rep, ZMQ_NOBLOCK);
                            $result = zmq_msg_data($msg);
                            zmq_msg_close($msg);
                          },
                         }
                        ]);
      ok($rv, "get truee value in scalar environment");
      is($result, $expected_result, "results correct");
    }
  }, undef, "PollItem correctly handles callback";

};

done_testing;
