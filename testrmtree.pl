use strict;
use warnings;
use diagnostics;

use feature 'say';

use feature "switch";

use File::Path qw(remove_tree);

remove_tree("Tempdir");