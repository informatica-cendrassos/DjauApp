# Demana les notificacions d'un alumne en un mes

La crida retorna les notificacions que hi ha d'un dels alumnes associats en un mes concret

## Petició

### /api/token/notificacions/mes/{mes}/{idAlumne}/

- `mes` és el més del que es volen recuperar les notificacions
- `idAlumne` és l'identificador de l'alumne del que es volen recuperar les notificacions

La crida necessita tenir en la capçalera el token de sessió

```http
Authorization: Bearer ${JWTOKEN}"
```

## Resposta

Es retorna un array Json amb els notificacions de l'alumne el mes demanat.

Per exemple:

```json
[
  {
    "id":155,"darrera_sincronitzacio":null},
    {
        "dia":"13/10/2022",
        "materia":"SMX12(2)",
        "hora":"14:50 a 15:50",
        "professor":"Àngel Bosch Hernàndez",
        "text":"Falta d'assistència",
        "tipus":"Falta"
    },
    {
        "dia":"10/10/2022",
        "materia":"SMX12(2)",
        "hora":"19:00 a 19:55",
        "professor":"Daniel Prados",
        "text":"Falta d'assistència",
        "tipus":"Falta"
    },
    {
        "dia":"10/10/2022",
        "materia":"SMX12(2)",
        "hora":"18:00 a 19:00",
        "professor":"Daniel Prados",
        "text":"Falta d'assistència",
        "tipus":"Falta"
    },
    {
        "dia":"11/10/2022",
        "hora":"19:00 a 19:55",    
        "professor":"Juaky Rubio",
        "text":"Parla, molesta i no deixa treballar als companys.",
        "tipus":"Falta"
    }
]
```
