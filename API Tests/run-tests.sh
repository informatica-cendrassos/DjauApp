#!/bin/bash

# ============================================================================
# Executa els tests Hurl de l'API del Djau
#
# Ús: ./run-tests.sh [--verbose] [--show-response] [--server test|production] [domini|fitxer.hurl ...]
#
# Exemples:
#   ./run-tests.sh                         # executa tots els tests
#   ./run-tests.sh --verbose               # executa tots els tests amb sortida detallada de hurl
#   ./run-tests.sh --show-response         # mostra les respostes de l'API
#   ./run-tests.sh --server test news      # executa els tests al servidor de proves
#   ./run-tests.sh --server production     # executa els tests al servidor de producció
#   ./run-tests.sh news                    # executa els tests del domini 'news'
#   ./run-tests.sh profile news            # executa els dominis 'profile' i 'news'
#   ./run-tests.sh profile/profile-ok.hurl # executa un sol test
# ============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VARS_FILE="${SCRIPT_DIR}/vars.env"

# Parseja flags opcionals i conserva els objectius de test
verbose_enabled=false
show_response_enabled=false
server_host=""
target_args=()
while (($#)); do
    case "$1" in
        --verbose) verbose_enabled=true ;;
        --show-response) show_response_enabled=true ;;
        --server)
            if (($# < 2)); then
                echo "Error: cal indicar un servidor: test o production." >&2
                exit 1
            fi
            case "$2" in
                test) server_host="djauproves.cendrassos.net" ;;
                production) server_host="djau.cendrassos.net" ;;
                *)
                    echo "Error: servidor '$2' desconegut; tria test o production." >&2
                    exit 1
                    ;;
            esac
            shift
            ;;
        *) target_args+=("$1") ;;
    esac
    shift
done

# Comprova que hurl és accessible
if ! command -v hurl &> /dev/null; then
    echo "Error: 'hurl' no s'ha trobat al PATH." >&2
    exit 1
fi

# Comprova que existeix el fitxer de variables
if [[ ! -f "${VARS_FILE}" ]]; then
    echo "Error: no s'ha trobat el fitxer '${VARS_FILE}'." >&2
    exit 1
fi

if [[ -n "${server_host}" ]]; then
    echo "Servidor: ${server_host}"
fi

# Demana les credencials de forma interactiva
read -rp "Usuari: " username
read -rsp "Contrasenya: " password
echo

# Determina quins tests cal executar
if [[ ${#target_args[@]} -eq 0 ]]; then
    # Per defecte: tots els tests de tots els subdirectoris
    mapfile -t test_targets < <(find "${SCRIPT_DIR}" -mindepth 2 -maxdepth 2 -name "*.hurl" | sort)
else
    # Construeix la llista de fitxers a partir dels arguments
    test_targets=()
    for arg in "${target_args[@]}"; do
        # Si l'argument és un fitxer .hurl directament
        if [[ "${arg}" == *.hurl ]]; then
            test_targets+=("${SCRIPT_DIR}/${arg}")
        else
            # Tracta-ho com a nom de directori (domini)
            mapfile -t domain_files < <(find "${SCRIPT_DIR}/${arg}" -maxdepth 1 -name "*.hurl" 2>/dev/null | sort)
            if [[ ${#domain_files[@]} -eq 0 ]]; then
                echo "Avís: no s'han trobat tests a '${arg}'." >&2
            fi
            test_targets+=("${domain_files[@]}")
        fi
    done
fi

if [[ ${#test_targets[@]} -eq 0 ]]; then
    echo "Error: no s'han trobat fitxers .hurl per executar." >&2
    exit 1
fi

echo "============================================================================"
echo "Executant ${#test_targets[@]} test(s)..."
echo "============================================================================"

# Marca les credencials interactives com a secretes perquè Hurl les oculti amb --very-verbose.
hurl_password_variable=password
hurl_args=(
    --test
    --variables-file "${VARS_FILE}"
    --secret "username=${username}"
    --secret "${hurl_password_variable}=${password}"
    --error-format=long
)

if [[ -n "${server_host}" ]]; then
    hurl_args+=(--variable "host=${server_host}")
fi

if [[ "${show_response_enabled}" == true ]]; then
    hurl_args+=(--very-verbose)
elif [[ "${verbose_enabled}" == true ]]; then
    hurl_args+=(--verbose)
fi

hurl "${hurl_args[@]}" \
    "${test_targets[@]}"
