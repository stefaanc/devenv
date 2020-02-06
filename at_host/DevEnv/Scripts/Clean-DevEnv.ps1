echo "#"
echo "# ======================================================================="
echo "# Clean-DevEnv.ps1
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# delete .kube"
echo "#"

del ~\.kube
echo ""

echo "#"
echo "# delete .helm"
echo "#"

del ~\.helm
echo ""

echo "#"
echo "# delete .certs"
echo "#"

mkdir ~\_tmp
cp ~\.certs\putty.* ~\_tmp
del ~\.certs\*
cp ~\_tmp\* ~\.certs
del ~\_tmp
echo ""

echo "#"
echo "# delete PuTTY log-files"
echo "#"

del ~\DevEnv\Scripts\PuTTY-log\*.*
echo ""

#echo "#"
#echo "# delete saved virtual hard disks"
#echo "#"
#
#del ~\DevEnv\"Virtual Machines"\"Virtual Hard Disks"\*.*
#echo ""