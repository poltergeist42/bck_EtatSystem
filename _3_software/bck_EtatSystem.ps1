<#
Infos
=====

    :Projet:             bck_EtatSystem
    :Nom du fichier:     bck_EtatSystem.ps1
    :dépôt GitHub:       https://github.com/poltergeist42/bck_EtatSystem.git
    :documentation:      https://poltergeist42.github.io/bck_EtatSystem/
    :Auteur:            `Poltergeist42 <https://github.com/poltergeist42>`_
    :Version:            20171103

####

    :Licence:            CC-BY-NC-SA
    :Liens:              https://creativecommons.org/licenses/by-nc-sa/4.0/

####

    :dev language:      Powershell
    :framework:         
    
####

Descriptif
==========

    :Projet:            Ce projet est un projet PowerShell. L'objectif est de créer des sauvegardes de l'état système au travers 
                        des cmdlets powershell de Windows Sever Backup
####

Reference Web
=============

    * https://technet.microsoft.com/fr-fr/library/jj902428(v=wps.630).aspx
        # Windows Server Backup Cmdlets in Windows PowerShell
        #
        # N.B : ces cmdlets remplacent la commandes DOS 'WBAdmin'

    * https://technet.microsoft.com/fr-fr/library/cc754015(v=ws.10).aspx
        # Doc microsoft WBAdmin

    * https://www.pluralsight.com/blog/tutorials/backup-and-restore-active-directory-on-windows-server-2008
        # Tutorial expliquant comment sauvegarde et restaurer l'état Système (avec WBadmin)
    
####

Liste des modules externes
==========================

    * 

####

#>

cls
Write-Host "`t## Début du script : bck_EtatSystem ##"

#########################
#                       #
#     Configuration     #
#                       #
#########################

$clientName = "Mon super client"
    # Permet de renseigner le nom du client. Ce nom est utilisé dans l'envoie de Mail

$pathBckES = "d:"
    # Permet de définir le disque ou le chemin réseau pour la sauvegarde de l'état système
    # N.B : dans le cas d'une sauvegarde réseau, le chemin doit être indiqué sous la forme :
    # "\\servername\sharedFolder\"

$verbose = $FALSE
    # Permet d'afficher dans la console, l'état de la sauvegarde
    # * $TRUE    --> Affichage activé
    # * $FALSE   --> Affichage désactivé

$vCfgEncoding = "Default"
    # Permet de définir l'encodage des fichiers et du mail. La valeur "Default",
    # récupère l'encodage du système depuis lequel est exécuter ce script.
    # Les valeurs acceptées sont :
    # "Unicode", "UTF7", "UTF8", "ASCII", "UTF32",
    # "BigEndianUnicode", "Default", "OEM"

    
## Paramètre de configuration de l'envoie de Mail
$vCfgSendMail = $False
    # Permet d'activer ou de désactiver l'envoie automatique du fichier '.csv' par mail.
    # Les valeurs acceptées sont :
    # * $TRUE   --> Envoie de mail activé
    # * $FALSE  --> Envoie de mail désactivé
    
$vCfgSendMailFrom = "user01@example.com"
    # Adresse mail de l'expéditeur
    #
    # Attention : "user01@example.com" doit être remplacé par l'adresse de l'expéditeur
    # dans la version en production de ce script
    
$vCfgSendMailTo = "user02@example.com"
    # Adresse Mail du destinataire
    #
    # Attention : "user02@example.com" doit être remplacé par l'adresse du destinataire
    # dans la version en production de ce script
    
$vCfgSendMailSmtp = "smtp.serveur.com"
    # Serveur SMTP à utiliser pour l'envoie de Mail
    #
    # Attention : "smtp.serveur.com" doit être remplacé par votre serveur SMTP
    # dans la version en production de ce script
    
$vCfgSendMailPort = 25
    # Numéro de port utilisé par le serveur SMTP
    
$vCfgSendMailAuth = $TRUE
    # Permet d'activer ou de désactiver l'authentification sur le SMTP.
    # Les valeurs acceptées sont :
    # * $FALSE  --> Pas d'authentification
    # * $TRUE   --> Authentification
    #
    # N.B : Si le serveur SMTP nécessite une authentification ($TRUE), les variables :
    # 'vCfgSendMailUsr' et 'vCfgSendMailPwd' seront également à renseigner
    
$vCfgSendMailUsr = "user@domain.dom"
    # Login utilisé pour l'authentification du SMTP
    #
    # Attention : "user@domain.dom" doit être remplacé par votre nom d'utilisateur
    # dans la version en production de ce script
    

$vCfgSendMailPwd = "P@sSwOrd"
    # Mot de passe utiliser avec le login du compte  d'authentification SMTP
    #
    # Attention : "P@sSwOrd" doit être remplace par votre mot de passe
    # dans la version en production de ce script
    


# N.B :Le chemin des journaux pour WindowsBackup se trouve :
# C:\Windows\Logs\WindowsServerBackup\

##########################
#                        #
#  Variables de requête  #
#                        #
##########################

$Policy = New-WBPolicy
    # Création d'un nouveau container 'Policy'
    
$BackupLocation  = New-WBBackupTarget -VolumePath $pathBckES

if ($vCfgSendMailAuth) {
    $vMailPwd = ConvertTo-SecureString -String $vCfgSendMailPwd -AsPlainText -Force
    $CredentialMail = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $vCfgSendMailUsr, $vMailPwd
}

$vAddDay = -0.5
$dte = (get-date).AddDays($vAddDay)
$dteShotStr = ((get-date).adddays($vAddDay)).ToShortDateString()
    
$computerName = (Get-WmiObject win32_operatingSystem).csname

## identification du type de commande disponibles
$chkCmdletWB = get-module -ListAvailable | where {($_.ModuleType -like "Manifest") -and ($_.Name -like "WindowsServerBackup")}

$Error.Clear()
$chkAppWB = get-command "wbadmin" -ErrorAction "silentlycontinue"
if($Error.Count -ne 0) { #Si on a une erreur
    $chkAppWB = $FALSE
}

$setCopy = $False
$bodyData = ""


#########################
#                       #
#         Main          #
#                       #
#########################


if ($chkCmdletWB) {
    Add-WBBackupTarget -Policy $Policy -Target $BackupLocation
        # Ajout du chemin de destination au container 'Policy'
    
    Add-WBSystemState $Policy
        # Ajout, dans le container 'Policy', de l'état du système à la liste des objet à sauvegarder.

    if ($verbose -eq $FALSE) {
        Start-WBBackup -Policy $Policy -AllowDeleteOldBackups -Force | Out-Null
    }
    else {
        Start-WBBackup -Policy $Policy -AllowDeleteOldBackups -Force
    }

    $statusBrut = Get-WBBackupSet

    foreach ($i in $statusBrut) {
        $iBckShort = $i.BackupTime
        if ($iBckShort -ge $dte) {
            foreach ($itm in $i){
                $VersionID = $itm.VersionID
                $BackupTime = $itm.BackupTime
                $BackupTarget = $itm.BackupTarget
                $RecoverableItems = $itm.RecoverableItems
                $Volume = $itm.Volume
                $Application = $itm.Application
                $SnapshotId = $itm.SnapshotId
                $BackupSetId = $itm.BackupSetId
            }
        }
    }
}
elseif ($chkAppWB) {
    wbadmin start systemstatebackup -backupTarget: $pathBckES -quiet
    $wGv = wbadmin get versions
    
    foreach ($i in $wGv) {
        if ($i -like "*$dteShotStr*") { 
            $setCopy = $True
        }
        if ($setCopy) {
            if (-not $i) {
                $setCopy = $False
                break
            }
            $bodyData += "`t`t$i`n"
        }
    }
}
else {
    write-host "Votre système ne contien pas les éléments nécéssaires"
}
    

##########################
#                        #
#     Envoie de Mail     #
#                        #
##########################

if ($chkCmdletWB) {
$vBody = @"
Bonjour.

Voici le résumé de la dernière sauvegarde de l'état du système du serveur : $computerName du client : $clientName

    VersionID`t`t`t: $VersionID
    BackupTime`t`t`t: $BackupTime
    BackupTarget`t`t: $BackupTarget
    RecoverableItems`t`t: $RecoverableItems
    Volume`t`t`t: $Volume
    Application`t`t`t: $Application
    SnapshotId`t`t`t: $SnapshotId
    BackupSetId`t`t`t: $BackupSetId


N.B : Le chemin des journaux pour WindowsBackup se trouve :
    * C:\Windows\Logs\WindowsServerBackup\

Cordialement, l'équipe ICS
"@
        
}

if ($chkAppWB) {
$vBody = @"
Bonjour.

Voici le résumé de la dernière sauvegarde de l'état du système du serveur : $computerName du client : $clientName

$bodyData

N.B : Le chemin des journaux pour WindowsBackup se trouve :
    * C:\Windows\Logs\WindowsServerBackup\

Cordialement, l'équipe ICS
"@
}

if ($vCfgSendMail) {
    if ($vCfgSendMailAuth) {
        Send-MailMessage -From $vCfgSendMailFrom `
        -Encoding $vCfgEncoding `
        -To $vCfgSendMailTo `
        -Subject "Rapport de sauvegarde de l'état du system du serveur : $computerName" `
        -Body $vBody `
        -Credential $CredentialMail `
        -SmtpServer $vCfgSendMailSmtp `
        -Port $vCfgSendMailPort `
        -UseSsl
    }
    else {
        Send-MailMessage -From $vCfgSendMailFrom `
        -Encoding $vCfgEncoding `
        -To $vCfgSendMailTo `
        -Subject "Rapport de sauvegarde de l'état du system du serveur : $computerName" `
        -Body $vBody `
        -SmtpServer $vCfgSendMailSmtp `
        -Port $vCfgSendMailPort
    }}


##########################
#                        #
#     Fin de tache       #
#                        #
##########################

Write-Host "`r`t## Fin du script : bck_EtatSystem ##"
