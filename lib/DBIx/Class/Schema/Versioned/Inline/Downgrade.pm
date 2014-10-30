package DBIx::Class::Schema::Versioned::Inline::Downgrade;

=head1 NAME

DBIx::Class::Schema::Versioned::Inline::Downgrade

=cut

use warnings;
use strict;

use Exporter 'import';
use version 0.77;
use vars qw/%DOWNGRADES @EXPORT/;
our @EXPORT = qw/since before after/;

=head1 SYNOPSIS

  package MyApp::Schema::Downgrade;
 
  use base 'DBIx::Class::Schema::Versioned::Inline::Downgrade';
  use DBIx::Class::Schema::Versioned::Inline::Downgrade qw/before after/;

  before '0.3.3' => sub {
      my $schema = shift;
      $schema->resultset('Foo')->update({ bar => '' });
  };

  after '0.3.5' => sub {
      my $schema = shift;
      # do something
  };

  1;


=head1 DESCRIPTION

schema/data downgrade helper for L<DBIx::Class::Schema::Versioned::Inline>.

Assuming that your Schema class is named C<MyApp::Schema> then you create a subclass of this class as C<MyApp::Schema::Downgrade> and call the before and after methods from your Downgrade.pm.

=head1 METHODS

=head2 before VERSION SUB

Calling it signifies that SUB should be run immediately before upgrading the schema to version VERSION. If multiple subroutines are given for the same version, they are run in the order that they were set up.

Example:

Say you have a column definition in one of you result classes that was initially created with C<is_nullable => 1> and you decide that in a newer schema version you need to change it to C<is_nullable => 0>. You need to make sure that any existing null values are changed to non-null before the schema is modified.

You old Foo result class looks like:

    __PACKAGE__->add_column(
        "bar",
        { data_type => "integer", is_nullable => 1 }
    );

For you updated version 0.4 schema you change this to:

    __PACKAGE__->add_column(
        "bar",
        { data_type => "integer", is_nullable => 1, extra => {
            changes => {
                '0.4' => { is_nullable => 0 },
            },
        }
    );

and in your Downgrade subclass;

    before '0.4' => sub {
        my $schema = shift;
        $schema->resultset('Foo')->update({ bar => '' });
    };

=cut

sub before {
    _add_downgrade( 'before', @_ );
}

=head2 after VERSION SUB

Calling it signifies that SUB should be run immediately after upgrading the schema to version VERSION. If multiple subroutines are given for the same version, they are run in the order that they were set up.

=cut

sub after {
    _add_downgrade( 'after', @_ );
}

sub _add_downgrade {
    my ( $type, $version, $sub ) = @_;
    push @{ $DOWNGRADES{$version}{$type} }, $sub;
}

=head2 versions

Returns an ordered list of the downgrade versions that have been registered.

=cut

sub versions {
    my $class = shift;
    return sort { version->parse->parse($a) <=> version->parse($b) }
      keys %DOWNGRADES;
}

=head2 after_downgrade VERSION

Returns the C<before> subroutines that have been registered for the given version.

=cut

sub after_downgrade {
    my ( $self, $version ) = @_;
    return unless $DOWNGRADES{$version}{after};
    return
      wantarray
      ? @{ $DOWNGRADES{$version}{after} }
      : $DOWNGRADES{$version}{after};
}

=head2 before_downgrade VERSION

Returns the C<before> subroutines that have been registered for the given version.

=cut

sub before_downgrade {
    my ( $self, $version ) = @_;
    return unless $DOWNGRADES{$version}{before};
    return
      wantarray
      ? @{ $DOWNGRADES{$version}{before} }
      : $DOWNGRADES{$version}{before};
}

1;
