# Runbook: 503 na consulta de crédito

**Objetivo:** restabelecer a consulta de crédito quando a aplicação responde 503 e o problema não está isolado em um único cliente.

**Quando usar:** cliente relata erro 503 ao consultar crédito, ou o monitoramento dispara indisponibilidade no endpoint de consulta com impacto em todos os clientes.

**Quem executa:** suporte N1 em plantão. N2 é acionado no passo 6, se a reciclagem do pool não resolver.

**Pré-requisitos:** acesso à VPN, permissão no GitHub Issues, acesso ao servidor de aplicação, acesso ao monitoramento e leitura no diretório de log do IIS.

## 1. Registrar o caso

No GitHub Issues, abrir o chamado com: horário exato da primeira falha, ambiente, cliente afetado (ou "todos"), mensagem de erro exibida na tela e status code retornado. Se houver print do erro, anexar.

## 2. Confirmar o escopo

Testar o endpoint fora da aplicação:

```bash
curl -i --max-time 10 https://app.exemplo.com/api/consulta/credito -H "Authorization: Bearer $TOKEN"
```

Interpretar o resultado:

| Resposta | Leitura inicial |
| --- | --- |
| 503 em todos os clientes | indisponibilidade do serviço, seguir para o passo 3 |
| 503 em um cliente | verificar configuração, cota ou dado específico daquele cliente |
| 200 com corpo vazio | problema de aplicação ou de integração, não de disponibilidade |
| Timeout | suspeitar de dependência lenta (banco, fila ou serviço externo) |

## 3. Verificar o pool no IIS

No servidor, abrir o IIS Manager e conferir o estado do application pool. Se estiver parado ou em reciclagem contínua, anotar o horário. Também vale olhar o log de eventos do Windows no mesmo intervalo.

Se o pool estiver parado, reciclar e repetir o teste do passo 2. Se voltar a cair em menos de 10 minutos, não reciclar de novo: coletar evidência e escalar.

## 4. Ler o log no horário da falha

```bash
cd C:\inetpub\logs\LogFiles\W3SVC1

# todos os 503 do intervalo
findstr " 503 " u_ex261014.log

# 5xx por minuto
awk '!/^#/ && $12>=500 {print substr($2,1,5)}' u_ex261014.log | sort | uniq -c
```

Guardar o trecho do log com data, hora, URL, status e `time-taken`. Esse trecho é a evidência principal do chamado.

## 5. Checar dependências

- Banco: a consulta responde? Há sessão bloqueada ou pool de conexão esgotado?
- Fila: há mensagem acumulada ou consumer parado?
- Serviço externo de crédito: responde 200 fora da aplicação?

O `sc-substatus` do log ajuda a separar indisponibilidade do IIS de erro da aplicação. Anotar o valor encontrado.

## 6. Escalar com contexto

Se o serviço não voltar após a reciclagem, escalar para N2 com:

- horário da primeira falha e horário da última tentativa
- saída do `curl` com status code
- trecho do log do IIS com `sc-status`, `sc-substatus` e `time-taken`
- estado do application pool e se houve reciclagem
- o que foi testado e descartado (banco, fila, serviço externo)
- clientes e volume estimado de chamados impactados

## 7. Como confirmar que resolveu

- O endpoint responde 200 com corpo válido.
- O cliente confirma a operação no sistema.
- O monitoramento volta ao normal e não há novo 503 em 15 minutos.
- O chamado é atualizado com a causa, a ação e o horário do restabelecimento.

## 8. Depois do fechamento

Se o mesmo 503 aparecer mais de uma vez na semana, abrir registro de problema e levar a causa para o time. Atualizar este runbook com o que faltou e com o que atrasou o atendimento.

## Histórico de revisão

| Data | Autor | Alteração |
| --- | --- | --- |
| 2026-10-20 | Elissandra | Criação do documento a partir do cenário de treino |
