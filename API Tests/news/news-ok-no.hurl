
# Comprova que un usuari logejat si no hi ha novetats respon que no. 
# per fer-ho, envia una data de darrera sincronització molt avançada 
# (2522-11-18 12:00:13) i comprova que el resultat és "No"
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



POST https://{{host}}/api/token/notificacions/news/{{IdAlumneIncorrecte}}/
Content-Type: application/json
Authorization: Bearer {{token}}
{
    "last_sync_date": "2522-11-18 12:00:13"
}


HTTP 200
[Asserts]
jsonpath "$.resultat" == "No"