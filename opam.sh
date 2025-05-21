#!/bin/sh

set -e
set -x

for v in 4.02 4.03 4.04 4.05 4.06 4.07 4.08 4.09 4.10 4.11 4.12 4.13 4.14 5.0 5.1 5.2 5.3 ; do
  if test "$(echo "$v" | cut -d. -f1)" -ge 5 ; then
    next_v=$(echo "$v + 0.1" | bc -l)
  else
    next_v=$(echo "$v + 0.01" | bc -l)
  fi
  if ! opam switch "$v" ; then
    opam switch create "$v" --empty
  fi
  opam repository set-repos kit-ty-kate default
  if opam switch set-invariant -y --formula '"ocaml-base-compiler" {>= "'${v}'.0" & < "'${next_v}'"} & "kit-ty-kate-platform"' ; then
    opam switch set-description 'ocaml-base-compiler (>= '${v}' & < '${next_v}') & kit-ty-kate-platform'
  else
    opam switch set-invariant -y --formula '"ocaml-base-compiler" {>= "'${v}'.0" & < "'${next_v}'"}'
    opam switch set-description 'ocaml-base-compiler (>= '${v}' & < '${next_v}')'
  fi
done
