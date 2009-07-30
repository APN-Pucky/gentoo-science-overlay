# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

OFED_VER="1.4"
OFED_SUFFIX="1.ofed1.4"

inherit openib

DESCRIPTION="OpenIB uverbs micro-benchmarks"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=sys-infiniband/libibverbs-1.1.2
		>=sys-infiniband/librdmacm-1.0.8"

src_compile() {
	emake || die "emake failed"
}

src_install() {
	dodoc README Copying runme
	dobin ib_*
}

