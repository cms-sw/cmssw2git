#!/bin/sh

source /afs/cern.ch/project/gd/LCG-share/3.1.25-0/etc/profile.d/grid_env.sh

# directory with CMS customizations
CMS_UI_CUSTOM=/afs/cern.ch/cms/LCG/LCG-2/UI

# next line make this work on any machine with AFS outside CERN
export X509_CERT_DIR=/afs/cern.ch/project/gd/LCG-share/certificates

# next line for BossLite/CRAB
export PYTHONPATH=${PYTHONPATH}:${GLITE_LOCATION}/lib

# now CMS custom configurations
#export PATH=${CMS_UI_CUSTOM}/bin:${PATH}
export GLITE_WMS_CLIENT_CONFIG=${CMS_UI_CUSTOM}/conf/glite_wms_CERN.conf
