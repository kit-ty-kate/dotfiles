# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit findlib darcs

DESCRIPTION="a DSL for SQL Queries in Caml"
HOMEPAGE="https://ocsigen.org/macaque/"
EDARCS_REPOSITORY="http://forge.ocamlcore.org/anonscm/darcs/macaque/macaque"

LICENSE="LGPL-2.1-with-linking-exception"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-ml/pgocaml"
RDEPEND="${DEPEND}"

src_compile() {
	cd src
	emake -j1 || die
}

src_install() {
	cd src
	findlib_src_preinst
	emake DESTDIR="${OCAMLFIND_DESTDIR}" -j1 install || die
}
