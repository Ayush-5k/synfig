#!/bin/sh

set -e

AUTORECONF=`command -v autoreconf || true` #if don't set true, script fails with no messages
if [ -z $AUTORECONF ]; then
        echo "*** No autoreconf found, please install it ***"
        exit 1
fi

INTLTOOLIZE=`command -v intltoolize || true`
if [ -z $INTLTOOLIZE ]; then
        echo "*** No intltoolize found, please install the intltool package ***"
        exit 1
fi

echo "running autopoint..."
autopoint --force

echo "running autoreconf..."
AUTOPOINT='intltoolize --automake --copy' autoreconf --force --install --verbose

# WORKAROUND 2013-08-15:
# Patch the generated po/Makefile.in.in file so that locale files are installed
# in the correct location on OS X and Free-BSD systems.  This is a workaround
# for a bug in intltool.  
# See https://launchpad.net/bugs/398571 and https://bugs.launchpad.net/bugs/992047
#
# TODO: Drop this hack, and bump our intltool version requirement once the issue
#       is fixed in intltool

echo "patching po/Makefile.in.in..."
sed 's/itlocaledir = $(prefix)\/$(DATADIRNAME)\/locale/itlocaledir = $(datarootdir)\/locale/;s/rm -f .intltool-merge-cache/rm -f .intltool-merge-cache .intltool-merge-cache.lock/' < po/Makefile.in.in > po/Makefile.in.in.tmp
# -- force didn't work under MacOS
mv -f po/Makefile.in.in.tmp po/Makefile.in.in

# Fix https://github.com/synfig/synfig/issues/3398
# For compatibility with MacOS we have to make sure "sh" binary 
# is found in "/bin/sh", not "/usr/bin/sh"
sed "s|#!/usr/bin/sh|#!/bin/sh|" < config/install-sh > config/install-sh.tmp
mv -f config/install-sh.tmp config/install-sh
chmod +x config/install-sh

echo "Done! Please run ./configure now."
