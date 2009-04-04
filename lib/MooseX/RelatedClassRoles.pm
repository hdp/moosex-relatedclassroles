package MooseX::Role::ApplyRelatedClassRoles;
# ABSTRACT: Apply roles to a class related to yours
use MooseX::Role::Parameterized;

parameter related_name => (
  isa      => 'Str',
  required => 1,
);

parameter accessor_name => (
  isa      => 'Str',
  lazy     => 1,
  default  => sub { $_[0]->related_name . '_class' },
);

parameter apply_method_name => (
  isa      => 'Str',
  lazy     => 1,
  default  => sub { 'apply_' . $_[0]->accessor_name . '_roles' },
);

role {
  my $p = shift;

  my $accessor_name     = $p->accessor_name;
  my $apply_method_name = $p->apply_method_name;

  requires $accessor_name;

  method $apply_method_name => sub {
    my $self = shift;
    my $meta = Moose::Meta::Class->create_anon_class(
      superclasses => [ $self->$accessor_name ],
      roles        => [ @_ ],
      cache        => 1,
    );
    $self->$accessor_name($meta->name);
  };
};

no MooseX::Role::Parameterized;
1;

__END__

=head1 SYNOPSIS

  package My::Class;
  use Moose;

  has driver_class => (
    isa => 'MyApp::Driver',
  );

  with 'MooseX::Role::ApplyRelatedClassRoles' => { related_name => 'driver' };

  # ...

  my $obj = My::Class->new(driver_class => "Some::Driver");
  $obj->apply_driver_class_roles("Other::Driver::Role");

=head1 DESCRIPTION

=cut
