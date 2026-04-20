# Obtenir el detall d'una de les sortides de l'alumne

D'entre les sortides d'un alumne, aquesta crida permet recuperar-ne les dades amb més detall. En especial importen la part de pagaments:

- Si s'ha de pagar o no
  - Si està pagada
- IDentificador del pagament

## Petició

### GET /api/token/sortides/{idSortida}/{idAlumne}

- `idSortida` és l'identificador de la sortida
- `idAlumne` és l'identificador de l'alumne

Necessita obligatòriament el token de sessió

```http
Authorization: Bearer ${JWTOKEN}"
```

## Resposta

Retornarà un JSON amb les dades concretes de la sortida

```json
[
    {
        "titol":"BATALLA DE L'EBRE",
        "desde":"12/11/2024 06:00",
        "finsa":"13/11/2024 21:00",
        "programa":"Sortida per treballar la Guerra Civil Espanyola, en concret en espais on hi existeixin evidències",
        "preu":"53.00",
        "dataLimitPagament":"2024-10-31 23:59:00",
        "realitzat":true,
        "idPagament":2144
    }
]
```
