# Gabarito dos desafios de SQL

Rode com: `sqlite3 treino.db < sql/setup.sql`

```sql
-- 1
SELECT id_chamado, id_cliente, prioridade, abertura
FROM chamados
WHERE status = 'ABERTO'
ORDER BY abertura ASC;

-- 2 (left join para trazer chamado sem cliente)
SELECT c.id_chamado, cl.nome, c.status
FROM chamados c
LEFT JOIN clientes cl ON cl.id = c.id_cliente;

-- 3
SELECT cl.nome, COUNT(*) AS total
FROM chamados c
JOIN clientes cl ON cl.id = c.id_cliente
GROUP BY cl.nome
ORDER BY total DESC;

-- 4
SELECT codigo_erro, COUNT(*) AS total
FROM chamados
GROUP BY codigo_erro
HAVING COUNT(*) > 2
ORDER BY total DESC;

-- 5 (sqlite nao tem DATEDIFF, entao usa julianday)
SELECT prioridade,
       ROUND(AVG((julianday(fechamento) - julianday(abertura)) * 24), 1) AS horas_media
FROM chamados
WHERE fechamento IS NOT NULL
GROUP BY prioridade
ORDER BY horas_media DESC;

-- 6
SELECT id_chamado, prioridade, status, abertura
FROM chamados
WHERE prioridade IN ('P1','P2')
  AND status <> 'FECHADO'
ORDER BY prioridade, abertura;

-- 7
SELECT c.id_chamado, cl.nome, c.codigo_erro, e.camada
FROM chamados c
JOIN clientes cl ON cl.id = c.id_cliente
JOIN erros e ON e.codigo = c.codigo_erro;

-- 8
SELECT cl.nome
FROM clientes cl
LEFT JOIN chamados c ON c.id_cliente = cl.id
WHERE c.id_chamado IS NULL;
```

## Se o banco for SQL Server (T-SQL), muda isto

- Limitar linhas: `SELECT TOP 10 ...` em vez de `LIMIT 10`.
- Data atual: `GETDATE()`, e não `NOW()`.
- Diferença de datas: `DATEDIFF(hour, abertura, fechamento)`.
- Concatenar: `+` ou `CONCAT()`.
- Nulo: `ISNULL(campo, 0)` em vez de `COALESCE`, que também existe.
- Arredondar: `ROUND(valor, 1)`.
- Igualdade de texto: `WHERE status = 'ABERTO'` funciona igual, mas o SQL Server é case-insensitive na configuração padrão.
