# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

EAPI="3"

inherit cmake-utils flag-o-matic toolchain-funcs

DESCRIPTION="A three-dimensional finite element mesh generator with built-in pre- and post-processing facilities."
HOMEPAGE="http://www.geuz.org/gmsh/"
SRC_URI="http://www.geuz.org/gmsh/src/${P}-source.tgz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="blas chaco cgns doc examples jpeg lua med metis mpi opencascade png taucs zlib X"

RDEPEND="X? ( x11-libs/fltk:1.1 )
		blas? ( virtual/blas virtual/lapack sci-libs/fftw:3.0 )
		cgns? ( sci-libs/cgnslib )
		jpeg? ( virtual/jpeg )
		lua? ( dev-lang/lua )
		med? ( >=sci-libs/med-2.3.4 )
		opencascade? ( sci-libs/opencascade )
		png? ( media-libs/libpng )
		zlib? ( sys-libs/zlib )
		mpi? ( virtual/mpi[cxx] )
		taucs? ( sci-libs/taucs )"

# taucs needs metis enabled.
# Wait for the REQUIRED_USE syntax in EAPI4.
# http://www.gentoo.org/proj/en/council/meeting-logs/20101130-summary.txt

DEPEND="${RDEPEND}
		dev-util/cmake
		doc? ( virtual/latex-base )"

S="${WORKDIR}/${P}-source"

pkg_setup() {
	ewarn "Put the F77 variable in env files to select your fortran compiler"
	ewarn "example for gfortran:"
	ewarn "echo \"F77=gfortran\" >> /etc/portage/env/sci-libs/gmsh"
}

src_configure() {
	use blas && mycmakeargs="${mycmakeargs}
						-DCMAKE_Fortran_COMPILER=$(tc-getF77)"

	mycmakeargs="${mycmakeargs} $(cmake-utils_use_enable blas BLAS_LAPACK)
								$(cmake-utils_use_enable cgns CGNS)
								$(cmake-utils_use_enable chaco CHACO)
								$(cmake-utils_use_enable X FLTK)
								$(cmake-utils_use_enable X FL_TREE)
								$(cmake-utils_use_enable X GRAPHICS)
								$(cmake-utils_use_enable med MED)
								$(cmake-utils_use_enable metis METIS)
								$(cmake-utils_use_enable taucs TAUCS)
								$(cmake-utils_use_enable opencascade OCC)"

	cmake-utils_src_configure ${mycmakeargs} \
		|| die "cmake configuration failed"
}

src_install() {
	cmake-utils_src_install

	cd "${WORKDIR}/${PF}"

	if use doc ; then
	    cd ${CMAKE_BUILD_DIR}
		emake pdf || die "failed to build documentation"
	    cd "${WORKDIR}/${PF}"
		dodoc doc/*.txt doc/texinfo/gmsh.pdf
	fi

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r demos tutorial || die "failed to install examples"
	fi
}
