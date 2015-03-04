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
	echo "Utilisation: $0 off|on [date1] [date2]"
	echo "- off: passe le site en maintenance"
	echo "- on: sort le site de la maintenance"
	echo "- date1: date et heure de début de maintenance, au format '2015-03-04_09:15' (! lire NOTE)"
	echo "- date2: date et heure de fin de maintenance, au format '2015-03-04_09:15'"
	echo "NOTE: si seule date1 est fournie, ce sera la date de fin"
}

# chargement de la configuration
. config.sh

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

# génère le contenu d'un fichier .htaccess en fonction de la configuration
function generer_htaccess {
	htaccess="# DORMANCE
RewriteEngine on
RewriteCond %{REQUEST_URI} !$nom_page
RewriteCond %{REQUEST_FILENAME} !(css|img).+$
RewriteCond %{REQUEST_FILENAME} !(.*png|.*jpg)$"
	for adr in "${adresses[@]}"; do
		# remplacement de tous les . par \.
		adr=${adr//./\\.}
		htaccess+=$'\n'
		htaccess+="RewriteCond %{REMOTE_ADDR} !^$adr$"
	done
	# gestion des dates de maintenance (nécessite une page compatible)
	htaccess+=$'\n'
	htaccess+="RewriteRule (.*) $redirection$arguments [R=302,L]"
}

# Mise en maintenance
function maintenance {
	echo "Mise en maintenance"
	# génération du contenu du .htaccess de maintenance
	generer_htaccess

	# parcours des destinations à mettre en maintenance
	for ((i = 0; i < ${#dossiers[@]}; i++)); do
		dest="${dossiers[$i]}"
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
		dest="${dossiers[$i]}"
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

# option de la ligne de commande : "on" ou "off"
if [ "$1" == "off" ]; then
	lire_parametres_dates $2 $3
	maintenance
elif [ "$1" == "on" ]; then
	sortie_maintenance
else
	notice
	exit 1
fi

