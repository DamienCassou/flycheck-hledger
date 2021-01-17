ELPA_DEPENDENCIES=package-lint flycheck dash

ELPA_ARCHIVES=melpa gnu

LINT_CHECKDOC_FILES=flycheck-hledger.el
LINT_PACKAGE_LINT_FILES=flycheck-hledger.el
LINT_COMPILE_FILES=flycheck-hledger.el

makel.mk:
	# Download makel
	@if [ -f ../makel/makel.mk ]; then \
		ln -s ../makel/makel.mk .; \
	else \
		curl \
		--fail --silent --show-error --insecure --location \
		--retry 9 --retry-delay 9 \
		-O https://gitlab.petton.fr/DamienCassou/makel/raw/v0.6.0/makel.mk; \
	fi

# Include makel.mk if present
-include makel.mk
