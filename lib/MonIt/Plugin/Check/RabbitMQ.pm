package MonIt::Plugin::Check::RabbitMQ;

use Mouse::Role;
use IO::Socket;
use Time::HiRes qw(gettimeofday tv_interval);

our $VERSION = '0.01';

around 'test' => sub {
    my $orig = shift;
    my ( $self, $data ) = @_;

    my $host = $data->{host} || 'localhost';
    my $port = $data->{port} || 5672;

    my $t0 = [gettimeofday];
    my $sock = IO::Socket::INET->new(
        Proto    => "tcp",
        PeerAddr => $host,
        PeerPort => $port,
    ) or $self->error("Could not connect to ".$host.':'.$port);
    return if $self->has_error;

    print $sock "AMQP\001\001\b\000";
    shutdown $sock, 1;
    my $res;
    while (<$sock>) {
        $res .= $_;
    }

    if($res =~ m/rabbitmq/i){
        return {code => 200, time => tv_interval($t0),};
    }

};

1;
