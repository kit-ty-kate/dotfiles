# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit findlib eutils

DESCRIPTION="An Ocaml library to handle dates and time"
HOMEPAGE="https://forge.ocamlcore.org/projects/calendar/"
SRC_URI="http://forge.ocamlcore.org/frs/download.php/605/${P}.tgz"

LICENSE="LGPL-2.1-linking-exception"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc +ocamlopt"

DEPEND=">=dev-lang/ocaml-3.09.1[ocamlopt]"

RDEPEND="${DEPEND}"

src_compile() {
	emake
	use doc && emake doc
}

src_test() {
	emake tests
}

src_install() {
	findlib_src_install
	dodoc README CHANGES
	use doc && dohtml -r doc
}
