#!/usr/bin/perl -w

# Reads data from a Current Cost device via USB port and logs it to a file

# Based on Paul Mutton's excellent Perl script and tutorial: http://www.jibble.org/currentcost/
# with modifications from Jamie Bennett: http://www.linuxuk.org/2008/12/currentcost-and-ubuntu/

# This module requires the Device::SerialPort Perl module.  Install this using Perl's package manager:
# At the Linux command line, type:
#    sudo perl -MCPAN -e shell
# And then type:
#    install Device::SerialPort

use strict;
use Device::SerialPort qw( :PARAM :STAT 0.07 );

my $PORT    = "/dev/ttyUSB0";
my $LOGFILE = "data.txt";

my $day;
my $month;
my $year;

print "Current Cost logger...\n";

my $ob = Device::SerialPort->new($PORT);
$ob->baudrate(57600);
$ob->write_settings;

open(SERIAL, "+>$PORT");
print "Opened serial port.\nYEAR,Mm,Dd,HH,MM,SS,Watts\n";

while (my $line = <SERIAL>) {
    if ($line =~ m!<time>(\d+):(\d+):(\d+)</time>.*<ch1><watts>0*(\d+)</watts></ch1>!) {
	# For Perl regex help, see http://www.cs.tut.fi/~jkorpela/perl/regexp.html
	# For Current Cost XML details, see http://www.currentcost.com/cc128/xml.htm

        my $hours = $1;
        my $mins  = $2;
        my $secs  = $3;
        my $watts = $4;

	# Get today's date from the Linux computer
	($day, $month, $year) = (localtime)[3,4,5];
	$month += 1;
	$year  += 1900;

	my $output = "$year,$month,$day,$hours,$mins,$secs,$watts\n";
        print $output;

	# Log the output to file
	# Open and close on every iteration to flush it to disk every iteration
	open(MYFILE, ">>$LOGFILE");
        print MYFILE $output;
	close(MYFILE);
    }
}

