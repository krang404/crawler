
# "Тестовый стенд для разработчиков в облаке Yandex Cloud на примере приложения crawler"

Данный проект выполнен в качестве выпускной работы курса OTUS DevOps: практики и инструменты в августе 2022 года. Репозиторий содержит инфраструктурный код для развертывания тестового стенда в облаке Yandex Cloud. Стенд представляет из себя ВМ под управлением Ubuntu 18.04 LTS. В качестве средства демонстрации использовано приложение crawler.

## Проект crawler

Приложение состоит из двух микросервисов, исходный код которых доступен в репозиториях
- [Search Engine Crawler] (https://github.com/express42/search_engine_crawler.git)
- [Serch Engine UI] (https://github.com/express42/search_engine_ui.git)

Engine Crawler парсит указанные в конфигурации сайты и сохраняет данные в БД MongoDB, а микросервис UI представляет собой интерефейс для поиска в БД.

Приложение использует очередь RabbitMQ и БД MongoDB.

## Инфраструктура в контейнерах

Для тестирования сборки проекта и его функционирования инфраструктура может быть развернута в контейнерах на одной ВМ с помощью Terrafrom и Ansible. Контейнерое развертывание используется в качестве средства демонстрации или тестирования продукта разработки. Это не prodaction-решение.

Необходимые предустановки для запуска проекта:

- Terraform v1.0 и выше
- Ansible v2.11 и выше
- Yandex CLI v0.90 и выше
- Подключенный сервисный аккаунт для работы в Yandex Cloud

### Screencast развертывания проекта

Screencast развертывания инфраструктуры в контейнерах доступен по ссылке

[Яндекс.Диск](https://disk.yandex.ru/i/VbkxYfaVH6HGZw "Скринкаст развертывания")

### Terraform

Минимально необходимое количество ресурсов для демонстрационного проекта:

- Вируальная машина (CPU - 2 Core, RAM - 8 Gb)
- Yandex Cloud Container Registry

Инфраструктурный код для развертывания стенда находится в директории /infra/terraform/docker-compose и описывает провиженнинг ВМ и создание Container Registry в облаке Yandex.Cloud. Для запуска достаточно подставить переменные в variables.tf и запустить terraform apply.

После успешного провиженнинга в outputs будут выведены внешний IP виртуальной машины и ID Container Registry. Эти данные понадобятся для дальнейшего развертывания инфраструктуры и запуска pipeline CI/CD.

Внешний IP и ID Container Registry передаются в inventory и файл переменных для Ansible (/infra/ansible/variables.yml),что добавляет больше автоматизации в развертывание.

Формирование файла с переменными производится как ресурс конфигурации через провайдера local, поэтому при удалении инфраструктуры файл с переменными также удаляется.

Также потребуется привязать к ВМ сервисный аккаунт, который описывается в модуле test_registry. Это необходимо для работы утилиты Credental Helper, которая используется для логина в Container Registry без ввода учетных данных вручную. К сожалению ресурсы, предоставляемые провайдером Yandex для Terraform, не позволяют реализовать внесение учетных данных сервисного аккаунта в метаданные ВМ через код конфигурации. Поэтому по окончании провиженнинга ВМ будет запущен скрипт infra/terraform/docker-compose/yc_register_script.sh, который внесет id сервисного аккаунта в метаданные ВМ. Также данный скрипт запросит credential для этого же сервисного аккаунта и выгрузит эти данные в файл infra/ansible/templates/key.json. Ключи потребуются для логина в приватное хранилище при развертывании тестовой инсталляции приложения crawler.

### Ansible

Инфраструктура разветывается в контейнерах с использованием Docker Compose. Все необходмые переменные уже определны в ходе работы Terraform. Единственное исключение описано ниже.

При провиженнинге конфигурации Docker Compose мы определим инициализирующий пароль с помощью переменной $gitlab_initial_root_password, а также создадим токен, определив переменную $gitlab_initial_shared_runners_registration_token для регистрации shared_ranner, который впоследствии используем для CI/CD. Эти переменные спрячем в файл infra/ansible/secure.yml, зашифрованный через ansible-vault.

    ansible-vault create secure.yml

Далее необходимо установить все пакеты docker и зависимости к ним на удаленный хост. Вся установка описана в плейбуке /infra/ansible/install_docker.yml

    ansible-playbook install_docker.yml

После установки Docker можно запускать развертывание контейнеров с Gitlab и Gitlab-Runner. Не забываем поставить ключ --ask-vault-pass

    ansible-playbook gitlab_up.yml --ask-vault-pass

Регистрация раннера производится с помощью плейбука /infra/ansible/registr_runner.yml, которым мы отправим на хост шаблон скрипта infra/ansible/templates/register_runner.sh.j2, а потом запустим этот скрипт также с использованием зашифрованных ранее переменных.

    ansible-playbook registr_runner.yml --ask-vault-pass

Таким образом мы полностью автоматизировали развертывание тестового репозитория для работы с кодом приложения. Теперь осталось только описать процессы CI/CD.

### Gitlab и CI/CD

После запуска репозитория можно начинать работать над тестированием и развертыванием приложения crawler. Для удобства внесем инфраструктурный код в .gitignore, чтобы не занимать места в тестовом репозитории.

Для начала добавим репозиторий в наш локальный git. Исходники микросервисов и скрипты для тестирования расположены в директории crawler. Здесь же находятся и Dockerfile для сборки образов.

Pipeline для непрерывной поставки описан в .gitlab-ci.yml. Он включает в себя 3 стадии: тестирование исходного кода, тестирование сборки образа и деплой образа в приватное хранилище для последующего развертывания в тестовой среде.

Логин в приватное хранилище осуществляется через Credential Helper, который предоставляет Yandex Cloud. Для этого мы вызовем его через образ cr.yandex/yc/metadata-token-docker-helper:0.2, который считает метаданные ВМ и подставить необходимые credential для логина.

Поскольку мы используем приватное хранилище, ссылка на образ принимает вид cr.yandex/registry_id/name_of_image. registry_id мы получили при провиженнинге виртуальной машины через Terraform. Этот ID хранится в переменной $YA_REGISTRY, которая определена при регистрации Gitlab-Runner.

При успешном завершении, итогом pipeline станут артефакты в виде образов микросервисов в приватном хранилище. Далее эти образы будут использованы при развертывании демонстрационной/тестовой инсталляции.

### Развертывание инсталляции

Запуск контейнеров с приложением осуществляется через плейбук /infra/ansible/crawler_up.yml.

    ansible-playbook crawler_up.yml

### Описание инсталляции

При успешном развертывании мы получаем работающий стенд, на котором, помимо Gitlab, запущены контейнера с микросервисами crwaler и crawler_ui, очередь RabbitMQ, БД MongoDB, сервис мониторинга Prometheus и node-exporter к нему, а также cAdvisor для мониторинга состояния контейнерной нагрузки.

Визуализация интерфейсов:

- crawler_ui http://HOST_IP:8000
- Prometheus http://HOST_IP:9090
- cAdvisor http://HOST_IP:8080
