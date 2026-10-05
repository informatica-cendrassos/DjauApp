
# Comprova que pot demanar mesos incorrectes i no dóna error
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
alumneId: jsonpath "$[0].id"


GET https://{{host}}/api/token/notificacions/mes/25/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}

HTTP 400
[Asserts]
jsonpath "$.error" exists
jsonpath "$.error[0]" == "Mes inexistent"

