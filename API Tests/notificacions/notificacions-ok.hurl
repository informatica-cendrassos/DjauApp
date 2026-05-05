
# Comprova que un usuari logejat pot demanar les notificacions
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

# Recupera la llista d'alumnes associats a l'usuari logejat
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/alumnes_associats/
Content-Type: application/json
Authorization: Bearer {{token}}

HTTP 200
[Captures]
alumneId: jsonpath "$.[0].id"


# Recupera les incidèncuies de l'alumne d'un mes concret
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/notificacions/mes/11/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}

HTTP 200
[Asserts]
jsonpath "$.[0].id" exists
# jsonpath "$.[0].darrera_sincronitzacio" exists

