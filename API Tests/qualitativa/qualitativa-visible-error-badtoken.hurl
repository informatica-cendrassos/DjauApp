# Comprova l'error si enviem un token incorrecte per consultar la visibilitat.
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/alumnes/qualitativa_visible/{{IdAlumneIncorrecte}}/
Content-Type: application/json
Authorization: Bearer {{badToken}}

HTTP 401
[Asserts]
jsonpath "$.detail" exists
jsonpath "$.detail" == "Given token not valid for any token type"
