#! /bin/bash
i=0
until git pull --rebase origin ${DEFAULT_BRANCH} > /dev/null && git push origin ${DEFAULT_BRANCH} > /dev/null; do
    if [[ "$i" -gt 5 ]]; then
        echo "Please check git permissions."
        exit 1
    fi
    sleep 5
    ((i=i+1))
done
