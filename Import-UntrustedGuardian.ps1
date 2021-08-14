$ComputerName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
$GuardianName = "UntrustedGuardian"
$CertificatePassword = ConvertTo-SecureString "1qaz@WSX" -AsPlainText -Force
$NodeCount = (Get-ClusterNode | Measure-Object).Count
$FileLocationPath = "$env:HOMEDRIVE\ClusterStorage\Volume01\Certificate"

#This is for confirm that do not import the same certificate on the same node
$j = 0
for ($i = 1; $i -le $NodeCount; $i++) {
    $Node = (Get-ClusterNode | Select-Object -ExpandProperty Name)[$j]
    $SigningFileName = "$FileLocationPath\Shielded VM Signing Certificate (UntrustedGuardian) ($Node).pfx"
    $EncryptionFileName = "$FileLocationPath\Shielded VM Encryption Certificate (UntrustedGuardian) ($Node).pfx"
    if ($Node -eq $ComputerName) {
        $j = $j + 1
    }
    elseif ($Node -ne $ComputerName) {
        Import-PfxCertificate -FilePath $SigningFileName -CertStoreLocation "Cert:\LocalMachine\Shielded VM Local Certificates" -Password $CertificatePassword
        Import-PfxCertificate -FilePath $EncryptionFileName -CertStoreLocation "Cert:\LocalMachine\Shielded VM Local Certificates" -Password $CertificatePassword
        $j = $j + 1
    }
}