
# Comprova que un usuari logejat pot demanar si hi ha novetats i que
# si hi ha, respon que sí.
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


# Comprova que pot demanar si hi ha novetats
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/notificacions/news/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}


HTTP 200
[Asserts]
jsonpath "$.resultat" exists
jsonpath "$.resultat" == "Sí" || jsonpath "$.resultat" == "No"
