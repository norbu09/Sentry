use inc::Module::Install;

name     'Sentry';
all_from 'lib/Sentry.pm';
author   q{Lenz Gschwendtner <norbu09@cpan.org>};
license  'perl';

build_requires 'Test::More';

requires 'Mouse';
requires 'Mouse::Role';
requires 'LWP::UserAgent';
requires 'URI::Escape';
requires 'XML::Simple';
requires 'IO::Socket';
requires 'Time::HiRes';
requires 'MouseX::Object::Pluggable';
requires 'Config::GitLike';
requires 'Sys::Hostname';

auto_install;

WriteAll;

