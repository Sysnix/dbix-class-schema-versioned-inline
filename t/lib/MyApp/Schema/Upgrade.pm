package MyApp::Schema::Upgrade;

use Moo;
with 'DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade';

sub _build_upgrades {
    my $self = shift;

    $self->since( '0.002' => sub {
    });

    $self->since( '0.004' => sub {
    });

    $self->since( '0.005' => sub {
    });

}

1;
