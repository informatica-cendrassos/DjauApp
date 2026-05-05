
# Comprova que un usuari logejat pot recuperar les dades de l'alumne associat
# ==============================================================================


# Comprova que l'alumne pot fer login per obtenir el token
# ------------------------------------------------------------------------------

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

# Comprova que pot recuperar dades de l'alumne associat
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/alumnes/dades/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}

HTTP 200
[Asserts]
jsonpath "$.grup" exists
jsonpath "$.datanaixement" exists
jsonpath "$.telefon" exists
jsonpath "$.adreca" exists
jsonpath "$.responsables" exists
jsonpath "$.responsables" isCollection