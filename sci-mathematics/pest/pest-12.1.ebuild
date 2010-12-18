# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit versionator toolchain-funcs

MY_P="${P/-/}"

DESCRIPTION="Model-independent Parameter ESTimation for model calibration and
predictive uncertainty analysis."
HOMEPAGE="http://www.pesthomepage.org"
SRC_URI="http://www.pesthomepage.org/getfiles.php?file=${MY_P}.tar.zip -> ${P}.tar.zip
	doc? ( http://www.pesthomepage.org/files/pestman.pdf
	       http://www.pesthomepage.org/files/addendum.pdf )"

# License is poorly specified on the SSPA web site.  It only says that
# Pest is freeware.
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
DEPEND="app-arch/unzip"
RDEPEND=""

MAKEOPTS="${MAKEOPTS} -j1"

# Need a Fortran 90 compiler.

S="${WORKDIR}/${PN}"

src_unpack() {
	mkdir "${S}" && cd "${S}"
	unpack "${P}.tar.zip"
	unpack ./"${MY_P}.tar"
}

src_prepare() {
	# I decided it was cleaner to make all edits with sed, rather than a patch.
	sed -i \
		-e "s;^F90=.*;F90=$(tc-getFC);" \
		-e "s;^LD=.*;LD=$(tc-getFC);" \
		 *.mak makefile
	sed -i \
		-e "s;^FFLAGS=.*;FFLAGS=${FFLAGS:--O2} -c;" \
		 *.mak
	sed -i \
		-e "s;^INSTALLDIR=.*;INSTALLDIR=${D}/usr/bin;" \
		-e 's;^install :;install :\n\tinstall -d $(INSTALLDIR);' \
		 makefile

	# These changes are just for 12.1 - should go away
	sed -i \
	    -e 's/\(.*jco2jco .*jco2jco.*\)/\1 openun.o/' \
	    -e 's/\(.*jcochek .*jcochek.o.*\)/\1 openun.o/' pestutl1.mak
	sed -i -e '/.*integer.*ies2ipar.*$/ d' cmaes_p.F sceua_p.F
}

src_compile() {
	emake cppp || die "cppp emake failed"
	for mfile in pest.mak ppest.mak pestutl1.mak pestutl2.mak pestutl3.mak pestutl4.mak pestutl5.mak pestutl6.mak sensan.mak mpest.mak
		do
			emake -f ${mfile} all || die "${mfile} emake failed"
			emake clean || die "emake clean failed"
		done
}

src_install() {
	emake install || die "emake install failed"

	if use doc ; then
		dodoc "${DISTDIR}"/pestman.pdf
		dodoc "${DISTDIR}"/addendum.pdf
	fi

}

src_test() {
	ebegin "Running d_test"
	make d_test || die "make d_test failed"
	eend $?
}
