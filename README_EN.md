# dormance
A script that quickly puts an Apache website in maintenance mode, using .htaccess files

[Documentation française](README.md)

## usage

Put the website in maintenance mode using default configuration (config.sh)
```
$ ./dormance off
```

Put the website in maintenance mode until march 4 2015, 6:15 PM
(requires a compatible maintenance page)
```
$ ./dormance off 2015-03-04_18:15
```

Put the website in maintenance mode from march 4 2015, 9:00 AM to march 5 2015, 5:00 PM
(requires a compatible maintenance page)
```
$ ./dormance off 2015-03-04_09:00 2015-03-05_17:00
```

Put the website back in production mode
```
$ ./dormance on
```

Use a specific configuration file
```
$ ./dormance -c myfile off
$ ./dormance -c myfile on
```

## configuration

The configuration file loaded by default is "config.sh". To load another one, use -c option
An example is given in "config.exemple.sh"
Configuration files must be executable (chmod +x)

### redirection

The maintenance page.
If it accepts GET parameters "debut" (start) and "fin" (end), they will receive dates optionally
passed through the command line

Examples:
```
redirection="/maintenance/maintenance.php"
```

```
redirection="http://domain.tld/maintenance.html"
```

### adresses

Requests originating from those IP adresses won't be affected by the redirection.
One address per line, surrounded by ""

Examples:
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

### folders (dossiers)

A list of folders to put in maintenance mode. A fodler and its optional rules is surrounded by "".
For each folder, if a .htaccess file already exists, it will be saved and replaced; when putting back
the website online, the original .htaccess file will be restored.
If the folder path is followed by a list of rules (mod_rewrite syntax, one per line, idented with "\t"),
only those rules will be affected by the redirection; if other redirections were already present in an existing
.htaccess file, they will continue to work.

Examples:
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

### splitting configuration

Variables are global. To split configuration files, one may move a variable déclaration
to another executable file, and execute it inside the main configuration file.

Example :

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


