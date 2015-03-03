#
# Dormance - configuration
#
# Tela Botanica - 2015-03 - Licence CeCILL v2 + GPL v3
#

# Page vers laquelle rediriger les requêtes
redirection="/maintenance/maintenance.html"
nom_page=$(basename $redirection) # ne pas modifier !

# Liste des dosiiers dans lesquels placer un .htaccess de maintenance
dossiers=(
"/home/mathias/test"
'/home/mathias/test/ta mémé.com'
"/home/mathias/couscous/poulet"
"/home/mathias/test/dossier1"
"/home/mathias/test/dossier1/b"
"/home/mathias/test/dossier1/a/"
)

# Liste des adresses IP qui ne subiront pas la redirection
adresses=(
"192.168.0.16"
"192.168.0.9"
"192.168.0.6"
)

