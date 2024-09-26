USE bdEstoque

-- a) Criar uma Stored Procedure para inserir as categorias de produto conforme abaixo:

CREATE PROCEDURE spInserir_Categoria_Produto
	@nomeCategoriaProduto VARCHAR(50)
	AS
	BEGIN
		INSERT INTO tbCategoriaProduto (nomeCategoriaProduto)
			VALUES (@nomeCategoriaProduto)
		PRINT ('Categoria Produto ' + @nomeCategoriaProduto + ' inserido com sucesso')
	END

EXEC spInserir_Categoria_Produto 'Bolo Festa'
EXEC spInserir_Categoria_Produto 'Bolo Simples'
EXEC spInserir_Categoria_Produto 'Torta'
EXEC spInserir_Categoria_Produto 'Salgado'

-- b) Criar uma Stored Procedure para inserir os produtos abaixo, sendo que, a procedure dever� antes de inserir verificar se o nome do produto j� existe, evitando assim que um produto seja duplicado:

CREATE PROCEDURE spInserir_Produto
	@nomeProduto VARCHAR(50)
	, @precoKiloProduto MONEY
	, @codCategoriaProduto INT
	AS
	BEGIN
		IF EXISTS (SELECT nomeProduto FROM tbProduto WHERE nomeProduto LIKE @nomeProduto)
		BEGIN
			PRINT ('Produto ' + @nomeProduto + ' ja existe, tente usar um nome diferente')
		END
		ELSE
		BEGIN
			INSERT INTO tbProduto(nomeProduto, precoKiloProduto, codCategoriaProduto)
				VALUES (@nomeProduto, @precoKiloProduto, @codCategoriaProduto)
			PRINT ('Produto ' + @nomeProduto + ' inserido com sucesso')
		END
	END

EXEC spInserir_Produto 'Bolo Floresta Negra', 42.00, 1
EXEC spInserir_Produto 'Bolo Prestigio', 43.00, 1
EXEC spInserir_Produto 'Bolo Nutella', 44.00, 1
EXEC spInserir_Produto 'Bolo Formigueiro', 17.00, 2
EXEC spInserir_Produto 'Bolo de cenoura', 19.00, 2
EXEC spInserir_Produto 'Torta de palmito', 45.00, 3
EXEC spInserir_Produto 'Torta de frango e catupiry', 47.00, 3
EXEC spInserir_Produto 'Tirta de escarola', 44.00, 3
EXEC spInserir_Produto 'Coxinha de Frango', 25.00, 4
EXEC spInserir_Produto 'Esfiha Carne', 27.00, 4
EXEC spInserir_Produto 'Folhado queijo', 31.00, 4
EXEC spInserir_Produto 'Risoles misto', 29.00, 4


-- c) Criar uma stored procedure para cadastrar os clientes abaixo relacionados, sendo que dever�o ser feitas duas valida��es:
-- - Verificar pelo CPF se o cliente j� existe. Caso j� exista emitir a mensagem: "Cliente cpf XXXXX j� cadastrado" (Acrescentar a coluna CPF)
-- - Verificar se o cliente � morador de Itaquera ou Guaianases, pois a confeitaria n�o realiza entregas para clientes que residam fora desses bairros. Caso o cliente n�o seja morador desses bairros enviar a mensagem "N�o foi poss�vel cadastrar o cliente XXXX pois o bairro XXXX n�o � atendido pela confeitaria"

CREATE PROCEDURE spCadastrar_Cliente
	@nomeCliente VARCHAR(50)
	, @dataNascimentoCliente DATE
	, @ruaCliente VARCHAR(50)
	, @numCasaCliente INT
	, @cepCliente CHAR (8)
	, @bairroCliente VARCHAR (50)
	, @sexoCliente CHAR(1)
	, @cpfCliente CHAR(11)
	AS
	BEGIN
		IF EXISTS (SELECT cpfCliente FROM tbCliente WHERE cpfCliente LIKE @cpfCliente)
		BEGIN
			PRINT ('Cliente cpf  ' + @cpfCliente + ' ja cadastrado')
		END
		ELSE IF (@bairroCliente NOT LIKE 'Guaianases' AND @bairroCliente NOT LIKE 'Itaquera')
		BEGIN
			PRINT ('Nao foi possivel cadastrar o cliente ' + @nomeCliente + ' pois o bairro ' + @bairroCliente + ' nao e atendido pela confeitaria')
		END
		ELSE
		BEGIN
			INSERT INTO tbCliente(nomeCliente, dataNascimentoCliente, ruaCliente, numCasaCliente, cepCliente, bairroCliente, sexoCliente, cpfCliente)
				VALUES (@nomeCliente, @dataNascimentoCliente, @ruaCliente, @numCasaCliente, @cepCliente, @bairroCliente, @sexoCliente, @cpfCliente)
			PRINT ('Cliente ' + @nomeCliente + ' cadastrado com sucesso')
		END
	END

EXEC spCadastrar_Cliente 'Samira Fatah', '05/05/1990', 'Rua Aguapei', 1000, '08.090-000', 'Guaianases', 'F', '12345678900'
EXEC spCadastrar_Cliente 'Cela Nogueira', '06/06/1992', 'Rua Andes', 234, '08.456-090', 'Guaianases', 'F', '23456789012'
EXEC spCadastrar_Cliente 'Paulo Cesar Siqueira', '04/04/1984', 'Rua Castelo do Piaui', 232, '08.109-000', 'Itaquera', 'M', '34567890123'
EXEC spCadastrar_Cliente 'Rodrigo Favavori', '09/04/1991', 'Rua Sanso Castelo Branco', 10, '08.431-090', 'Guaianases', 'M', '45678901234'
EXEC spCadastrar_Cliente 'Flavia Regina Brito', '22/04/1992', 'Rua Mariano Moro', 300, '08.200-123', 'Itaquera', 'F', '56789012345'

-- d) Criar via stored procedure as encomendas abaixo relacionadas, fazendo as verifica��es abaixo: No momento da encomenda o cliente ir� fornecer o seu cpf. Caso ele n�o tenha sido cadastrado enviar a mensagem "n�o foi poss�vel efetivar a encomenda pois o cliente xxxx n�o est� cadastrado"
-- - Verificar se a data de entrega n�o � menor do que a data da encomenda. Caso seja enviar a mensagem "n�o � poss�vel entregar uma encomenda antes da encomenda ser realizada"
-- - Caso tudo esteja correto, efetuar a encomenda e emitir a mensagem: "Encomenda XXX para o cliente YYY efetuada com sucesso" sendo que no lugar de XXX dever� aparecer o n�mero da encomenda e no YYY dever� aparecer o nome do cliente;

CREATE PROCEDURE spCriar_Encomenda
	@dataDaEncomenda DATETIME
	, @cpfCliente CHAR(11)
	, @valorTotalEncomenda MONEY
	, @dataEntregaEncomenda DATETIME
	AS
	BEGIN
		IF NOT EXISTS (SELECT cpfCliente FROM tbCliente WHERE cpfCliente LIKE @cpfCliente)
		BEGIN
			PRINT ('nao e possivel efetivar uma encomenda pois o cliente ' + @cpfCliente + ' nao esta cadastrado')
		END
		ELSE IF (@dataDaEncomenda > @dataEntregaEncomenda)
		BEGIN
			PRINT ('nao � poss�vel entregar uma encomenda antes da encomenda ser realizada')
		END
		ELSE
		BEGIN
			DECLARE @codCliente INT
			DECLARE @codEncomenda INT
			DECLARE @nomeCliente VARCHAR(50)
			SET @codCliente = (SELECT codCliente FROM tbCliente WHERE cpfCliente LIKE @cpfCliente)
			INSERT INTO tbEncomenda(dataEncomenda, codCliente, valorTotalEncomenda, dataEntregaEncomenda)
				VALUES (@dataDaEncomenda, @codCliente, @valorTotalEncomenda, @dataEntregaEncomenda)
			SET @codEncomenda = (SELECT MAX(codEncomenda) FROM tbEncomenda)
			SET @nomeCliente = (SELECT nomeCliente FROM tbCliente WHERE codCliente LIKE @codCliente)
			PRINT ('Encomenda ' + CONVERT(VARCHAR(16), @codEncomenda) + ' para o cliente ' + @nomeCliente + ' efetuada com sucesso')
		END
	END


EXEC spCriar_Encomenda '08/08/2015', '12345678900', 450.00, '15/08/2015'
EXEC spCriar_Encomenda '10/10/2015', '23456789012', 200.00, '15/10/2015'
	

-- e) Ao adicionar a encomenda, criar uma Stored procedure, para que sejam inseridos os itens da encomenda conforme tabela a seguir.
-- Basicamente tem q inserir codEncomenda, codProduto, quantidadeKilos e subTotal
CREATE PROCEDURE spInserir_Itens_Encomenda
	@codEncomenda INT
	, @codProduto INT
	, @quantidadeKilos INT
	, @subTotal MONEY
	AS
	BEGIN
		INSERT INTO tbItensEncomenda(codEncomenda, codProduto , quantidadeKilos, subTotal)
			VALUES (@codEncomenda, @codProduto , @quantidadeKilos, @subTotal)
	END

EXEC spInserir_Itens_Encomenda 1 , 1 , 2.5, 105.00
EXEC spInserir_Itens_Encomenda 1 , 10 , 2.6, 70.00
EXEC spInserir_Itens_Encomenda 1 , 9 , 6, 150.00
EXEC spInserir_Itens_Encomenda 11 , 12 , 4.3, 125.00
EXEC spInserir_Itens_Encomenda 2 , 9 , 8, 200.00
EXEC spInserir_Itens_Encomenda 3 , 11 , 3.2, 100.00
EXEC spInserir_Itens_Encomenda 3 , 9 , 2, 50.00
EXEC spInserir_Itens_Encomenda 4 , 2 , 3.5, 150.00
EXEC spInserir_Itens_Encomenda 4 , 3 , 2.2, 100.00
EXEC spInserir_Itens_Encomenda 5 , 6 , 3.4, 150.00

-- f) Ap�s todos os cadastros, criar Stored procedures para alterar o que se pede:
-- 1- O pre�o dos produtos da categoria "Bolo festa" sofreram um aumento de 10%
-- 2- O pre�o dos produtos categoria "Bolo simples" est�o em promo��o e ter�o um desconto de 20%;
-- 3- O pre�o dos produtos categoria "Torta" aumentaram 25%
-- 4- O pre�o dos produtos categoria "Salgado", com exce��o da esfiha de carne, sofreram um aumento de 20%

CREATE PROCEDURE spMudar_Preco_Categoria
	@nomeCategoriaProduto VARCHAR(50)
	, @porcentagemMudanca REAL
	AS
	BEGIN
		DECLARE @codCategoriaProduto INT
		SET @codCategoriaProduto = (SELECT codCategoriaProduto FROM tbCategoriaProduto WHERE nomeCategoriaProduto = @nomeCategoriaProduto)

		UPDATE tbProduto
			SET precoKiloProduto = precoKiloProduto + (precoKiloProduto * @porcentagemMudanca / 100)
			WHERE codCategoriaProduto = @codCategoriaProduto
	END

EXEC spMudar_Preco_Categoria 'Bolo Festa', 10
EXEC spMudar_Preco_Categoria 'Bolo Simples', -20
EXEC spMudar_Preco_Categoria 'Torta', 25
EXEC spMudar_Preco_Categoria 'Salgado', 20

-- g) Criar uma procedure para excluir clientes pelo CPF sendo que:
-- 1- Caso o cliente possua encomendas emitir a mensagem "Impossivel remover esse cliente pois o cliente XXXXX possui encomendas; onde XXXXX � o nome do cliente.
-- 2- Caso o cliente n�o possua encomendas realizar a remo��o e emitir a mensagem "Cliente XXXX removido com sucesso", onde XXXX � o nome do cliente;

CREATE PROCEDURE spExcluir_Cliente
	@cpfCliente CHAR(11)
	AS
	BEGIN
		DECLARE @nomeCliente VARCHAR(50)
		SET @nomeCliente = (SELECT nomeCliente FROM tbCliente WHERE @cpfCliente LIKE cpfCliente)

		IF EXISTS (SELECT codEncomenda FROM tbCliente
			INNER JOIN tbEncomenda ON tbCliente.codCliente = tbEncomenda.codCliente
			WHERE cpfCliente LIKE @cpfCliente)
		BEGIN
			PRINT('Impossivel remover esse cliente pois o cliente ' + @nomeCliente + ' possui encomendas')
		END
		ELSE
		BEGIN
			DELETE FROM tbCliente WHERE cpfCliente LIKE @cpfCliente
			PRINT('Cliente ' + @nomeCliente + ' removido com sucesso')
		END
	END

EXEC spExcluir_Cliente '12345678900'

-- h) Criar uma procedure que permita excluir qualquer item de uma encomenda cuja data de entrega seja maior que a data atual. Para tal o cliente dever� fornecer o c�digo da encomenda e o c�digo do produto que ser� exclu�do da encomenda. A procedure dever� remover o item e atualizar o valor total da encomenda, do qual dever� ser subtra�do o valor do item a ser removido. A procedure poder� remover apenas um item da encomenda de cada vez.
	
CREATE PROCEDURE spExcluir_Encomenda
	@codEncomenda INT
	, @codProduto INT
	AS
	BEGIN
		DECLARE @dataEncomenda DATETIME
		SET @dataEncomenda = (SELECT dataEncomenda FROM tbEncomenda WHERE @codEncomenda LIKE codEncomenda)

		DECLARE @dataEntregaEncomenda DATETIME
		SET @dataEntregaEncomenda = (SELECT dataEntregaEncomenda FROM tbEncomenda WHERE @codEncomenda LIKE codEncomenda)

		DECLARE @precoKiloProduto MONEY
		SET @precoKiloproduto = (SELECT precoKiloproduto FROM tbProduto WHERE @codProduto LIKE codProduto)

		IF (@dataEncomenda > @dataEntregaEncomenda)
		BEGIN
			DELETE FROM tbItensEncomenda WHERE @codProduto = codProduto AND @codEncomenda = codEncomenda

			UPDATE tbItensEncomenda
			SET subTotal = subTotal - @precoKiloproduto
			WHERE codProduto = @codProduto 

			PRINT ('Produto de ID ' + @codProduto + ' removido com sucesso')
		END
		ELSE
		BEGIN 
			PRINT ('Nao foi possivel concluir a acao')
		END
	END