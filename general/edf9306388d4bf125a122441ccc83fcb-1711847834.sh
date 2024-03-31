#!/usr/bin/env bash

cd ~/Desktop || exit
if [[ -f "log.txt" ]]; then rm "log.txt"; fi

{
  echo "Installing dnscrypt-proxy"
  brew install --quiet dnscrypt-proxy || exit

  dnscrypt_conf=$(brew info dnscrypt-proxy | grep toml | head -n 1 | xargs)
  echo "dnscrypt-proxy config: ${dnscrypt_conf}"

  if [[ -f "${dnscrypt_conf}" ]]; then rm "${dnscrypt_conf}"; fi
  curl -fsSL https://raw.githubusercontent.com/quaoz/.img-upload/main/general/331f750bd5149f8cae6dbbc57fd2fab9-1711845255.toml -o "${dnscrypt_conf}"

  sudo brew services restart dnscrypt-proxy
  sudo lsof +c 15 -Pni UDP:5355

  echo "Installing dnsmasq"
  brew install --quiet dnsmasq || exit

  dnsmasq_conf="$(brew --prefix)/etc/dnsmasq.conf"
  echo "dnsmasq config: ${dnsmasq_conf}"

  if [[ -f "${dnsmasq_conf}" ]]; then rm "${dnsmasq_conf}"; fi
  curl -fsSL https://raw.githubusercontent.com/quaoz/.img-upload/main/general/823ff1f59a42db105674192b7be3a43c-1711847268.conf -o "${dnsmasq_conf}"

  sudo brew services start dnsmasq
  sudo networksetup -setdnsservers "Wi-Fi" 127.0.0.1

  scutil --dns | head
  networksetup -getdnsservers "Wi-Fi"

  dig +dnssec icann.org | head
  dig www.dnssec-failed.org | head
  dig mw.lonelil.ru
} 2>&1 | tee -a log.txt
