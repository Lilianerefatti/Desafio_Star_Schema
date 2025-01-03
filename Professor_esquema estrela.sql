-- Drop database star_schema;
show Databases;
CREATE DATABASE star_schema;
USE star_schema; 

-- Criando a Tabela Dim_Professor --
CREATE TABLE Dim_Professor (
    id_professor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    formacao VARCHAR(100),
    data_nascimento DATE,
    sexo ENUM('Masculino', 'Feminino'),
    status_contratual ENUM('Permanente', 'Temporário')
);
desc Dim_Professor;

-- Criando a Tabela Dim_Curso --
CREATE TABLE Dim_Curso (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nome_curso VARCHAR(100) NOT NULL,
    nivel ENUM('Graduação', 'Pós-graduação'),
    modalidade ENUM('Presencial', 'Online', 'Híbrido')
);
desc Dim_Curso;

-- Criando a Tabela Dim_Departamento --
CREATE TABLE Dim_Departamento (
    id_departamento INT AUTO_INCREMENT PRIMARY KEY,
    nome_departamento VARCHAR(100) NOT NULL,
    sigla VARCHAR(10)
);
desc Dim_Departamento;

-- Criando a Tabela Dim_Periodo --
CREATE TABLE Dim_Periodo (
    id_periodo INT AUTO_INCREMENT PRIMARY KEY,
    ano INT,
    semestre ENUM('1º', '2º'),
    inicio_periodo DATE,
    fim_periodo DATE
);
Desc Dim_Periodo;

-- Criando a tabela de datas --
CREATE TABLE Dim_Data (
    id_data_oferta INT AUTO_INCREMENT PRIMARY KEY,
    data DATE,
    dia INT,
    mes INT,
    ano INT,
    trimestre ENUM('1º', '2º', '3º', '4º'),
    semestre ENUM('1º', '2º'),
    nome_mes VARCHAR(20),
    nome_dia VARCHAR(20),
    id_periodo INT,  -- Nova chave estrangeira para relacionar com Dim_Periodo
    FOREIGN KEY (id_periodo) REFERENCES Dim_Periodo(id_periodo)  -- Relacionamento com Dim_Periodo
);
Desc Dim_Data;

-- Criando a Tabela Fato --
CREATE TABLE Fato_Professor (
    id_fato INT AUTO_INCREMENT PRIMARY KEY,
    id_professor INT,
    id_curso INT,
    id_departamento INT,
    id_periodo INT,
    qtd_aulas INT,
    qtd_horas INT,
    avaliacao_curso DECIMAL(3, 2),
    
    FOREIGN KEY (id_professor) REFERENCES Dim_Professor(id_professor),
    FOREIGN KEY (id_curso) REFERENCES Dim_Curso(id_curso),
    FOREIGN KEY (id_departamento) REFERENCES Dim_Departamento(id_departamento),
    FOREIGN KEY (id_periodo) REFERENCES Dim_Periodo(id_periodo)
);

-- Inserindo dados nas tabelas dimensões --
-- Inserindo dados na tabela Dim_Professor
INSERT INTO Dim_Professor (nome, formacao, data_nascimento, sexo, status_contratual)
	VALUES 
	('João Silva', 'Mestre em Computação', '1985-04-15', 'Masculino', 'Permanente'),
	('Maria Oliveira', 'Doutora em Engenharia', '1982-11-23', 'Feminino', 'Temporário'),
	('Carlos Souza', 'Mestre em Matemática', '1990-07-01', 'Masculino', 'Permanente'),
	('Ana Costa', 'Doutora em Física', '1987-01-10', 'Feminino', 'Permanente');

-- Inserindo dados na tabela Dim_Curso
INSERT INTO Dim_Curso (nome_curso, nivel, modalidade)
	VALUES 
	('Algoritmos Avançados', 'Pós-graduação', 'Presencial'),
	('Redes de Computadores', 'Graduação', 'Online'),
	('Cálculo I', 'Graduação', 'Presencial'),
	('Física Experimental', 'Pós-graduação', 'Híbrido');

-- Inserindo dados na tabela Dim_Departamento
INSERT INTO Dim_Departamento (nome_departamento, sigla)
	VALUES 
	('Departamento de Computação', 'DCC'),
	('Departamento de Engenharia', 'DE'),
	('Departamento de Matemática', 'DM'),
	('Departamento de Física', 'DF');

-- Inserindo dados na tabela Dim_Periodo
INSERT INTO Dim_Periodo (ano, semestre, inicio_periodo, fim_periodo)
	VALUES 
	(2023, '1º', '2023-01-01', '2023-06-30'),
	(2023, '2º', '2023-07-01', '2023-12-31');
    
-- Inserindo dados na tabela Dim_Data
INSERT INTO Dim_Data (data, dia, mes, ano, trimestre, semestre, nome_mes, nome_dia, id_periodo)
	VALUES 
	('2023-01-15', 15, 1, 2023, '1º', '1º', 'Janeiro', 'Domingo', 1), 
	('2023-03-20', 20, 3, 2023, '1º', '1º', 'Março', 'Segunda-feira', 1),
	('2023-06-10', 10, 6, 2023, '2º', '1º', 'Junho', 'Sábado', 1),
	('2023-08-05', 5, 8, 2023, '3º', '2º', 'Agosto', 'Sábado', 2),
	('2023-10-10', 10, 10, 2023, '3º', '2º', 'Outubro', 'Terça-feira', 2);

-- Inserindo dados na tabela Fato --
INSERT INTO Fato_Professor (id_professor, id_curso, id_departamento, id_periodo, qtd_aulas, qtd_horas, avaliacao_curso)
	VALUES 
	(1, 1, 1, 1, 30, 90, 4.5),  -- João Silva, Algoritmos Avançados, Computação, 1º Semestre, 30 aulas, 90 horas, Avaliação 4.5
	(2, 2, 1, 1, 20, 60, 4.0),  -- Maria Oliveira, Redes de Computadores, Computação, 1º Semestre, 20 aulas, 60 horas, Avaliação 4.0
	(3, 3, 3, 2, 25, 75, 4.8),  -- Carlos Souza, Cálculo I, Matemática, 2º Semestre, 25 aulas, 75 horas, Avaliação 4.8
	(4, 4, 4, 2, 18, 54, 5.0);  -- Ana Costa, Física Experimental, Física, 2º Semestre, 18 aulas, 54 horas, Avaliação 5.0

-- Realizando consultas --
-- Total de aulas ministradas por professor --
SELECT p.nome, SUM(f.qtd_aulas) AS total_aulas
FROM Fato_Professor f
JOIN Dim_Professor p ON f.id_professor = p.id_professor
GROUP BY p.id_professor;

-- Média de avaliação dos cursos por departamento --
SELECT d.nome_departamento, AVG(f.avaliacao_curso) AS media_avaliacao
FROM Fato_Professor f
JOIN Dim_Departamento d ON f.id_departamento = d.id_departamento
GROUP BY d.id_departamento;

-- Número total de horas de aula ministradas por curso --
SELECT c.nome_curso, SUM(f.qtd_horas) AS total_horas
FROM Fato_Professor f
JOIN Dim_Curso c ON f.id_curso = c.id_curso
GROUP BY c.id_curso;

-- Número de aulas ministradas por professor e curso --
SELECT p.nome, c.nome_curso, SUM(f.qtd_aulas) AS total_aulas
FROM Fato_Professor f
JOIN Dim_Professor p ON f.id_professor = p.id_professor
JOIN Dim_Curso c ON f.id_curso = c.id_curso
GROUP BY p.id_professor, c.id_curso;

-- Avaliação média dos cursos por semestre --
SELECT per.ano, per.semestre, AVG(f.avaliacao_curso) AS media_avaliacao
FROM Fato_Professor f
JOIN Dim_Periodo per ON f.id_periodo = per.id_periodo
GROUP BY per.ano, per.semestre;

-- Número total de aulas ministradas por departamento --
SELECT d.nome_departamento, SUM(f.qtd_aulas) AS total_aulas
FROM Fato_Professor f
JOIN Dim_Departamento d ON f.id_departamento = d.id_departamento
GROUP BY d.id_departamento;

-- Desempenho por tipo de contrato (Permanente vs Temporário) --
SELECT p.status_contratual, AVG(f.avaliacao_curso) AS media_avaliacao
FROM Fato_Professor f
JOIN Dim_Professor p ON f.id_professor = p.id_professor
GROUP BY p.status_contratual;

-- Quantidade de horas de aula por departamento e período --
SELECT d.nome_departamento, per.ano, per.semestre, SUM(f.qtd_horas) AS total_horas
FROM Fato_Professor f
JOIN Dim_Departamento d ON f.id_departamento = d.id_departamento
JOIN Dim_Periodo per ON f.id_periodo = per.id_periodo
GROUP BY d.id_departamento, per.id_periodo;

-- Número de aulas ministradas por professor em cada semestre --
SELECT p.nome, per.ano, per.semestre, SUM(f.qtd_aulas) AS total_aulas
FROM Fato_Professor f
JOIN Dim_Professor p ON f.id_professor = p.id_professor
JOIN Dim_Periodo per ON f.id_periodo = per.id_periodo
GROUP BY p.id_professor, per.id_periodo;

-- Cursos ministrados por cada professor em um semestre específico --
SELECT p.nome, c.nome_curso
FROM Fato_Professor f
JOIN Dim_Professor p ON f.id_professor = p.id_professor
JOIN Dim_Curso c ON f.id_curso = c.id_curso
JOIN Dim_Periodo per ON f.id_periodo = per.id_periodo
WHERE per.ano = 2023 AND per.semestre = '1º'
ORDER BY p.nome, c.nome_curso;

-- Total de aulas e horas ministradas por tipo de curso --
SELECT c.nivel, 
       SUM(f.qtd_aulas) AS total_aulas, 
       SUM(f.qtd_horas) AS total_horas
FROM Fato_Professor f
JOIN Dim_Curso c ON f.id_curso = c.id_curso
GROUP BY c.nivel;

-- Número de aulas e avaliação média por tipo de contrato e departamento -- 
SELECT p.status_contratual, d.nome_departamento, 
       SUM(f.qtd_aulas) AS total_aulas, 
       AVG(f.avaliacao_curso) AS media_avaliacao
FROM Fato_Professor f
JOIN Dim_Professor p ON f.id_professor = p.id_professor
JOIN Dim_Departamento d ON f.id_departamento = d.id_departamento
GROUP BY p.status_contratual, d.id_departamento;

-- Número de professores por departamento --
SELECT d.nome_departamento, COUNT(DISTINCT f.id_professor) AS num_professores
FROM Fato_Professor f
JOIN Dim_Departamento d ON f.id_departamento = d.id_departamento
GROUP BY d.id_departamento;

-- Consulta para verificar os dados de Fato_Professor --
SELECT 
    fp.id_fato,
    p.nome AS professor,
    c.nome_curso,
    d.nome_departamento,
    per.ano,
    per.semestre,
    da.data,
    fp.qtd_aulas,
    fp.qtd_horas,
    fp.avaliacao_curso
FROM Fato_Professor fp
JOIN Dim_Professor p ON fp.id_professor = p.id_professor
JOIN Dim_Curso c ON fp.id_curso = c.id_curso
JOIN Dim_Departamento d ON fp.id_departamento = d.id_departamento
JOIN Dim_Periodo per ON fp.id_periodo = per.id_periodo
JOIN Dim_Data da ON per.id_periodo = da.id_periodo
ORDER BY fp.id_fato;

-- Consulta para verificar o número de aulas ministradas por departamento --
SELECT 
    d.nome_departamento,
    SUM(fp.qtd_aulas) AS total_aulas
FROM Fato_Professor fp
JOIN Dim_Departamento d ON fp.id_departamento = d.id_departamento
GROUP BY d.nome_departamento;

-- Consulta para verificar informações sobre as datas e períodos --
SELECT d.data, d.nome_mes, p.ano, p.semestre
FROM Dim_Data d
JOIN Dim_Periodo p ON d.id_periodo = p.id_periodo
ORDER BY d.data;
