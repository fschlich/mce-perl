###############################################################################
## ----------------------------------------------------------------------------
## Number sequence class for use with MCE::Shared.
##
###############################################################################

package MCE::Shared::Sequence;

use strict;
use warnings;

no warnings qw( threads recursion uninitialized );

our $VERSION = '1.699_003';

use Scalar::Util qw( looks_like_number );
use MCE::Shared::Base;

use constant {
   _BEGV => 0,  # sequence begin value
   _ENDV => 1,  # sequence end value
   _STEP => 2,  # sequence step size
   _FMT  => 3,  # sequence format
   _ITER => 4,  # iterator count
};

use overload (
   q("")    => \&MCE::Shared::Base::_stringify_a,
   q(0+)    => \&MCE::Shared::Base::_numify,
   fallback => 1
);

sub _croak {
   goto &MCE::Shared::Base::_croak;
}

sub new {
   my ( $class, @self ) = @_;

   _croak( 'Invalid BEGIN' ) unless looks_like_number( $self[_BEGV] );
   _croak( 'Invalid END'   ) unless looks_like_number( $self[_ENDV] );

   $self[_STEP] = ( $self[_BEGV] <= $self[_ENDV] ) ? 1 : -1
      unless ( defined $self[_STEP] );

   _croak( 'Invalid STEP'  ) unless looks_like_number( $self[_STEP] );

   $self[_ITER] = undef;
   bless \@self, $class;
}

sub next {
   my ( $self ) = @_;
   my $iter = $self->[_ITER];

   if ( defined $iter ) {
      my $seq; my ( $begv, $endv, $step, $fmt ) = @{ $self };
      ## always compute from _BEGV to not lose precision

      if ( $begv <= $endv ) {
         $seq = $begv + ( $iter * $step );
         return unless ( $seq >= $begv && $seq <= $endv );
      }
      else {
         $seq = $begv - -( $iter * $step );
         return unless ( $seq >= $endv && $seq <= $begv );
      }

      $self->[_ITER]++, ( defined $fmt )
         ? sprintf( $fmt, $seq )
         : $seq;
   }
   else {
      $self->[_ITER] = 0;
      $self->next();
   }
}

sub prev {
   my ( $self ) = @_;
   my $iter = $self->[_ITER];

   if ( defined $iter ) {
      my $seq; my ( $begv, $endv, $step, $fmt ) = @{ $self };
      ## always compute from _BEGV to not lose precision

      if ( $begv <= $endv ) {
         $seq = $begv + ( $iter * $step );
         return unless ( $seq >= $begv && $seq <= $endv );
      }
      else {
         $seq = $begv - -( $iter * $step );
         return unless ( $seq >= $endv && $seq <= $begv );
      }

      $self->[_ITER]--, ( defined $fmt )
         ? sprintf( $fmt, $seq )
         : $seq;
   }
   else {
      $self->[_ITER] = int(
         ( $self->[_ENDV] - $self->[_BEGV] ) / $self->[_STEP]
      );
      $self->prev();
   }
}

sub reset {
   $_[0]->[_ITER] = undef;
}

1;

__END__

###############################################################################
## ----------------------------------------------------------------------------
## Module usage.
##
###############################################################################

=head1 NAME

MCE::Shared::Sequence - Number sequence generator

=head1 VERSION

This document describes MCE::Shared::Sequence version 1.699_003

=head1 SYNOPSIS

   # non-shared
   use MCE::Shared::Sequence;

   my $s = MCE::Shared::Sequence->new( $begin, $end, $step, $fmt );

   # shared
   use MCE::Hobo;
   use MCE::Shared Sereal => 1;

   my $s = MCE::Shared->sequence( 1, 100 );

   sub parallel {
      my ( $id ) = @_;
      while ( my $seq = $s->next ) {
         print "$id: $seq\n";
      }
   }

   MCE::Hobo->new( \&parallel, $_ ) for 1 .. 8;

   $_->join for MCE::Hobo->list();

=head1 DESCRIPTION

Helper class for L<MCE::Shared|MCE::Shared>.

=head1 API DOCUMENTATION

To be completed before the final 1.700 release.

=over 3

=item new

=item next

=item prev

=item reset

=back

=head1 INDEX

L<MCE|MCE>, L<MCE::Core|MCE::Core>, L<MCE::Shared|MCE::Shared>

=head1 AUTHOR

Mario E. Roy, S<E<lt>marioeroy AT gmail DOT comE<gt>>

=cut
