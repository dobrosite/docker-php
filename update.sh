#!/usr/bin/env bash
##
## Этот файл создан на основе https://github.com/docker-library/php/blob/master/update.sh.
##

set -e

# https://secure.php.net/gpg-keys.php
declare -A gpgKeys=(
	# https://secure.php.net/downloads.php#gpg-7.3
	# https://secure.php.net/gpg-keys.php#gpg-7.3
	['7.3']='CBAF69F173A0FEA4B537F470D66C9593118BCCB6 F38252826ACD957EF380D39F2F7956BC5DA04B5D'

	# https://secure.php.net/downloads.php#gpg-7.2
	# https://secure.php.net/gpg-keys.php#gpg-7.2
	['7.2']='1729F83938DA44E27BA0F4D3DBDB397470D12172 B1B44D8F021E4E2D6021E995DC9FF8D3EE5AF27F'

	# https://secure.php.net/downloads.php#gpg-7.1
	# https://secure.php.net/gpg-keys.php#gpg-7.1
	['7.1']='A917B1ECDA84AEC2B568FED6F50ABC807BD5DCD0 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E 1729F83938DA44E27BA0F4D3DBDB397470D12172'

	# https://secure.php.net/downloads.php#gpg-7.0
	# https://secure.php.net/gpg-keys.php#gpg-7.0
	['7.0']='1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3'

	# https://secure.php.net/downloads.php#gpg-5.6
	# https://secure.php.net/gpg-keys.php#gpg-5.6
	['5.6']='0BD78B5F97500D450838F95DFE857D9A90D90EC1 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3'

	# https://secure.php.net/gpg-keys.php#gpg-5.5
	['5.5']='0B96609E270F565C13292B24C13C70B87267B52D 0BD78B5F97500D450838F95DFE857D9A90D90EC1 F38252826ACD957EF380D39F2F7956BC5DA04B5D'

	# https://secure.php.net/gpg-keys.php#gpg-5.4
	['5.4']='F38252826ACD957EF380D39F2F7956BC5DA04B5D'

	# https://secure.php.net/gpg-keys.php#gpg-5.3
	['5.3']='0A95E9A026542D53835E3F3A7DEC4E69FC9C83D7 0B96609E270F565C13292B24C13C70B87267B52D'

)
# see https://secure.php.net/downloads.php

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

if ! which jq >/dev/null 2>/dev/null; then
    echo 'ОШИБКА: Не найдена утилита jq. См. http://stedolan.github.io/jq/'
    exit 129
fi

versions=$(find . -maxdepth 1 -name '?.?' -printf '%f ')

generated_warning() {
	cat <<-EOH
		##
		## ВНИМАНИЕ! Этот файл создаётся сценарием "update.sh".
		## Не меняйте его вручную — он будет перезаписан.
		##

	EOH
}

for version in ${versions}; do

    echo '========='
    echo " PHP ${version}"
    echo '========='

	rcVersion="${version%-rc}"

	# "7" для "7.x", "5" для "5.x" и т. д.
	majorVersion="${rcVersion%%.*}"
	# "2" для "x.2" и т. д.
	minorVersion="${rcVersion#$majorVersion.}"
	minorVersion="${minorVersion%%.*}"
	# Идентификатор версии вида 70300.
	versionId="${majorVersion}$(printf '%02d' ${minorVersion})00"

	# scrape the relevant API based on whether we're looking for pre-releases
	apiUrl="https://secure.php.net/releases/index.php?json&max=200&version=${rcVersion%%.*}"
	apiJqExpr='
		(keys[] | select(startswith("'"$rcVersion"'."))) as $version
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
	if [[ "$rcVersion" != "$version" ]]; then
		apiUrl='https://qa.php.net/api.php?type=qa-releases&format=json'
		apiJqExpr='
			.releases[]
			| select(.version | startswith("'"$rcVersion"'."))
			| [
				.version,
				.files.xz.path // "",
				"",
				.files.xz.sha256 // "",
				.files.xz.md5 // ""
			]
		'
	fi

	echo "Ищу последнюю версию PHP ${version}..."

	IFS=$'\n'
	possibles=( $(
		curl -fsSL "$apiUrl" \
			| jq --raw-output "$apiJqExpr | @sh" \
			| sort -rV
	) )
	unset IFS

	if [[ "${#possibles[@]}" -eq 0 ]]; then
		echo >&2
		echo >&2 "error: unable to determine available releases of $version"
		echo >&2
		exit 1
	fi

	# format of "possibles" array entries is "VERSION URL.TAR.XZ URL.TAR.XZ.ASC SHA256 MD5" (each value shell quoted)
	#   see the "apiJqExpr" values above for more details
	eval "possible=( ${possibles[0]} )"

	fullVersion="${possible[0]}"
	echo "Последняя версия: ${fullVersion}"
	url="${possible[1]}"
	echo "URL: ${url}"
	ascUrl="${possible[2]}"
	sha256="${possible[3]}"
	echo "SHA256: ${sha256}"
	md5="${possible[4]}"
	echo "MD5: ${md5}"
	filename="${possible[5]}"
	echo "Имя файла: ${filename}"


	gpgKey="${gpgKeys[$rcVersion]}"
	if [[ -z "$gpgKey" ]]; then
		echo >&2 "ERROR: missing GPG key fingerprint for $version"
		echo >&2 "  try looking on https://secure.php.net/downloads.php#gpg-$version"
		exit 1
	fi

	# if we don't have a .asc URL, let's see if we can figure one out :)
	if [[ -z "$ascUrl" ]] && wget -q --spider "$url.asc"; then
		ascUrl="$url.asc"
	fi

	dockerfiles=()

	for suite in buster stretch jessie; do
		[[ -d "${version}/${suite}" ]] || continue

		alpineVer="${suite#alpine}"

		baseDockerfile=Dockerfile.debian.template
		if [[ "${suite#alpine}" != "$suite" ]]; then
			baseDockerfile=Dockerfile.alpine.template
		fi

		for variant in apache; do
			targetPath="${version}/${suite}/${variant}"

			[[ -d "${targetPath}" ]] || continue

			echo '-----------------------'
			echo "Собираю ${targetPath}:"
            echo "• PHP ${fullVersion}"
            echo "• ОС: ${suite}"
            echo "• Вариант: ${variant}"
            echo

			echo "→ Удаляю старые файлы..."
			rm -r "${targetPath}"/*
			find "${targetPath}" -mindepth 1 -type d -exec rm -v {} \;

			Dockerfile="${version}/${suite}/${variant}/Dockerfile"

			echo "→ Создаю ${Dockerfile} из ${baseDockerfile} + Dockerfile.${variant}.block-*"
			{ generated_warning; cat "$baseDockerfile"; } > "${Dockerfile}"

			gawk -i inplace -v variant="$variant" '
				$1 == "##</autogenerated>##" { ia = 0 }
				!ia { print }
				$1 == "##<autogenerated>##" { ia = 1; ab++; ac = 0; if (system("test -f Dockerfile." variant ".block-" ab) != 0) { ia = 0 } }
				ia { ac++ }
				ia && ac == 1 { system("cat Dockerfile." variant ".block-" ab) }
			' "${Dockerfile}"

			echo '→ Копирую общие файлы...'
			cp -r context/common/* "${targetPath}/"

			echo '→ Копирую файлы Apache...'
			cp -rf context/apache/* "${targetPath}/"

			echo '→ Меняю Dockerfile с учётом ОС и версии PHP:'
			if [[ ${versionId} -lt 70200 ]] || [[ "${suite}" = 'jessie' ]]; then
				echo '  ⋅ Удаляю argon2 (поддерживается начиная с 7.2 и Debian Stretch)'
				sed -ri '/argon2/d' "${Dockerfile}"
			fi

			if [[ ${suite} = 'stretch' ]]; then
				echo '  ⋅ Удаляю libicu-dev (в Debian Stretch она не требуется для сборки intl)'
				sed -ri '/libicu-dev/d' "${Dockerfile}"

				# PHP 5.x
				if [[ "$majorVersion" = '5' ]]; then
				echo '  ⋅ Удаляю libssl-dev и libssl1.0-dev'
					sed -ri 's!libssl-dev!libssl1.0-dev!g' "${Dockerfile}"
				fi
			fi

			if [[ ${suite} = 'buster' ]]; then
				echo '  ⋅ Для Debian Buster меняем версию библиотеки argon2'
				sed -ri 's!libargon2-0-dev!libargon2-dev!g' "${Dockerfile}"
				sed -ri 's!libargon2-0!libargon2-1!g' "${Dockerfile}"
			fi

			if (( ${versionId} >= 50400 )); then
				echo '  ⋅ Удаляю lemon и libmysqld-dev (начиная с PHP 5.4 уже не нужны)'
				sed -ri '/libmysqld-dev/d' "${Dockerfile}"
				sed -ri '/lemon/d' "${Dockerfile}"
				sed -ri '/--with-pdo_sqlite3/d' "${Dockerfile}"
				sed -ri '/--with-sqlite\W/d' "${Dockerfile}"
			fi

			if (( ${versionId} < 70200 )); then
				echo '  ⋅ Удаляю sodium (включено в ядро PHP начиная с 7.2)'
				sed -ri '/sodium/d' "${Dockerfile}"
			fi

			if (( ${versionId} >= 70000 )); then
				echo '  ⋅ Удаляю расширение mysql (удалено в PHP 7.0)'
				sed -ri '/--with-mysql=/d' "${Dockerfile}"
			fi

			if (( ${versionId} >= 70200 )); then
				echo '  ⋅ Удаляю mcrypt (удалено в PHP 7.2)'
				sed -ri '/mcrypt/d' "${Dockerfile}"
				sed -ri '/libmcrypt-dev/d' "${Dockerfile}"
			fi

			if (( ${versionId} < 50400 )); then
				sed -ri 's/xdebug-%%XDEBUG_VERSION%%/xdebug-2.2.7/g' "${Dockerfile}"
			elif (( ${versionId} < 50500 )); then
				sed -ri 's/xdebug-%%XDEBUG_VERSION%%/xdebug-2.4.1/g' "${Dockerfile}"
			elif (( ${versionId} < 70000 )); then
				sed -ri 's/xdebug-%%XDEBUG_VERSION%%/xdebug-2.5.5/g' "${Dockerfile}"
			elif (( ${versionId} >= 70300 )); then
				sed -ri 's/xdebug-%%XDEBUG_VERSION%%/xdebug-2.7.0beta1/g' "${Dockerfile}"
			else
				sed -ri 's/xdebug-%%XDEBUG_VERSION%%/xdebug/g' "${Dockerfile}"
			fi

			# Добавление «-slim» для всех версий Debian новее Jessie.
			# TODO always add slim once jessie is removed
			if [[ "${suite}" != 'jessie' ]]; then
				suite="${suite}-slim"
			fi

			sed -ri \
				-e 's!%%DEBIAN_SUITE%%!'"${suite}"'!' \
				-e 's!%%ALPINE_VERSION%%!'"$alpineVer"'!' \
				"${Dockerfile}"
			dockerfiles+=( "${Dockerfile}" )
		done
	done

	echo
	echo "Подставляю данные для скачивания в файлы: ${dockerfiles[@]}..."
	(
		set -x
		sed -ri \
			-e 's!%%PHP_VERSION%%!'"$fullVersion"'!' \
			-e 's!%%GPG_KEYS%%!'"$gpgKey"'!' \
			-e 's!%%PHP_URL%%!'"$url"'!' \
			-e 's!%%PHP_FILENAME%%!php.tar.'"$(expr match ${filename} '.*\.\(.*\)')"'!' \
			-e 's!%%PHP_ASC_URL%%!'"$ascUrl"'!' \
			-e 's!%%PHP_SHA256%%!'"$sha256"'!' \
			-e 's!%%PHP_MD5%%!'"$md5"'!' \
			"${dockerfiles[@]}"
	)

	echo '→ Обновляю входные точки...'
	for dockerfile in "${dockerfiles[@]}"; do
		cmd="$(awk '$1 == "CMD" { $1 = ""; print }' "$dockerfile" | tail -1 | jq --raw-output '.[0]')"
		entrypoint="$(dirname "$dockerfile")/usr/local/bin/docker-php-entrypoint"
		sed -i 's! php ! '"$cmd"' !g' "$entrypoint"
	done

	echo 'Готово.'
done
