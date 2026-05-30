
# Comprova que un usuari logejat pot veure les dades d'una sortida concreta 
# i que si la sortida té pagament, el camp idPagament no és null
#
# ```json
# [{"titol":"BATALLA DE L'EBRE","desde":"12/11/2024 06:00","finsa":"13/11/2024 21:00",
# "programa":"Sortida per treballar la Guerra Civil Espanyola, en concret en espais on e",
# preu":"53.00", "dataLimitPagament":"2024-10-31 23:59:00","realitzat":true,"idPagament":2144}]
# ```
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


# Comprova que pot recuperar les dades d'una sortida concreta
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/sortides/{{sortidaOk}}/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}


HTTP 200
[Captures]
idPagament: jsonpath "$.idPagament"

[Asserts]
jsonpath "$.titol" exists
jsonpath "$.desde" exists
jsonpath "$.finsa" exists
jsonpath "$.programa" exists
jsonpath "$.preu" exists
jsonpath "$.dataLimitPagament" exists
jsonpath "$.realitzat" exists
jsonpath "$.idPagament" exists
jsonpath "$.idPagament" != null

# Carregar la pàgina de pagament de la sortida (si no està realitzada)

GET https://djauproves.cendrassos.net/sortides/pagoOnlineApi/{{idPagament}}/
Content-Type: text/html
Authorization: Bearer {{token}}

HTTP 200

[Asserts]
header "Content-Type" == "text/html; charset=utf-8"
xpath "string(//li/strong/text())" contains "NO TÉ AUTORITZACIÓ PER ACCEDIR AL PAGAMENT"



