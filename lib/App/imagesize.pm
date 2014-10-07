package App::imagesize;

use strict;
use 5.008_005;
our $VERSION = '0.01';

sub new_from_args {
    my ($class, @args) = @_;
    my $self = bless {}, 'App::imagesize';

    # ... parse args ...
    $self->{args} = \@args;

    $self;
}

sub run {
    my ($self) = @_;

    unless (@{$self->{args}}) {
        print <<'USAGE';
imagesize { file | dimension }+

Image sizes in pixels and mm are shown for each file.
Dimensions modify the density of image files (dpi), for instance:
12x15mm, 100mm (height calculated), x32mm (width calculated)
USAGE
        return 1;
    }

    my ($mx, $my); # requested print size
    foreach my $file (@{$self->{args}}) {
        if ($file =~ /^(\d*)(x(\d+))?mm$/) {
            ($mx,$my) = ($1,$3);
        } elsif( -e $file ) {
            my ($w,$h);
            if ($mx || $my) {
                my ($px,$py,$dx,$dy,$sx,$sy) = $self->getsize($file);
                my $rx = 25.4 * ( $mx ? ($px/$mx) : ($py/$my) );
                my $ry = 25.4 * ( $my ? ($py/$my) : ($px/$mx) );
                system qw(convert -units PixelsPerInch -density),
                    sprintf("%.0fx%.0f\n",$rx,$ry), $file, $file;
            }
            printf "$file: %dx%d at %dx%ddpi = %dx%dmm\n", $self->getsize($file);
        } else {
            die "file not found: $file\n";
        }
    }
}

sub getsize { # uses 'identify' instead of Image::Size
    my ($self, $file) = @_;
	my $info = do { # avoid the shell, no escaping needed
		my @args =  ('-format','%G %x%y','-units','PixelsPerInch',$file);
		open my $fh, "-|", "identify", @args or die "$!\n";
		<$fh>;
	};
	if ($info =~ /^(\d+)x(\d+) ([0-9.]+) PixelsPerInch([0-9.]+) PixelsPerInch/) {
		my ($px,$py,$dx,$dy) = ($1,$2,$3,$4);
		my ($sx,$sy) = map { $_ * 25.4 } ($px/$dx, $py/$dy);
		return ($px,$py,$dx,$dy,$sx,$sy);
	} else {
		die "!$info";
	}
}

1;
__END__

=encoding utf-8

=head1 NAME

App::imagesize - ...

=head1 SYNOPSIS

    imagesize ...

Run C<imagesize -h> or C<perldoc imagesize> for more details.

=head1 DESCRIPTION

App::imagesize ...

Requires the command line tools C<convert> and C<identify>.

=head1 AUTHOR

Jakob Voß E<lt>jakob.voss@gbv.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2014- Jakob Voß

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Image::Size>

=cut
