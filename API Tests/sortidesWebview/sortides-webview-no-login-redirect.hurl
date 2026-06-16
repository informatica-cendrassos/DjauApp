
# Comprova que la passarel·la de pagament per a l'app mòbil (Bearer token)
# no redirigeix al login web ni a passarella amb sessió de cookies.
#
# Regressió detectada: pagoOnlineApi carrega correctament amb Bearer, però el HTML
# redirigeix a /sortides/passarella/ que exigeix sessió web i acaba a
# /usuaris/login/?next=/sortides/passarella/{id}/...
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


# Busca una sortida amb pagament pendent (pagament=true, realitzat=false)
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/sortides/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}

HTTP 200
[Captures]
sortidaPagamentPendent: jsonpath "$[?(@.pagament == true && @.realitzat == false)].id" first


# Recupera el detall i l'idPagament de la sortida pendent
# ------------------------------------------------------------------------------
GET https://{{host}}/api/token/sortides/{{sortidaPagamentPendent}}/{{alumneId}}/
Content-Type: application/json
Authorization: Bearer {{token}}

HTTP 200
[Captures]
idPagament: jsonpath "$.idPagament"

[Asserts]
jsonpath "$.idPagament" exists
jsonpath "$.idPagament" != null
jsonpath "$.realitzat" == false


# pagoOnlineApi ha de mostrar la passarel·la sense redirigir al login web
# ------------------------------------------------------------------------------
GET https://{{host}}/sortides/pagoOnlineApi/{{idPagament}}/
Authorization: Bearer {{token}}

HTTP 200

[Asserts]
header "Content-Type" == "text/html; charset=utf-8"
xpath "//li/strong[contains(normalize-space(.), 'NO TÉ AUTORITZACIÓ')]" not exists
body not contains "/usuaris/login/"
body not contains "/sortides/passarella/"


# passarella amb Bearer no ha de redirigir al login web (com fa el WebView)
# ------------------------------------------------------------------------------
GET https://{{host}}/sortides/passarella/{{idPagament}}/
Authorization: Bearer {{token}}
[Options]
location-trusted: true

HTTP 200

[Asserts]
url not contains "/usuaris/login/"
body not contains "/usuaris/login/"
