##############################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
##############################################################################

package Perl::Critic::BuildUtilities;

use strict;
use warnings;

use English q<-no_match_vars>;

our $VERSION = '1.078';

use base qw{ Exporter };

our @EXPORT_OK = qw<
    recommended_module_versions
    test_wrappers_to_generate
    get_PL_files
    dump_unlisted_or_optional_module_versions
    emit_tar_warning_if_necessary
>;


use lib 't/tlib';

use Devel::CheckOS qw< os_is >;

use Perl::Critic::TestUtilitiesWithMinimalDependencies qw<
    should_skip_author_tests
>;


sub recommended_module_versions {
    return (
        'File::HomeDir'         => 0,
        'Perl::Tidy'            => 0,
        'Regexp::Parser'        => '0.20',

        # All of these are for Documentation::PodSpelling
        'File::Which'           => 0,
        'IPC::Open2'            => 1,
        'Pod::Spell'            => 1,
        'Text::ParseWords'      => 3,
    );
}


sub test_wrappers_to_generate {
    my @tests_to_be_wrapped = qw<
        t/00_modules.t
        t/01_config.t
        t/01_config_bad_perlcriticrc.t
        t/02_policy.t
        t/03_pragmas.t
        t/04_defaults.t
        t/05_utils.t
        t/05_utils_ppi.t
        t/06_violation.t
        t/07_perlcritic.t
        t/08_document.t
        t/09_theme.t
        t/10_userprofile.t
        t/11_policyfactory.t
        t/12_policylisting.t
        t/13_bundled_policies.t
        t/14_policy_parameters.t
        t/15_statistics.t
        t/20_policy_podspelling.t
        t/20_policy_requiretidycode.t
        t/80_policysummary.t
        t/92_memory_leaks.t
        t/94_includes.t
    >;

    return
        map
            { $_ . '_without_optional_dependencies.t' }
            @tests_to_be_wrapped;
}

sub get_PL_files {
    my %PL_files;

    $PL_files{'t/ControlStructures/ProhibitNegativeExpressionsInUnlessAndUntilConditions.run.PL'} =
        't/ControlStructures/ProhibitNegativeExpressionsInUnlessAndUntilConditions.run';
    $PL_files{'t/Variables/RequireLocalizedPunctuationVars.run.PL'} =
        't/Variables/RequireLocalizedPunctuationVars.run';

    if (should_skip_author_tests()) {
        print
              "\nWill not generate extra author tests.  Set "
            . '$ENV{TEST_AUTHOR} to a true value to have them generated.'
            . "\n\n";
    }
    else {
        $PL_files{'t/generate_without_optional_dependencies_wrappers.PL'} =
            [ test_wrappers_to_generate() ];
    }

    return \%PL_files;
}

sub dump_unlisted_or_optional_module_versions {
    print
        "\nVersions of optional/unlisted/indirect dependencies:\n\n";

    my @unlisted_modules = (
        qw<
            Exporter
            Readonly::XS
        >,
        keys %{ { recommended_module_versions() } },
    );

    foreach my $module (sort @unlisted_modules) {
        my $version;

        eval "use $module; \$version = \$${module}::VERSION;";
        if ($EVAL_ERROR) {
            $version = 'not installed';
        } elsif (not defined $version) {
            $version = 'undef';
        }

        print "    $module = $version\n";
    }

    print "\n";

    return;
}

sub emit_tar_warning_if_necessary {
    if ( os_is( qw<Solaris> ) ) {
        print <<'END_OF_TAR_WARNING';
NOTE: tar(1) on some Solaris systems cannot deal well with long file
names.

If you get warnings about missing files below, please ensure that you
extracted the Perl::Critic tarball using GNU tar.

END_OF_TAR_WARNING
    }
}

1;

__END__

=head1 NAME

Perl::Critic::BuildUtilities - Common bits of compiling Perl::Critic.


=head1 DESCRIPTION

Various utilities used in assembling Perl::Critic, primary for use by
*.PL programs that generate code.


=head1 IMPORTABLE SUBROUTINES

=over

=item C<recommended_module_versions()>

Returns a hash mapping between recommended (but not required) modules
for Perl::Critic and the minimum version required of each module,


=item C<test_wrappers_to_generate()>

Returns a list of test wrappers to be generated by
F<t/generate_without_optional_dependencies_wrappers.PL>.


=item C<get_PL_files()>

Returns a reference to a hash with a mapping from the name of a .PL
program to an array of the parameters to be passed to it, suited for
use by L<Module::Build::API/"PL_files"> or
L<ExtUtils::MakeMaker/"PL_FILES">.  May print to C<STDOUT> messages
about what it is doing.


=item C<dump_unlisted_or_optional_module_versions()>

Prints to C<STDOUT> a list of all the unlisted (e.g. things in core
like L<Exporter>), optional (e.g. L<File::Which>), or potentially
indirect (e.g. L<Readonly::XS>) dependencies, plus their versions, if
they're installed.


=item C<emit_tar_warning_if_necessary()>

On some Solaris systems, C<tar(1)> can't deal with long file names and
thus files are not correctly extracted from the tarball.  So this
prints a warning if the current system is Solaris.


=back


=head1 AUTHOR

Elliot Shank  C<< <perl@galumph.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Elliot Shank C<< <perl@galumph.com> >>. All rights
reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut

##############################################################################
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
