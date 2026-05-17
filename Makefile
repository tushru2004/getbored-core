.PHONY: agents-api-wake agents-wake-api agents-api-wake-kill agents-wake-api-kill

agents-api-wake: ## Start isolated API-wake cmux agent workspace
	~/Agents-api-wake/configs/getbored/cmux-api-wake-up

agents-wake-api: agents-api-wake ## Alias for agents-api-wake

agents-api-wake-kill: ## Kill isolated API-wake cmux agent workspace
	~/Agents-api-wake/configs/getbored/cmux-api-wake-up --kill

agents-wake-api-kill: agents-api-wake-kill ## Alias for agents-api-wake-kill
