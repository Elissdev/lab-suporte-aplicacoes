# Lab de Suporte a Aplicações

Exercícios que uso para treinar o que aparece no atendimento N1 e N2: consultar a base de chamados, ler log de servidor web, testar uma API e escrever procedimento que outra pessoa consiga executar sem mim.

Os dados são sintéticos. Nenhum cliente, log ou chamado real está neste repositório.

## Conteúdo

| Pasta / arquivo | Exercício | O que treina |
| --- | --- | --- |
| `sql/` | 8 consultas sobre chamados, clientes e erros | SELECT, JOIN, LEFT JOIN, GROUP BY, HAVING, subconsulta e cálculo de tempo |
| `logs/iis_sample.log` | Análise de log IIS de um dia | Filtro por status, agrupamento por URL e por hora, identificação de requisição lenta |
| `runbook-template.md` | Modelo em branco | Estrutura de POP e runbook |
| `exemplos/runbook-503-consulta-credito.md` | Runbook preenchido | Passo a passo com evidência, critério de resolução e pacote de escalonamento |

Requisitos: `sqlite3`, `awk`, `curl` e, opcionalmente, `jq`.

---

## 1. SQL

O banco de treino tem três tabelas: `clientes`, `chamados` e `erros`. A tabela `chamados` guarda status (ABERTO, EM_ANALISE, ESCALADO, FECHADO), prioridade (P1 a P4), código de erro e as datas de abertura e fechamento. A tabela `erros` relaciona cada código à camada onde ele ocorre: REDE, IIS, APLICACAO, BANCO ou FILA.

```bash
sqlite3 treino.db < sql/setup.sql
sqlite3 treino.db
```

Dentro do sqlite, `.tables` lista as tabelas e `.schema chamados` mostra a estrutura. As perguntas estão em `sql/desafios.sql` e o gabarito em `sql/gabarito.md`. O arquivo `treino.db` é gerado localmente e não entra no versionamento.

As consultas cobrem:

1. Chamados abertos em ordem de abertura
2. Chamado com segmento do cliente, incluindo chamado sem cliente cadastrado
3. Total de chamados por cliente
4. Código de erro com mais de duas ocorrências
5. Tempo médio de fechamento por prioridade
6. P1 e P2 ainda não fechados
7. Chamado com cliente e camada do erro
8. Cliente que nunca abriu chamado

O cálculo de tempo usa `julianday()` porque o SQLite não tem `DATEDIFF`.

---

## 2. Log do IIS

O arquivo segue o formato W3C. A linha `#Fields` define a posição de cada coluna:

```text
date time s-ip cs-method cs-uri-stem cs-uri-query s-port cs-username c-ip cs(User-Agent) cs(Referer) sc-status sc-substatus sc-win32-status time-taken
```

Os comandos abaixo ignoram as linhas de comentário, que quebram a contagem de campo.

```bash
cd logs

# distribuição de status no dia
awk '!/^#/ {print $12}' iis_sample.log | sort | uniq -c | sort -rn

# quantidade de erro 500
awk '!/^#/ && $12==500' iis_sample.log | wc -l

# URLs que mais retornaram 500
awk '!/^#/ && $12==500 {print $5}' iis_sample.log | sort | uniq -c | sort -rn

# requisições acima de 5 segundos (time-taken em milissegundos)
awk '!/^#/ && ($NF+0) > 5000 {print $2, $5, $12, $NF}' iis_sample.log

# todas as 503 com horário
awk '!/^#/ && $12==503 {print $2, $5, $15}' iis_sample.log

# 5xx por hora
awk '!/^#/ && $12>=500 {print substr($2,1,2)}' iis_sample.log | sort | uniq -c
```

Perguntas para responder com o log:

- Qual URL concentra mais erro 500?
- Qual horário tem mais resposta 5xx?
- O que significa `time-taken` igual a 30000?
- Os 504 aparecem nas mesmas URLs dos 500? O que isso sugere sobre a causa?

---

## 3. HTTP com curl

```bash
curl -i https://httpbin.org/status/500
curl -i https://httpbin.org/status/401
curl -i https://httpbin.org/delay/3 --max-time 2
curl -s https://httpbin.org/headers | jq
curl -s -o /dev/null -w '%{http_code} %{time_total}\n' https://httpbin.org/get
```

O objetivo é distinguir erro de cliente (4xx) de erro de servidor (5xx), reconhecer timeout e ler cabeçalho de resposta sem depender de interface gráfica.

---

## 4. Runbook

Um runbook útil responde quatro coisas: quando usar, o que fazer na ordem, como confirmar que resolveu e o que enviar no escalonamento.

1. Leia `runbook-template.md`.
2. Compare com `exemplos/runbook-503-consulta-credito.md`.
3. Escreva o seu para outro cenário, por exemplo: cliente relata que o relatório de fechamento demora mais de 10 minutos desde a atualização.

Critério de revisão: se outra pessoa do time seguir o documento sem perguntar nada, o runbook está pronto.

---

## 5. ITIL na prática

Escreva um exemplo real para cada conceito:

| Conceito | Pergunta de apoio |
| --- | --- |
| Incidente | O que interrompeu ou degradou o serviço para o usuário? |
| Problema | Qual causa se repete em vários incidentes? |
| Requisição | O que é pedido sem falha no serviço, como acesso ou instalação? |
| Escalonamento funcional | Quando o caso vai para quem tem conhecimento técnico específico? |
| Escalonamento hierárquico | Quando o caso vai para quem tem autoridade para decidir prioridade ou prazo? |

---

## Uso

Material de estudo pessoal. Pode usar como base para o seu próprio laboratório, mantendo a atribuição.
