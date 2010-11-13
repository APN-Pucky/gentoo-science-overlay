# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils fortran mpi

MY_PV=${PV/_/}
DESCRIPTION="MPICH2 - A portable MPI implementation"
HOMEPAGE="http://www.mcs.anl.gov/research/projects/mpich2/index.php"
SRC_URI="http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/${MY_PV}/${PN}-${MY_PV}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+cxx debug doc fortran threads romio mpi-threads"

COMMON_DEPEND="dev-libs/libaio
	sys-apps/hwloc
	romio? ( net-fs/nfs-utils )
	$(mpi_imp_deplist)"

DEPEND="${COMMON_DEPEND}
	dev-lang/perl
	sys-devel/libtool"

RDEPEND="${COMMON_DEPEND}"

S="${WORKDIR}"/${PN}-${MY_PV}

pkg_setup() {
	MPI_ESELECT_FILE="eselect.mpi.mpich2"

	if use fortran ; then
		FORTRAN="g77 gfortran ifort ifc"
		fortran_pkg_setup
	fi

	if use mpi-threads && ! use threads; then
		ewarn "mpi-threads requires threads, assuming that's what you want"
	fi

	if mpi_classed; then
		MPD_CONF_FILE_DIR=/etc/$(mpi_class)
	else
		MPD_CONF_FILE_DIR=/etc/${PN}
	fi

}

src_prepare() {
	# We need f90 to include the directory with mods, and to
	# fix hardcoded paths for src_test()
	# Submitted upstream.
	sed -i \
		-e "s,FCFLAGS\( *\)=,FCFLAGS\1?=," \
		-e "s,\$(bindir)/,${S}/bin/,g" \
		-e "s,@MPIEXEC@,${S}/bin/mpiexec,g" \
		$(find ./test/ -name 'Makefile.in') || die

	if ! use romio; then
		# These tests in errhan/ rely on MPI::File ...which is in romio
		echo "" > test/mpi/errors/cxx/errhan/testlist
	fi

	# 293665:  Should check in on MPICH2_MPIX_FLAGS in later releases
	# (>1.3) as this is seeing some development in trunk as of r6350.
	sed -i \
		-e 's|\(WRAPPER_[A-Z90]*FLAGS\)="@.*@"|\1=""|' \
		src/env/mpi*.in || die
}

src_configure() {
	local c="--enable-shared --enable-sharedlibs=gcc"
	local romio_conf

	# The configure statements can be somewhat confusing, as they
	# don't all show up in the top level configure, however, they
	# are picked up in the children directories.

	use debug && c="${c} --enable-g=all --enable-debuginfo"

	if use mpi-threads; then
		# MPI-THREAD requries threading.
		c="${c} --with-thread-package=pthreads"
		c="${c} --enable-threads=default"
	else
		if use threads ; then
			c="${c} --with-thread-package=pthreads"
		else
			c="${c} --with-thread-package=none"
		fi
		c="${c} --enable-threads=single"
	fi

	# enable f90 support for appropriate compilers
	case "${FORTRANC}" in
	    gfortran|if*)
			c="${c} --enable-f77 --enable-fc";;
	    g77)
			c="${c} --enable-f77 --disable-fc";;
	esac

	! mpi_classed && c="${c} --sysconfdir=/etc/${PN}"
	econf $(mpi_econf_args) ${c} ${romio_conf} \
		--docdir=$(mpi_root)/usr/share/doc/${PF} \
		--with-pm=hydra \
		--disable-mpe \
		--with-hwloc-prefix=/usr \
		$(use_enable romio) \
		$(use_enable cxx) \
		|| die
}

src_compile() {
	# Oh, the irony.
	# http://wiki.mcs.anl.gov/mpich2/index.php/Frequently_Asked_Questions#Q:_The_build_fails_when_I_use_parallel_make.
	# https://trac.mcs.anl.gov/projects/mpich2/ticket/297
	emake -j1 || die
}

src_test() {
	local rc

	make \
		CC="${S}"/bin/mpicc \
		CXX="${S}"/bin/mpicxx \
		F77="${S}"/bin/mpif77 \
		FC="${S}"/bin/mpif90 \
		FCFLAGS="${FCFLAGS} -I${S}/src/binding/f90/" \
		testing
	rc=$?

	return ${rc}
}

src_install() {
	local d=$(echo ${D}/$(mpi_root)/ | sed 's,///*,/,g')
	local f

	emake DESTDIR="${D}" install || die

	mpi_dodir /usr/share/doc/${PF}
	mpi_dodoc COPYRIGHT README CHANGES RELEASE_NOTES || die
	mpi_newdoc src/pm/hydra/README README.hydra || die
	if use romio; then
		mpi_newdoc src/mpi/romio/README README.romio || die
	fi

	if ! use doc; then
		rm -rf "${d}"usr/share/doc/${PF}/www*
	fi

	mpi_imp_add_eselect
}
