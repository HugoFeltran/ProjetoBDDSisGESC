-- ============================================================
-- SisGESC — Sistema de Gestão Educacional
-- Universidade / Faculdade Privada
-- Banco de Dados: MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS sisgesc
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sisgesc;

-- ============================================================
-- MÓDULO TRANSVERSAL
-- ============================================================

CREATE TABLE tb_usuario (
  usuario_id        INT             NOT NULL AUTO_INCREMENT,
  email             VARCHAR(100)    NOT NULL,
  senha             VARCHAR(255)    NOT NULL,
  tipo_usuario      VARCHAR(20)     NOT NULL COMMENT 'aluno | professor | admin | funcionario',
  cpf               VARCHAR(11)     NOT NULL,
  CONSTRAINT pk_usuario     PRIMARY KEY (usuario_id),
  CONSTRAINT uq_usuario_email EMAIL UNIQUE (email),
  CONSTRAINT uq_usuario_cpf  UNIQUE (cpf)
) COMMENT = 'Cadastro central de acesso ao sistema';

-- ============================================================
-- MÓDULO ACADÊMICO
-- ============================================================

CREATE TABLE tb_curso (
  curso_id            INT           NOT NULL AUTO_INCREMENT,
  nome_curso          VARCHAR(100)  NOT NULL,
  carga_horaria       INT           NOT NULL,
  duracao_semestres   INT           NOT NULL,
  CONSTRAINT pk_curso PRIMARY KEY (curso_id)
) COMMENT = 'Cursos oferecidos pela instituição';

-- --------------------------------------------------------

CREATE TABLE tb_sala (
  sala_id       INT           NOT NULL AUTO_INCREMENT,
  codigo_sala   VARCHAR(20)   NOT NULL,
  bloco         VARCHAR(10),
  capacidade    INT           NOT NULL,
  tipo_sala     VARCHAR(30)   COMMENT 'aula | laboratorio | auditorio',
  status_sala   VARCHAR(20)   NOT NULL DEFAULT 'ativa',
  CONSTRAINT pk_sala PRIMARY KEY (sala_id)
) COMMENT = 'Salas disponíveis na instituição';

-- --------------------------------------------------------

CREATE TABLE tb_aluno (
  rgm                 INT           NOT NULL,
  usuario_id          INT           NOT NULL,
  nome_aluno          VARCHAR(120)  NOT NULL,
  cpf                 VARCHAR(11)   NOT NULL,
  data_nascimento     DATE          NOT NULL,
  email_institucional VARCHAR(100)  UNIQUE,
  telefone            VARCHAR(15),
  semestre            INT           NOT NULL,
  status_aluno        VARCHAR(20)   NOT NULL DEFAULT 'ativo'
                      COMMENT 'ativo | trancado | formado | evadido | jubilado',
  CONSTRAINT pk_aluno          PRIMARY KEY (rgm),
  CONSTRAINT fk_aluno_usuario  FOREIGN KEY (usuario_id) REFERENCES tb_usuario (usuario_id)
) COMMENT = 'Cadastro de alunos da instituição';

-- --------------------------------------------------------

CREATE TABLE tb_disciplina (
  disciplina_id     INT           NOT NULL AUTO_INCREMENT,
  curso_id          INT           NOT NULL,
  nome_disciplina   VARCHAR(100)  NOT NULL,
  carga_horaria     INT           NOT NULL,
  ementa            VARCHAR(500),
  CONSTRAINT pk_disciplina          PRIMARY KEY (disciplina_id),
  CONSTRAINT fk_disciplina_curso    FOREIGN KEY (curso_id) REFERENCES tb_curso (curso_id)
) COMMENT = 'Disciplinas vinculadas aos cursos';

-- ============================================================
-- MÓDULO DE RECURSOS HUMANOS
-- ============================================================

CREATE TABLE tb_cargo (
  cargo_id            INT             NOT NULL AUTO_INCREMENT,
  nome_cargo          VARCHAR(80)     NOT NULL,
  nivel_hierarquico   VARCHAR(30)     COMMENT 'operacional | tatico | estrategico',
  salario_base        DECIMAL(10,2)   NOT NULL,
  CONSTRAINT pk_cargo PRIMARY KEY (cargo_id)
) COMMENT = 'Cargos da instituição — garante 3FN';

-- --------------------------------------------------------

CREATE TABLE tb_setor (
  setor_id      INT           NOT NULL AUTO_INCREMENT,
  nome_setor    VARCHAR(100)  NOT NULL,
  coordenador   VARCHAR(120),
  area          VARCHAR(60),
  status_setor  VARCHAR(20)   NOT NULL DEFAULT 'ativo',
  CONSTRAINT pk_setor PRIMARY KEY (setor_id)
) COMMENT = 'Setores / departamentos da instituição';

-- --------------------------------------------------------

CREATE TABLE tb_funcionarios (
  funcionario_id      INT           NOT NULL AUTO_INCREMENT,
  cargo_id            INT           NOT NULL,
  setor_id            INT           NOT NULL,
  usuario_id          INT           NOT NULL,
  nome_funcionario    VARCHAR(120)  NOT NULL,
  rg                  VARCHAR(20),
  email_institucional VARCHAR(100)  UNIQUE,
  telefone            VARCHAR(15),
  tipo_contrato       VARCHAR(20)   NOT NULL COMMENT 'CLT | PJ | temporario',
  status_funcionario  VARCHAR(20)   NOT NULL DEFAULT 'ativo'
                      COMMENT 'ativo | inativo | afastado',
  data_criacao        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ultima_atualizacao  TIMESTAMP     ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_funcionarios            PRIMARY KEY (funcionario_id),
  CONSTRAINT fk_funcionarios_cargo      FOREIGN KEY (cargo_id)    REFERENCES tb_cargo    (cargo_id),
  CONSTRAINT fk_funcionarios_setor      FOREIGN KEY (setor_id)    REFERENCES tb_setor    (setor_id),
  CONSTRAINT fk_funcionarios_usuario    FOREIGN KEY (usuario_id)  REFERENCES tb_usuario  (usuario_id)
) COMMENT = 'Colaboradores da instituição';

-- --------------------------------------------------------

CREATE TABLE tb_professores (
  professor_id      INT           NOT NULL AUTO_INCREMENT,
  funcionario_id    INT           NOT NULL,
  registro_mec      VARCHAR(30),
  titulacao         VARCHAR(20)   NOT NULL
                    COMMENT 'graduado | especialista | mestre | doutor',
  area_atuacao      VARCHAR(80),
  status_professor  VARCHAR(20)   NOT NULL DEFAULT 'ativo',
  CONSTRAINT pk_professores             PRIMARY KEY (professor_id),
  CONSTRAINT fk_professores_funcionario FOREIGN KEY (funcionario_id) REFERENCES tb_funcionarios (funcionario_id)
) COMMENT = 'Extensão de funcionários específica para docentes';

-- --------------------------------------------------------

CREATE TABLE tb_historico (
  historico_cargo_id  INT   NOT NULL AUTO_INCREMENT,
  funcionario_id      INT   NOT NULL,
  data_admissao       DATE  NOT NULL,
  data_demissao       DATE,
  CONSTRAINT pk_historico             PRIMARY KEY (historico_cargo_id),
  CONSTRAINT fk_historico_funcionario FOREIGN KEY (funcionario_id) REFERENCES tb_funcionarios (funcionario_id)
) COMMENT = 'Histórico de admissão e demissão de funcionários';

-- --------------------------------------------------------

CREATE TABLE tb_presenca (
  presenca_id       INT             NOT NULL AUTO_INCREMENT,
  funcionario_id    INT             NOT NULL,
  dias_trabalhados  INT             NOT NULL,
  hora_entrada      VARCHAR(5)      NOT NULL COMMENT 'Formato HH:MM',
  hora_ida_almoco   VARCHAR(5),
  hora_volta_almoco VARCHAR(5),
  hora_saida        VARCHAR(5)      NOT NULL,
  horas_trabalhadas DECIMAL(4,2)    NOT NULL,
  CONSTRAINT pk_presenca              PRIMARY KEY (presenca_id),
  CONSTRAINT fk_presenca_funcionario  FOREIGN KEY (funcionario_id) REFERENCES tb_funcionarios (funcionario_id)
) COMMENT = 'Registro de ponto dos funcionários';

-- --------------------------------------------------------

CREATE TABLE tb_folha_pagamento (
  folha_pagamento_id  INT             NOT NULL AUTO_INCREMENT,
  funcionario_id      INT             NOT NULL,
  salario_bruto       DECIMAL(10,2)   NOT NULL,
  descontos           DECIMAL(10,2)   NOT NULL DEFAULT 0,
  salario_liquido     DECIMAL(10,2)   NOT NULL,
  data_pagamento      DATE            NOT NULL,
  codigo_pagamento    VARCHAR(60),
  CONSTRAINT pk_folha_pagamento             PRIMARY KEY (folha_pagamento_id),
  CONSTRAINT fk_folha_pagamento_funcionario FOREIGN KEY (funcionario_id) REFERENCES tb_funcionarios (funcionario_id)
) COMMENT = 'Folha de pagamento mensal dos funcionários';

-- ============================================================
-- MÓDULO ACADÊMICO (cont.) — depende de tb_professores
-- ============================================================

CREATE TABLE tb_turma (
  turma_id        INT           NOT NULL AUTO_INCREMENT,
  disciplina_id   INT           NOT NULL,
  professor_id    INT           NOT NULL,
  sala_id         INT           NOT NULL,
  codigo_turma    VARCHAR(20),
  vagas_totais    INT           NOT NULL,
  vagas_ocupadas  INT           NOT NULL DEFAULT 0,
  status_turma    VARCHAR(20)   NOT NULL DEFAULT 'aberta'
                  COMMENT 'aberta | em_andamento | encerrada',
  CONSTRAINT pk_turma               PRIMARY KEY (turma_id),
  CONSTRAINT fk_turma_disciplina    FOREIGN KEY (disciplina_id)  REFERENCES tb_disciplina  (disciplina_id),
  CONSTRAINT fk_turma_professor     FOREIGN KEY (professor_id)   REFERENCES tb_professores (professor_id),
  CONSTRAINT fk_turma_sala          FOREIGN KEY (sala_id)        REFERENCES tb_sala        (sala_id)
) COMMENT = 'Turmas — instância de uma disciplina em um período';

-- ============================================================
-- MÓDULO FINANCEIRO
-- ============================================================

CREATE TABLE tb_contrato (
  contrato_id     INT           NOT NULL AUTO_INCREMENT,
  aluno_rgm       INT           NOT NULL,
  data_inicio     DATE          NOT NULL,
  data_fim        DATE,
  status_contrato VARCHAR(20)   NOT NULL DEFAULT 'ativo'
                  COMMENT 'ativo | suspenso | encerrado',
  CONSTRAINT pk_contrato        PRIMARY KEY (contrato_id),
  CONSTRAINT fk_contrato_aluno  FOREIGN KEY (aluno_rgm) REFERENCES tb_aluno (rgm)
) COMMENT = 'Contrato educacional entre aluno e instituição';

-- --------------------------------------------------------

CREATE TABLE tb_mensalidade (
  mensalidade_id      INT             NOT NULL AUTO_INCREMENT,
  contrato_id         INT             NOT NULL,
  valor_bruto         DECIMAL(10,2)   NOT NULL,
  valor_desconto      DECIMAL(10,2)   NOT NULL DEFAULT 0,
  valor_final         DECIMAL(10,2)   NOT NULL,
  data_vencimento     DATE            NOT NULL,
  status_mensalidade  VARCHAR(20)     NOT NULL DEFAULT 'pendente'
                      COMMENT 'pendente | paga | atrasada | cancelada',
  CONSTRAINT pk_mensalidade           PRIMARY KEY (mensalidade_id),
  CONSTRAINT fk_mensalidade_contrato  FOREIGN KEY (contrato_id) REFERENCES tb_contrato (contrato_id)
) COMMENT = 'Mensalidades geradas pelo contrato';

-- --------------------------------------------------------

CREATE TABLE tb_pagamentos (
  pagamento_id      INT             NOT NULL AUTO_INCREMENT,
  mensalidade_id    INT             NOT NULL,
  valor_pago        DECIMAL(10,2)   NOT NULL,
  data_pagamento    TIMESTAMP       NOT NULL,
  forma_pagamento   VARCHAR(20)     NOT NULL
                    COMMENT 'boleto | pix | cartao | transferencia',
  codigo_transacao  VARCHAR(60),
  CONSTRAINT pk_pagamentos              PRIMARY KEY (pagamento_id),
  CONSTRAINT fk_pagamentos_mensalidade  FOREIGN KEY (mensalidade_id) REFERENCES tb_mensalidade (mensalidade_id)
) COMMENT = 'Registro dos pagamentos realizados';

-- --------------------------------------------------------

CREATE TABLE tb_inadimplencia (
  inadimplencia_id    INT             NOT NULL AUTO_INCREMENT,
  mensalidade_id      INT             NOT NULL,
  dias_atraso         INT             NOT NULL,
  valor_devido        DECIMAL(10,2)   NOT NULL,
  data_registro       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status_cobranca     VARCHAR(20)     NOT NULL DEFAULT 'em_aberto'
                      COMMENT 'em_aberto | negociando | quitado | protestado',
  ultima_atualizacao  TIMESTAMP       ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_inadimplencia             PRIMARY KEY (inadimplencia_id),
  CONSTRAINT fk_inadimplencia_mensalidade FOREIGN KEY (mensalidade_id) REFERENCES tb_mensalidade (mensalidade_id)
) COMMENT = 'Registro de inadimplências';

-- --------------------------------------------------------

CREATE TABLE tb_negociacao (
  negociacao_id       INT             NOT NULL AUTO_INCREMENT,
  inadimplencia_id    INT             NOT NULL,
  numero_parcelas     INT             NOT NULL,
  valor_total         DECIMAL(10,2)   NOT NULL,
  valor_parcela       DECIMAL(10,2)   NOT NULL,
  data_negociacao     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status_negociacao   VARCHAR(20)     NOT NULL DEFAULT 'em_andamento'
                      COMMENT 'em_andamento | cumprida | quebrada',
  CONSTRAINT pk_negociacao                PRIMARY KEY (negociacao_id),
  CONSTRAINT fk_negociacao_inadimplencia  FOREIGN KEY (inadimplencia_id) REFERENCES tb_inadimplencia (inadimplencia_id)
) COMMENT = 'Negociação de dívidas inadimplentes';

-- ============================================================
-- MÓDULO ACADÊMICO (cont.) — depende de tb_contrato e tb_turma
-- ============================================================

CREATE TABLE tb_matricula (
  matricula_id        INT           NOT NULL AUTO_INCREMENT,
  aluno_rgm           INT           NOT NULL,
  turma_id            INT           NOT NULL,
  status_matricula    VARCHAR(20)   NOT NULL DEFAULT 'ativa'
                      COMMENT 'ativa | trancada | cancelada | concluida',
  data_matricula      DATE          NOT NULL,
  ultima_atualizacao  TIMESTAMP     ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_matricula           PRIMARY KEY (matricula_id),
  CONSTRAINT fk_matricula_aluno     FOREIGN KEY (aluno_rgm)  REFERENCES tb_aluno  (rgm),
  CONSTRAINT fk_matricula_turma     FOREIGN KEY (turma_id)   REFERENCES tb_turma  (turma_id)
) COMMENT = 'Entidade associativa — Aluno N:N Turma';

-- --------------------------------------------------------

CREATE TABLE tb_nota (
  nota_id             INT             NOT NULL AUTO_INCREMENT,
  matricula_id        INT             NOT NULL,
  nota_A1             DECIMAL(4,2)    CHECK (nota_A1 BETWEEN 0 AND 10),
  nota_A2             DECIMAL(4,2)    CHECK (nota_A2 BETWEEN 0 AND 10),
  nota_AF             DECIMAL(4,2)    CHECK (nota_AF BETWEEN 0 AND 10),
  nota_final          DECIMAL(4,2)    CHECK (nota_final BETWEEN 0 AND 10),
  media_final         DECIMAL(4,2)    CHECK (media_final BETWEEN 0 AND 10),
  status_nota         VARCHAR(20)     COMMENT 'aprovado | reprovado | em_recuperacao',
  data_lancamento     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
  ultima_atualizacao  TIMESTAMP       ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_nota          PRIMARY KEY (nota_id),
  CONSTRAINT fk_nota_matricula FOREIGN KEY (matricula_id) REFERENCES tb_matricula (matricula_id)
) COMMENT = 'Notas do aluno por matrícula';

-- --------------------------------------------------------

CREATE TABLE tb_frequencia (
  frequencia_id       INT             NOT NULL AUTO_INCREMENT,
  matricula_id        INT             NOT NULL,
  total_aulas         INT             NOT NULL,
  total_faltas        INT             NOT NULL DEFAULT 0,
  percentual_presenca DECIMAL(5,2),
  status_frequencia   VARCHAR(30)     COMMENT 'regular | em_risco | reprovado_falta',
  ultima_atualizacao  TIMESTAMP       ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_frequencia          PRIMARY KEY (frequencia_id),
  CONSTRAINT fk_frequencia_matricula FOREIGN KEY (matricula_id) REFERENCES tb_matricula (matricula_id)
) COMMENT = 'Frequência do aluno por matrícula';

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
