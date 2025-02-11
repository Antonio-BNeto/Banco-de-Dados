
-- Questão 1

CREATE TABLE tarefas (
    id_tarefas INTEGER,
    funcao TEXT,
    codigo CHAR(11),
    numero INTEGER,
    categoria CHAR(1)
);

-- As iserções abaixo devem ser executadas

INSERT INTO tarefas VALUES (2147483646, 'limpar chão do corredor central',
'98765432111', 0, 'F');

INSERT INTO tarefas VALUES (2147483647, 'limpar janelas da sala 203',
'98765432122', 1, 'F');

INSERT INTO tarefas VALUES (null, null, null, null, null);

-- As inserçẽs abaixo não devem ser executadas.

INSERT INTO tarefas VALUES (2147483644, 'limpar chão do corredor superior', -- inserção não realizada
'987654323211', 0, 'F');

INSERT INTO tarefas VALUES (2147483643, 'limpar chão do corredor superior', --  inserção não realizada
'98765432321', 0, 'FF');

-- Questão 2

-- Função funcionou após a execução da solução
INSERT INTO tarefas VALUES (2147483648, 'limpar portas do térreo', '32323232955', 4,
'A');

-- Erro mostrado:
/*
ERROR:  integer out of range
*/

-- Significado do erro

/*
Como o atributo id_tarefa foi atribuido do tipo INTEGER então está restrito
a valores de -2147483648 to +2147483647 e como o INSERT utilizado está no escopo
maior que o permitido se torna preciso alterar o tipo de atributo de INTEGER para 
BIGINT que tem o intervalo fechado entre -9223372036854775808 e +9223372036854775807
fazendo com que o se torne muito mais dificil de da erro.
*/

-- Solução do erro:
--Solução está correta
ALTER TABLE tarefas ALTER COLUMN id_tarefas TYPE BIGINT;

-- Questão 3

/*
Como o intervalo que o atributo "numero" aceita é de no máximo 32767, então 
o tipo que se encaixa melhor com o atributo é o SMALLINT que tem o
intervalo fechado de -32768 até +32767.
*/

ALTER TABLE tarefas ALTER COLUMN numero TYPE SMALLINT;

-- Inserções que não devem ser executadas.
INSERT INTO tarefas VALUES (2147483649, 'limpar portas da entrada principal','32322525199', 32768, 'A');
INSERT INTO tarefas VALUES (2147483650, 'limpar janelas da entrada principal', '32333233288', 32769, 'A');

-- Inserções que devem ser executadas.
INSERT INTO tarefas VALUES (2147483651, 'limpar portas do 1o andar','32323232911', 32767, 'A');
INSERT INTO tarefas VALUES (2147483652, 'limpar portas do 2o andar', '32323232911', 32766, 'A');

-- Questão 4

-- Utilizando o RENAME para alterar o nome dos atributos

ALTER TABLE tarefas RENAME COLUMN id_tarefas TO id;
ALTER TABLE tarefas RENAME COLUMN funcao TO descricao;
ALTER TABLE tarefas RENAME COLUMN codigo TO func_resp_cpf;
ALTER TABLE tarefas RENAME COLUMN numero TO prioridade;
ALTER TABLE tarefas RENAME COLUMN categoria TO status;

-- Criando a constrain para que o atributo não seja null

ALTER TABLE tarefas ALTER COLUMN id SET NOT NULL;
ALTER TABLE tarefas ALTER COLUMN descricao SET NOT NULL;
ALTER TABLE tarefas ALTER COLUMN func_resp_cpf SET NOT NULL;
ALTER TABLE tarefas ALTER COLUMN prioridade SET NOT NULL;
ALTER TABLE tarefas ALTER COLUMN status SET NOT NULL;

-- Erro mostrado:

/*
ERRO: column "atributos" of relation "tarefas" contains null values
*/

-- Significado do erro:

/*
Não é possivel fazer com que uma coluna seja  NOT NULL enquanto existir tuplas
com valores NULL nesta coluna.
*/

-- Solução:

/*
Remove as tuplas com base em alguma condição definida pelo WHERE,
assim eu o utilizei para remover as tuplas que possuiam valores NULL.
*/
DELETE FROM tarefas
WHERE
    id IS NULL OR
    descricao IS NULL OR
    func_resp_cpf IS NULL OR
    prioridade IS NULL OR
    status IS NULL;

-- Questão 5

-- Adicionando restrição de integridade no atributo "id"

ALTER TABLE tarefas ADD PRIMARY KEY (id);

-- inserção deve funcionar normalmente
INSERT INTO tarefas VALUES (2147483653, 'limpar portas do 1o andar','32323232911', 2, 'A');

-- inserção não deve funcionar após o insert anterior ter sido executado
INSERT INTO tarefas VALUES (2147483653, 'aparar a grama da área frontal', '32323232911', 3, 'A');


--Questão 6

-- Letra (A)

-- Utilizando CHECK para realizar a constraint.
ALTER TABLE tarefas ADD CHECK (LENGTH(func_resp_cpf) = 11);

-- Testando a constrain

-- func_resp_cpf com tamanho 10
INSERT INTO tarefas VALUES (2147483653, 'aparar a grama da área frontal', '3232323291', 3, 'A');

-- func_resp_cpf com tamanho 11
INSERT INTO tarefas VALUES (2300000000, 'aparar a grama da área frontal', '32323232911', 3, 'A');

-- func_resp_cpf com tamanho 12
INSERT INTO tarefas VALUES (2147483653, 'aparar a grama da área frontal', '323232329112', 3, 'A');

-- Retirando as tuplas inseridas na tabela
DELETE FROM tarefas WHERE id=2300000000;

-- Letra (B)

-- Alterando os valores da coluna de status

UPDATE tarefas SET status = 'P' WHERE status = 'A';
UPDATE tarefas SET status = 'E' WHERE status = 'R';
UPDATE tarefas SET status = 'C' WHERE status = 'F';

-- Adicionando CHECK para evitar erros durante inserções

ALTER TABLE tarefas ADD CHECK (status IN ('P','E','C'));

-- Questão 7

-- Arrumando as tuplas com prioridade maior que 5
UPDATE tarefas SET prioridade = 5 where prioridade > 5;

-- Adicionando a constrain para que só seja inserido uma tupla com prioridade entre 0 e 5
ALTER TABLE tarefas ADD CHECK (prioridade >= 0 AND prioridade <= 5);

-- Questão 8

CREATE TABLE funcionario (
    cpf CHAR(11) PRIMARY KEY,
    data_nasc DATE NOT NULL,
    nome VARCHAR(120) NOT NULL,
    funcao char(11) NOT NULL,
    nivel char(1) NOT NULL,
    superior_cpf CHAR(11) REFERENCES funcionario (cpf),

    CHECK(funcao = 'SUP_LIMPEZA' or (funcao = 'LIMPEZA' AND superior_cpf IS NOT NULL)),
    CHECK(nivel IN ('J', 'P', 'S'))
);

-- devem funcionar:
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES ('12345678911', '1980-05-07', 'Pedro da Silva', 'SUP_LIMPEZA', 'S', null);
INSERT INTO funcionario(cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES ('12345678912', '1980-03-08', 'Jose da Silva', 'LIMPEZA', 'J', '12345678911');

-- não deve funcionar
INSERT INTO funcionario(cpf, data_nasc, nome, funcao, nivel, superior_cpf) VALUES ('12345678913', '1980-04-09', 'joao da Silva', 'LIMPEZA', 'J', null);

-- Questão 9

-- Realizando a inserção de 10 tuplas válidas
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) 
VALUES
  ('12345678913', '1997-03-05', 'Rafael', 'SUP_LIMPEZA', 'S', null),
  ('12345678914', '1998-04-10', 'Igor', 'SUP_LIMPEZA', 'S', '12345678913'),
  ('12345678915', '1999-05-23', 'Ewerton', 'SUP_LIMPEZA', 'P', null),
  ('12345678916', '2000-06-01', 'Pedro', 'LIMPEZA', 'J', '12345678914'),
  ('12345678917', '2001-07-28', 'Rafaella', 'SUP_LIMPEZA', 'J', null),
  ('12345678918', '2002-08-22', 'Mariana', 'LIMPEZA', 'P', '12345678913'),
  ('12345678919', '2003-09-21', 'Victor', 'SUP_LIMPEZA', 'S', null),
  ('12345678920', '2004-10-19', 'Roberto', 'LIMPEZA', 'P', '12345678919'),
  ('12345678921', '2005-11-18', 'Leon', 'SUP_LIMPEZA', 'P', null),
  ('12345678922', '2006-12-17', 'Bruce Wayne', 'SUP_LIMPEZA', 'J', '12345678919'); -- inserção realizada
  
-- 10 exemplos de inserções que não funcionam

INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf) 
VALUES
    ('12345678923', '2004-10-19', 'Ronaldo', 'SUP_LIMPEZA', 'A', null),
    ('12345678924', '2004-10-19', 'Elisa', 'LIMPEZA', 'S', null),
    ('12345678925', '2004-10-19', 'Raissa', 'LIMPEZA', 'J', '12345675820'),
    ('12345678913', '2004-10-19', 'Afonso Pereira', 'SUP_LIMPEZA', 'P', null),
    ('12345678932', '2004-10-19', 'Bianca', 'GERENTE', 'J', null),
    (null, '2004-10-19', 'Jorge', 'SUP_LIMPEZA', 'S', null),
    ('12345678928', null, 'Fernanda', 'SUP_LIMPEZA', 'P', null),
    ('12345678929', '2004-10-19', null, 'SUP_LIMPEZA', 'P', null),
    ('12345678930', '2004-10-19', 'Douglas', null, 'J', null),
    ('12345678931', '2004-10-19', 'Arthur', 'SUP_LIMPEZA', null, null);

-- Questão 10

INSERT INTO funcionario(cpf, data_nasc, nome, funcao, nivel, superior_cpf)
VALUES('32323232911', '1967-06-22', 'Mirieny', 'SUP_LIMPEZA', 'S', NULL);

INSERT INTO funcionario(cpf, data_nasc, nome, funcao, nivel, superior_cpf)
VALUES('98765432111', '1988-07-30', 'Niela', 'LIMPEZA', 'P', '32323232911');

INSERT INTO funcionario(cpf, data_nasc, nome, funcao, nivel, superior_cpf)
VALUES('98765432122', '1998-08-27', 'Jé', 'LIMPEZA', 'P', '32323232911');

-- (Opção 1) ON DELETE CASCADE

-- Adicionando a chave estrangeira
ALTER TABLE tarefas ADD CONSTRAINT tarefa_fkey_func_resp_cpf FOREIGN KEY (func_resp_cpf) REFERENCES funcionario(cpf) ON DELETE CASCADE;

--Erro mostrado:
/*
ERROR:  insert or update on table "tarefas" violates foreign key constraint "tarefas_fkey_func_resp_cpf"
DETAIL:  Key (func_resp_cpf)=(32323232955) is not present in table "funcionario".
*/

--Significado do erro:

/*
os cpfs que tão na tabela tarefas não estão 
na coluna da tabela funcionario.
*/

-- Solução

-- Adicionando funcionarios que tem cpf existentes na coluna func_resp_cpf da tabela tarefas
INSERT INTO funcionario (cpf, data_nasc, nome, funcao, nivel, superior_cpf)
VALUES
    ('32323232955', '1997-03-05', 'Rafael', 'SUP_LIMPEZA', 'S', null),
    ('32323232911', '1998-04-10', 'Igor', 'SUP_LIMPEZA', 'S', '12345678911'),
    ('98765432111', '1999-05-23', 'Ewerton', 'LIMPEZA', 'J', '12345678911'),
    ('98765432122', '2000-06-01', 'Pedro', 'SUP_LIMPEZA', 'P', null);


-- Realizando a remoção do funcionario com o 'menor' cpf que possui alguma tarefa

-- Encontrando o funcionario
SELECT f.*FROM funcionario f INNER JOIN tarefas t ON
f.cpf = t.func_resp_cpf GROUP BY f.cpf ORDER BY CAST(f.cpf AS DECIMAL) LIMIT 1;

-- Saida da busca
/*
 cpf     | data_nasc  | nome |   funcao    | nivel | superior_cpf
-------------+------------+------+-------------+-------+--------------
 32323232911 | 1998-04-10 | Igor | SUP_LIMPEZA | S     | 12345678911
*/

-- Deletando o funcionario encontrado
DELETE FROM funcionario f WHERE f.cpf = '32323232911';

-- (Opção 2) ON DELETE RESTRICT

-- Adicionando a chave estrangeira 
ALTER TABLE tarefas DROP CONSTRAINT tarefas_func_resp_cpf_fkey;
ALTER TABLE tarefas ADD FOREIGN KEY (func_resp_cpf) REFERENCES funcionario (cpf) ON DELETE RESTRICT;

-- Executando um comando DELETE que seja bloqueado pela constraint.

-- Buscando funcionarios que tem os resquisitos
SELECT f.* FROM funcionario f INNER JOIN tarefas t ON
f.cpf = t.func_resp_cpf GROUP BY f.cpf;

-- Saida da busca
/*
  cpf     | data_nasc  |  nome   |   funcao    | nivel | superior_cpf
-------------+------------+---------+-------------+-------+--------------
 32323232955 | 1997-03-05 | Rafael  | SUP_LIMPEZA | S     |
 98765432111 | 1999-05-23 | Ewerton | LIMPEZA     | J     | 12345678911
 98765432122 | 2000-06-01 | Pedro   | SUP_LIMPEZA | P     |
*/

-- Deletando o funcionario Rafael
DELETE FROM funcionario f WHERE f.cpf = '32323232955';

--- Questão 11

-- Removendo da tabela tarefas o NOT NULL da coluna func_resp_cpf
ALTER TABLE tarefas ALTER COLUMN func_resp_cpf DROP NOT NULL;

-- A coluna func_resp_cpf pode ser NULL somente se status for igual a 'P'

-- Removendo a constraint existente da coluna status para adicionala novamente acrescentando a condição imposta na coluna func_resp_cpf
ALTER TABLE tarefas DROP CONSTRAINT tarefas_status_check;
-- Adicionando a constraint pedida na questão
ALTER TABLE tarefas ADD CHECK ((status IN ('E', 'C') AND func_resp_cpf IS NOT NULL) OR status = 'P');

--- ON DELETE SET NULL

-- Adicionando a chave estrangeira de acordo com a questão
ALTER TABLE tarefas DROP CONSTRAINT tarefas_func_resp_cpf_fkey;
ALTER TABLE tarefas ADD FOREIGN KEY (func_resp_cpf) REFERENCES funcionario (cpf) ON DELETE SET NULL;