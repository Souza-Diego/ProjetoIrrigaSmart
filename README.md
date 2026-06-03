# 🌱 IrrigaSmart

Sistema de irrigação inteligente desenvolvido como projeto acadêmico, integrando Internet das Coisas (IoT), automação e monitoramento em tempo real para auxiliar no cuidado de plantas.

O projeto combina um aplicativo mobile desenvolvido em Flutter, um dispositivo embarcado baseado em ESP32 e uma infraestrutura de armazenamento de dados utilizando Flask e MySQL, permitindo monitorar a umidade do solo, controlar a irrigação e acompanhar históricos de uso.

## 📋 Funcionalidades

### Monitoramento em Tempo Real

* Visualização da umidade atual do solo
* Status da irrigação (ativa ou inativa)
* Horário da última irrigação
* Informações climáticas da região
* Atualização automática dos dados

### Controle de Irrigação

* Acionamento manual da irrigação
* Interrupção manual da irrigação
* Irrigação automática baseada na umidade do solo
* Irrigação por horário programado
* Modo combinado (horário + umidade)
* Configuração de intervalo mínimo entre irrigações

### Gerenciamento de Plantas

* Catálogo de espécies com informações de cultivo
* Aplicação automática de parâmetros recomendados
* Configuração personalizada de irrigação

### Configuração do Sistema

* Calibração dinâmica do sensor de umidade
* Configuração da rede Wi-Fi via Bluetooth Low Energy (BLE)
* Persistência das configurações no dispositivo

### Histórico e Armazenamento

* Registro de irrigações realizadas
* Histórico de leituras de umidade
* Armazenamento em banco de dados MySQL
* Consulta de dados históricos pelo aplicativo

## 🏗️ Arquitetura

O aplicativo foi desenvolvido seguindo princípios de Domain-Driven Design (DDD), organizado nas seguintes camadas:

```text
dominio/          -> Regras de negócio e entidades
aplicacao/        -> Serviços de aplicação
infraestrutura/   -> Comunicação externa, BLE, HTTP e persistência
dados/            -> DTOs e dados estáticos
apresentacao/     -> Telas e componentes visuais
```

## Telas do App



## Protótipo e Diagramas



## ⚙️ Tecnologias Utilizadas

### Aplicativo Mobile

* Flutter
* Dart

### Hardware

* ESP32 DevKit
* Sensor capacitivo de umidade do solo
* Módulo relé
* Bomba submersível 5V

### Backend

* Python Flask
* MySQL

### Comunicação

* HTTP
* Bluetooth Low Energy (BLE)
* mDNS

### Serviços Externos

* OpenWeatherMap API
* ngrok

## 🔌 Componentes do Protótipo

* ESP32 DevKit
* Sensor capacitivo de umidade do solo
* Relé 5V
* Bomba submersível
* LEDs indicadores de status
* Caixa protetora impressa em 3D
* Anel irrigador impresso em 3D
* Mangueira com gotejador

## 📊 Funcionalidades Futuras

* Sistema de autenticação de usuários
* Suporte a múltiplos dispositivos
* Notificações inteligentes
* Gráficos e estatísticas avançadas
* Integração com previsões de chuva
* Infraestrutura em nuvem
* Cadastro personalizado de plantas

## 👨‍💻 Equipe

* Diego Pereira de Souza - @Souza-Diego
* Mariana Aparecida Gomes Soares - @Mariana-Aparecida-Gomes

## 📚 Projeto Acadêmico

Projeto desenvolvido no programa Acelera, com foco na aplicação prática de conceitos de desenvolvimento mobile, sistemas embarcados, banco de dados, automação e Internet das Coisas (IoT).

---

Sistema desenvolvido para promover o uso consciente da água através da automação inteligente da irrigação.
