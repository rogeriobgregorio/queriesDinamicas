USE MASTER
GO
DROP DATABASE IF EXISTS queries_dinamicas
GO
CREATE DATABASE queries_dinamicas
GO
USE queries_dinamicas
GO
/*
Exercício:
Considere a tabela Produto com os seguintes atributos:
Produto (Codigo | Nome | Valor)

Considere a tabela ENTRADA e a tabela SAÍDA com os seguintes atributos:
(Codigo_Transacao | Codigo_Produto | Quantidade | Valor_Total)

Cada produto que a empresa compra, entra na tabela ENTRADA. 
Cada produto que a empresa vende, entra na tabela SAIDA.

Criar uma procedure que receba um código 
(‘e’ para ENTRADA e ‘s’ para SAIDA), 
crie uma exceção de erro para código inválido, 
receba o codigo_transacao, codigo_produto 
e a quantidade e preencha a tabela correta, 
com o valor_total de cada transação de cada produto.
*/

CREATE TABLE produtos (
	codigo	INT			 NOT NULL,
	nome	VARCHAR(100) NOT NULL,
	valor	DECIMAL(8,2) NOT NULL,

PRIMARY KEY(codigo)
);
GO

CREATE TABLE entradas (
	codigo_transacao INT			NOT NULL,
	codigo_produto	 INT			NOT NULL,
	quantidade		 INT			NOT NULL,
	valor_total		 DECIMAL(10, 2) NOT NULL,

	PRIMARY KEY(codigo_transacao),
	FOREIGN KEY(codigo_produto) REFERENCES produtos(codigo)
);
GO

CREATE TABLE saidas (
  codigo_transacao INT NOT NULL,
  codigo_produto INT NOT NULL,
  quantidade INT NOT NULL,
  valor_total DECIMAL(10, 2) NOT NULL,

  PRIMARY KEY (codigo_transacao), 
  FOREIGN KEY(codigo_produto) REFERENCES produtos(codigo)
);
GO

CREATE PROCEDURE sp_registrar_transacao
	@tipo_transacao CHAR(1),
	@codigo_transacao INT,
	@codigo_produto INT,
	@quantidade INT
AS
BEGIN
	DECLARE @valor_unitario DECIMAL(10, 2)
	DECLARE @valor_total DECIMAL(10, 2)

	-- Verificar se o tipo de transação é válido
	IF @tipo_transacao NOT IN ('e', 's')
	BEGIN
		RAISERROR('Tipo de transação inválido. Use ''e'' para entrada ou ''s'' para saída.', 16, 1)
		RETURN
	END

	-- Obter o valor unitário do produto
	SELECT @valor_unitario = valor FROM produtos WHERE codigo = @codigo_produto

	-- Calcular o valor total da transação
	SET @valor_total = @valor_unitario * @quantidade

	-- Inserir registro na tabela correta (entrada ou saída)
	IF @tipo_transacao = 'e'
	BEGIN
		INSERT INTO entradas (codigo_transacao, codigo_produto, quantidade, valor_total)
		VALUES (@codigo_transacao, @codigo_produto, @quantidade, @valor_total)
	END
	ELSE
	BEGIN
		INSERT INTO saidas (codigo_transacao, codigo_produto, quantidade, valor_total)
		VALUES (@codigo_transacao, @codigo_produto, @quantidade, @valor_total)
	END
END
