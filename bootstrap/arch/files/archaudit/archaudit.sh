#!/bin/bash -
# copy this file to /usr/local/sbin (or any other $PATH location)

# ensure exits
VAR_FILE="/var/cache/pacman/archaudit.sha1sum"
MAIL_TO="root"
HOST=$(uname -n)
PKGMGR=$(which pacman)
AUDIT=$(which arch-audit)

if [[ ! -f ${VAR_FILE} ]]; then
        mkdir $(dirname ${VAR_FILE})
        touch ${VAR_FILE}
fi

# syncs and downloads all packages, without asking
${PKGMGR} -Sy --noconfirm > /dev/null
PKGLIST=$(${AUDIT} -u)
SHA_NEW=$(echo "$PKGLIST" | sha1sum | cut -d" " -f1)
SHA_OLD=$(cat ${VAR_FILE})

if [[ ${SHA_NEW} != ${SHA_OLD} && ${PKGLIST} != "" ]]; then
        MSG="The following packages have security updates available:\n\r\n\r${PKGLIST}\r\n\r\nSincerely yours arch-audit\r\n"
        echo -e "${MSG}" | mail -s "Security updates available on ${HOST}" -q /dev/stdin ${MAIL_TO}
        echo ${SHA_NEW} > ${VAR_FILE}
fi
