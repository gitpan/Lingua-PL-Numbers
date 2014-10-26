package Lingua::PL::Numbers;

$VERSION = '1.0';

use strict;
use vars qw($Idziesiatka);
use Carp;

sub new
{
	my $class = shift;
	my $number = shift || '';
	$Idziesiatka=0;

	my $self = {};
	bless $self, $class;

	if( $number =~ /\d+/ ) {
		return( $self->parse($number) );
	};

	return( $self );
};


sub parse 
{
	my $self = shift;
	my $number = shift;
	return( SLOWNIE($number,0) );
};

sub currency
{
	my $self = shift;
	my $number = shift;
	return( SLOWNIE($number,1) );
};



sub SLOWNIE {
	my ($Numer,$currency)=@_;

	my ($temps, $tempd, $tempj, $zlote, $grosze, $Licznik, $grd, $grj, $MiejsceDz, $T_S, $SLOWNIE);

	if ($Numer == 0) {
		if ($currency) {
			$SLOWNIE = "zero z� zero gr";
		} else {
			$SLOWNIE = "zero";
		}
	} else {
		if ($Numer > 9999999999999.99 || $Numer < 0) {
			carp "out of range in $Numer";
			$SLOWNIE = "out of range";
		} else {
			$Numer = Trim($Numer);
			$MiejsceDz = InStr($Numer);
			if ($MiejsceDz > 0 && Right($Numer,2) ne "00") {
				if ($currency) {
					$grosze = Left(Mid($Numer, $MiejsceDz + 1)."00", 2);
					$grd = Dziesiatki(Right($grosze, 2));
					if ($Idziesiatka!=1) {
						$grj = Jednostki(Right($grosze, 1));
					}
					$grosze = " ".$grd.$grj."gr";
					$Numer = Trim(Left($Numer, $MiejsceDz - 1));
				} else {
					carp "no decimals allowed in parse mode in $Numer";
					$zlote = "no decimals allowed in parse mode in $Numer";
				}
			} elsif ($currency) {
				$grosze = " zero gr";
			}
			if ($Numer>0 && ($currency || !$MiejsceDz)) {
				$Licznik = 1;
				while ($Numer ne "") {
					$temps = "";
					$tempd = "";
					$tempj = "";
					$temps = Setki(Right("000".$Numer, 3));
					$tempd = Dziesiatki(Right("00".$Numer, 2));
					if ($Idziesiatka!=1) {
						$tempj = Jednostki(Right($Numer, 1));
					}
					if ($Licznik==1) {
						$T_S = $temps.$tempd.$tempj;
					} elsif ($Licznik==2) {
						$T_S = $temps.$tempd.$tempj.KTys($Numer);
					} elsif ($Licznik==3||$Licznik==4||$Licznik==5) {
						$T_S = $temps.$tempd.$tempj.KMil($Numer, $Licznik);
					}
					$zlote = $T_S.$zlote;
		
					if (length($Numer) > 3) {
						$Numer = Left($Numer, length($Numer) - 3);
						$Licznik++;
					} else {
						$Numer = "";
					}
				}
			} elsif ($currency || !$MiejsceDz) {
				$zlote = "zero "
			}
			if ($Numer > -1) {
				if ($currency) {
					$SLOWNIE = $zlote."z�".$grosze;
				} else {
					$SLOWNIE = $zlote;
				}
			}
		}
	}
	return $SLOWNIE;
}

sub KTys {
	my $Numer=shift;
	my $KTys;
	my $tys=Val(Right("000".$Numer, 3));
	if ($tys == 0) {
		$KTys = "";
	} else {
		$tys = Val(Right($Numer, 2));
		if ($tys == 1) {
			$KTys = "�c ";
		} else {
			if ($tys == 12 || $tys == 13 || $tys == 14) {
				$KTys = "�cy ";
			} else {
				$tys = Val(Right($Numer, 1));
			}
			if ( $tys == 2 || $tys == 3 || $tys == 4) {
				$KTys = "�ce ";
			} else {
				$KTys = "�cy ";
			}
		}
		$KTys = "tysi".$KTys;
	}
	return $KTys;
}

sub KMil {
	my ($Numer, $L)=@_;
	my ($KMil,$mil);
	my @RzadW;
	$RzadW[3] = "milion";
	$RzadW[4] = "miliard";
	$RzadW[5] = "bilion";
	$mil = Val(Right("000".$Numer, 3));
	if ($mil == 0) {
		$KMil = "";
	} else {
		$mil = Val(Right($Numer, 2));
		if ($mil == 1) {
			$KMil = " ";
		} else {
			if ($mil == 12 || $mil == 13 || $mil == 14) {
				$KMil = "�w ";
			} else {
				$mil = Val(Right($Numer, 1));
				if ($mil == 2 || $mil == 3 || $mil == 4) {
					$KMil = "y ";
				} else {
					$KMil = "�w ";
				}
			}
		}
		$KMil = $RzadW[$L].$KMil;
	}
	return $KMil;
}

sub Setki {
	my $Numer=shift;
	my ($setka, $wynik);
	$setka = Val(Left($Numer, 1));
	if ($setka == 1) {
		$wynik= "sto ";
	} elsif ($setka == 2) {
		$wynik = "dwie�cie ";
	} elsif ($setka == 3) {
		$wynik = "trzysta ";
	} elsif ($setka == 4) {
		$wynik = "czterysta ";
	} elsif ($setka == 5) {
		$wynik = "pi��set ";
	} elsif ($setka == 6) {
		$wynik = "sze��set ";
	} elsif ($setka == 7) {
		$wynik = "siedemset ";
	} elsif ($setka == 8) {
		$wynik = "osiemset ";
	} elsif ($setka == 9) {
		$wynik = "dziewi��set ";
	} else {
		$wynik = "";
	}
	return $wynik;
}

sub Dziesiatki {
	my $Number=shift;
	my $wynik="";
	$Idziesiatka = Val(Left($Number, 1));
	if ($Idziesiatka == 1) {
		if (Val($Number) == 10) {
			$wynik = "dziesi�� ";
		} elsif (Val($Number) == 11) {
			$wynik = "jedena�cie ";
		} elsif (Val($Number) == 12) {
			$wynik = "dwana�cie ";
		} elsif (Val($Number) == 13) {
			$wynik = "trzyna�cie ";
		} elsif (Val($Number) == 14) {
			$wynik = "czterna�cie ";
		} elsif (Val($Number) == 15) {
			$wynik = "pi�tna�cie ";
		} elsif (Val($Number) == 16) {
			$wynik = "szesna�cie ";
		} elsif (Val($Number) == 17) {
			$wynik = "siedemna�cie ";
		} elsif (Val($Number) == 18) {
			$wynik = "osiemna�cie ";
		} elsif (Val($Number) == 19) {
			$wynik = "dziewi�tna�cie ";
		}
	} else {
		if ($Idziesiatka == 2) {
			$wynik = "dwadzie�cia ";
		} elsif ($Idziesiatka == 3) {
			$wynik = "trzydzie�ci ";
		} elsif ($Idziesiatka == 4) {
			$wynik = "czterdzie�ci ";
		} elsif ($Idziesiatka == 5) {
			$wynik = "pi��dziesi�t ";
		} elsif ($Idziesiatka == 6) {
			$wynik = "sze��dziesi�t ";
		} elsif ($Idziesiatka == 7) {
			$wynik = "siedemdziesi�t ";
		} elsif ($Idziesiatka == 8) {
			$wynik = "osiemdziesi�t ";
		} elsif ($Idziesiatka == 9) {
			$wynik = "dziewi��dziesi�t ";
		}
	}	
	return $wynik;
}
 
sub Jednostki {
	my $Numer=shift;
	my ($jedst, $wynik);
	$jedst = Val(Right($Numer, 1));
	if ($jedst == 1) {
		$wynik = "jeden ";
	} elsif ($jedst == 2) {
		$wynik = "dwa ";
	} elsif ($jedst == 3) {
		$wynik = "trzy ";
	} elsif ($jedst == 4) {
		$wynik = "cztery ";
	} elsif ($jedst == 5) {
		$wynik = "pi�� ";
	} elsif ($jedst == 6) {
		$wynik = "sze�� ";
	} elsif ($jedst == 7) {
		$wynik = "siedem ";
	} elsif ($jedst == 8) {
		$wynik = "osiem ";
	} elsif ($jedst == 9) {
		$wynik = "dziewi�� ";
	}
	return $wynik;
}

sub Left {
	my ($Numer, $count) = @_;
	$Numer = substr($Numer,0,$count);
	return $Numer;
}

sub Right {
	my ($Numer, $count) = @_;
	$Numer = substr($Numer,-$count);
	return $Numer;
}

sub Trim {
	my $Numer = shift;
	$Numer=~s/^\s+//;
	$Numer=~s/\s+$//;
	return $Numer;
}

sub Val {
	my $Numer = shift;
	$Numer=~s/\D//g;
	return $Numer;
}

sub Mid {
	my ($Numer, $count) = @_;
	$Numer = substr($Numer,$count-1);
}

sub InStr {
	my $Numer = shift;
	my $ret=0;
	if ($Numer=~/^(\d+)\./) {
		$ret=length($1)+1;
	}
	return $ret;
}



1;

=pod

=head1 NAME

Lingua::PL::Numbers - Perl module for converting numeric values into their Polish equivalents

    
=head1 DESCRIPTION

Initial release, documentation and updates will follow.

=head1 SYNOPSIS

  use Lingua::PL::Numbers;
    
  my $numbers = Lingua::PL::Numbers->new;


  my $text = $numbers->parse( 123 );

  # prints 'sto dwadzie�cia trzy'
  print $text;


  my $currency = $numbers->currency ( 123.45 );

  # prints 'sto dwadzie�cia trzy z� czterdzie�ci pi�� gr'
  print $currency;


=head1 KNOWN BUGS

None, but that does not mean there are not any.

=head1 AUTHOR

Henrik Steffen, <cpan@topconcepts.de>

=cut

