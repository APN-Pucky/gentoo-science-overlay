# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

if [[ ${PV} = 9999* ]]; then
	EBZR_REPO_URI="http://oregonstate.edu/~benisong/software/projects/starparse/releases/1.0"
	EBZR_BOOTSTRAP="eautoreconf"
	BZR="bzr"
else
	SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
fi

inherit autotools ${BZR}

DESCRIPTION="Library for parsing NMR star files (peak-list format) and CIF files"
HOMEPAGE="http://burrow-owl.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="guile"

RDEPEND="guile? ( dev-scheme/guile )"
DEPEND="${RDEPEND}"

src_compile() {
	econf $(use_enable guile) || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
