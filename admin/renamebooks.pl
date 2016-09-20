#!/usr/bin/perl
# ABSTRACT: Translate tools

use autodie;
use strict;
use warnings;
use utf8;
use diagnostics;
binmode(STDOUT, ":utf8");

use Getopt::Long;
use Pod::Usage;

##############################
# Documentation

my $man = 0;
my $help = 0;
## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions('help|?' => \$help, man => \$man) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

=head1 NAME

    renamebooks

=head1 DESCRIPTION

Generates the sed script to replace bad abbreviations of the books of the Bible by good ones.

    The abbreviations used in Divinum Officium are inspired 
    by those of the Vulgate, the 1961 editio typica of
    the Breviarium Romanum and the 1962 editio typica
    of the Missale Romanum.

=head1 USAGE OF GENERATED renamebooks.sed

It is then simple to use the sed script generated with the following command line:
    sed -f renamebooks.sed -i.tmp <file>

or on a directory :
    find /path/to/files -type f -exec sed -i -f renamebooks.sed {} \;

=head1 OPTIONS

=over 4

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=head1 AUTHOR

    Luc Absil - <luc@absil.fr> - 2016
    GPLv3

Please report bugs using https://github.com/DivinumOfficium/divinum-officium/issues/


=back

=cut

#
#######################


# LIST OF ABBREVIATIONS
#######################
my %unnumbered = (
   #good_abbr=> [ old_abbr,… ]
    Gen      => [ "Rdz" ],
    Ex       => [ "Exod", "Exodus", "Esod", "Exo", "Wj" ],
    Levit    => [ "Lev", "Kpł" ],
    Num      => [ "Num" ],
    Deut     => [ "Pp" ],
    Ios      => [],
    Judic    => [],
    Ruth     => [],
    Tob      => [],
    Judith   => [ "Jdt", "Jd" ],
    Esth     => [ "Est" ],
    Job      => [ "Giobbe" ],
    Ps       => [ "Psalmum", "Psalmus", "PSALM" ],
    Prov     => [ "Prov", "Prz", "Spr" ],
    Eccl     => [ "Eccl", "Koh" ],
    Cant     => [ "Cant", "Pnp", "Hld" ],
    Sap      => [ "Wis", "Sap", "Weish" ],
    Eccli    => [ "Sir", "Eccli", "Syr", "Ecclus" ],
    Isai     => [ "Isa", "Is", "Iz", "Jes" ],
    Jerem    => [ "Jer", "Jr", "Ger" ],
    Baruch   => [ "Bar" ],
    Ezech    => [ "Ezek", "Ezech", "Ez", "Ezec" ],
    Dan      => [ "Dan", "Dn" ],
    Osee     => [ "Hos", "Oz" ],
    Joël     => [ "Joel", "Gioele", "Jl", "Jonć" ],
    Amos     => [ "Amos" ],
    Abd      => [ "Abd" ],
    Jonæ     => [ "Jonah" ],
    Mich     => [ "Mic", "Mi" ],
    Nah      => [ "Nah" ],
    Hab      => [ "Hab", "Habac" ],
    Soph     => [ "Zeph" ],
    Agg      => [ "Agg", "Hag" ],
    Zach     => [ "Zech", "Zach", "Za", "Sach", "Zak", "Zch" ],
    Malach   => [ "Mal", "Malach", "Ml" ],
    Matth    => [ "Matt", "Mat", "Mt" ],
    Marc     => [ "Mark", "Marco" ],
    Luc      => [ "Luke", "Łk", "Lk", "Luca" ],
    Joann    => [ "John", "Joannes", "J", "Joh", "Giovanni", "Giov", "Gio", "Jn" ],
    Act      => [ "Acts", "Dz", "Apg", "ApCsel", "Atti" ],
    Rom      => [ "Rom", "Rz", "Röm", "Róm" ],
    Gal      => [ "Gal", "Ga" ],
    Ephes    => [ "Eph", "Ef", "Efe" ],
    Phil     => [ "Phil", "Flp", "Fil", "Filipp" ],
    Col      => [ "Col", "Kol" ],
    Tit      => [ "Titus", "Tit", "Tt", "Tyt", "Tito" ],
    Philem   => [ "Phlm" ],
    Hebr     => [ "Heb", "Hbr", "Zsid", "Ebr" ],
    Jacob    => [ "Jas", "Jac", "Jk", "Jak", "Giac", "Gia", "James" ],
    Jud      => [ "Jude", "Juda", "Judas", "Jud", "Giuda" ],
    Apoc     => [ "Rev", "Apo", "Apoc", "Ap", "Offb" ],
    );

my %numbered = (
   #good_abbr => [ [number(s)], [ old_abbr,… ] ]
    "1 Reg"   => [ [1], [ "Sam", "Sm" ] ],
    "2 Reg"   => [ [2], [ "Sam", "Sm" ] ],
    "3 Reg"   => [ [1, 3], ["Kgs", "Kings", "Krl" ] ],
    "4 Reg"   => [ [2, 4], ["Kgs", "Kings", "Krl" ] ],
    "1 Paral" => [ [1], [ "Chr" ] ],
    "2 Paral" => [ [2], [ "Chr" ] ],
    "1 Esdr"  => [ [1], [] ],
    "2 Esdr"  => [ [2], [ "Neh" ] ],
    "3 Esdr"  => [ [3], [] ],
    "4 Esdr"  => [ [4], [] ],
    "1 Mach"  => [ [1], [ "Mac" ] ],
    "2 Mach"  => [ [2], [ "Mac" ] ],
    "1 Cor"   => [ [1], [ "Cor", "Kor", "Kor", "Cro" ] ],
    "2 Cor"   => [ [2], [ "Cor", "Kor", "Kor", "Cro" ] ],
    "1 Thess" => [ [1], [ "Thess", "Tes", "Tessz", "Tess" ] ],
    "2 Thess" => [ [2], [ "Thess", "Tes", "Tessz", "Tess" ] ],
    "1 Tim"   => [ [1], [ "Tim", "Tm" ] ],
    "2 Tim"   => [ [2], [ "Tim", "Tm" ] ],
    "1 Petri" => [ [1], [ "Pet", "Petri", "Pét", "P", "Pietro" ] ],
    "2 Petri" => [ [2], [ "Pet", "Petri", "P", "Pietro" ] ],
    "1 Joann" => [ [1], [$unnumbered{Joann}[1]] ],
    "2 Joann" => [ [2], [$unnumbered{Joann}[1]] ],
    "3 Joann" => [ [3], [$unnumbered{Joann}[1]] ],
);

# List of abbreviations for a given book
########################################
# list_unnumbered(key_book);
sub list_unnumbered {
    my ($key_book) = @_;
    my @arr = @{$unnumbered{$key_book}};
    push @arr, $key_book;
    my $str = "\!( *)(" . join("|", @arr) . ")(\\.?) ";
    return ($str,);
}

# list_numbered(key_book);
sub list_numbered {
    my ($key_book) = @_;
    my @abbrs = ();
    my @nbers = ();
    
    # add roman numerals
    foreach my $i ( 0 .. $#{ $numbered{$key_book}[1] } ) {
        if ( defined $numbered{$key_book}[0][$i] ) {
            my $nb = $numbered{$key_book}[0][$i];
            if ( $nb < 4 ) {
                push @nbers, $nb;
                push @nbers, 'I'x$nb;
                } else {
                push @nbers, 'IV';
                }
        }
    }

    # add old abbr & derivates
    if ($key_book ne "3 Reg" and $key_book ne "4 Reg"){
        foreach my $nb ( @nbers ) {
            foreach my $i ( 0 .. $#{ $numbered{$key_book}[1] } ) {
            push @abbrs, "\!( *)$nb(\\.?)( *)$numbered{$key_book}[1][$i](\\.?) ";
            }
        }
    }
    
    # add good_abbr & derivates
    push @abbrs, "\!( *)$key_book(\\.?) ";
    
    return @abbrs;
}

#sedline(old, new)
sub sedline {
    my ($old, $new) = @_;
    my @lines = "s/$old/\!$new /";
}


# Processing
##############################
{
#directory as a variable
my $dir = "out";

#creation of the sed script
open my $fh, '>:encoding(UTF-8)', "renamebooks.sed";

#unnumbered books abbreviations
foreach my $book ( keys %unnumbered ) {
    my @abbrs = list_unnumbered($book);

    foreach my $i ( 0 .. scalar(@abbrs) ) {
        if (defined $abbrs[$i] ){
            my @lines = sedline($abbrs[$i],$book);
            print {$fh} "@lines", "\n";
        }
    }
}

#numbered books abbreviations
foreach my $book ( keys %numbered ) {
    my @abbrs = list_numbered($book);

    foreach my $i ( 0 .. scalar(@abbrs) ) {
        if (defined $abbrs[$i] ){
            my @lines = sedline($abbrs[$i],$book);
            print {$fh} "\n", "@lines";
        }
    }
}

#close sed script
close $fh;

}
