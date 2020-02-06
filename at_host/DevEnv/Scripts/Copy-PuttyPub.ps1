echo "#"
echo "# ======================================================================="
echo "# Copy-PuttyPub.ps1"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Convert and append ~\.certs\putty.pub to ~\DevEnv\@guest\.ssh\authorized_keys"
echo "#"

$PUB = Get-Content ~\.certs\putty.pub
$TXT = ""
foreach ($Line in $PUB) {
    if ($Line -match '^Comment:') {
	    $Comment = $Line.split('"')[1]
	}
	else {
        if ($Line -notmatch '^---') {
            $TXT = $TXT + $Line
	    }
	}
}
$TXT = "ssh-rsa " + $TXT + " " + $Comment
New-Item -Type File -Path ~\DevEnv\@guest\.ssh -Name authorized_keys -Force -Value $TXT
