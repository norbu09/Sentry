#!/usr/bin/perl -Ilib

package Sentry::Plugin::Backend::Prowl;

use Mouse::Role;
use LWP::UserAgent;
use URI::Escape;
use XML::Simple;

with 'MouseX::Object::Pluggable';

has 'prowl_apikeys' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub { [] }
);

has 'prowl_app' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    lazy => 1,
    default  => 'Sentry'
);

has 'prowl_prio' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
    lazy => 1,
    default  => 0
);

has 'prowl_event' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    lazy => 1,
    default  => 'alert'
);

has 'prowl_message' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    lazy => 1,
    default  => ''
);

has 'prowl_url' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    lazy => 1,
    default  => 'https://prowl.weks.net/publicapi/'
);

has 'prowl_err' => (
    is        => 'rw',
    predicate => 'has_prowl_error',
);

around 'notify' => sub {
    my $orig = shift;
    my ($self) = @_;

    if ( $self->has_error ) {
        my $message = "Host:  " . $self->hostname . "\n";
        $message .= "Check: " . $self->plugin . "\n";
        $message .= "Error: ";
        $message .= $self->error;
        $message .= "\n======\n";
        print STDERR $message;
        $self->prowl_message($message);
        $self->prowl_send();
    }
};

sub prowl_verify {
    my ( $self, $key ) = @_;
    my $path   = 'verify?apikey=' . $key;
    my $result = $self->_call($path);
    return $result;
}

sub prowl_add_key {
    my ( $self, $key ) = @_;
    if ( $self->prowl_verify($key) ) {
        push( @{ $self->prowl_apikeys }, $key );
    }
    else {
        warn $self->err;
    }
    return;
}

sub prowl_send {
    my $self = shift;
    my @req;
    if ( length $self->prowl_message > 10000 ) {
        $self->prowl_message( substr( $self->prowl_message, 0, 10000 ) );
    }
    if ( length $self->prowl_event > 1024 ) {
        $self->prowl_event( substr( $self->prowl_event, 0, 1024 ) );
    }
    push( @req, "apikey=" . join( ',', @{ $self->prowl_apikeys } ) );
    push( @req, "description=" . uri_escape( $self->prowl_message ) );
    push( @req, "event=" . uri_escape( $self->prowl_event ) );
    push( @req, "priority=" . $self->prowl_prio );
    push( @req, "application=" . uri_escape( $self->prowl_app ) );
    my $path = 'add?' . join( '&', @req );
    print STDERR "Request: $path\n";
    my $result = $self->_call($path);
    return $result;
}

sub _call {
    my ( $self, $path ) = @_;
    my $uri = $self->prowl_url . $path;
    print STDERR "URI: $uri\n" if $self->is_debug;

    my $req = HTTP::Request->new();
    $req->method('GET');
    $req->uri($uri);

    #$req->content( to_json($content) ) if ($content);

    my $ua  = LWP::UserAgent->new();
    my $res = $ua->request($req);
    print STDERR "Result: " . $res->decoded_content . "\n" if $self->is_debug;
    if ( $res->is_success ) {
        return XMLin( $res->decoded_content );
    }
    else {
        if ( my $_err = XMLin( $res->decoded_content ) ) {
            $self->prowl_err($_err);
        }
        else {
            $self->prowl_err( $res->status_line );
        }
    }
    return;
}

1;
