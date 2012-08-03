#!/usr/bin/perl

use strict;
use 5.10.0;
my ($mx, $my); # requested print size

unless( @ARGV ) {
    say 'imagesize { file | dimension }+';
    say '';
    say '  Image sizes in pixels and mm are shown for each file.';
    say '  Dimensions modify the density of image files (dpi), for instance:';
    say '  12x15mm, 100mm (height calculated), x32mm (width calculated)';
    exit 1;
}

sub getsize {
    my $file = shift;
    my $info = do { # avoid the shell, no escaping needed
        my @args =  ('-format','%G %x%y','-units','PixelsPerInch',$file);
        open my $fh, "-|", "identify", @args or die "$!\n";
        <$fh>;
    };
    if ($info =~ /^(\d+)x(\d+) (\d+) PixelsPerInch(\d+) PixelsPerInch/) {
        my ($px,$py,$dx,$dy) = ($1,$2,$3,$4);
        my ($sx,$sy) = map { $_ * 25.4 } ($px/$dx, $py/$dy);
        return ($px,$py,$dx,$dy,$sx,$sy);
    } else {
        die $info;
    }
}

foreach my $file (@ARGV) {
    if ($file =~ /^(\d*)(x(\d+))?mm$/) {
        ($mx,$my) = ($1,$3);
    } elsif( -e $file ) {
        my ($w,$h);
        if ($mx || $my) {
            my ($px,$py,$dx,$dy,$sx,$sy) = getsize($file);
            my $rx = 25.4 * ( $mx ? ($px/$mx) : ($py/$my) );
            my $ry = 25.4 * ( $my ? ($py/$my) : ($px/$mx) );
            system qw(convert -units PixelsPerInch -density),
                sprintf("%.0fx%.0f",$rx,$ry), $file, $file;
        }
        printf "$file: %dx%d at %dx%ddpi = %dx%dmm", getsize($file);
    } else {
        die "file not found: $file\n";
    }
}