#!/bin/bash

#
# Dormance
#
# Un script qui met un site Web sous Apache en maintenance en un clin d'œil
# Tela Botanica - 2015-03 - Licence CeCILL v2 + GPL v3
#
# Nécessite mod_rewrite
#

# notice d'utilisation
function notice {
	echo "Utilisation: $0 [-c fichierconfig.sh] off|on [date1] [date2]"
	echo "   off: passe le site en maintenance"
	echo "   on: sort le site de la maintenance"
	echo "   -c fichierconfig.sh: charge la configuration depuis fichierconfig.sh plutôt que config.sh (défaut)"
	echo "   date1: date et heure de début de maintenance, au format '2015-03-04_09:15' (! lire NOTE)"
	echo "   date2: date et heure de fin de maintenance, au format '2015-03-04_09:15'"
	echo "NOTE: si seule date1 est fournie, elle sera considérée comme date de fin"
}

# fichier de configuration par défaut
fichier_config="config.sh"

# recherche un 2e et un 3e arguments facultatifs pour transmettre comme
# dates de début et de fin à la page de maintenance (nécessite une page compatible)
# - si seul le 2e argument est fourni, on considère que c'est une date de fin
function lire_parametres_dates {
	arguments=""
	if [ -n "$1" ]; then
		arguments+="?"
		echo "arg1 vaut $1"
		if [ -n "$2" ]; then
			echo "arg2 vaut $2"
			arguments+="debut=$1&fin=$2"
		else
			arguments+="fin=$1"
		fi
	fi
}

# recherche un paramètre "on" ou "off" qui détermine l'action à engager
# (mise en maintenance du site ou sortie de maintenance)
function charger_config_et_lire_parametre_on_off {
	# chargement de la configuration
	. $fichier_config

	if [ "$1" == "off" ]; then
		lire_parametres_dates $2 $3
		maintenance
	elif [ "$1" == "on" ]; then
		sortie_maintenance
	else
		notice
	fi
}

# base du fichier .htaccess
function generer_htaccess_base {
	htaccess_base="# DORMANCE
RewriteEngine on
RewriteCond %{REQUEST_URI} !$nom_page
RewriteCond %{REQUEST_FILENAME} !(css|img).+$
RewriteCond %{REQUEST_FILENAME} !(.*png|.*jpg)$"
	for adr in "${adresses[@]}"; do
		# remplacement de tous les . par \.
		adr=${adr//./\\.}
		htaccess_base+=$'\n'
		htaccess_base+="RewriteCond %{REMOTE_ADDR} !^$adr$"
	done
}

# génère le contenu d'un fichier .htaccess en fonction de la configuration,
# avec une redirection pour tout le dossier
function generer_htaccess_simple {
	htaccess=$htaccess_base
	# gestion des dates de maintenance (nécessite une page compatible)
	htaccess+=$'\n'
	htaccess+="RewriteRule (.*) $redirection$arguments [L]"
}

# génère le contenu d'un fichier .htaccess en fonction de la configuration,
# avec des règles spécifiques qui se superposent ou s'ajoutent à d'éventuelles
# règles existantes
function generer_htaccess_regles {
	htaccess=$htaccess_base
	# parcours des règles fines pour ce .htaccess
	for ((j = 1; j < ${#regles[@]}; j++)); do
		regle=${regles[$j]}
		htaccess+=$'\n'
		htaccess+="RewriteRule $regle $redirection$arguments [L]"
	done
	htaccess+=$'\n'
	# si un fichier .htaccess existait déjà
	if [ -e "$chemin_htaccess_maintenance" ]; then
		htaccess+=$'\n'
		htaccess+=`cat "$chemin_htaccess_maintenance"`
	fi
}

# Mise en maintenance
function maintenance {
	echo "Mise en maintenance"
	# génération du contenu de base des futurs .htaccess
	generer_htaccess_base

	# parcours des destinations à mettre en maintenance
	for ((i = 0; i < ${#dossiers[@]}; i++)); do
		# tentative de découpage de la règle
		IFS=$'\n\t' read -d '' -r -a regles <<< "${dossiers[$i]}"
		nbregles=${#regles[@]}
		dest=${regles[0]}
		# traitement de la règle
		if [ -d "$dest" ]; then
			echo "+ traitement de $dest"
			chemin_htaccess="$dest/.htaccess"
			chemin_htaccess_maintenance="$dest/htaccess.maintenance"
			# si un .htaccess existe déjà
			if [ -e "$chemin_htaccess" ]; then
				# vérifie si le .htaccess existant n'est pas déjà un .htaccess de maintenance (double-off-proof)
				premiere_ligne=$(head -n 1 "$chemin_htaccess")
				if [ "$premiere_ligne" == "# DORMANCE" ]; then
					echo " ! le dossier était déjà en maintenance !"
				else
					# s'il n'y a pas déjà un fichier htaccess.maintenance, on le crée
					if [ ! -e "$chemin_htaccess_maintenance" ]; then
						echo "   déplacement d'un fichier '.htaccess' existant vers 'htaccess.maintenance'"
						mv "$chemin_htaccess" "$chemin_htaccess_maintenance"
					fi
				fi
			fi
			# dans tous les cas on met à jour le fichier .htaccess
			if [ $nbregles == 1 ]; then
				# génération du contenu du .htaccess de maintenance
				generer_htaccess_simple
			else
				# génération du contenu du .htaccess de maintenance en fonction de l'existant
				generer_htaccess_regles
			fi
			echo "   écriture du .htaccess"
			echo "$htaccess" > "$chemin_htaccess"
		else
			echo "! $dest n'est pas un dossier"
		fi
	done

	#echo "$htaccess"
}

# Sortie de la maintenance
function sortie_maintenance {
	echo "Sortie de maintenance"
	# parcours des destinations à sortir de la maintenance
	for ((i = 0; i < ${#dossiers[@]}; i++)); do
		# récupération du dossier de la règle
		IFS=$'\n\t' read -d '' -r -a regles <<< "${dossiers[$i]}"
		dest=${regles[0]}
		# traitement de la règle
		if [ -d "$dest" ]; then
			echo "+ traitement de $dest"
			chemin_htaccess="$dest/.htaccess"
			chemin_htaccess_maintenance="$dest/htaccess.maintenance"
			# vérifie si le .htaccess qu'on s'apprête à supprimer est bien un .htaccess de maintenance (double-on-proof)
			if [ -e "$chemin_htaccess" ]; then
				premiere_ligne_s=$(head -n 1 "$chemin_htaccess")
				if [ "$premiere_ligne_s" == "# DORMANCE" ]; then
					echo "   suppression du .htaccess"
					rm "$chemin_htaccess"
				else
					echo " ! le dossier n'était pas en maintenance"
				fi
			else
				echo " ! le dossier n'était pas en maintenance"
			fi
			if [ -e "$chemin_htaccess_maintenance" ]; then
				echo "   déplacement d'un fichier 'htaccess.maintenance' existant en '.htaccess'"
				mv "$chemin_htaccess_maintenance" "$chemin_htaccess"
			fi
		else
			echo "! $dest n'est pas un dossier"
		fi
	done
}

# recherche l'option facultative de la ligne de commande : -c nomfichierconfig
# @TODO utiliser getopts si besoin de nouveaux paramètres facultatifs
if [ "$1" == "-c" ]; then
	if [ "$2" != "" ]; then
		fichier_config=$2
		if [ -e "$fichier_config" ]; then
			charger_config_et_lire_parametre_on_off $3 $4 $5
		else
			echo "Fichier de configuration introuvable : $fichier_config"
		fi
	else
		notice
		exit 1
	fi
else
	charger_config_et_lire_parametre_on_off "$@"
fi

