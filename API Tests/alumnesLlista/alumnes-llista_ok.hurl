# Comprova que un usuari logejat pot demanar la llista d'alumnes
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
[Asserts]
header "Content-Type" == "application/json"



GET https://{{host}}/api/token/alumnes_associats/
Content-Type: application/json
Authorization: Bearer {{token}}

HTTP 200
[Captures]
alumneId: jsonpath "$.[0].id"
[Asserts]
jsonpath "$" count > 0
jsonpath "$[0].nom" exists
jsonpath "$[0].cognoms" exists
jsonpath "$[0].id" exists
