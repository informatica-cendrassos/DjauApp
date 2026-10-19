# Comprova l'error si enviem un token incorrecte per descarregar el PDF.
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/alumnes/qualitativa_pdf/{{IdAlumneIncorrecte}}/
Accept: application/pdf
Authorization: Bearer {{badToken}}

HTTP 401
[Asserts]
jsonpath "$.detail" exists
jsonpath "$.detail" == "Given token not valid for any token type"
