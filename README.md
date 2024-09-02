Скрипт для управления доменами в OpenWrt, настроенной через скрипт [точечной маршрутизации](https://github.com/itdoginfo/domain-routing-openwrt). Подробнее про сам процесс [тут](https://itdog.info/tochechnaya-marshrutizaciya-po-domenam-na-routere-s-openwrt/#%D1%81%D0%B2%D0%BE%D0%B8-%D0%B4%D0%BE%D0%BC%D0%B5%D0%BD%D1%8B).

Используется `uci` для управления конфигурацией в файле `/etc/config/dhcp`.

> [!WARNING]
> Для работы скрипта в файле `/etc/config/dhcp` ipset должен находиться в самом **конце** файла, либо его вообще не должно быть. Скрипт сам внесёт нужные изменения.

- [Подготовка](#подготовка)
- [Установка](#установка)
- [Использование](#использование)
- [TODO](#todo)

## Подготовка

Нужен `curl` или `wget` для скачивания скрипта.

Установите что-то одно:

```sh
opkg update
opkg install curl
opkg install wget
```

## Установка

Сделайте бэкап файла `/etc/config/dhcp` (опционально):

```sh
cp /etc/config/dhcp /etc/config/dhcp.bak
```

Скачайте скрипт в нужную директорию (например, `/root` или `/tmp`. В случае с `/tmp` скрипт будет удалён после перезагрузки роутера):

```sh
# curl
curl https://raw.githubusercontent.com/vernette/domainctl/master/domainctl.sh -o /root/domainctl.sh

# wget
wget https://raw.githubusercontent.com/vernette/domainctl/master/domainctl.sh -O /root/domainctl.sh
```

Сделайте его исполняемым:

```sh
chmod +x /root/domainctl.sh
```

## Использование

```sh
# Вывод примера использования и доступных команд
./domainsctl.sh

# Добавление домена. Если домен уже добавлен, то будет выведено сообщение об ошибке.
./domainsctl.sh add google.com

# Удаление домена. Если домен не добавлен, то будет выведено сообщение об ошибке.
./domainsctl.sh remove google.com

# Получение списка добавленных доменов
./domainsctl.sh list
```

После добавления или удаления домена перезапускаются сервисы `dnsmasq` и `firewall`.

## TODO

- [ ] Добавить возможность загрузки доменов из файла
