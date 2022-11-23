include .env

start: # start an instance
	limactl start $(LIMA_NAME)
stop: # stop an instance
	limactl stop $(LIMA_NAME)
list: # list instances
	limactl list
shell: # execute shell
	limactl shell $(LIMA_NAME)

.PHONY: start stop list shell

up: # create a new instance
	if [ -e $(LIMA_NAME).yaml ]; then \
		printf '? overwrite [y/N] ' && read yn && [ "$$yn" = 'y' ]; \
	fi
	curl -fsSL $(DOCKER_CONFIG_URL) \
	| sed -e 's/\(^\- location: "~"$$\)/\1\n  writable: true/' \
	| awk '{print;} END{print "ssh:\n  loadDotSSHPubKeys: false\n  localPort: $(SSH_PORT)";}' \
	| awk '{print;} END{print "cpus: 4\nmemory: \"8GiB\"\ndisk: \"100GiB\"";}' \
	| tee $(LIMA_NAME).yaml
	limactl start $(LIMA_NAME).yaml
	docker_host="DOCKER_HOST=unix://\$$HOME/.lima/$(LIMA_NAME)/sock/docker.sock" \
	&& sed -i '' -e "/^export DOCKER_HOST=/d" $(PROFILE) \
	&& echo "export $$docker_host" | tee -a $(PROFILE) \
	&& export $$docker_host

alpine: # create an alpine container
	limactl shell $(LIMA_NAME) docker run -d -it --rm  -v $$HOME:$$HOME alpine:latest

ssh-keyadd: # add the public key for ssh connection
	ssh -A \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-i $(LIMA_SSH_PRIVATE_KEY) \
		-p $(SSH_PORT) \
		$$USER@127.0.0.1 \
		"printf '$$(cat $(SSH_PUBLIC_KEY))' > ~/.authorized_keys"

ssh: # ssh connection with the private key
	ssh -A \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-i $(SSH_PRIVATE_KEY) \
		-p $(SSH_PORT) \
		$$USER@127.0.0.1

ssh-forward: # port forwarding for external connections
	ssh -A \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-i $(SSH_PRIVATE_KEY) \
		-p $(SSH_PORT) \
		$$USER@127.0.0.1 \
		-g \
		$$(for p in $(SSH_FORWARD_PORTS); do \
			from=$$(echo $$p | cut -d':' -f1); \
			to=$$(echo $$p | cut -d':' -f2); \
			printf ' -L %d:127.0.0.1:%d ' $$from $${to:-$$from}; \
		done)

.PHONY: up alpine ssh-keyadd ssh ssh-forward

help: # list available targets and some
	@len=$$(awk -F':' 'BEGIN {m = 0;} /^[^\s]+:/ {gsub(/%/, "<service>", $$1); l = length($$1); if(l > m) m = l;} END {print m;}' $(MAKEFILE_LIST)) && \
	printf "%s%s\n\n%s\n%s\n" \
		"usage:" \
		"$$(printf " make <\033[1mtarget\033[0m>")" \
		"targets:" \
		"$$(awk -F':' '/^[^ ]+:/ {gsub(/%/, "<service>", $$1); gsub(/^[^#]+/, "", $$2); gsub(/^[# ]+/, "", $$2); if ($$2) printf "  \033[1m%-'$$len's\033[0m  %s\n", $$1, $$2;}' $(MAKEFILE_LIST))"

.PHONY: help
