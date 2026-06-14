# Djau Cendrassos App

L'aplicació funciona interactuant amb l'aplicació mòbil del programa de gestió de presència, incidències i més per a Instituts, Escoles i Acadèmies. [Djau](https://github.com/ctrl-alt-d/django-aula).

La idea inicial era tenir alguna forma de que els tutors dels alumnes puguin rebre notificacions en el mòbil de les incidències dels alumnes que es vagin produint.

En l'aplicació permet veure el detall i les incidències de tots els alumnes de cada responsable

![androidBase](documentacio/imatges/notificacions.png)

Les funcionalitats implementades són:

- Veure la llista de les incidències de tot el curs dels alumnes
- Emet avisos en detectar noves incidències
- Es poden verificar les dades dels tutors
- Veure les sortides i pagaments dels alumnes i efectuar-ne el pagament

[Més informació](documentacio/tutorial.md)

## Plataformes

El programa pot funcionar en diverses plataformes:

- Android

> Tot i que haria de ser possible executar-lo en Apple IOS només s'ha provat en Android.

També es possible executar-la com una aplicació Web i com aplicacions d'escriptori en Windows i Linux.

> Aquestes plataformes tenen algunes limitacions

## Configuració

Es poden canviar múltiples aspectes de la configuració editant les constants definides
a `djau_theme.dart` i `config_djau.dart` (Es diuen Cendrassos però canviant els valors
de la configuració es poden adaptar a qualsevol altre centre)

[Més infomació](documentacio/configuracio.md)

## Compilar i executar

Qualsevol canvi en la configuració o en el codi requereix recompilar de nou el programa. Per fer-ho cal tenir instal·lat el Flutter SDK.

Mentre s'executa el programa Flutter fa "live preview" en els canvis que es vagi fent des d'Android Studio o Visual Studio Code.

[Informació](documentacio/desenvolupament.md)

## Tests d'API

Donats els constants canvis en l'API s'han generat tests en [hurl](https://github.com/Orange-OpenSource/hurl) per comprovar que el funcionament de l'API no ha canviat.

En el README del directori explica com executar-los

[Informació](./API%20Tests/readme.md)
