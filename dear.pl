# dear [option] outfile indir

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use File::Path qw(remove_tree);
use IO::Compress::Bzip2 qw(bzip2 $Bzip2Error);
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Compress::Zip qw(zip $ZipError);
use File::Basename;
use Archive::Tar;
use strict;
use warnings;
use diagnostics;
use Archive::Tar;
use File::Find;
use Digest::MD5;

use feature 'say';


my $num_args = scalar @ARGV;

my $indir;
my $outfile;
my $flag;
my $option = "";
my $duplicates_list = "duplicates_list.txt";

if ($num_args == 2) {
	# no options have been specified
	($outfile, $indir) = @ARGV;
	say "outfile: $outfile, indir: $indir";
} elsif ($num_args == 3) {
	# option has been specified
	($option, $outfile, $indir) = @ARGV;
	say "option: $option, outfile: $outfile, indir: $indir";
}

chomp($indir);
my $folder_name = basename($indir);
# say "Folder name: $folder_name\n";
my $new = "Tempdir/" . $folder_name;

if (dirname($outfile) eq dirname($indir . "/something")) {
	say "oh no indir and outfile are in the same directory!! pls don't do this";
} else {
	if (-d $indir) {
		if (-d dirname($outfile)) {
			my($num_of_files_and_dirs,$num_of_dirs,$depth_traversed) = rcopy($indir,$new);
			say "$num_of_files_and_dirs, $num_of_dirs, $depth_traversed";

			my %files;
			my $wasted = 0;
			# get all files in the directory
			say (find(\&check_file, $indir || "."));

			# open the duplicates list file
			open(my $fh, '>', $duplicates_list); 

			local $" = ", ";
			# Create new tar object
			my $tar = Archive::Tar->new();
		  	my $firstFile = "";
		  	my $firstMD5 = -1;

		  	# sort everything in basename order
			foreach my $name (sort {basename ($a) cmp basename ($b)} keys %files) {
			  	my %md5;
			  	# get dat md5
			  	foreach my $md5 (@{$files{$name}}) {
			  		say "firstFile: $firstFile, firstMD5: $firstMD5";
			  		my $basename = basename $name;
					say "basename: $basename, md5: $md5";
					# check for name matches
			    	if ($basename eq $firstFile) {
			    		# check to make sure md5 isn't matching (i.e. same name but diff md5)
			    		if ($md5 ne $firstMD5) {
							say "added $name";
							$tar->add_files($name);
							$firstFile = $basename;
							$firstMD5 = $md5;
						} else { # same name and same md5
						    open(FILE, $name) or next;
						    say "opened $name";
						    binmode(FILE);
						    push @{$md5{Digest::MD5->new->addfile(*FILE)->hexdigest}},$name;
					        print $fh "$firstFile $name\n";	
					    }
					} else { # different name don't worry about md5
						say "added $name";
						$tar->add_files($name);
						$firstFile = $basename;
						$firstMD5 = $md5;
					}
			  	}
			}

			close $fh;
			remove_tree("Tempdir");

			# add files to tar
			$tar->add_files($duplicates_list);
			# delete the leftover duplicates file
			unlink $duplicates_list;
			$outfile = join "", $outfile, ".tar";
			$tar->write($outfile);

			# compression options based on flag
			if (lc $ARGV[0] eq "-g") {
				# compress with gzip
				say "* Compress with gzip";
				gzip $outfile => ($outfile . ".gz") or die "gzip failed: $GzipError\n";
			} elsif (lc $ARGV[0] eq "-b") {
				# compress with bzip2
				say "* Compress with bzip2";
				bzip2 $outfile => ($outfile . ".bz2") or die "bzip2 failed: $Bzip2Error\n";
			} elsif (lc $ARGV[0] eq "-c") {
				# compress (WITH ZIP refer to readme.txt)
				say "* Compress with compress";
				system("compress -f $outfile");
			} else {
				# don't need to do anything, leave as tar file
			}


			# pushes files + their md5 into a hash
			sub check_file {
				my $filename = $_;
  				my $fullpath = $File::Find::name;	
  				my $size = (stat($filename))[7];
		  		if (-e $filename) { 
		  			print "$filename exists!\n";
					say "File name: $filename, size: $size"; 
				}

				push @{$files{$fullpath}}, Digest::MD5->new->add($size)->hexdigest;
			}
		} else {
			say "outfile directory not found!! pls check it exists";
		}
	} else {
		say "indir not found!! pls check it exists";
	}
}