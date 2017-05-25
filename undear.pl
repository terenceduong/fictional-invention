#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use feature 'say';
use feature "switch";

use File::Basename;
use IO::Uncompress::Bunzip2;
use IO::Uncompress::Gunzip;
use Archive::Tar;


my $num_args = scalar @ARGV;

my $options;
my $file_name;
my $output_folder;

if ($num_args == 3) {
	($options, $file_name, $output_folder) = @ARGV;
	my $firstchar = substr($output_folder, 0, 1);
	if ($firstchar eq "/") { # make sure first char of output_folder argument isn't a /
		$output_folder = substr($output_folder, 1);
	}
	$output_folder = dirname ($output_folder . "/.");
	say "options: $options, file name: $file_name, outputfolder: $output_folder";

	if (-d $output_folder) { # make sure output folder exists
		if (-e $file_name) { # make sure file exists too
			my @exts = qw (.bz2 .gz .Z .tar);
			chomp $file_name;
			say ("Filename: $file_name");

			# determine file type
			my ($name, $dir, $ext) = fileparse($file_name, @exts);
			say $ext;

			if ($ext eq '.tar.bz2') {
				# bz2 file
				say "$file_name is a tar.bz2 file";
				system("tar -xjf $file_name -C $output_folder");

			}
			elsif ($ext eq '.tar.gz') {
				# gz file
				say "$file_name is a tar.gz file";
			}
			elsif ($ext eq '.tar.Z') {
				# Z / compress file
				say "$file_name is a tar.Z compress file";
				system("uncompress $file_name");
			}
			elsif ($ext eq '.tar') {
				# just tar file
				say "$file_name is a tar file";
				system("tar -xf $file_name -C $output_folder");
			}
			else {
				# other file type
				say "$file_name is an unknown file type";
				exit 1;
			}

			if ($options eq "-d") {
				# delete duplicate files, i.e. delete the duplicates list and extract everything
				say "* Delete duplicate files";
			} elsif ($options eq "-l") {
				# unarchive duplicate files as soft links to the original (use ln -s)
				say "* Create soft links"
			} elsif ($options eq "-c") {
				# unarchive duplicate files as copies of the original i.e. copy original file 
				# all occurrences of duplicates (same as before you archived everything)
				say "* Restore all copies";
			} else {
				flag_usage();
			}
		} else {
			file_name_error();
		}
	} else {
		output_folder_error();
	}
} else {
	usage();
}

sub usage {
	say "Usage: undear.pl <flag> <filename> <output folder name>";
	say "Exiting.";
	exit 1;
}

sub flag_usage {
	say "Usage: undear.pl <flag> <filename> <output folder name>";
	say "Flag only acceps -d, -l or -c";
	say "Exiting.";
	exit 1;
}

sub output_folder_error {
	say "Output folder doesn't exist, please check again";
	say "Exiting.";
	exit 1;
}

sub file_name_error {
	say "File doesn't exist, please check again";
	say "Exiting.";
	exit 1;
}