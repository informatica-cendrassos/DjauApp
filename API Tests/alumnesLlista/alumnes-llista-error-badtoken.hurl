# Comprova que dóna error si enviem el token incorrecte
# ==============================================================================


GET https://{{host}}/api/token/alumnes_associats/
Content-Type: application/json
Authorization: Bearer {{badToken}}

HTTP 401
[Asserts]
jsonpath "$.detail" exists
jsonpath "$.detail" == "Given token not valid for any token type"