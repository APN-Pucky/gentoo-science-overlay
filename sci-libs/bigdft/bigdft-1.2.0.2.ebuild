# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="3"

inherit eutils toolchain-funcs

DESCRIPTION="A DFT electronic structure code using a wavelet basis set"
HOMEPAGE="http://inac.cea.fr/L_Sim/BigDFT/"
SRC_URI="http://inac.cea.fr/L_Sim/BigDFT/${P}.tar.gz
		http://inac.cea.fr/L_Sim/BigDFT/${PN}-1.3.2.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda doc mpi test"

RDEPEND="virtual/blas
	virtual/lapack
	mpi? ( virtual/mpi )
	cuda? ( dev-util/nvidia-cuda-sdk )
	=sci-libs/libxc-1.0[fortran]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=sys-devel/autoconf-2.59
	doc? ( virtual/latex-base )"

src_prepare() {
	epatch ${FILESDIR}/${P}-0001.patch
	epatch ${FILESDIR}/${P}-0002.patch
	epatch ${FILESDIR}/${P}-0003.patch
	epatch ${FILESDIR}/${P}-0004.patch
	epatch ${FILESDIR}/${P}-testH.patch

	rm -r src/PSolver/ABINIT-common
	mv ../${PN}-1.3.2/src/PSolver/ABINIT-common src/PSolver/
	sed -i -e's%@LIBXC_INCLUDE@%-I/usr/lib/finclude%g' \
		src/PSolver/ABINIT-common/Makefile.*
	sed -i -e's%config\.inc%config.h%g' \
		src/PSolver/ABINIT-common/*.F90
}

src_configure() {
	if use mpi; then
		MY_FC="mpif90"
		MY_CC="mpicc"
	else
		MY_FC="${tc-getFC}"
		MY_CC="$(tc-getCC)"
	fi

	econf \
		$(use_enable mpi) \
		--enable-libpoissonsolver \
		--enable-libbigdft \
		--enable-binaries \
		--with-moduledir=/usr/$(get_libdir)/finclude \
		--with-ext-linalg="`pkg-config --libs-only-l lapack`" \
		--with-ext-linalg-path="`pkg-config --libs-only-L lapack`" \
		--with-xc-module-path="/usr/lib/finclude" \
		$(use_enable cuda cuda-gpu) \
		$(use_with cuda cuda-path /opt/cuda) \
		$(use_with cuda lib-cutils /opt/cuda/lib) \
		FCFLAGS="${FCFLAGS:- ${FFLAGS:- -O2}}" \
		FC="${MY_FC}" \
		CC="${MY_CC}" \
		LD="$(tc-getLD)" \
		|| die "configure failed"
}

src_compile() {
	emake -j1 HAVE_LIBXC=1 || die "make failed"
	if use doc; then
		emake HAVE_LIBXC=1 doc || die "make doc failed"
	fi
}

src_test() {
	if use test; then
		emake check
	fi
}

src_install() {
	emake HAVE_LIBXC=1 DESTDIR="${D}" install || die "install failed"
	dodoc README INSTALL COPYING ChangeLog AUTHORS NEWS || die "dodoc failed"
}

