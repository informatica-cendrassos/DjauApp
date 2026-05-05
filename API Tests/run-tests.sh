#!/bin/bash

# ============================================================================
# Executa els tests Hurl de l'API del Djau
#
# Ús: ./run-tests.sh [--verbose] [domini|fitxer.hurl ...]
#
# Exemples:
#   ./run-tests.sh                         # executa tots els tests
#   ./run-tests.sh --verbose               # executa tots els tests amb sortida detallada de hurl
#   ./run-tests.sh news                    # executa els tests del domini 'news'
#   ./run-tests.sh profile news            # executa els dominis 'profile' i 'news'
#   ./run-tests.sh profile/profile-ok.hurl # executa un sol test
# ============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VARS_FILE="${SCRIPT_DIR}/vars.env"

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

# Demana les credencials de forma interactiva
read -rp "Usuari: " username
read -rsp "Contrasenya: " password
echo

# Parseja flags opcionals i conserva els objectius de test
verbose_enabled=false
target_args=()
for arg in "$@"; do
    if [[ "${arg}" == "--verbose" ]]; then
        verbose_enabled=true
    else
        target_args+=("${arg}")
    fi
done

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

# Executa hurl amb les credencials injectades per variable
hurl_args=(
    --test
    --variables-file "${VARS_FILE}"
    --variable "username=${username}"
    --secret "password=${password}"
    --error-format=long
)

if [[ "${verbose_enabled}" == true ]]; then
    hurl_args+=(--verbose)
fi

hurl "${hurl_args[@]}" \
    "${test_targets[@]}"
