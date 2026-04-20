
# No podem entrar si l'usuari o la contasenya no són correctes

POST https://{{host}}/api-token-auth/
Content-Type: application/json
{
	"username": "{{username}}",
	"password": "{{badPassword}}"
}

HTTP 401
[Asserts]
header "Content-Type" == "application/json"
jsonpath "$.detail" exists
jsonpath "$.detail" == "No active account found with the given credentials"

