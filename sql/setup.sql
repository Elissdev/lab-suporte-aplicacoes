-- Banco de treino: chamados de suporte
DROP TABLE IF EXISTS chamados;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS erros;

CREATE TABLE clientes (
  id INTEGER PRIMARY KEY,
  nome TEXT,
  segmento TEXT,
  plano TEXT
);

CREATE TABLE chamados (
  id_chamado INTEGER PRIMARY KEY,
  id_cliente INTEGER,
  abertura TEXT,
  fechamento TEXT,
  status TEXT,          -- ABERTO, EM_ANALISE, ESCALADO, FECHADO
  prioridade TEXT,      -- P1, P2, P3, P4
  codigo_erro TEXT,
  descricao TEXT
);

CREATE TABLE erros (
  codigo TEXT PRIMARY KEY,
  camada TEXT,          -- REDE, IIS, APLICACAO, BANCO, FILA
  descricao TEXT
);

INSERT INTO clientes VALUES
 (1,'Banco Aurora','Banco','Enterprise'),
 (2,'Varejo Ponto','Varejo','Enterprise'),
 (3,'Fintech Zeta','Fintech','Standard'),
 (4,'Cooperativa Sul','Cooperativa','Standard'),
 (5,'Loja Rápida','Varejo','Basic'),
 (6,'Rede Nova','Varejo','Basic');

INSERT INTO chamados VALUES
 (1,1,'2026-10-01 09:12','2026-10-01 10:40','FECHADO','P2','HTTP-503','Consulta de crédito fora do ar'),
 (2,1,'2026-10-02 14:05','2026-10-02 15:10','FECHADO','P3','HTTP-500','Erro ao gerar relatório'),
 (3,2,'2026-10-03 08:30',NULL,'ABERTO','P1','HTTP-504','Timeout na integração de score'),
 (4,2,'2026-10-03 11:00','2026-10-04 09:20','FECHADO','P2','HTTP-504','Timeout na integração de score'),
 (5,3,'2026-10-05 16:45',NULL,'EM_ANALISE','P3','API-401','Token expirado no cliente'),
 (6,3,'2026-10-06 10:10',NULL,'ESCALADO','P2','HTTP-503','Application pool parado'),
 (7,4,'2026-10-06 13:55','2026-10-07 08:05','FECHADO','P4','DOC-001','Dúvida sobre relatório'),
 (8,4,'2026-10-07 09:25',NULL,'ABERTO','P3','HTTP-500','Erro ao consultar histórico'),
 (9,5,'2026-10-08 12:40','2026-10-08 13:15','FECHADO','P4','DOC-001','Solicitação de acesso'),
 (10,1,'2026-10-09 07:50',NULL,'ABERTO','P1','HTTP-503','Aplicação indisponível na abertura'),
 (11,2,'2026-10-09 15:30','2026-10-09 16:00','FECHADO','P3','API-401','Token expirado no cliente'),
 (12,5,'2026-10-10 10:15',NULL,'EM_ANALISE','P4','HTTP-404','URL de endpoint errada'),
 (13,1,'2026-10-10 18:20',NULL,'ABERTO','P2','HTTP-504','Timeout na integração de score'),
 (14,3,'2026-10-11 09:05','2026-10-11 10:00','FECHADO','P3','HTTP-500','Erro ao gerar relatório'),
 (15,2,'2026-10-12 08:00',NULL,'ABERTO','P2','FILA-MSG','Mensagens acumuladas na fila');

INSERT INTO erros VALUES
 ('HTTP-503','IIS','Application pool parado ou aplicação recusando conexão'),
 ('HTTP-500','APLICACAO','Exceção não tratada na aplicação'),
 ('HTTP-504','REDE','Timeout entre gateway e aplicação ou integração externa'),
 ('API-401','APLICACAO','Token ausente, inválido ou expirado'),
 ('HTTP-404','IIS','Rota ou arquivo não encontrado'),
 ('FILA-MSG','FILA','Consumidor de mensageria parado ou lento'),
 ('DOC-001','SUPORTE','Requisição de serviço, não é falha');
