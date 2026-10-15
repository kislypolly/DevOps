# DevOps Infrastructure Lab

Автоматизация DevOps-инфраструктуры на Ubuntu 24.04 с использованием **Terraform, Ansible, Bash и Docker Compose**.

Ansible настраивает сервер, Terraform создаёт Docker-ресурсы, Bash-скрипт отслеживает состояние сервисов, а Docker Compose запускает Hello World с Nginx reverse proxy.

## Prerequisites

- Linux / WSL с Terraform и Ansible
- Ubuntu 24.04 VM с SSH-доступом
- Docker Engine и Docker Compose на VM (устанавливаются Ansible)

Перед запуском необходимо настроить SSH-доступ, указать адрес VM в `ansible/inventory.ini` и проверить параметры подключения Terraform.

## Quick start
Все команды Ansible и Terraform выполняются из корневого каталога `devops-hw1` в локальном терминале Linux/WSL. Переход между каталогами указан в командах ниже.

Bash-скрипт и Docker Compose запускаются непосредственно на удалённой виртуальной машине. Перед запуском необходимо скопировать `scripts/monitor.sh` и содержимое каталога `compose/` на VM. Команды Docker Compose выполняются из каталога `~/devops-hw1-compose`, куда были скопированы файлы проекта.

**Ansible — настройка сервера**

```bash
cd ansible
ansible-playbook -i inventory.ini setup_host.yml
```

**Terraform — создание Docker-ресурсов**

```bash
cd ../terraform
terraform init
terraform plan
terraform apply
```

**Bash — мониторинг сервиса**

На виртуальной машине, после копирования скрипта:

```bash
./monitor.sh docker
```

**Docker Compose — запуск приложения**

На виртуальной машине, после копирования каталога `compose`:

```bash
docker compose up -d
```

## Verification

### Terraform

Четыре ресурса: Docker image, container, network и volume. Nginx возвращает HTTP 200.

```bash
terraform state list
```

<img width="1232" height="222" alt="Terraform verification" src="https://github.com/user-attachments/assets/227fed2f-08b0-434a-bf76-15bbb1951b6b" />

### Ansible

Повторная проверка Playbook: `ok=6`, `changed=0`, `failed=0`.

```bash
ansible-playbook -i inventory.ini setup_host.yml --check
```

<img width="1243" height="768" alt="Ansible verification" src="https://github.com/user-attachments/assets/dc87be08-6547-4869-98bc-80316d6ed4e9" />

### Bash Monitoring

Скрипт определяет активный и неактивный сервисы и подсчитывает ошибки в системном журнале.

<img width="1234" height="362" alt="image" src="https://github.com/user-attachments/assets/f82c5355-532c-4475-933e-3a97e7053c04" />


### Docker Compose

Два контейнера (`app` и `nginx`) работают. Приложение возвращает HTTP 200.

```bash
docker compose ps
curl http://127.0.0.1:8082
```

<img width="1226" height="315" alt="image" src="https://github.com/user-attachments/assets/c0e57257-0a12-4108-aa49-b186ebb33e6e" />


## Architecture & Challenges

**Архитектура.** Terraform и Docker Compose используют отдельные сети и порты (`8081` и `8082`), чтобы не конфликтовать с существующими сервисами. Nginx в Compose работает как reverse proxy, а контейнер приложения доступен через внутреннюю Docker-сеть, а Nginx reverse proxy принимает HTTP-запросы на порту 8082.

**Возникшие проблемы.** Docker работает на удалённой VM, поэтому Terraform подключается к нему через SSH. Чтобы избежать конфликтов с уже работающими контейнерами, были выделены отдельные порты. Повторная проверка Ansible подтвердила отсутствие необходимых изменений.

## Results

Инфраструктура успешно развёрнута. Проверены Terraform, Ansible, Bash Monitoring и Docker Compose.
