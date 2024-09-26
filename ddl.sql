CREATE DATABASE bdEstoque
GO

--USE master
--DROP DATABASE bdEstoque

USE bdEstoque

CREATE TABLE tbCliente (
	codCliente INT PRIMARY KEY IDENTITY(1,1)
	, nomeCliente VARCHAR(50)
	, dataNascimentoCliente DATE
	, ruaCliente VARCHAR (50)
	, numCasaCliente INT
	, cepCliente CHAR (8)
	, bairroCliente VARCHAR (50)
	, cidadeCliente VARCHAR (50)
	, estadoCliente VARCHAR (50)
	, cpfCliente CHAR(11)
	, sexoCliente CHAR(1)
)
--DROP TABLE tbCliente

CREATE TABLE tbEncomenda (
	codEncomenda INT PRIMARY KEY IDENTITY(1,1)
	, dataEncomenda DATETIME
	, codCliente INT FOREIGN KEY REFERENCES tbCliente(codCliente)
	, valorTotalEncomenda MONEY
	, dataEntregaEncomenda DATETIME
)
--DROP TABLE tbEncomenda

CREATE TABLE tbCategoriaProduto (
	codCategoriaProduto INT PRIMARY KEY IDENTITY(1,1)
	,nomeCategoriaProduto VARCHAR(50)
)
--DROP TABLE tbCategoriaProduto

CREATE TABLE tbProduto (
	codProduto INT PRIMARY KEY IDENTITY(1,1)
	, nomeProduto VARCHAR(50)
	, precoKiloProduto MONEY
	, codCategoriaProduto INT FOREIGN KEY REFERENCES tbCategoriaProduto(codCategoriaProduto)
)
--DROP TABLE tbProduto

CREATE TABLE tbItensEncomenda (
	codItensVenda INT PRIMARY KEY IDENTITY(1,1)
	, codEncomenda INT FOREIGN KEY REFERENCES tbEncomenda(codEncomenda)
	, codProduto INT FOREIGN KEY REFERENCES tbProduto(codProduto)
	, quantidadeKilos INT
	, subTotal MONEY
)
--DROP TABLE tbItensEncomenda