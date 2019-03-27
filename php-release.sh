#!/usr/bin/env bash
##
## Возвращает сведения о выпуске запрошенной версии PHP.
##

PHP_VERSION=${1}

if [[ "${PHP_VERSION}" == '' ]]; then
	echo 'Не указана версия PHP.'
	exit 129
fi

url="https://secure.php.net/releases/index.php?json&max=200&version=${PHP_VERSION}"
jqExpr='
(keys[] | select(startswith("'"${PHP_VERSION}"'."))) as $version
| [ $version, (
	.[$version].source[]
	| select(.filename // "" | endswith(".xz") // endswith(".bz2"))
	|
		"https://secure.php.net/get/" + .filename + "/from/this/mirror",
		"https://secure.php.net/get/" + .filename + ".asc/from/this/mirror",
		.sha256 // "",
		.md5 // "",
		.filename
) ]
'

IFS=$'\n'
possibles=( $(
	curl -fsSL "${url}" \
		| jq --raw-output "${jqExpr} | @sh" \
		| sort -rV
) )
unset IFS

if [[ "${#possibles[@]}" -eq 0 ]]; then
	echo >&2 "ОШИБКА: не удалось найти доступные для загрузки выпуски PHP ${PHP_VERSION}."
	exit 30
fi

eval "possible=( ${possibles[0]} )"

fullVersion="${possible[0]}"
url="${possible[1]}"
ascUrl="${possible[2]}"
sha256="${possible[3]}"
md5="${possible[4]}"
filename=$(basename "${possible[5]}")

echo "DISTRIB_RELEASE=${fullVersion}"
echo "DISTRIB_URL_ASC=${ascUrl}"
echo "DISTRIB_URL=${url}"
echo "DISTRIB_SHA256=${sha256}"
echo "DISTRIB_MD5=${md5}"
echo "DISTRIB_FILENAME=${filename}"
