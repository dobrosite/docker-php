#!/bin/bash

# Корневая папка проекта.
project_dir=$(readlink -f $(dirname "$0"))
# Папка тестов.
tests_dir="${project_dir}/tests"

force_build=0
if [[ "${1}" == '--build' ]]; then
    force_build=1
fi

##
# Собирает образ Docker.
#
# @param $1 Имя образа.
# @param $2 Папка контекста для образа.
#
function build_image
{
    local image=${1}
    local folder=${2}

    if ! docker build --tag ${image} "${folder}"; then
        echo "ОШИБКА: Не удалось собрать образ \"${image}\"!"
        exit 150
    fi
}

#versions=$(find "${project_dir}" -maxdepth 1 -name '?.?' -printf '%f ')
versions='7.3'
for version in ${versions}; do
    folders=$(find "${project_dir}/${version}" -name Dockerfile -printf '%h ')
    for folder in ${folders}; do
        image=${folder/${project_dir}\//}
        image="docker-php-${image//\//-}"

        if ! docker image inspect ${image} >/dev/null; then
            echo '----------------------------------------------------------'
            echo " Образ ${image} не найден, собираю..."
            echo '----------------------------------------------------------'
            build_image ${image} "${folder}"
            echo 'Образ успешно собран.'
        elif [[ ${force_build} -eq 1 ]]; then
            build_image ${image} "${folder}"
        fi

        echo '----------------------------------------------------------'
        echo " Выполняю тесты для ${image}..."
        echo '----------------------------------------------------------'
        docker run --volume="${project_dir}/tests:/usr/local/tests:ro"  ${image} /usr/local/tests/tests.sh
    done
done

#if [[ ${failed_tests_count} -ne 0 ]]; then
#    echo "Провалено тестов: ${failed_tests_count}."
#    exit 1
#fi

#echo 'Все тесты успешно выполнены.'
