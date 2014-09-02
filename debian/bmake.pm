# A debhelper build system class for handling simple bmake-based projects.
#
# Copyright: © 2008 Joey Hess
#            © 2008-2009 Modestas Vainius
# License: GPL-2+

package Debian::Debhelper::Buildsystem::bmake;

use strict;
use Debian::Debhelper::Dh_Lib qw(compat escape_shell clean_jobserver_makeflags);
use base 'Debian::Debhelper::Buildsystem::makefile';

sub DESCRIPTION {
	"bmake"
}

sub exists_make_target {
	my ($this, $target) = @_;

	# Use make -n to check to see if the target would do
	# anything. There's no good way to test if a target exists.
	my @opts=("-s", "-n");
	my $buildpath = $this->get_buildpath();
	unshift @opts, "-C", $buildpath if $buildpath ne ".";
	open(SAVEDERR, ">&STDERR");
	open(STDERR, ">/dev/null");
	open(MAKE, "-|", $this->{makecmd}, @opts, $target);
	my $output=<MAKE>;
	chomp $output;
	close MAKE;
	open(STDERR, ">&SAVEDERR");
	return defined $output && length $output;
}

# Currently, we don't want parallel build with bmake.
sub do_make {
	my $this=shift;

	# Avoid possible warnings about unavailable jobserver,
	# and force make to start a new jobserver.
	clean_jobserver_makeflags();

	$this->doit_in_builddir($this->{makecmd}, @_);
}

sub check_auto_buildable {
	my $this=shift;
	my ($step)=@_;

	if (-e $this->get_buildpath("makefile") ||
	    -e $this->get_buildpath("Makefile"))
	{
        my $ret = ($this->SUPER::check_auto_buildable(@_));

        open (MAKEFILE, "makefile") || open (MAKEFILE, "Makefile") ||
            return 0;

        while (<MAKEFILE>) {
                chomp;
                if (/^\.?\s*include\s+</) {
                        close MAKEFILE;
                        $ret++;
                        return $ret;
                }
        }
        close MAKEFILE;
        return $ret;
	}
	return 0;
}

sub new {
	my $class=shift;
	my $this=$class->SUPER::new(@_);
	$this->{makecmd} = "bmake";
	return $this;
}

1
