# POP / Runbook: [nome do procedimento]

**Objetivo:** o que este documento resolve, em uma frase.
**Quando usar:** sintoma que dispara este procedimento. Exemplo: cliente reporta 503 na consulta de crédito.
**Quem executa:** suporte N1, N2 ou plantão.
**Pré-requisitos:** acesso ao servidor, VPN, permissão no GitHub Issues, ferramenta de monitoramento.

## Passo a passo
1. Abrir o chamado no GitHub Issues e registrar horário, cliente e mensagem de erro exata.
2. Verificar alerta no monitoramento: é um cliente ou todos?
3. Testar a URL no navegador ou com curl, anotando o status code.
4. Acessar o servidor e verificar o status do application pool.
5. Ler o log do IIS no horário exato do erro e filtrar por 500 e 503.
6. Abrir o Event Viewer e procurar erro da aplicação no mesmo horário.
7. Se o pool estiver parado, reciclar e testar novamente.
8. Registrar no chamado o que foi feito, com evidência e horário.

## Como confirmar que resolveu
- A URL volta a responder 200.
- O cliente confirma a operação.
- O alerta volta ao normal no monitoramento.

## Se não resolver
Escalar para N2 com: horário, status code, trecho do log, o que já foi testado e o que foi descartado. Avisar o cliente o próximo prazo de retorno.

## Histórico de revisão
- Data, autor, o que mudou.
