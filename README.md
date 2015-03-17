# dormance
Un script qui met un site Web Apache en maintenance rapidement, en utilisant des fichiers .htaccess

[English documentation](README_EN.md)

## utilisation

Mettre le site en maintenance en utilisant la configuration par défaut (config.sh)
```
$ ./dormance off
```

Mettre le site en maintenance jusqu'au 4 mars 2015 à 18h15
(nécessite une page de maintenance compatible)
```
$ ./dormance off 2015-03-04_18:15
```

Mettre le site en maintenance du 4 mars 2015 à 9h00 jusqu'au 5 mars 2015 à 17h00
(nécessite une page de maintenance compatible)
```
$ ./dormance off 2015-03-04_09:00 2015-03-05_17:00
```

Remettre le site en production
```
$ ./dormance on
```

Utiliser un fichier de configuration spécifique
```
$ ./dormance -c monfichier off
$ ./dormance -c monfichier on
```

## configuration

Le fichier de configuration chargé par défaut est "config.sh". Sinon, utiliser l'option -c
Un exemple est donné dans "config.exemple.sh"
Les fichiers de configurations doivent être exécutables (chmod +x)

### redirection

La page de maintenance.
Si elle accepte des paramètres GET "debut" et "fin", ceux-ci recevront les éventuelles dates
passées par la ligne de commande

Exemples:
```
redirection="/maintenance/maintenance.php"
```

```
redirection="http://domaine.tld/maintenance.html"
```

### adresses

Les requêtes provenant de ces adresses IP ne seront pas affectées par la redirection.
Une adresse par ligne, encadrée par des ""

Exemples:
```
adresses=(
"192.168.0.16"
"192.168.0.9"
"192.168.0.6"
)

```

```
adresses=(
)
```

### dossiers

Liste des dossiers à mettre en maintenance. Un dossier et ses éventuelles règles est encadré par des ""
Pour chaque dossier, si un fichier .htaccess existe déjà, il sera sauvegardé et remplacé; au moment de
remettre le site en production, le fichier .htaccess d'origine sera restauré.
Si le chemin du dossier est suivi d'une liste de règles (syntaxe de mod_rewrite, une par ligne, indentées par "\t"),
seules ces règles seront afectées par la redirection; si des redirections étaient déjà présentes dans un
fichier .htaccess existant, elles continueront de fonctionner.

Exemples:
```
dossiers=(
"/home/user/www/application"
"/var/www/foo bar"
)
```

```
dossiers=(
"/home/user/www/application"
"/var/www
	^page:eflore.*$
	^page:(bdtxa|isfan|apd)$
	^(bdtfx|bdtxa|bdtre|isfan|apd)[-/:]nn[-/:]([0-9]+)[-/:]([a-z]+)$
"
"/home/user/www/websites/ta mémé.com"
)
```

### factoriser la configuration

Les variables sont globales. Pour factoriser la configuration, on peut déplacer une déclaration
de variable dans un autre fichier exécutable, et l'exécuter depuis le fichier de configuration.

Exemple :

config.sh
```
...
# Liste des adresses IP qui ne subiront pas la redirection
. adresses.sh
...
```
adresses.sh
```
adresses=(
"192.168.0.16"
"192.168.0.9"
"192.168.0.6"
)
```


