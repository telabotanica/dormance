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
	echo "Utilisation: $0 [off|on]"
	echo "- off: passe le site en maintenance"
	echo "- on: sort le site de la maintenance"
}

# chargement de la configuration
. config.sh

# génère le contenu d'un fichier .htaccess en fonction de la configuration
function generer_htaccess {
	htaccess="RewriteEngine on
RewriteCond %{REQUEST_URI} !$nom_page
RewriteCond %{REQUEST_FILENAME} !(css|img).+$
RewriteCond %{REQUEST_FILENAME} !(.*png|.*jpg)$"
	for adr in "${adresses[@]}"; do
		# remplacement de tous les . par \.
		adr=${adr//./\\.}
		htaccess+=$'\n'
		htaccess+="RewriteCond %{REMOTE_ADDR} !^$adr$"
	done
	htaccess+=$'\nRewriteRule (.*) /maintenance/maintenance.html [R=302,L]'
}

# mise en maintenance
function maintenance {
	echo "Mise en maintenance"
	# génération du contenu du .htaccess de maintenance
	generer_htaccess

	# parcours des destinations à mettre en maintenance
	for ((i = 0; i < ${#dossiers[@]}; i++)); do
		dest="${dossiers[$i]}"
		if [ -d "$dest" ]; then
			echo "- traitement de $dest"
			chemin_htaccess="$dest/.htaccess"
			chemin_htaccess_maintenance="$dest/htaccess.maintenance"
			if [ -e "$chemin_htaccess" ]; then
				if [ ! -e "$chemin_htaccess_maintenance" ]; then
					echo "-> copie d'un fichier '.htaccess' existant en 'htaccess.maintenance'"
					mv $chemin_htaccess $chemin_htaccess_maintenance
				fi
			fi
			echo "-> écriture du .htaccess"
			echo "$htaccess" > $chemin_htaccess
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
			echo "- traitement de $dest"
			chemin_htaccess="$dest/.htaccess"
			chemin_htaccess_maintenance="$dest/htaccess.maintenance"
			echo "-> suppression du .htaccess"
			rm $chemin_htaccess
			if [ ! -e "$chemin_htaccess_maintenance" ]; then
				echo "-> copie d'un fichier 'htaccess.maintenance' existant en '.htaccess'"
				mv $chemin_htaccess_maintenance $chemin_htaccess
			fi
		else
			echo "! $dest n'est pas un dossier"
		fi
	done
}

# option de la ligne de commande : "on" ou "off"
if [ "$1" == "off" ]; then
	maintenance
elif [ "$1" == "on" ]; then
	sortie_maintenance
else
	notice
	exit 1
fi

