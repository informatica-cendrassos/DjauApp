# Obtenir la llista de sortides d'un alumne

L'API retorna la llista resumida de les sortides que hi ha previstes per un alumne

## Petició

### GET /api/token/sortides/{idAlumne}/

- `idAlumne` és l'identificador de l'alumne

Necessita obligatòriament el token de sessió

```http
Authorization: Bearer ${JWTOKEN}"
```

## Resposta

Retorna una llista en un Json amb les sortides

```json
[
    {
        "id":62,
        "titol":"BATALLA DE L'EBRE",
        "data":"2024-11-12 06:00:00",
        "pagament":true,
        "realitzat":true
    },
    {
        "id":111,
        "titol":"Ciència Sorprenent",
        "data":"2024-11-11 11:00:00",
        "pagament":false,
        "realitzat":false
    },
    {
        "id":136,
        "titol":"COM COMENÇA TOT  4ESO C i PS",
        "data":"2024-11-06 13:40:00",
        "pagament":false,
        "realitzat":false
    },
    {
        "id":89,
        "titol":"MATFESTA-PARADES",
        "data":"2024-10-25 08:20:00",
        "pagament":false,
        "realitzat":false
    }
]
```
