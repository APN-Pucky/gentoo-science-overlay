# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils flag-o-matic base

DESCRIPTION="DNA sequence assembly (gap4, gap5), editing and analysis tools (Spin)."
HOMEPAGE="http://sourceforge.net/projects/staden"
SRC_URI="http://downloads.sourceforge.net/staden/staden-2.0.0b8.tar.gz
		http://sourceforge.net/projects/staden/files/staden/2.0.0b8/staden_doc-2.0.0b8-src.tar.gz"

LICENSE="staden"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug fortran X png curl tcl tk zlib"

# either g77 or gfortran must be available
# edit src/mk/linux.mk accordingly

#
# this is a glibc-2.9 issue, see https://sourceforge.net/tracker/index.php?func=detail&aid=2629155&group_id=100316&atid=627058
#
# 
#
DEPEND=">=dev-lang/tk-8.4
		>=dev-lang/tcl-8.4
		dev-tcltk/tklib
		>=sci-libs/io_lib-1.12.2
		>=sys-libs/zlib-1.2
		>=media-libs/libpng-1.2
		sci-biology/samtools
		>=app-arch/xz-utils-4.999"

# maybe we should depend on app-arch/lzma or app-arch/xz-utils?

RDEPEND="tcl? ( >=dev-tcltk/itcl-3.2 )
		tk? ( >=dev-tcltk/itk-3.2 )
		>=dev-tcltk/iwidgets-4.0"

S="${WORKDIR}"/staden-2.0.0b8-src

src_prepare() {
	unpack ${A} || die
	cd "${S}" || die "Cannot cd ${WORKDIR}/staden-2.0.0b8-src"
	epatch "${FILESDIR}"/rpath.patch || die "failed to apply -rpath=/usr/lib/staden patch"
	./bootstrap || die "bootstrap failed"
}

src_configure(){
	local myconf
	use X && myconf=" --with-x"
	myconf=" --with-tklib=/usr/lib/tklib0.5" # HACK
	use amd64 && myconf="${myconf} --enable-64bit"
	use debug && append-cflags "-DCACHE_REF_DEBUG"
	econf ${myconf} || die "configure failed"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "make install failed"
	#cd "${WORKDIR}"/staden_doc-2.0.0b8-src || die "failed to cd "${WORKDIR}"/staden_doc-2.0.0b8-src"
	#make install prefix="${D}"/usr || die "failed to install pre-created docs from upstream"

	# install the LDPATH so that it appears in /etc/ld.so.conf after env-update
	# subsequently, apps linked against /usr/lib/staden can be run because
	# loader can find the library (I failed to use '-Wl,-rpath,/usr/lib/staden'
	# somehow for gap2caf, for example
	echo 'LDPATH=/usr/lib/staden' > 99staden || die
	doenvd 99staden
}
