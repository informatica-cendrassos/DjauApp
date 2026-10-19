# Comprova l'error si no enviem el token per consultar la visibilitat.
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/alumnes/qualitativa_visible/{{IdAlumneIncorrecte}}/
Content-Type: application/json

HTTP 401
[Asserts]
jsonpath "$.detail" exists
jsonpath "$.detail" == "Credencials d'autenticació no disponibles."
