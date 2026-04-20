# Comprova l'accés a l'endpoint de news amb GET per a dos alumnes
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


# ------------ CAS 1: alumne real ----------------------------

GET https://{{host}}/api/token/notificacions/news/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}


HTTP 200
[Asserts]
jsonpath "$.resultat" exists


# ------------ CAS 2: alumne inexistent ----------------------------

GET https://{{host}}/api/token/notificacions/news/{{IdAlumneIncorrecte}}/
Content-Type: application/json
Authorization: Bearer {{token}}


HTTP 200
[Asserts]
jsonpath "$.resultat" == "No"