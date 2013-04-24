#!/bin/csh
# protect aginst grid setup using bash command in case the user
# redefines and alias for bash (yes, someone does it)
set bashalias = `alias bash`
unalias bash
source /afs/cern.ch/project/gd/LCG-share/3.1.25-0/etc/profile.d/grid_env.csh
alias bash $bashalias

# directory with CMS customizations
set CMS_UI_CUSTOM = /afs/cern.ch/cms/LCG/LCG-2/UI

# next line make this work on any machine with AFS outside CERN
setenv X509_CERT_DIR /afs/cern.ch/project/gd/LCG-share/certificates

# next line for BossLite/CRAB
setenv PYTHONPATH ${PYTHONPATH}:${GLITE_LOCATION}/lib

# now CMS custom configurations
#setenv PATH ${CMS_UI_CUSTOM}/bin:${PATH}
setenv GLITE_WMS_CLIENT_CONFIG ${CMS_UI_CUSTOM}/conf/glite_wms_CERN.conf
