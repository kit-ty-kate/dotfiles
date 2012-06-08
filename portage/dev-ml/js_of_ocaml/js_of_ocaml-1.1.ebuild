# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils findlib

DESCRIPTION="A compiler from OCaml bytecode to javascript"
HOMEPAGE="http://ocsigen.org/js_of_ocaml/"
SRC_URI="http://www.ocsigen.org/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

DEPEND="dev-lang/ocaml[ocamlopt]
>=dev-ml/lwt-2.3.0
=dev-ml/deriving-ocsigen-0.3b"
RDEPEND="${DEPEND}"

src_compile() {
	emake
	use doc && emake doc
}

src_install() {
	findlib_src_preinst
	emake BINDIR="${D}/usr/bin" install
	dodoc CHANGES README
	use doc && dohtml -r doc/api-html
}
