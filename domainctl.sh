#!/bin/sh

IPSET_INDEX=-1
IPSET_NAME="vpn_domains"
COMMAND=$1
DOMAIN=$2

print_usage() {
  printf "Usage: $0 <command> [domain]\n\n"
  printf "Commands:\n"
  printf "  add <domain>     - Add a domain to the ipset.\n"
  printf "  remove <domain>  - Remove a domain from the ipset.\n"
  printf "  list             - List all domains in the ipset.\n"
  printf "  restart          - Restart dnsmasq and firewall.\n"
  exit 1
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

validate_command() {
  if { [ "$COMMAND" = "add" ] || [ "$COMMAND" = "remove" ]; } && [ -z "$DOMAIN" ]; then
    printf "Error: Domain is required for '%s' command.\n\n" "$COMMAND"
    print_usage
  fi
}

restart_services() {
  printf "Restarting dnsmasq...\n"
  service dnsmasq restart >/dev/null
  printf "Restarting firewall...\n"
  service firewall restart >/dev/null
}

main() {
  if [ "$#" -lt 1 ]; then
    print_usage
    exit 1
  fi

  validate_command "$COMMAND" "$DOMAIN"
  verify_ipset_config
  verify_ipset_name

  case "$COMMAND" in
    add)
      if check_domain_in_ipset "$DOMAIN"; then
        printf "Domain '%s' already exists in ipset.\n" "$DOMAIN"
      else
        add_domain_to_ipset "$DOMAIN"
      fi
      ;;
    remove)
      if check_domain_in_ipset "$DOMAIN"; then
        remove_domain_from_ipset "$DOMAIN"
      else
        printf "Domain '%s' not found in ipset.\n" "$DOMAIN"
      fi
      ;;
    list)
      list_domains
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
