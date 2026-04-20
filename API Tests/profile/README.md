# Dades de l'alumne

Retorna les dades de l'alumne i del seu tutor associat.

## Petició

### GET /api/token/alumnes/dades/{idAlumne}/

- `idAlumne` és l'identificador de l'alumne del que es volen recuperar les dades

La crida necessita tenir en la capçalera el token de sessió

```http
Authorization: Bearer ${JWTOKEN}"
```

## Resposta

Retornarà les dades en un arxiu JSON

```json
{
    "grup":"SMX2A",
    "datanaixement":"13/5/2004",
    "telefon":"",
    "adreça":"CR Pere III 62  ESC. C 1er 1era , Figueres",
    "responsables": [
        {
            "nom":"Ganchozo Risco, Miriam Graciela",
            "mail":"keylu5810@hotmail.com","tfn":""
        },
    ]
}
```
