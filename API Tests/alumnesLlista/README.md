# Obtenir la llista d'alumnes associats al compte

Un cop el programa ha aconseguit iniciar sessió, el primer que necessitarà
fer és aconseguir el nom i l'id d'algun dels seus alumnes associats.

## Petició

### GET /api/token/alumnes_associats/

Capçaleres obligatòries

```http
Authorization: Bearer ${JWTOKEN}"
```

## Resposta: Llista d'alumnes associats

La resposta vindrà amb un array de JSON amb una forma semblant a aquesta:

```json
[
    {
        "nom":"Anthony Josue",
        "cognoms":"BlaBla BlaBla",
        "id":686
    },
    {
        "nom":"Massiel",
        "cognoms":"Cognoms Cognoms",
        "id":763
    },
    {
        "nom":"Rihanna Kahori",
        "cognoms":"Lalalal Lalalla",
        "id":764
    }
]
```
