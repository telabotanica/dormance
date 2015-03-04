#
# Dormance - configuration
#
# Tela Botanica - 2015-03 - Licence CeCILL v2 + GPL v3
#

# Page vers laquelle rediriger les requêtes
redirection="/maintenance/maintenance.page.exemple.php"
nom_page=$(basename $redirection) # ne pas modifier !

# Liste des dosiiers dans lesquels placer un .htaccess de maintenance
dossiers=(
"/var/www/monsite/"
"/home/user/test"
)

# Liste des adresses IP qui ne subiront pas la redirection
adresses=(
"192.168.0.16"
)

