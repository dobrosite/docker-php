#!/bin/bash

# Папка тестов.
tests_dir=$(readlink -f $(dirname "$0"))

failed_tests_count=0

filenames=$(find "${tests_dir}" -mindepth 2 -name '*.sh')
for filename in ${filenames}; do
    test_name=${filename/${tests_dir}\//}
    test_name=${test_name%.sh}
    echo "Проверяется: ${test_name}"
    if ! "${filename}"; then
        failed_tests_count=$((failed_tests_count+1))
    fi
done

if [[ ${failed_tests_count} -ne 0 ]]; then
    echo "Провалено тестов: ${failed_tests_count}."
    exit 1
fi

echo 'Все тесты успешно выполнены.'
