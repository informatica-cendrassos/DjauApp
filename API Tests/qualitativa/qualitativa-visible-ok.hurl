# Comprova si l'avaluació qualitativa és visible per a un alumne associat.
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

# Comprova la visibilitat de l'avaluació qualitativa.
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/alumnes/qualitativa_visible/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}

HTTP 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.resultat" exists
jsonpath "$.resultat" matches /^(Sí|No)$/
