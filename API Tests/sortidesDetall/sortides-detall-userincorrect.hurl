
# Comprova que no es veuen les sortiddes amb un alumne incorrecte i un token no vàlid
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


# Recupera la llista de sortides de l'alumne
# [{"id":62,"titol":"BATALLA DE L'EBRE","data":"2024-11-12 06:00:00","pagament":true,"realitzat":true},
# {"id":111,"titol":"Ciència Sorprenent","data":"2024-11-11 11:00:00","pagament":false,"realitzat":false},
# {"id":136,"titol":"COM COMENÇA TOT  4ESO C i PS","data":"2024-11-06 13:40:00","pagament":false,"realitzat":false},
# {"id":89,"titol":"MATFESTA-PARADES","data":"2024-10-25 08:20:00","pagament":false,"realitzat":false}]
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/sortides/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}	

HTTP 200
[Captures]
sortidaOk: jsonpath "$.[0].id"



GET https://{{host}}/api/token/sortides/{{sortidaOk}}/{{IdAlumneIncorrecte}}/
Content-Type: application/json
Authorization: Bearer {{token}}	


HTTP 401
[Asserts]
jsonpath "$.detail" exists
jsonpath "$.detail" == "Given token not valid for any token type"






