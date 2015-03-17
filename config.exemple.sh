#
# Dormance - configuration
#
# Tela Botanica - 2015-03 - Licence CeCILL v2 + GPL v3
#

# Page vers laquelle rediriger les requêtes
redirection="/maintenance/maintenance.php"
nom_page=$(basename $redirection) # ne pas modifier !

# Liste des adresses IP qui ne subiront pas la redirection
adresses=(
"192.168.0.16"
"192.168.0.9"
"192.168.0.6"
)

# Liste des dossiers dans lesquels placer un .htaccess de maintenance
# Les dossiers à traiter sont encadrés par des ""
# Pour n'affecter que certaines règles de redirection précises, revenir
#	à la ligne (\n), indenter d'une tabulation (\t) et ajouter la règle (syntaxe mod_rewrite)
# Si un .htaccess existe déjà, il sera sauvé lors de "off" puis restauré lors de "on"
dossiers=(
"/home/user/www/my-website.com"
"/usr/local/appli-v1.4"
"/home/user/www
	^page:eflore.*$
	^page:(bdtxa|isfan|apd)$
	^(bdtfx|bdtxa|bdtre|isfan|apd)[-/:]nn[-/:]([0-9]+)[-/:]([a-z]+)$
"
"/home/user/foo/bar/stuff"
)

