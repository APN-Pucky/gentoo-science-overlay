# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit autotools eutils prefix

DESCRIPTION="General-purpose software package for simulation virtually all kinds of solid-state NMR experiments"
HOMEPAGE="http://bionmr.chem.au.dk/bionmr/software/index.php"
SRC_URI="http://www.bionmr.chem.au.dk/download/${PN}/3.0/${PN}-source-${PV}.tgz"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux"
LICENSE="GPL-2"
IUSE="threads gtk tk"

RDEPEND="
	dev-libs/libf2c
	virtual/blas
	virtual/lapack
	gtk? ( x11-libs/gtk+:1 )
	tk? ( dev-lang/tk )"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/${PN}-source-${PV}

src_prepare() {
	edos2unix Makefile
	epatch "${FILESDIR}"/${PV}-gentoo.patch
	epatch "${FILESDIR}"/${PV}-type.patch
	eprefixify Makefile
#	eautoreconf
}

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS}" \
		|| die
}

#src_configure(){
# Broken
#		$(use_enable threads parallel) \
#	econf \
#		--disable-parallel \
#		$(use_enable tk tklib) \
#		$(use_enable gtk simplot)
#}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc vnmrtools/README.vnmrtools NEWS README TODO AUTHORS || die
}
