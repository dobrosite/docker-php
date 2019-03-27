version-patch:
	sed -ri 's/xdebug-%%XDEBUG_VERSION%%/xdebug-2.7.0beta1/g' $(CONTEXT_DIR)/Dockerfile

#sed -ri '/libmysqld-dev/d' "${Dockerfile}"
#sed -ri '/lemon/d' "${Dockerfile}"

#sed -ri '/--with-pdo_sqlite3/d' "${Dockerfile}"
#		--with-pdo_sqlite3=shared,/usr \

#sed -ri '/--with-sqlite\W/d' "${Dockerfile}"
#		--with-sqlite3=shared \
