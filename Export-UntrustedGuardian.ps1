$GuardianName = "UntrustedGuardian"
$CertificatePassword = ConvertTo-SecureString "1qaz@WSX" -AsPlainText -Force
$ComputerName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
$FileLocationPath = "$env:HOMEDRIVE\ClusterStorage\Volume01\Certificate"

#To create Shielded VM Local Certificates if Guradian service is not exist
if ($null -eq (Get-HgsGuardian)) {
    Write-Output "Guardian '$GuardianName' could not be found on this local system. Create a new one"
    New-HgsGuardian -Name $GuardianName -GenerateCertificates
}

#Get the Certificate Thumbprint
$encryptionCertificate = Get-Item -Path "Cert:\LocalMachine\Shielded VM Local Certificates\$((Get-HgsGuardian).EncryptionCertificate.Thumbprint)"
$signingCertificate = Get-Item -Path "Cert:\LocalMachine\Shielded VM Local Certificates\$((Get-HgsGuardian).SigningCertificate.Thumbprint)"

#Confirm if the Certificate have private keys
if (-not ($encryptionCertificate.HasPrivateKey -and $signingCertificate.HasPrivateKey)) {
    throw 'One or both of the certificates in the guardian do not have private keys. ' + `
        'Please ensure the private keys are available on the local system for this guardian.'
}

#Check Certificare folder is exist in the C:\ClusterStorage\Volume01\, if not then will create a folder named` Certificate
if (!(Test-Path -Path $FileLocationPath)) {
    New-Item -ItemType Directory -Path $FileLocationPath
}
#Export Certificate to PFX with Private password
Export-PfxCertificate -Cert $encryptionCertificate -FilePath "$FileLocationPath\Shielded VM Encryption Certificate (UntrustedGuardian) ($ComputerName).pfx" -Password $CertificatePassword
Export-PfxCertificate -Cert $signingCertificate -FilePath "$FileLocationPath\Shielded VM Signing Certificate (UntrustedGuardian) ($ComputerName).pfx" -Password $CertificatePassword