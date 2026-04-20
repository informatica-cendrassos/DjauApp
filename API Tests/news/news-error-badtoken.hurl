# Comprova que dóna error si enviem el token incorrecte
# ==============================================================================


POST https://{{host}}/api/token/notificacions/news/{{IdAlumneIncorrecte}}/
Content-Type: application/json
Authorization: Bearer {{badToken}}
{
    "last_sync_date": "2122-11-18 12:00:13"
}


HTTP 401
[Asserts]
jsonpath "$.detail" exists
jsonpath "$.detail" == "Given token not valid for any token type"
