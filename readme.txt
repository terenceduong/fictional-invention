Assume that Compress uses the compress command from the terminal.
	As a result, this requires the installation of ncompress.
	"sudo apt-get install ncompress" should do the trick.


*** dear.pl ***
Usage: dear.pl <flag> <outfile> <indir>

flag accepts -g, -b, -c or nothing. These flags simply determine how the tar file is compressed that's all.
outfile can be a name or directory / name but the directory must exist beforehand
indir must be a directory but it must exist beforehand also

The program will first compare the names of files in the directory (and subdirs) and if there are matches then compare their MD5 values. If both of these match then the file will NOT be added into the archive and instead added to the duplicates_list.txt file.
Any other case will result in the file being added into the archive. i.e. this program does not check for duplicate files with different file names.

The result will be an untouched indir folder and a resulting outfile.tar(.extension) file. 
	> .extension based on what flag is used upon running the program.




*** undear.pl ***
Usage: undear.pl <flag> <filename> <outdir>

flag accepts -d, -l and -c.
Undear will dearchive then consult the duplicates_list.txt to figure out where the old files were before, then based on the options flag will restore / symbolic link or delete files.
-d just deleted the duplicates list, this results in single copies of all files.
-c copies the original file to the location of where the duplicate files were i.e. restoring original file before dearing it.
-l finds relative links between the original file and duplicates and creates the symbolic links between them.