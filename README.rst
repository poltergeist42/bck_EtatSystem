=====================================
Informations générales bck_EtatSystem
=====================================

:Auteur:            `Poltergeist42 <https://github.com/poltergeist42>`_
:Projet:             bck_EtatSystem
:dépôt GitHub:       https://github.com/poltergeist42/bck_EtatSystem.git
:documentation:      https://poltergeist42.github.io/bck_EtatSystem/
:Licence:            CC BY-NC-SA 4.0
:Liens:              https://creativecommons.org/licenses/by-nc-sa/4.0/

Descriptions
============

Ce projet est un projet PowerShell. L'objectif est de créer des sauvegardes de l'état
système au travers des cmdlets powershell de Windows Sever Backup

####

Téléchargement / Installation
=============================

Vous pouvez télécharger le projet entier directement depuis son `dépôt GitHub <https://github.com/poltergeist42/bck_EtatSystem>`_ .
ou récupérer juste le script depuis le dossier `_3_software du dépôt GitHub <https://github.com/poltergeist42/bck_EtatSystem/tree/master/_3_software>`_ .

Le script n'a pas besoin d'installation, il doit simplement être exécuté.

####
    
Utilisation
===========

    #. **Personnalisation**
    
        Se script doit être personnalisé. Pour faciliter cette personnalisation,
        l'ensemble des variables à modifier ont été placées au début du script sous
        l'entête "Configuration".
       
        **Détail des variables à personnaliser** :
                   
        :clientName:
            Permet de renseigner le nom du client. Ce nom est utilisé dans l'envoie de Mail

        :pathBckES:
            Permet de définir le disque ou le chemin réseau pour la sauvegarde
            de l'état système
            
            N.B : dans le cas d'une sauvegarde réseau, le chemin doit être indiqué sous
            la forme :
            
                * "\\servername\sharedFolder\"

        :verbose:
            Permet d'afficher dans la console, l'état de la sauvegarde
            
                * $TRUE    --> Affichage activé
                * $FALSE   --> Affichage désactivé

       :vCfgEncoding:
            Permet de définir l'encodage des fichiers et du mail. La valeur "Default",
            récupère l'encodage du système depuis lequel est exécuter ce script.
            Les valeurs acceptées sont :
            
                * "Unicode", "UTF7", "UTF8", "ASCII", "UTF32", "BigEndianUnicode",
                  "Default", "OEM"
    
        :vCfgSendMail:
            Permet d'activer ou de désactiver l'envoie automatique du fichier '.csv' par
            mail. Les valeurs acceptées sont :
            
                * $TRUE   --> Envoie de mail activé
                * $False  --> Envoie de mail désactivé
                
            **N.B** : Cette fonctionnalité est désactivé par défaut ($FALSE)
    
        :vCfgSendMailFrom:
            Adresse mail de l'expéditeur

            **Attention** : "user01@example.com" doit être remplacé par l'adresse de
            l'expéditeur dans la version en production de ce script.
    
        :vCfgSendMailTo:
            Adresse Mail du destinataire

            **Attention** : "user02@example.com" doit être remplacé par l'adresse
            du destinataire dans la version en production de ce script.
    
        :vCfgSendMailSmtp:
            Serveur SMTP à utiliser pour l'envoie de Mail.

            **Attention** : "smtp.serveur.com" doit être remplacé par votre serveur SMTP
            dans la version en production de ce script.
    
        :vCfgSendMailPort:
            Numéro de port utilisé par le serveur SMTP.
        
        :vCfgSendMailAuth:
            Permet d'activer ou de désactiver l'authentification sur le SMTP.
            Les valeurs acceptées sont :
            
                * $FALSE  --> Pas d'authentification
                * $TRUE   --> Authentification

            **N.B** : Si le serveur SMTP nécessite une authentification ($TRUE),
            les variables : 'vCfgSendMailUsr' et 'vCfgSendMailPwd'
            seront également à renseigner. Ce mode est activé par défaut en cas d'envoie
            automatique d'un mail depuis se script.
    
        :vCfgSendMailUsr:
            Login utilisé pour l'authentification du SMTP.

            **Attention** : "user@domain.dom" doit être remplacé par votre nom
            d'utilisateur dans la version en production de ce script.

        :vCfgSendMailPwd:
            Mot de passe utiliser avec le login du compte  d'authentification SMTP.

            **Attention** : "P@sSwOrd" doit être remplace par votre mot de passe
            dans la version en production de ce script.
    

    
    #. **Automatisation et planification**
    
        Si la tâche doit être effectuée régulièrement, il faut créer une tache planifié.
        On peut s'aider de la page ci-dessous pour exécuter un script PowerShell dans une
        tâche planifiée.
        
            * https://www.adminpasbete.fr/executer-script-powershell-via-tache-planifiee/
    
####

Restauration de l'état du système
==================================

    #. **Démarrer en mode restauration du service d'annuaire**
    
        * Au démarrage du serveur, Juste avant le lancement du système, enfoncez /relâchez
          la touche 'F8' jusqu'a l'apparition d'un menu en mode console.
          
        * Utilisez les flèches du clavier 'Haut' et 'Bas' pour se déplacer dans le menu.
          Sélectionnez l'item "mode de restauration du service d'annuaire" et appuyez sur
          'Entré' pour valider.
          
          **N.B** : Vous devrez renseigner le nom d'utilisateur et le mot de passe du
          compte que vous avez renseigné lors de la création de l'AD.
          
    #. **Identifier la version de l'état du système à restaurer**
    
        * Ouvrez une console PowerShell et saisir la commande : ::
        
            Get-WBBackupSet
            
        * Vous devriez obtenir une liste de plusieurs tableau présentés sous cette forme : ::
          
            VersionId        : 10/25/2017-20:00
            BackupTime       : 25/10/2017 22:00:27
            BackupTarget     : D:
            RecoverableItems : Volumes, SystemState, Applications, Files, BareMetalRecovery
            Volume           : {Réservé au système, Disque local (C:)}
            Application      : {FRS, AD, Registry}
            VssBackupOption  : VssFullBackup
            SnapshotId       : d6655a57-0676-4a29-a9ae-05ba848f7c43
            BackupSetId      : d012671d-445b-4b64-8c67-be861c7ef5b9
        
        * A l'aide de la propriété **'BackupTime'**, repérez la date de la sauvegarde qui
          vous intéresse.
          
        * Vérifiez dans la propriété **'RecoverableItems'** que l'item **'SystemState'**
          est bien présent.
          
    #. **Restaurer l'état du système depuis une sauvegarde**
        
        * Récupérez, dans une variable, la sauvegarde qui vous intéresse : ::
          
            $varBck = Get-WBBackupSet | where { $_.VersionId  -like "10/25/2017-20:00" }
              # N.B : Pensez à remplacer la valeur entre guillemet par la valeur
              # 'VersionId' de votre sauvegarde
              
        * Lancez la restauration : ::
        
            Start-WBSystemStateRecovery -BackupSet $varBck -AuthoritativeSysvolRecovery -RestartComputer
                # N.B : Si vous ajoutez le paramètre '-Force' à la fin de cette commande,
                # Le serveur lancera la restauration sans vous demander confirmation

####
    
Arborescence du projet
======================

Pour aider à la compréhension de mon organisation, voici un bref descriptif de
L'arborescence de ce projet. Cette arborescence est à reproduire si vous récupérez ce dépôt
depuis GitHub. ::

	openFile               # Dossier racine du projet (non versionner)
	|
	+--project             # (branch master) contient l'ensemble du projet en lui même
	|  |
	|  +--_1_userDoc       # Contiens toute la documentation relative au projet
	|  |   |
	|  |   \--source       # Dossier réunissant les sources utilisées par Sphinx
	|  |
	|  +--_2_modelisation  # Contiens tous les plans et toutes les modélisations du projet
	|  |
	|  +--_3_software      # Contiens toute la partie programmation du projet
	|  |
	|  \--_4_PCB           # Contient toutes les parties des circuits imprimés (routage,
	|                      # Implantation, typon, fichier de perçage, etc.
	|
	\--webDoc              # Dossier racine de la documentation qui doit être publiée
	   |
	   \--html             # (branch gh-pages) C'est dans ce dossier que Sphinx vat
	                       # générer la documentation à publier sur internet

