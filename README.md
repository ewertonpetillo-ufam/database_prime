# PRIME Database - PostgreSQL com Docker

Sistema de banco de dados PostgreSQL para o projeto PRIME - Parkinson's Disease Clinical Assessment System.

## Estrutura do Projeto

```
database/
├── docker-compose.yml          # Configuração do Docker Compose
├── .env                        # Variáveis de ambiente (NÃO versionar!)
├── .env.example                # Template de variáveis de ambiente
├── .gitignore                  # Arquivos a serem ignorados pelo Git
├── init-scripts/               # Scripts de inicialização do banco
│   ├── 01-init-db.sql         # Cria database e extensions
│   └── 02-create-schema.sql   # Cria todo o schema do banco
├── database_schema.sql         # Schema original (referência)
└── README.md                   # Este arquivo
```

## Requisitos

- Docker >= 20.10
- Docker Compose >= 2.0
- 2GB de RAM disponível para o container
- Porta 5432 disponível (ou configurar outra no .env)

## Início Rápido

### 1. Configure as variáveis de ambiente

```bash
# Copie o template
cp .env.example .env

# Edite o .env e altere a senha (IMPORTANTE!)
nano .env  # ou use seu editor preferido

# Gere uma senha segura com:
openssl rand -base64 32
```

### 2. Inicie o banco de dados

```bash
# Iniciar o container em background
docker-compose up -d

# Verificar logs
docker-compose logs -f postgres

# Verificar saúde do container
docker-compose ps
```

### 3. Verificar a instalação

```bash
# Conectar ao banco via psql
docker-compose exec postgres psql -U prime_admin -d prime_db

# Ou usando psql local
psql postgresql://prime_admin:SUA_SENHA@localhost:5432/prime_db
```

## Scripts de Inicialização

Os scripts em `init-scripts/` são executados **apenas na primeira inicialização** do container, em ordem alfabética:

1. **01-init-db.sql**: Cria o database `prime_db` e as extensions necessárias
   - `uuid-ossp`: Para geração de UUIDs
   - `pgcrypto`: Para funções criptográficas (hashing de CPF)

2. **02-create-schema.sql**: Cria todo o schema do banco de dados
   - 45 tabelas + 3 views
   - Índices e constraints
   - Triggers e funções
   - Dados de referência (domínios)

## Integração com Backend

### Variáveis de Ambiente do Backend

Configure no seu backend (Node.js, Python, etc.):

```bash
# Conexão via localhost (desenvolvimento local)
DATABASE_URL=postgresql://prime_admin:SUA_SENHA@localhost:5432/prime_db

# Conexão via Docker network (backend em container)
DATABASE_URL=postgresql://prime_admin:SUA_SENHA@postgres:5432/prime_db
```

### Adicionar Backend ao Docker Compose

Se seu backend estiver em Docker, adicione-o à rede `prime-network`:

```yaml
services:
  backend:
    # ... suas configurações
    networks:
      - prime-network
    depends_on:
      postgres:
        condition: service_healthy

networks:
  prime-network:
    external: true
    name: prime-network
```

## Comandos Úteis

### Gerenciamento do Container

```bash
# Parar o container
docker-compose stop

# Iniciar novamente
docker-compose start

# Reiniciar
docker-compose restart

# Parar e remover (dados persistem no volume!)
docker-compose down

# Remover TUDO incluindo volume (CUIDADO!)
docker-compose down -v
```

### Acesso ao Banco

```bash
# Shell interativo no container
docker-compose exec postgres bash

# Cliente psql
docker-compose exec postgres psql -U prime_admin -d prime_db

# Executar SQL via arquivo
docker-compose exec -T postgres psql -U prime_admin -d prime_db < seu_script.sql

# Dump do banco (backup)
docker-compose exec postgres pg_dump -U prime_admin prime_db > backup_$(date +%Y%m%d).sql

# Restore do banco
docker-compose exec -T postgres psql -U prime_admin -d prime_db < backup.sql
```

### Monitoramento

```bash
# Logs em tempo real
docker-compose logs -f postgres

# Últimas 100 linhas
docker-compose logs --tail=100 postgres

# Status e saúde
docker-compose ps

# Uso de recursos
docker stats prime-postgres
```

## Segurança

### Boas Práticas Implementadas

- Senha forte gerada aleatoriamente
- `.env` no `.gitignore` (não versionado)
- Container rodando como usuário não-root
- Rede Docker isolada
- Health check configurado
- Scripts de init somente leitura

### Para Produção

1. **Altere todas as credenciais**
   ```bash
   openssl rand -base64 32  # Nova senha
   ```

2. **Restrinja permissões do .env**
   ```bash
   chmod 600 .env
   ```

3. **Use secrets management**
   - AWS Secrets Manager
   - HashiCorp Vault
   - Docker Secrets (Swarm)

4. **Configure SSL/TLS**
   - Adicione certificados no container
   - Configure `postgresql.conf` para SSL

5. **Backup automatizado**
   - Configure cron job para pg_dump
   - Armazene em local seguro (S3, etc.)

6. **Limite recursos**
   - Ajuste CPU/RAM no docker-compose.yml
   - Configure connection pooling

## Estrutura do Schema

O banco de dados contém:

- **10 tabelas de domínio/referência**: Gênero, etnia, medicações, etc.
- **3 entidades core**: Pacientes, avaliadores, questionários
- **3 tabelas clínicas**: Dados antropométricos, avaliações, impressões
- **10 escalas neurológicas**: UPDRS, MEEM, UDysRS, FOGQ, etc.
- **3 tabelas de tarefas motoras**: Definições, checklist, coletas
- **2 tabelas de dados binários**: Coletas CSV e features processadas
- **1 tabela de relatórios PDF**
- **1 tabela de auditoria**: Rastreamento de mudanças
- **3 views**: Sumários de pacientes, questionários e coletas

### Destaques

- **Privacidade**: CPF armazenado como hash HMAC (LGPD/HIPAA compliant)
- **Normalização**: 3NF completo
- **Auditoria**: Trigger automático para mudanças críticas
- **Performance**: 40+ índices estratégicos
- **Flexibilidade**: JSONB para dados variáveis

## Troubleshooting

### Container não inicia

```bash
# Verifique logs
docker-compose logs postgres

# Verifique se a porta está em uso
lsof -i :5432

# Remova e recrie
docker-compose down
docker-compose up -d
```

### Scripts não executaram

Scripts só rodam na **primeira** inicialização. Para forçar:

```bash
# Remover volume
docker-compose down -v

# Recriar tudo
docker-compose up -d
```

### Erro de conexão

```bash
# Verifique se está rodando
docker-compose ps

# Teste health check
docker-compose exec postgres pg_isready

# Verifique variáveis
docker-compose exec postgres env | grep POSTGRES
```

## Suporte

- Documentação completa do schema: `database_diagram.md`
- Issues: [GitHub Issues](seu-repo-aqui)
- Documentação PostgreSQL: https://www.postgresql.org/docs/16/

## Licença

[Especifique a licença do projeto]
# database_prime
