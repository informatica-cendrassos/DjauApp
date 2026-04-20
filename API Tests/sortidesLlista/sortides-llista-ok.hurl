
# Comprova que un usuari identificat pot demanar la llista de sortides associades a un alumne
# ==============================================================================
# [{"id":62,"titol":"BATALLA DE L'EBRE","data":"2024-11-12 06:00:00","pagament":true,"realitzat":true},
# {"id":111,"titol":"Ciència Sorprenent","data":"2024-11-11 11:00:00","pagament":false,"realitzat":false},
# {"id":136,"titol":"COM COMENÇA TOT  4ESO C i PS","data":"2024-11-06 13:40:00","pagament":false,"realitzat":false},
# {"id":89,"titol":"MATFESTA-PARADES","data":"2024-10-25 08:20:00","pagament":false,"realitzat":false}]

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


# Obtenir la llista de sortides de l'alumne especificat
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/sortides/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}

HTTP 200
[Asserts]
// Comprova que tots els resultats obtinguts tenen el camp id de la sortida
jsonpath "$.[*].id" exists

