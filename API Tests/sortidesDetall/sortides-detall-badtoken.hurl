
# Comprova que no es veuen les sortiddes si no posa un token correcte
# ==============================================================================

GET https://{{host}}/api/token/sortides/{{sortidaOk}}/
Content-Type: application/json
Authorization: Bearer {{badToken}}


HTTP 401
[Asserts]
jsonpath "$.detail" exists
jsonpath "$.detail" == "Given token not valid for any token type"






