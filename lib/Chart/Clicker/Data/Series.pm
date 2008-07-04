package Chart::Clicker::Data::Series;
use Moose;
use MooseX::AttributeHelpers;

use Chart::Clicker::Data::Range;

has 'error_count' => ( is => 'rw', isa => 'Int' );
has 'errors' => ( is => 'rw', isa => 'Num' );
has 'name' => ( is => 'rw', isa => 'Str' );
has 'range' => (
    is => 'rw',
    isa => 'Chart::Clicker::Data::Range',
    default => sub { Chart::Clicker::Data::Range->new() }
);
has 'keys' => (
    metaclass => 'Collection::Array',
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    provides => {
        'push' => 'add_to_keys',
        'count' => 'key_count'
    }
);
has 'values' => (
    metaclass => 'Collection::Array',
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    provides => {
        'push' => 'add_to_values',
        'count' => 'value_count'
    }
);

sub prepare {
    my $self = shift();

    my $values = $self->values();
    my $keys = $self->keys();

    $self->key_count(scalar(@{ $keys }));
    $self->value_count(scalar(@{ $values }));

    if($self->key_count() != $self->value_count()) {
        die('Series key/value counts dont match.');
    }

    if($self->errors()) {
        my @errors = @{ $self->errors() };
        $self->error_count(scalar(@errors));

        if($self->error_count() != $self->value_count()) {
            die('Series error/value counts don\'t match');
        }
    }

    my ($long, $max, $min);
    $long = 0;
    $max = $values->[0];
    $min = $values->[0];
    my $count = 0;
    foreach my $key (@{ $self->keys() }) {

        my $val = $values->[$count];

        # Max
        if($val > $max) {
            $max = $val;
        }

        # Min
        if($val < $min) {
            $min = $val;
        }
        $count++;
    }
    $self->range(
        Chart::Clicker::Data::Range->new({ lower => $min, upper => $max })
    );

    return 1;
}

no Moose;

1;
__END__

=head1 NAME

Chart::Clicker::Data::Series

=head1 DESCRIPTION

Chart::Clicker::Data::Series represents a series of values to be charted.

=head1 SYNOPSIS

  use Chart::Clicker::Data::Series;

  my @keys = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
  my @values = (42, 25, 86, 23, 2, 19, 103, 12, 54, 9);

  my $series = Chart::Clicker::Data::Series->new({
    keys    => \@keys,
    value   => \@values
  });

=head1 METHODS

=head2 Constructors

=over 4

=item I<new>

Creates a new, empty Series

=item I<errors>

Set/Get the errors for this series.

=item I<add_to_keys>

Adds a key to this series.

=item I<keys>

Set/Get the keys for this series.

=item I<key_count>

Get the count of keys in this series.

=item I<name>

Set/Get the name for this Series

=item I<numeric_keys>

Set/Get the flag that denotes if this series' keys are all numeric.

=item I<prepare>

Prepare this series.  Performs various checks and calculates
various things.

=item I<range>

Returns the range for this series.

=item I<add_to_values>

Add a value to this series.

=item I<value_count>

Get the count of values in this series.

=item I<values>

Set/Get the values for this series.

=back

=head1 AUTHOR

Cory 'G' Watson <jheephat@cpan.org>

=head1 LICENSE

You can redistribute and/or modify this code under the same terms as Perl
itself.
