# Tests de l'API del Djau

Es tests estan fets amb [Hurl](https://github.com/Orange-OpenSource/hurl).

La instal·lació no hauria de ser un problema ja que només cal obtenir el binari de "Releases" (o instal·lar-lo amb **cargo** de Rust)

## Executar tots els tests

Abans d'executar els tests cal tenir jocs de proves correctes:

- Adreça del host on fer les proves (varificar el fitxer vars.env)
- un usuari i una contrasenya verificats
- Id que no és una sortida (suposo que el que ja hi ha mai existirà)
- Els valors inexistents són improvisats ja que no se me n'ha proporcionat cap, però haurien de funcionar.

S'edita el fitxer `vars.env` i, si cal, s'hi canvia el host on està instal·lat el programa:

```ini
host=djauproves.cendrassos.net
IdAlumneIncorrecte=99999
badPassword=wrongpassword
sortidaInexistent=99999
badToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3NjcwMDQ0NiwiaWF0IjoxNzc2NjE0MDQ2LCJqdGkiOiI0MGM2MDhmOTE1NGM0ZDgyYTY3OGVkMTVmMzQ0YWVmNCIsInVzZXJfaWQiOjIzNzJ9.snjXg3vKOJwxbmG1cnPjgUNFy9vilYZvWgerx9wIW0U
```

Per executar tots els tests:

```bash
./run-tests.sh
```

Es demanarà l'usuari i la contrasenya (la contrasenya no es mostra en pantalla):

```log
Usuari: API1RRE
Contrasenya:
============================================================================
Executant 19 test(s)...
============================================================================
```

Va mostrant l'execució de cada un dels tests i en acabar dóna una estadística del resultat:

```log
alumnesLlista/alumnes-llista-error-badtoken.hurl: Success (1 request(s) in 22 ms)
alumnesLlista/alumnes-llista-notoken.hurl: Success (1 request(s) in 21 ms)
alumnesLlista/alumnes-llista_ok.hurl: Success (2 request(s) in 406 ms)
news/news-error-badtoken.hurl: Success (1 request(s) in 25 ms)
news/news-error-incorrect-date-format.hurl: Success (3 request(s) in 310 ms)
news/news-error-nodate.hurl: Success (3 request(s) in 308 ms)
news/news-error-notoken.hurl: Success (1 request(s) in 20 ms)
news/news-ok-no.hurl: Success (2 request(s) in 305 ms)
news/news-ok-si.hurl: Success (3 request(s) in 460 ms)
profile/profile-error-badtoken.hurl: Success (1 request(s) in 126 ms)
profile/profile-error-notoken.hurl: Success (1 request(s) in 126 ms)
profile/profile-ok.hurl: Success (3 request(s) in 341 ms)
sortidesDetall/sortides-detall-badtoken.hurl: Success (1 request(s) in 26 ms)
sortidesDetall/sortides-detall-no-pagament-ok.hurl: Success (4 request(s) in 364 ms)
sortidesDetall/sortides-detall-ok.hurl: Success (4 request(s) in 367 ms)
sortidesDetall/sortides-detall-sortida_inexistent.hurl: Success (4 request(s) in 390 ms)
sortidesLlista/sortides-llista-error-badtoken.hurl: Success (1 request(s) in 22 ms)
sortidesLlista/sortides-llista-notoken.hurl: Success (1 request(s) in 21 ms)
sortidesLlista/sortides-llista-ok.hurl: Success (2 request(s) in 406 ms)
--------------------------------------------------------------------------------
Executed files:  19
Succeeded files: 19 (100.0%)
Failed files:    0 (0.0%)
Duration:        4500 ms
```

En l'execució es poden veure a què són deguts els errors ja que al afegir `--error-format=long` mostra les capçaleres i el contingut de la resposta rebuda.

## Executar les proves d'un sol domini

Només cal passar el directori de les proves que es voen fer. Per exemple per executar totes les proves de la part de "sortides":

```bash
$ ./run-tests.sh sortidesDetall
Usuari: API1RRE
Contrasenya:
============================================================================
Executant 4 test(s)...
============================================================================
sortidesDetall/sortides-detall-badtoken.hurl: Running [1/4]
sortidesDetall/sortides-detall-badtoken.hurl: Success (1 request(s) in 26 ms)
sortidesDetall/sortides-detall-no-pagament-ok.hurl: Running [2/4]
sortidesDetall/sortides-detall-no-pagament-ok.hurl: Success (4 request(s) in 364 ms)
sortidesDetall/sortides-detall-ok.hurl: Running [3/4]
sortidesDetall/sortides-detall-ok.hurl: Success (4 request(s) in 367 ms)
sortidesDetall/sortides-detall-sortida_inexistent.hurl: Running [4/4]
sortidesDetall/sortides-detall-sortida_inexistent.hurl: Success (4 request(s) in 390 ms)
--------------------------------------------------------------------------------
Executed files:  4
Succeeded files: 4 (100.0%)
Failed files:    0 (0.0%)
Duration:        1147 ms
```

## Executar un sol test

Passa el fitxer directament com a argument:

```bash
$ ./run-tests.sh news profile/profile-ok.hurl
profile/profile-ok.hurl: Success (3 request(s) in 7830 ms)
--------------------------------------------------------------------------------
Executed files:    1
Executed requests: 3 (0.3/s)
Succeeded files:   1 (100.0%)
Failed files:      0 (0.0%)
Duration:          7844 ms
```

## Altres

Hurl es pot executar de moltes altres formes. La documentació és bastant explícita. [web](http://hurl.dev)
