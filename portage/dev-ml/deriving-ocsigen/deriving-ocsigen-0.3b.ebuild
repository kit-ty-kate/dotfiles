# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils findlib

DESCRIPTION="A deriving library for Ocsigen"
HOMEPAGE="http://ocsigen.org"
SRC_URI="http://www.ocsigen.org/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc +ocamlopt"

DEPEND="dev-lang/ocaml[ocamlopt?]"
RDEPEND="${DEPEND}"

src_compile() {
	if use ocamlopt; then
		emake
	else
		emake byte
	fi
}

src_install() {
	findlib_src_preinst
	if use ocamlopt; then
		emake DESTIR="${D}" install
	else
		emake DESTIR="${D}" install-byte
	fi
	dodoc CHANGES README
}
