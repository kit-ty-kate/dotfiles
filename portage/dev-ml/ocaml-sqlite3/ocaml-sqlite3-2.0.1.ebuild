# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit oasis

MY_PN="sqlite3-ocaml"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A package for ocaml that provides access to SQLite databases."
HOMEPAGE="https://bitbucket.org/mmottl/sqlite3-ocaml"
SRC_URI="https://bitbucket.org/mmottl/${MY_PN}/downloads/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-db/sqlite-3.3.3
	>=dev-ml/findlib-1.3.2"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}
