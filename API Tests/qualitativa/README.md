# Avaluació qualitativa

Comprova si l'avaluació qualitativa està disponible per a un alumne associat i
que el PDF corresponent es pot descarregar amb una sessió autenticada.

## Peticions

### `GET /api/token/alumnes/qualitativa_visible/{idAlumne}/`

La resposta ha de ser un document JSON amb el camp `resultat`, amb valor `Sí`
o `No`.

### `GET /api/token/alumnes/qualitativa_pdf/{idAlumne}/`

La resposta correcta ha de ser un PDF (`Content-Type: application/pdf`).

Els fitxers també comproven que tots dos extrems rebutgen peticions sense token
o amb un token invàlid.
