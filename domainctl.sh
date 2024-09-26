#!/usr/bin/env sh

IPSET_INDEX=-1
IPSET_NAME="vpn_domains"
COMMAND=$1
ARGUMENT=$2

print_usage() {
  printf "Usage: $0 <command> [argument]\n\n"
  printf "Commands:\n"
  printf "  add <domain>     - Add a domain to the ipset.\n"
  printf "  remove <domain>  - Remove a domain from the ipset.\n"
  printf "  file <file>      - Add domains from a file to the ipset.\n"
  printf "  url <url>        - Add domains from a URL to the ipset.\n"
  printf "  list             - List all domains in the ipset.\n"
  printf "  export <file>    - Export domains in the ipset to a file.\n"
  printf "  restart          - Restart dnsmasq and clear the vpn_domains table.\n"
  exit 0
}

verify_ipset_config() {
  if ! uci -q get dhcp.@ipset[$IPSET_INDEX] >/dev/null; then
    printf "No ipset configured. Adding...\n"
    uci add dhcp ipset >/dev/null
    uci commit dhcp
  fi
}

verify_ipset_name() {
  if ! uci -q get dhcp.@ipset[$IPSET_INDEX].name >/dev/null; then
    printf "No ipset name set. Adding...\n"
    uci add_list dhcp.@ipset[$IPSET_INDEX].name=$IPSET_NAME
    uci commit dhcp
  fi
}

check_domain_in_ipset() {
  if uci -q get dhcp.@ipset[$IPSET_INDEX].domain | grep -qw "$1"; then
    return 0
  fi
  return 1
}

add_domain_to_ipset() {
  uci add_list dhcp.@ipset[$IPSET_INDEX].domain="$1"
  uci commit dhcp
  printf "Domain '%s' added to ipset.\n" "$1"
}

remove_domain_from_ipset() {
  uci del_list dhcp.@ipset[$IPSET_INDEX].domain="$1"
  uci commit dhcp
  printf "Domain '%s' removed from ipset.\n" "$1"
}

list_domains() {
  DOMAINS=$(uci -q get dhcp.@ipset[$IPSET_INDEX].domain)
  if [ -z "$DOMAINS" ]; then
    printf "No domains found in ipset.\n"
  else
    printf "%s\n" $DOMAINS
  fi
}

add_domains_from_file() {
  if [ -f "$1" ]; then
    while IFS= read -r line; do
      if [ -n "$line" ]; then
        if check_domain_in_ipset "$line"; then
          printf "Domain '%s' already exists in ipset.\n" "$line"
        else
          add_domain_to_ipset "$line"
        fi
      fi
    done <"$1"
  else
    printf "File '%s' not found.\n" "$1"
  fi
}

add_domains_from_url() {
  TEMP_FILE=$(mktemp)
  wget -q "$1" -O "$TEMP_FILE"
  if [ $? -ne 0 ]; then
    printf "Failed to download URL.\n"
    rm "$TEMP_FILE"
    exit 1
  fi
  add_domains_from_file "$TEMP_FILE"
  rm "$TEMP_FILE"
}

validate_command() {
  if { [ "$COMMAND" = "add" ] || [ "$COMMAND" = "remove" ]; } && [ -z "$ARGUMENT" ]; then
    printf "Error: Domain is required for '%s' command.\n\n" "$COMMAND"
    print_usage
  fi
}

restart_services() {
  printf "Restarting dnsmasq...\n"
  service dnsmasq restart >/dev/null
  printf "Clearing the vpn_domains table...\n"
  nft flush set inet fw4 vpn_domains >/dev/null
}

main() {
  if [ "$#" -lt 1 ]; then
    print_usage
    exit 1
  fi

  validate_command "$COMMAND" "$ARGUMENT"
  verify_ipset_config
  verify_ipset_name

  case "$COMMAND" in
    add)
      if check_domain_in_ipset "$ARGUMENT"; then
        printf "Domain '%s' already exists in ipset.\n" "$ARGUMENT"
      else
        add_domain_to_ipset "$ARGUMENT"
      fi
      ;;
    file)
      add_domains_from_file "$ARGUMENT"
      ;;
    url)
      add_domains_from_url "$ARGUMENT"
      ;;
    remove)
      if check_domain_in_ipset "$ARGUMENT"; then
        remove_domain_from_ipset "$ARGUMENT"
      else
        printf "Domain '%s' not found in ipset.\n" "$ARGUMENT"
      fi
      ;;
    list)
      list_domains
      ;;
    export)
      domains=$(list_domains)
      if [[ "$domains" = "No domains found in ipset." ]]; then
        printf "No domains found in ipset. Nothing to export.\n"
      elif [ -z "$ARGUMENT" ]; then
        printf "No file specified.\n"
        exit 1
      else
        list_domains >"$ARGUMENT"
        printf "Domains exported to '%s'\n" "$ARGUMENT"
      fi
      ;;
    restart)
      restart_services
      ;;
    *)
      printf "Unknown command: %s\n\n" "$COMMAND"
      print_usage
      ;;
  esac
}

main "$@"
