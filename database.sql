DROP DATABASE IF EXISTS db_catalogo;
DROP DATABASE IF EXISTS db_clientes;
DROP DATABASE IF EXISTS db_produtos;
CREATE DATABASE db_clientes;
USE db_clientes;

SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS Enderecos;

CREATE TABLE Clientes(
    id INT AUTO_INCREMENT,
    nome VARCHAR (255) NOT NULL,
    idade INT NOT NULL,
    cpf VARCHAR (11) NOT NULL,
    email VARCHAR (255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE Enderecos(
	id INT AUTO_INCREMENT,
    user_id INT NOT NULL,
    cep VARCHAR(50),
    cidade VARCHAR(50),
    rua VARCHAR(50),
    numero INT,
    ap INT,
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES Clientes(id) ON DELETE CASCADE
);

DELIMITER //
CREATE PROCEDURE adicionar_cliente (IN nome_in VARCHAR(255), IN idade_in INT, IN cpf_in VARCHAR(11), IN email_in VARCHAR(255))
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Clientes WHERE nome = nome_in) THEN
		INSERT INTO Clientes (nome, idade, cpf, email) 
		VALUES (nome_in, idade_in, cpf_in, email_in);
	END IF;
END //

CREATE PROCEDURE apagar_cliente (IN id_in INT)
BEGIN
	IF EXISTS (SELECT 1 FROM Clientes WHERE id = id_in) THEN
		DELETE FROM Clientes WHERE id = id_in;
	END IF;
END //

CREATE PROCEDURE atualizar_cliente (IN id_in INT, IN nome_in VARCHAR(255), IN idade_in INT, IN cpf_in VARCHAR(11), IN email_in VARCHAR(255))
BEGIN
	IF EXISTS (SELECT 1 FROM Clientes WHERE id = id_in) THEN
		UPDATE Clientes 
		SET nome = nome_in, idade = idade_in, cpf = cpf_in, email = email_in
		WHERE id = id_in;
	END IF;
END //

CREATE PROCEDURE ler_cliente (IN id_in INT)
BEGIN
	SELECT * FROM Clientes WHERE id = id_in;
END //

CREATE PROCEDURE ler_clientes ()
BEGIN
	SELECT * FROM Clientes;
END //

CREATE PROCEDURE adicionar_endereco (IN user_id_in INT, IN cep_in VARCHAR(50), IN cidade_in VARCHAR(50), IN rua_in VARCHAR(50), IN numero_in INT, IN ap_in INT)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Clientes INNER JOIN Enderecos ON Clientes.id = Enderecos.user_id WHERE Clientes.id = user_id_in AND Enderecos.cep = cep_in AND Enderecos.cidade = cidade_in AND Enderecos.rua = rua_in AND Enderecos.numero = numero_in AND Enderecos.ap = ap_in) THEN
		INSERT INTO Enderecos (user_id, cep, cidade, rua, numero, ap)
		SELECT id, cep_in, cidade_in, rua_in, numero_in, ap_in FROM Clientes WHERE id = user_id_in;
    END IF;
END //

CREATE PROCEDURE apagar_endereco (IN id_in INT)
BEGIN
	IF EXISTS (SELECT 1 FROM Enderecos WHERE id = id_in) THEN
		DELETE FROM Enderecos WHERE id = id_in;
    END IF;
END //

CREATE PROCEDURE ler_endereco (IN id_in INT)
BEGIN
	SELECT * FROM Enderecos WHERE id = id_in;
END // 

CREATE PROCEDURE ler_enderecos ()
BEGIN	
		SELECT * FROM Enderecos;
END //

CREATE PROCEDURE atualizar_endereco (IN id_in INT, IN cep_in VARCHAR(50), IN cidade_in VARCHAR(50), IN rua_in VARCHAR(50), IN numero_in INT, IN ap_in INT) 
BEGIN
	IF EXISTS (SELECT 1 FROM Enderecos WHERE id = id_in) THEN
		UPDATE Enderecos
        SET cep = cep_in, cidade = cidade_in, rua = rua_in, numero = numero_in, ap = ap_in
        WHERE id = id_in;
    END IF;
END //

DELIMITER ;


CREATE DATABASE db_produtos;
USE db_produtos;

CREATE TABLE Produtos (
	id INT AUTO_INCREMENT,
    nome VARCHAR(255),
    velocidade INT,
    preco INT,
    disponibilidade BIT NOT NULL,
    PRIMARY KEY (id)
);

DELIMITER //
CREATE PROCEDURE adicionar_produto (IN nome_in VARCHAR (255), IN velocidade_in INT, IN preco_in INT, IN disponibilidade_in BIT)
BEGIN
IF NOT EXISTS (SELECT 1 FROM Produtos WHERE nome = nome_in AND velocidade = velocidade_in AND preco = preco_in AND disponibilidade = disponibilidade_in) THEN
	INSERT INTO Produtos (nome, velocidade, preco, disponibilidade) VALUES (nome_in, velocidade_in, preco_in, disponibilidade_in);
	END IF;
END //

CREATE PROCEDURE apagar_produto (IN id_in INT)
BEGIN
	IF EXISTS (SELECT 1 FROM Produtos WHERE id = id_in) THEN
		DELETE FROM Produtos WHERE id = id_in;
	END IF;
END //

CREATE PROCEDURE atualizar_produto (IN id_in INT, IN nome_in VARCHAR(255), IN velocidade_in INT, IN preco_in INT, IN disponibilidade_in BIT)
BEGIN
	IF EXISTS (SELECT 1 FROM Produtos WHERE id = id_in) THEN
		UPDATE Produtos
		SET nome = nome_in, velocidade = velocidade_in, preco = preco_in, disponibilidade = disponibilidade_in
		WHERE id = id_in;
	END IF;
END //

CREATE PROCEDURE ler_produto (IN id_in INT)
BEGIN
	SELECT * FROM Produtos WHERE id = id_in;
END //

CREATE PROCEDURE ler_produtos ()
BEGIN
	SELECT * FROM Produtos;
END //
DELIMITER ;


CREATE DATABASE db_catalogo;
USE db_catalogo;

CREATE TABLE Clientes_Produtos (
	id INT AUTO_INCREMENT,
    id_cliente INT NOT NULL, 
    id_produto INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_cliente) REFERENCES db_clientes.Clientes(id) ON DELETE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES db_produtos.Produtos(id) ON DELETE CASCADE
);

DELIMITER //
CREATE PROCEDURE adicionar_clientes_produtos(IN id_cliente_in INT, IN id_produto_in INT)
BEGIN
	IF EXISTS (SELECT 1 FROM db_clientes.Clientes WHERE id = id_cliente_in ) AND EXISTS (SELECT 1 FROM db_produtos.Produtos WHERE id = id_produto_in)
    AND NOT EXISTS (SELECT 1 FROM db_catalogo.Clientes_Produtos WHERE id_cliente = id_cliente_in AND id_produto = id_produto_in) AND EXISTS (SELECT 1 FROM db_produtos.Produtos WHERE id = id_produto_in AND disponibilidade = 1) THEN
		INSERT INTO db_catalogo.Clientes_Produtos(id_cliente, id_produto) VALUES (id_cliente_in, id_produto_in);
    END IF;
END //

CREATE PROCEDURE apagar_clientes_produtos(IN id_cliente_in INT, IN id_produto_in INT)
BEGIN
	IF EXISTS (SELECT 1 FROM db_catalogo.Clientes_Produtos WHERE id_cliente = id_cliente_in AND id_produto = id_produto_in) THEN
		DELETE FROM db_catalogo.Clientes_Produtos WHERE id_cliente = id_cliente_in  AND id_produto = id_produto_in;
    END IF;
END //

CREATE PROCEDURE atualizar_clientes_produtos (IN id_in INT, IN id_cliente_in INT, IN id_produto_in INT)
BEGIN
	IF EXISTS (SELECT 1 FROM db_catalogo.Clientes_Produtos WHERE id = id_in ) AND EXISTS (SELECT 1 FROM db_produtos.Produtos WHERE id = id_produto_in AND disponibilidade = 1) AND EXISTS (SELECT 1 FROM db_clientes.Clientes WHERE id = id_cliente_in) THEN
		UPDATE db_catalogo.Clientes_Produtos
        SET id_cliente = id_cliente_in, id_produto = id_produto_in
        WHERE id = id_in;
    END IF;
END //

CREATE PROCEDURE ler_produtos_do_cliente (IN id_cliente_in INT)
BEGIN
	SELECT db_produtos.Produtos.nome, db_produtos.Produtos.velocidade, db_produtos.Produtos.preco, db_produtos.Produtos.disponibilidade FROM db_clientes.Clientes INNER JOIN db_catalogo.Clientes_Produtos ON db_clientes.Clientes.id = db_catalogo.Clientes_Produtos.id_cliente
    INNER JOIN db_produtos.Produtos ON db_catalogo.Clientes_Produtos.id_produto = db_produtos.Produtos.id WHERE db_clientes.Clientes.id = id_cliente_in;
END //

CREATE PROCEDURE ler_clientes_do_produto (IN id_produto_in INT)
BEGIN
	SELECT db_clientes.Clientes.nome, db_clientes.Clientes.idade, db_clientes.Clientes.cpf, db_clientes.Clientes.email  FROM db_clientes.Clientes INNER JOIN db_catalogo.Clientes_Produtos ON db_clientes.Clientes.id = db_catalogo.Clientes_Produtos.id_cliente
    INNER JOIN db_produtos.Produtos ON db_catalogo.Clientes_Produtos.id_produto = db_produtos.Produtos.id WHERE db_produtos.Produtos.id = id_produto_in;
END //
DELIMITER ;