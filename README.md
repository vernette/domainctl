Скрипт для управления доменами в OpenWrt, настроенной через скрипт [точечной маршрутизации](https://github.com/itdoginfo/domain-routing-openwrt). Подробнее про сам процесс [тут](https://itdog.info/tochechnaya-marshrutizaciya-po-domenam-na-routere-s-openwrt/#%D1%81%D0%B2%D0%BE%D0%B8-%D0%B4%D0%BE%D0%BC%D0%B5%D0%BD%D1%8B).

Используется `uci` для управления конфигурацией в файле `/etc/config/dhcp`.

Работоспособность проверена на следующих версиях OpenWrt:

- 23.05.4
- 23.05.5

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
wget -4 https://raw.githubusercontent.com/vernette/domainctl/master/domainctl.sh -O /root/domainctl.sh
```

Сделайте его исполняемым:

```sh
chmod +x /root/domainctl.sh
```

## Использование

> [!NOTE]
> После добавления/удаления домена обязательно выполните `./domainctl.sh restart`. После этого желательно вручную зафорсить получение IP адреса через роутер с помощью nslookup или dig, чтобы добавить его в set vpn_domains: `nslookup example.com 192.168.1.1` или `dig example.com @192.168.1.1`.

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

#### Список доменов по ссылке

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

### Перезапуск dnsmasq и очистка таблицы vpn_domains

```sh
./domainctl.sh restart
```

### Получение списка добавленных доменов

```sh
./domainctl.sh list
```

### Экспорт доменов в файл

```sh
./domainctl.sh export domains.txt
```

## TODO

- [ ] Добавить обработку доменов из файла и по ссылке, чтобы убрать домены третьего уровня и выше
- [x] Добавить возможность экспорта доменов в файл
- [x] Добавить возможность загрузки доменов из файла
- [x] Добавить возможность загрузки доменов по ссылке
