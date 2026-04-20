
# Comprova que un usuari logejat pot demanar si hi ha novetats i que
# si hi ha, respon que sí. Per fer-ho, envia una data de darrera sincronització
# molt antiga (2022-11-18 12:00:13) i comprova que el resultat és "Sí"
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



POST https://{{host}}/api/token/notificacions/news/
Content-Type: application/json
Authorization: Bearer {{token}}
{
    "last_sync_date": "2022-11-18 12:00:13"
}


HTTP 200
[Asserts]
jsonpath "$.resultat" == "Sí"