# Comprova que es pot descarregar el PDF d'avaluació qualitativa d'un alumne.
# ==============================================================================

POST https://{{host}}/api-token-auth/
Content-Type: application/json
{
  "username": "{{username}}",
  "password": "{{password}}"
}

HTTP 200
[Captures]
token: jsonpath "$.access"

# Recupera un alumne associat al tutor autenticat.
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/alumnes_associats/
Content-Type: application/json
Authorization: Bearer {{token}}

HTTP 200
[Captures]
alumneId: jsonpath "$[0].id"

# Descarrega el document PDF.
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/alumnes/qualitativa_pdf/{{alumneId}}/
Accept: application/pdf
Authorization: Bearer {{token}}

HTTP 200
[Asserts]
header "Content-Type" contains "application/pdf"
