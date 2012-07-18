# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit findlib

DESCRIPTION="OCamlPAM - an OCaml library for PAM"
HOMEPAGE="http://sharvil.nanavati.net/projects/ocamlpam/"
SRC_URI="http://sharvil.nanavati.net/projects/${PN}/files/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+ocamlopt"

DEPEND="dev-lang/ocaml[ocamlopt?]
	sys-libs/pam"
RDEPEND="${DEPEND}"

src_compile() {
	emake META || die
	emake byte || die
	if use ocamlopt; then
		emake opt || die
	fi
}

src_install() {
	findlib_src_preinst
	emake DESTDIR="${OCAMLFIND_DESTDIR}" install || die
}
