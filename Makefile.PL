use inc::Module::Install;

name     'MonIt';
all_from 'lib/MonIt.pm';
author   q{Lenz Gschwendtner <norbu09@cpan.org>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

