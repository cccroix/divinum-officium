#!/usr/bin/env bash
# Prints to stdout the (sed) regex to correct the abbreviations of the books
#
# Usage:
#   ./renamebook.sh | sed -rf- [sed options, eg -i] /path/to/my/files
#

varnumpattern='!( *)(([[:digit:]]|[IV]{1,3})( ?)(\.?)( *))(VARNAMES)( ?)(\.?) '
goodnumpattern='!\3 GOODNAME '
function corrects_num_names {
  while read -a names
  do
    varnames="${names[@]}"
    varnames="${varnames//' '/'|'}"
    goodname="${names[0]}"
    var="${varnumpattern/'VARNAMES'/$varnames}"
    good="${goodnumpattern/'GOODNAME'/$goodname}"
    echo "s#$var#$good#g"
  done <<EOF
    Cor Kor Cro
    Esdr Neh
    Joann John Joannes J Joh Giovanni Giov Gio Jn
    Mach Mac
    Paral Chr
    Petri Pet Pét P Pietro
    Reg Kgs Kings Krl Sam Sm Samuel
    Thess Tes Tessz Tess
    Tim Tm
EOF
}

varpattern='!( *)(VARNAMES)( ?)(\.?) '
goodpattern='!GOODNAME '
function corrects_names {
  while read -a names
  do
    varnames="${names[@]}"
    varnames="${varnames//' '/'|'}"
    goodname="${names[0]}"
    var="${varpattern/'VARNAMES'/$varnames}"
    good="${goodpattern/'GOODNAME'/$goodname}"
    echo "s#$var#$good#g"
  done <<EOF
    Abd Abd
    Act Acts Dz Apg ApCsel Atti
    Agg Agg Hag
    Amos Amos
    Apoc Rev Apo Apoc Ap Offb
    Baruch Bar
    Cant Cant Pnp Hld
    Col Col Kol
    Dan Dan Dn
    Deut Pp
    Eccl Eccl Koh
    Eccli Sir Eccli Syr Ecclus
    Ephes Eph Ef Efe
    Esth Est
    Ex Exod Exodus Esod Exo Wj
    Ezech Ezek Ezech Ez Ezec
    Gal Gal Ga
    Gen Rdz
    Hab Hab Habac
    Hebr Heb Hbr Zsid Ebr
    Ios
    Isai Isa Is Iz Jes
    Jacob Jas Jac Jk Jak Giac Gia James
    Jerem Jer Jr Ger
    Joann John Joannes J Joh Giovanni Giov Gio Jn
    Job Giobbe
    Jonæ Jonah
    Joël Joel Gioele Jl Jonć
    Jud Jude Juda Judas Jud Giuda
    Judic
    Judith Jdt Jd
    Levit Lev Kpł
    Luc Luke Łk Lk Luca
    Malach Mal Malach Ml
    Marc Mark Marco
    Matth Matt Mat Mt
    Mich Mic Mi
    Nah Nah
    Num Num
    Osee Hos Oz
    Phil Phil Flp Fil Filipp
    Philem Phlm
    Prov Prov Prz Spr
    Ps Psalmum Psalmus PSALM
    Rom Rom Rz Röm Róm
    Ruth
    Sap Wis Sap Weish
    Soph Zeph
    Tit Titus Tit Tt Tyt Tito
    Tob
    Zach Zech Zach Za Sach Zak Zch
EOF
}

function corrects_numbers {
    oldpattern="${goodnumpattern/'GOODNAME'/'([[:alpha:]]+)'}"
    newpattern="${goodnumpattern/'GOODNAME'/'\1'}"
    while read roman arab
    do
      old="${oldpattern/'\3'/$roman}"
      new="${newpattern/'\3'/$arab}"
      echo "s#$old#$new#g"
    done <<EOF
      I 1
      II 2
      III 3
      IV 4
EOF
}

function prints_regex {
  corrects_num_names
  corrects_numbers
  corrects_names
}

prints_regex
