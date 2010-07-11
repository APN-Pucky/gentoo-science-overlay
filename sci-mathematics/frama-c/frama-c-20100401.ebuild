# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils

DESCRIPTION="Frama-C is a suite of tools dedicated to the analysis of the source code of software written in C."
HOMEPAGE="http://www.frama-c.cea.fr/"
NAME="Boron"
SRC_URI="http://www.frama-c.com/download/${PN/-c/-c-$NAME}-${PV/_/-}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="apron doc gtk +why"
RESTRICT="strip"

DEPEND=">=dev-lang/ocaml-3.10.2
		>=dev-ml/ocamlgraph-1.4
		gtk? ( >=x11-libs/gtksourceview-2.8
			>=gnome-base/libgnomecanvas-2.26
			>=dev-ml/lablgtk-2.14 )
		sci-mathematics/ltl2ba
		apron? ( sci-mathematics/apron )"
RDEPEND="${DEPEND}"
PDEPEND="why? ( >=sci-mathematics/why-2.26 )"

S="${WORKDIR}/${PN/-c/-c-$NAME}-${PV/_/-}"

src_prepare(){
	epatch "${FILESDIR}/${P}-plugin_install.patch"
	epatch "${FILESDIR}/${P}-always_init.patch"

	touch config_file
	sed -i configure.in \
		-e "s:1.4):1.5):g"
	eautoreconf
}

src_configure() {
	if use gtk; then
		myconf="--enable-gui"
	else
		myconf="--disable-gui"
	fi

	econf ${myconf} || die "econf failed"
}

src_compile() {
	# dependencies can not be processed in parallel,
	# this is the intended behavior.
	emake -j1 depend || die "emake depend failed"
	emake all top DESTDIR="/" || die "emake failed"
}

src_install(){
	emake install DESTDIR="${D}" || die "emake install failed"
	dodoc Changelog doc/README

	if use doc; then
		dodoc doc/manuals/*
	fi
}
