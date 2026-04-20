# Comprova que es pot fer login amb un usuari correcte
# ==============================================================================

POST https://{{host}}/api-token-auth/
Content-Type: application/json
{
	"username": "{{username}}",
	"password": "{{password}}"
}

# La resposta ha de ser 200 OK i ha de contenir un token d'accés i un de refresh
# {
#   "access":"eyJhbGciOiJaYSfd1S...-AuT7lU",
#   "refresh":"eyJhbGciOi...6HFRt7Rh4"
# }

HTTP 200
[Captures]
token: jsonpath "$.access"
[Asserts]
header "Content-Type" == "application/json"
jsonpath "$.access" exists
jsonpath "$.access" != ""
jsonpath "$.refresh" exists
jsonpath "$.refresh" != ""
