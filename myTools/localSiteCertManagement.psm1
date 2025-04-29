

# @TODO change to make-cert calls
# https://stackoverflow.com/questions/8169999/how-can-i-create-a-self-signed-certificate-for-localhost
# Also need to add cert in mmc.exe, and inetmgr.exe
function New-LocalCert {
    param (
        # e.g. "192.168.11.49:3001"
        [Parameter(Position = 0)]
        [string] $Address
    )

    New-SelfSignedCertificate -DnsName $Address -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(100)
  
}

function New-NucleusLocalCerts {
   param (
        # e.g. "192.168.11.49:3001"
        [Parameter(Position = 0)]
        [string] $IpAddress
    )

    New-LocalCert "$IpAddress:3001"
    New-LocalCert "$IpAddress:3004"
    New-LocalCert "$IpAddress:8080"
    New-LocalCert "$IpAddress:8082"
    New-LocalCert "$IpAddress:8083"





}