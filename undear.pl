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

			if ($ext eq '.tar.bz2') {
				# bz2 file
				say "$file_name is a tar.bz2 file";
				system("tar -xjf $file_name -C $output_folder");

			}
			elsif ($ext eq '.tar.gz') {
				# gz file
				say "$file_name is a tar.gz file";
				system("tar -xzf $file_name -C $output_folder");
			}
			elsif ($ext eq '.tar.Z') {
				# Z / compress file
				say "$file_name is a tar.Z compress file";
				system("uncompress $file_name");
				chop($file_name);
				chop($file_name);
				system("tar -xf $file_name -C $output_folder");
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
				unlink($output_folder . "/duplicates_list.txt");
			} elsif ($options eq "-l") {
				# unarchive duplicate files as soft links to the original (use ln -s)
				say "* Create soft links";

				open (MYFILE, $output_folder . "/duplicates_list.txt");
				my $target_file;
				my $link_file;

				while (<MYFILE>) {
					chomp;
					($target_file, $link_file) = split(' ');
					my $target_file_destination = "$output_folder/$target_file";
					my $link_file_destination = "$output_folder/$link_file";
					my $link_dest = dirname $link_file_destination;
					my $target_dest = dirname $target_file_destination;
					my $relative_path = `realpath --relative-to=./$link_dest ./$target_dest`;
					chomp $relative_path;
					$target_file = basename $target_file;
					
					# crazy debugerinoes
					# say "target_file: $target_file";
					# say "target_file_destination: $target_file_destination";
					# say "link_file_destination: $link_file_destination";
					# say "link_dest: $link_dest";
					# say "target_dest: $target_dest";
					# say "relative_path: $relative_path\n";
					# say "output_folder: $output_folder";
					unless (-d dirname($link_file_destination)) {mkdir dirname($link_file_destination);}
					system("ln -s -v $relative_path/$target_file $link_file_destination");
				}

				unlink($output_folder . "/duplicates_list.txt");

			} elsif ($options eq "-c") {
				# unarchive duplicate files as copies of the original i.e. copy original file 
				# all occurrences of duplicates (same as before you archived everything)
				say "* Restore all copies";

				open (MYFILE, $output_folder . "/duplicates_list.txt");
				my $source_file;
				my $dest_file;

				while (<MYFILE>) {
					chomp;
					($source_file, $dest_file) = split(' ');
					my $output_dest = "$output_folder/$dest_file";
					unless (-d dirname $output_dest) {mkdir dirname($output_dest);}
					system("cp -v $output_folder/$source_file $output_dest");
				}

				unlink($output_folder . "/duplicates_list.txt");
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