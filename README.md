Скрипт для управления доменами в OpenWrt, настроенной через скрипт [точечной маршрутизации](https://github.com/itdoginfo/domain-routing-openwrt). Подробнее про сам процесс [тут](https://itdog.info/tochechnaya-marshrutizaciya-po-domenam-na-routere-s-openwrt/#%D1%81%D0%B2%D0%BE%D0%B8-%D0%B4%D0%BE%D0%BC%D0%B5%D0%BD%D1%8B).

Используется `uci` для управления конфигурацией в файле `/etc/config/dhcp`.
Работоспособность проверена на OpenWrt 23.05.4.

> [!WARNING]
> Для работы скрипта в файле `/etc/config/dhcp` ipset должен находиться в самом **конце** файла, либо его вообще не должно быть. Скрипт сам внесёт нужные изменения.

- [Подготовка](#подготовка)
- [Установка](#установка)
- [Использование](#использование)
- [TODO](#todo)

## Подготовка

Для работы и скачивания скрипта требуется встроенный в OpenWrt `wget` (uclient-fetch).

Если по какой-то причине он отсутствует, установите его:

```sh
opkg install uclient-fetch
```

## Установка

Сделайте бэкап файла `/etc/config/dhcp` (опционально):

```sh
cp /etc/config/dhcp /etc/config/dhcp.bak
```

Скачайте скрипт в нужную директорию, например, `/root` или `/tmp`. В случае с `/tmp` скрипт будет удалён после перезагрузки роутера:

```sh
wget https://raw.githubusercontent.com/vernette/domainctl/master/domainctl.sh -O /root/domainctl.sh
```

Сделайте его исполняемым:

```sh
chmod +x /root/domainctl.sh
```

## Использование

### Добавление доменов

#### Один домен

```sh
./domainctl.sh add google.com
```

#### Список доменов из файла

```sh
./domainctl.sh file domains.txt
```

Пример содержимого файла `domains.txt`:

```
google.com
youtube.com
yandex.ru
```

#### Добавление списка доменов по ссылке

```sh
./domainctl.sh url 'https://example.com'
```

Примеры ссылок:

| Сайт                                             | Ссылка                                                                                                                             |
| ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| [iplist.opencck.org](https://iplist.opencck.org) | [https://iplist.opencck.org/?format=text&data=domains&wildcard=1](https://iplist.opencck.org/?format=text&data=domains&wildcard=1) |
| GitHub                                           | https://raw.githubusercontent.com/JamieFarrelly/Popular-Site-Subdomains/master/Instagram.com.txt                                   |

### Удаление домена

```sh
./domainctl.sh remove google.com
```

### Перезапуск dnsmasq и firewall

```sh
./domainctl.sh restart
```

### Получение списка добавленных доменов

```sh
./domainctl.sh list
```

## TODO

- [ ] Добавить обработку ссылок, чтобы убрать домены третьего уровня и выше
- [x] Добавить возможность загрузки доменов из файла
- [x] Добавить возможность загрузки доменов по ссылке
