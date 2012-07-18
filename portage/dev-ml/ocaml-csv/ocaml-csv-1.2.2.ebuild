# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit oasis

MY_P=csv-${PV}

DESCRIPTION="A pure OCaml library to read and write CSV files"
HOMEPAGE="https://forge.ocamlcore.org/projects/csv/"
SRC_URI="http://forge.ocamlcore.org/frs/download.php/613/${MY_P}.tar.gz"

LICENSE="LGPL-2.1-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}
