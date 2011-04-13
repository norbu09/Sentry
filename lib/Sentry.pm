package Sentry;

use strict;
use warnings;
use Mouse;
use Sys::Hostname;

with 'MouseX::Object::Pluggable';

=head1 NAME

MonIt - The great new MonIt!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

has 'debug' => (is => 'rw', isa => 'Bool', default => 0, predicate => 'is_debug');
has 'running' => (is => 'rw', isa => 'Str');
has 'hostname' => (is => 'rw', isa => 'Str', default => hostname());
has 'error' => (is => 'rw', isa => 'Str', predicate => 'has_error');

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use MonIt;

    my $foo = MonIt->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 check

=cut

sub check {
    my ($self, $check, $data) = @_;

    $self->running($check);
    my $test = 'Check::'.ucfirst($check);
    eval ($self->load_plugin($test));
    if($@){
        $self->error = "Could not load test definition: $test";
        return;
    }   
    
    return $self->test($data);
}

=head2 test

the test stub function the Check plugins have to override

=cut

sub test {
    my ($self, $data) = @_;

    return;
}

=head2 notify

the test stub function the Check plugins have to override

=cut

sub notify {
    my ($self, $data) = @_;

    return;
}

=head1 AUTHOR

Lenz Gschwendtner, C<< <norbu09 at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-monit at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MonIt>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MonIt


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MonIt>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MonIt>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MonIt>

=item * Search CPAN

L<http://search.cpan.org/dist/MonIt/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Lenz Gschwendtner.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of MonIt