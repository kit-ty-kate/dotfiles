# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="PG'OCaml is a set of OCaml bindings for the PostgreSQL database"
HOMEPAGE="http://pgocaml.forge.ocamlcore.org/"
SRC_URI="http://forge.ocamlcore.org/frs/download.php/922/${P}.tgz"

LICENSE="LGPL-2.1-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64"
IUSE="batteries"

DEPEND="dev-ml/calendar
	!batteries? ( dev-ml/extlib )
	batteries? ( dev-ml/batteries )
	dev-ml/ocaml-csv
	dev-ml/pcre-ocaml
	>=dev-lang/ocaml-3.10[ocamlopt]"
RDEPEND="${DEPEND}"

src_prepare() {
	echo "DESTDIR := \"${D}/\"" >> Makefile.config
}

src_configure() {
	emake depend || die
	emake || die
}

src_install() {
	emake install || die
}
