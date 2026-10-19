# Comprova l'error si no enviem el token per descarregar el PDF.
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/alumnes/qualitativa_pdf/{{IdAlumneIncorrecte}}/
Accept: application/pdf

HTTP 401
[Asserts]
jsonpath "$.detail" exists
jsonpath "$.detail" == "Credencials d'autenticació no disponibles."
