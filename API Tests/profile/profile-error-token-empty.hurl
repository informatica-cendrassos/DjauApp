# Comprova l'error si no enviem token
# ==============================================================================


GET https://{{host}}/api/token/alumnes/dades/{{IdAlumneIncorrecte}}/
Content-Type: application/json
Authorization: Bearer

HTTP 401
[Asserts]
jsonpath "$.detail" exists
jsonpath "$.detail" == "Credencials d'autenticació no disponibles."
