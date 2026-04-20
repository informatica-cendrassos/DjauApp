# Comprovar si un alumne té alguna novetat

Comprova si algun alumne té alguna novetat des de la darrera vegada que
es va comprovar

## Petició

### GET /api/token/notificacions/news/{idAlumne}/

- `idAlumne` serà un dels `id` de l'alumne que es vol comprovar

Necessita obligatòriament el token de sessió

```http
Authorization: Bearer ${JWTOKEN}"
```

## Resposta

La resposta és 'Si' en cas de que hi hagi novetats o 'No'  en cas que no n'hi hagi

El document JSON de resposta té aquesta forma:

```json
{
    "resultat":"Sí"
}
```
