package DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade;

=head1 NAME

DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade

=cut

use Exporter 'import';
use version 0.77;
use vars qw/%UPGRADES @EXPORT/;
@EXPORT = qw/since rename/;

=head1 SYNOPSIS

  package MyApp::Schema::Upgrade;
 
  use base 'DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade';
  use DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade qw( since rename );

  since '0.3.3' => sub {

      # class 'Item' renamed to 'Product' with new table name 'products'
      rename class => 'Item', to => 'Product', table => 'products';

      # class 'Product' column 'desc' renamed to 'description'
      rename class => 'Product', column => 'desc', to => 'description';

  };

  since '0.3.5' => sub {
      # do something
  };

  1;


  package MyApp::Schema::Result::Item;

  __PACKAGE__->until( '0.3.2' );

  __PACKAGE__->table("items");

  __PACKAGE__->add_columns(
      "desc",
      { ... },
      ...
  );
  ...
  1;


  package MyApp::Schema::Result::Product;

  __PACKAGE__->since( '0.3.3' );

  __PACKAGE__->table("products");

  __PACKAGE__->add_columns(
      "description",
      { ... },
      ...
  );
  ...
  1;


=head1 DESCRIPTION

schema/data upgrade helper for DBIC in the style of L<Jifty::Upgrade>.

=cut

=head1 METHODS

=head2 since VERSION SUB>

C<since> is meant to be called by subclass. Calling it signifies that SUB should be run when upgrading to version VERSION, after tables and columns are added, but before tables and columns are removed. If multiple subroutines are given for the same version, they are run in the order that they were set up.

=cut

sub since {
    my ( $version, $sub ) = @_;
    if ( exists $UPGRADES{$version} ) {
        $UPGRADES{$version} = sub { $UPGRADES{$version}->(); $sub->(); }
    }
    else {
        $UPGRADES{$version} = $sub;
    }
}

=head2 versions

Returns an ordered list of the upgrade versions that have been registered.

=cut

sub versions {
    my $class = shift;
    return sort { version->parse->parse($a) <=> version->parse($b) }
      keys %UPGRADES;
}

=head2 upgrade_to

Runs the subroutine that has been registered for the given version; if no subroutine was registered, returns a no-op subroutine.

=head2 rename table => CLASS, [column => COLUMN,] to => NAME

Used in upgrade subroutines, this executes the necessary SQL to rename the table, or column in the table, to a new name.

=cut

1;
