SCRIPT_NAME_INSTALL_SKINNYWMS=Install SkinnyWMS
SCRIPT_NAME_INSTALL_MAGICS=Install ecCodes and Magics
SCRIPT_NAME_INSTALL_POLYTOPE=Install Polytope
BLUEPRINT_NAME=SkinnyWMS on Ubuntu

ifeq (${INSTANCE_NAME},)
INSTANCE_NAME ?= skinnywms-000
#INSTANCE_NAME := $(shell read -p "Instance name: " pwd; echo $$pwd)
endif

KEY_GIT_USER=password/git-username
KEY_GIT_PASS=password/git-access-token
KEY_POLYTOPE_USERNAME:=password/polytope-client-user
KEY_POLYTOPE_CLIENT_TOKEN:=password/polytope-client-token

default: install

.PHONY: echo login create-instance install cleanup cleanup-workflows cleanup-tasks cleanup-scripts create-secrets create-scripts create-tasks create-workflows

install: createxw-tasks create-workflows create-blueprints
re-install: cleanup create-tasks create-workflows create-blueprints
cleanup: cleanup-blueprints cleanup-workflows cleanup-tasks

create-instance:
	@morpheus instances add --name "${INSTANCE_NAME}" --payload ./morpheus/instance.json

setup-cloud:
	@morpheus remote add european-weather-cloud https://morpheus.ecmwf.int/ --insecure
	@morpheus remote use european-weather-cloud

login:
	@echo "Hint: If you use a subtenant account, your username is <subtenancy>\<username>, e.g. 'dwd\mmuster'"
	@morpheus login --insecure


create-secrets:
# this will be obsolete in the future once
# the aviso package is available on pypi.org
	@echo "creating/updating secret '${KEY_GIT_USER}'"
	@{ \
	if [ -n "${GIT_USERNAME}" ]; then \
		morpheus cypher put ${KEY_GIT_USER} ${GIT_USERNAME} --ttl 86400000 -y -q; \
	else \
		read -p "username for 'https://git.ecmwf.int': " pwd; \
		morpheus cypher put ${KEY_GIT_USER} $$pwd --ttl 86400000 -y -q; \
	fi \
	}
	@echo "creating/updating secret '${KEY_GIT_PASS}'"
	@{ \
	if [ -n "${GIT_ACCESS_TOKEN}" ]; then \
		morpheus cypher put ${KEY_GIT_PASS} ${GIT_ACCESS_TOKEN} --ttl 86400000 -y -q; \
	else \
		read -s -p "access token or password: " pwd; \
		morpheus cypher put ${KEY_GIT_PASS} $$pwd --ttl 86400000 -y -q; \
	fi \
	}
	@echo ""

cleanup-secrets:
	@echo "Cleaning up secret '${KEY_GIT_USER}'"
	-@(morpheus cypher list | grep '${KEY_GIT_USER}' > /dev/null) \
		&& morpheus cypher remove "${KEY_GIT_USER}" -y \
		|| echo "Nothing to clean up."
	@echo "Cleaning up secret '${KEY_GIT_PASS}'"
	-@(morpheus cypher list | grep '${KEY_GIT_PASS}' > /dev/null) \
		&& morpheus cypher remove "${KEY_GIT_PASS}" -y \
		|| echo "Nothing to clean up."

create-secrets-polytope:
	@echo "creating/updating secret '${KEY_POLYTOPE_USERNAME}'"
	@{ \
	if [ -n "${POLYTOPE_USERNAME}" ]; then \
		morpheus cypher put ${KEY_POLYTOPE_USERNAME} ${POLYTOPE_USERNAME} --ttl 86400000 -y -q; \
	else \
		read -p "username for 'https://git.ecmwf.int': " pwd; \
		morpheus cypher put ${KEY_POLYTOPE_USERNAME} $$pwd --ttl 86400000 -y -q; \
	fi \
	}
	@echo "creating/updating secret '${KEY_POLYTOPE_CLIENT_TOKEN}'"
	@{ \
	if [ -n "${POLYTOPE_CLIENT_TOKEN}" ]; then \
		morpheus cypher put ${KEY_POLYTOPE_CLIENT_TOKEN} ${POLYTOPE_CLIENT_TOKEN} --ttl 86400000 -y -q; \
	else \
		read -s -p "polytope client token: " pwd; \
		morpheus cypher put ${KEY_POLYTOPE_CLIENT_TOKEN} $$pwd --ttl 86400000 -y -q; \
	fi \
	}
	@echo ""

cleanup-secrets-polytope:
	@echo "Cleaning up secret '${KEY_POLYTOPE_USERNAME}'"
	-@(morpheus cypher list | grep '${KEY_POLYTOPE_USERNAME}' > /dev/null) \
		&& morpheus cypher remove "${KEY_POLYTOPE_USERNAME}" -y \
		|| echo "Nothing to clean up."
	@echo "Cleaning up secret '${KEY_POLYTOPE_CLIENT_TOKEN}'"
	-@(morpheus cypher list | grep '${KEY_POLYTOPE_CLIENT_TOKEN}' > /dev/null) \
		&& morpheus cypher remove "${KEY_POLYTOPE_CLIENT_TOKEN}" -y \
		|| echo "Nothing to clean up."

create-tasks:
	@echo "Adding task '${SCRIPT_NAME_INSTALL_SKINNYWMS}'"
	@(morpheus tasks list | grep '${SCRIPT_NAME_INSTALL_SKINNYWMS}' > /dev/null) \
		&& echo "Script '${SCRIPT_NAME_INSTALL_SKINNYWMS}' already exists." \
		|| morpheus tasks add \
				--name "${SCRIPT_NAME_INSTALL_SKINNYWMS}" \
				--type "script" \
				--code "install-SKINNYWMS" \
				--file ./morpheus/install.sh \
				--no-prompt
	@echo "Adding task '${SCRIPT_NAME_INSTALL_MAGICS}'"
	@(morpheus tasks list | grep '${SCRIPT_NAME_INSTALL_MAGICS}' > /dev/null) \
		&& echo "Script '${SCRIPT_NAME_INSTALL_MAGICS}' already exists." \
		|| morpheus tasks add \
				--name "${SCRIPT_NAME_INSTALL_MAGICS}" \
				--type "script" \
				--code "install-eccodes-magics" \
				--file ./morpheus/install_magics.sh \
				--no-prompt
	@(morpheus tasks list | grep '${SCRIPT_NAME_INSTALL_POLYTOPE}' > /dev/null) \
		&& echo "Script '${SCRIPT_NAME_INSTALL_POLYTOPE}' already exists." \
		|| morpheus tasks add \
				--name "${SCRIPT_NAME_INSTALL_POLYTOPE}" \
				--type "script" \
				--code "install-polytope" \
				--file ./morpheus/install_polytope.sh \
				--no-prompt
	

cleanup-tasks:
	@echo "Cleaning up task '${SCRIPT_NAME_INSTALL_SKINNYWMS}'"
	-@(morpheus tasks list | grep '${SCRIPT_NAME_INSTALL_SKINNYWMS}' > /dev/null) \
		&& morpheus tasks remove "${SCRIPT_NAME_INSTALL_SKINNYWMS}" -y \
		|| echo "Nothing to clean up."
	@echo "Cleaning up task '${SCRIPT_NAME_INSTALL_MAGICS}'"
	-@(morpheus tasks list | grep '${SCRIPT_NAME_INSTALL_MAGICS}' > /dev/null) \
		&& morpheus tasks remove "${SCRIPT_NAME_INSTALL_MAGICS}" -y \
		|| echo "Nothing to clean up."

cleanup-workflows:
	@echo "Cleaning up workflow '${SCRIPT_NAME_INSTALL_SKINNYWMS}'"
	-@(morpheus workflows list | grep '${SCRIPT_NAME_INSTALL_SKINNYWMS}' > /dev/null) \
		&& echo "Unfortunately removing workflow fails with: Error Communicating with the Appliance. 500 Internal Server Error" \
		&& echo "Please remove workflow '${SCRIPT_NAME_INSTALL_SKINNYWMS}' manually" \
		&& morpheus workflows remove "${SCRIPT_NAME_INSTALL_SKINNYWMS}" -y \
		|| echo "Nothing to clean up."

create-workflows:
	@echo "Creating/updating workflow '${SCRIPT_NAME_INSTALL_SKINNYWMS}'"
	-@(morpheus workflows list | grep '${SCRIPT_NAME_INSTALL_SKINNYWMS}' > /dev/null) \
		&& morpheus workflows update "${SCRIPT_NAME_INSTALL_SKINNYWMS}" --tasks "${SCRIPT_NAME_INSTALL_SKINNYWMS}","${SCRIPT_NAME_INSTALL_POLYTOPE}" \
		|| morpheus workflows add "${SCRIPT_NAME_INSTALL_SKINNYWMS}" --tasks "${SCRIPT_NAME_INSTALL_SKINNYWMS}","${SCRIPT_NAME_INSTALL_POLYTOPE}"

create-blueprints:
	@echo "Adding blueprint '${BLUEPRINT_NAME}'"
	@(morpheus blueprints list | grep '${BLUEPRINT_NAME}' > /dev/null) \
		&& echo "Blueprint '${BLUEPRINT_NAME}' already exists." \
		|| morpheus blueprints add \
				--name "${BLUEPRINT_NAME}" \
				--payload ./morpheus/blueprint.yaml

cleanup-blueprints:
	@echo "Cleaning up blueprint '${BLUEPRINT_NAME}'"
	-@(morpheus blueprints list | grep '${BLUEPRINT_NAME}' > /dev/null) \
		&& morpheus blueprints remove "${BLUEPRINT_NAME}" -y \
		|| echo "Nothing to clean up."

run-workflows:
	@morpheus instances run-workflow "${INSTANCE_NAME}" "${SCRIPT_NAME_INSTALL_SKINNYWMS}"