# dear [option] outfile indir

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use File::Basename;
use Archive::Tar;
use strict;
use warnings;
use diagnostics;
use Archive::Tar;

use feature 'say';

use feature "switch";


my $num_args = scalar @ARGV;
say "Number of arguments $num_args";
if ($num_args != 0) {
	foreach my $arg(@ARGV) {
		say $arg;
	}
}

my $indir;
my $outfile;
my $flag;
my $option;

if ($num_args == 2) {
	# no options have been specified
	$outfile = $ARGV[0];
	$indir = $ARGV[1];
} elsif ($num_args == 3) {
	# option has been specified
	($option, $outfile, $indir) = @ARGV;
	say "option: $option, outfile: $outfile, indir: $indir";
	if (lc $ARGV[0] eq "-g") {
		# compress with gzip
		say "*Compress with gzip";
	} elsif (lc $ARGV[0] eq "-b") {
		# compress with bzip2
		say "*Compress with bzip2";
	} elsif (lc $ARGV[0] eq "-z") {
		# compress (WITH ZIP refer to readme.txt)
		say "*Compress with zip";
	}
}


chomp($indir);
my $folder_name = basename($indir);
say "Folder name: $folder_name\n";
my $new = "Tempdir/" . $folder_name;

say "$indir, $new";

if (-d $indir) {
	my($num_of_files_and_dirs,$num_of_dirs,$depth_traversed) = rcopy($indir,$new);
	say "$num_of_files_and_dirs, $num_of_dirs, $depth_traversed";
} else {
	say "indir not found!!";
}


#!/usr/bin/perl -w
# This is a duplicate file finder.

use File::Find;
use Digest::MD5;

my %files;
my $wasted = 0;
find(\&check_file, $indir || ".");

open(my $fh, '>', 'duplicatesList.txt'); 

local $" = ", ";
my $first = 1;
say "Remove all duplicates? (y/n)";
my $in = <STDIN>;
chomp $in;

# Create new tar object
my $tar = Archive::Tar->new();

foreach my $size (sort {$b <=> $a} keys %files) {
  next unless @{$files{$size}} > 1;
  my %md5;
  $first = 1;
  foreach my $file (@{$files{$size}}) {

  	

    if ($first != 1) {
	    open(FILE, $file) or next;
	    binmode(FILE);
	    push @{$md5{Digest::MD5->new->addfile(*FILE)->hexdigest}},$file;
	    # print "\n\n-----KENFILE---\n\n $file \n\n";

	    if (lc $in eq "y" && $first == 0) {
	    	# unlink($file);
	        print "would have removed $file\n";
	    }
        print $fh "$file\n";	

	} else {
		# say "added $file";
		$tar->add_files($indir. "/*");
	}
	$first = 0;
  }

  foreach my $hash (keys %md5) {
    next unless @{$md5{$hash}} > 1;
    print "$size: @{$md5{$hash}}\n";
    $wasted += $size * (@{$md5{$hash}} - 1);
  }
}

$tar->write($outfile . ".tar");

1 while $wasted =~ s/^([-+]?\d+)(\d{3})/$1,$2/;
print "$wasted bytes in duplicated files\n";

close $fh;

sub check_file {
  -f && push @{$files{(stat(_))[7]}}, $File::Find::name;
}