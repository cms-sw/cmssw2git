#!/usr/bin/env python
from ws_sso_content_reader import getContent
from commands import getstatusoutput
from sys import exit
from simplejson import loads

def die(s):
  print s
  exit(1)

def format(s, **kwds):
  return s % kwds

if __name__ == "__main__":
  result = getContent("https://eulisse.web.cern.ch/eulisse/cgi-bin/git-collector/cvs-queue/CMSSW_6_2_X", "~/.globus/usercert.pem", "~/.globus/userkey.pem")
  print result
  tagsets = loads(result)
  updateCmd = ""
  for tagset in tagsets:
    exportCommands = ""
    for package, newTag, oldTag in tagsets[tagset]:
      exportCommands += format("rm -rf %(package)s ; cvs export -r %(newTag)s %(package)s ; \n",
                               package=package,
                               newTag=newTag)
      
    updateCmd += format("set -ex;\n"
                        "pushd tagsets/cmssw-ib ;\n"
                        "git checkout CMSSW_6_2_X; git clean -fdx; \n"
                        "git checkout -b tagset-%(tagset)s ;\n"
                        "git merge -s ours CMSSW_6_2_X;\n"
                        "if [ \"X`git branch -r | grep tagset-%(tagset)s | sed -e's/[\\t ]*//'`\" = Xorigin/tagset-%(tagset)s ]; then\n"
                        "  git rebase origin/tagset-%(tagset)s;\n"
                        "fi ;\n" +
                        exportCommands +
                        "git add -A . ;\n"
                        "git commit -m'Updated for tagset %(tagset)s' || true;\n"
                        "git push origin tagset-%(tagset)s:tagset-%(tagset)s;\n"
                        "popd; \n"
                        ,
                        tagset=tagset)
    
  err, out = getstatusoutput("rm -rf tagsets/cmssw-ib ; git clone -b CMSSW_6_2_X git@github.com:cms-sw/cmssw-ib.git tagsets/cmssw-ib")
  if err:
    die("Cannot clone:\n" + out)
  print updateCmd
  err, out = getstatusoutput(updateCmd + "echo DONE")
  if err:
    print out
