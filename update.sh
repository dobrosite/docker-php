#!/bin/bash
set -e

declare -A gpgKeys
gpgKeys=(
#	['7.0']='1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763'
#	['5.6']='0BD78B5F97500D450838F95DFE857D9A90D90EC1 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3'
#	['5.5']='0B96609E270F565C13292B24C13C70B87267B52D 0BD78B5F97500D450838F95DFE857D9A90D90EC1 F38252826ACD957EF380D39F2F7956BC5DA04B5D'
	['5.4']='F38252826ACD957EF380D39F2F7956BC5DA04B5D'
	['5.3']='0A95E9A026542D53835E3F3A7DEC4E69FC9C83D7 0B96609E270F565C13292B24C13C70B87267B52D'
)
# see http://php.net/downloads.php

cd $(dirname "$(readlink -f "${BASH_SOURCE}")")

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )


packagesUrl='http://php.net/releases/index.php?serialize=1&version=5&max=100'
packages=$(echo "$packagesUrl" | sed -r 's/[^a-zA-Z.-]+/-/g')

curl -sSL "${packagesUrl}" > "$packages"

for version in "${versions[@]}"; do
#	fullVersion=''
#	for comp in xz bz2; do
#		fullVersion="$(sed 's/;/;\n/g' $packages | grep -e 'php-'"$version"'.*\.tar\.'"$comp" | sed -r 's/.*php-('"$version"'[^"]+)\.tar\.'"$comp"'.*/\1/' | sort -V | tail -1)"
#		if [ "$fullVersion" ]; then
#			break
#		fi
#	done
#
#	gpgKey="${gpgKeys[$version]}"
#	if [ -z "$gpgKey" ]; then
#		echo >&2 "ERROR: missing GPG key fingerprint for $version"
#		echo >&2 "  try looking on http://php.net/downloads.php#gpg-$version"
#		exit 1
#	fi

	( set -x; cp docker-php-* "$version/" )

	for variant in apache; do
#		echo "Generating $version/$variant/Dockerfile from $variant-Dockerfile-block-*"
#		awk '
#			$1 == "##</autogenerated>##" { ia = 0 }
#			!ia { print }
#			$1 == "##<autogenerated>##" { ia = 1; ab++; ac = 0 }
#			ia { ac++ }
#			ia && ac == 1 { system("cat '$variant'-Dockerfile-block-" ab) }
#		' "$version/Dockerfile" > "$version/$variant/Dockerfile"
		( set -x; cp docker-php-* "$version/$variant/" )
	done

#	if [ -z "$fullVersion" ]; then
#		echo >&2 "ERROR: missing $version in $packagesUrl"
#		continue
#	fi
#
#	(
#		set -x
#		sed -ri '
#			s/^(ENV PHP_VERSION) .*/\1 '"$fullVersion"'/;
#			s/^(ENV GPG_KEYS) [0-9a-fA-F ]*$/\1 '"$gpgKey"'/
#		' "$version/Dockerfile" "$version/"*/Dockerfile
#	)
done

rm ${packages}
