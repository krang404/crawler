# Приложение crawler

Приложение состоит из двух микросервисов. Crawler парсит указанные в конфигурации сайты и сохраняет данные в БД MongoDB, а микросервис UI представляет собой интерефейс для поиска в БД.

# Проект crawler

Данный проект содержит инфраструктурный код для развертывания приложения в облаке Yandex Cloud.

## Инфраструктура в контейнерах

Для тестирования сборки проекта и его функционирования инфраструктура может быть развернута в контейнерах на одной ВМ с помощью Terrafrom и Ansible.

### Terraform

Минимально необходимое количество ресурсов для демонстрационного проекта:

- Вируальная машина (CPU - 2 Core, RAM - 8 Gb)
- Yandex Cloud Container Registry

Инфраструктурный код находится в папке /infra/terraform и описывает провиженнинг ВМ и создание Container Registry в облаке Yandex.Cloud. Для запуска достаточно подставить переменные в variables.tf и запустить terraform apply.

После успешного провиженнинга в outputs будут выведены внешний IP виртуальной машины и ID Container Registry. Эти данные понадобятся для дальнейшего развертывания инфраструктуры и запуска pipeline CI/CD.

### Ansible

Инфраструктура разветывается в контейнерах с использованием Docker Compose. Inventory в нашем случае заполняется вручную: достаточно внести IP из outputs 

Первое, что необходимо сделать, - установить все пакеты docker и зависимости к ним. Вся установка описана в плейбуке /infra/ansible
