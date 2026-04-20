# Comprova l'error si no enviem el token
# ==============================================================================

GET https://{{host}}/api/token/notificacions/mes/11/{{IdAlumneIncorrecte}}/
Content-Type: application/json

HTTP 401
[Asserts]
jsonpath "$.detail" exists
jsonpath "$.detail" == "Credencials d'autenticació no disponibles."
