use strict;
use warnings;
use diagnostics;

use feature 'say';

use feature "switch";


say $ARGV[0];
say "Number of arguments ", scalar @ARGV;
# say "Number of arguments ", $#ARGV + 1;

if ($ARGV[0] eq "memes") {
	say "YES\n";
} else {
	say "NO\n";
}

system("echo lalalala");

# my $line = <STDIN>;

# chomp $line;

# print STDOUT $line, "\n";

# print;
