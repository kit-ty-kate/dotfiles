# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit findlib

MY_P=vincenthz-${PN}-be2b8c1

DESCRIPTION="a binding for SHA interface code in OCaml"
HOMEPAGE="https://github.com/vincenthz/ocaml-sha"
SRC_URI="https://nodeload.github.com/vincenthz/${PN}/tarball/v${PV} -> ${P}.tar.gz"

LICENSE="LGPL-2.1-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

src_compile() {
	emake -j1 || die
}

src_install() {
	findlib_src_preinst
	emake DESTDIR="${D}" -j1 install || die
}
