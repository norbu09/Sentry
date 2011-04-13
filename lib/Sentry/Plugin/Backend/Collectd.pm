#!/usr/bin/perl -Ilib

package Sentry::Plugin::Backend::Collectd;

use Mouse::Role;
use Collectd::Unixsock;

has 'collectd_socket' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    lazy     => 1,
    default  => '/var/run/collectd-unixsock'
);

around 'notify' => sub {
    my $orig = shift;
    my ($self) = @_;

    return unless $self->last_response;
    return unless $self->last_response->{time};
    return unless -S $self->collectd_socket;

    my $sock = Collectd::Unixsock->new( $self->collectd_socket );

    my $id = {
        host => $self->hostname, 
        plugin => $self->plugin, 
        type => 'latency', 
    };

    $sock->putval(
        $id,
        time   => time(),
        values => [ $self->last_response->{time} ]
    );

};

1;
