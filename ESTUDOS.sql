CREATE DATABASE BD_PROVABD24
USE BD_PROVABD24

create table tb_surfista (
   id_surfista int not null,
   nome_surfista varchar(100) not null
)

insert into tb_surfista values(10, 'GABRIEL MEDINA')
insert into tb_surfista values(17, 'JULIAN WILSON')
insert into tb_surfista values(12, 'KELLY SLATER')
insert into tb_surfista values(15, 'FILIPE TOLEDO')


create table tb_bateria (
   id_bateria int not null primary key identity(1,1),
   id_surfista_1 int not null,
   id_surfista_2 int not null
)

create table tb_ondas_bateria (
   id_onda int not null primary key identity(1,1),
   id_bateria int not null,
   id_surfista int not null,
   nota_1  numeric(10,2) check (nota_1 >=0 and nota_1 <=10),
   nota_2  numeric(10,2) check (nota_2 >=0 and nota_2 <=10),
   nota_3  numeric(10,2) check (nota_3 >=0 and nota_3 <=10),
   nota_4  numeric(10,2) check (nota_4 >=0 and nota_4 <=10)
)


create table tb_ondas_placar (
   id_bateria int not null,
   id_surfista int not null,
   nome_surfista varchar(100) not null,
   nota_final_onda1 numeric(10,2) null default(0.0),
   nota_final_onda2 numeric(10,2) null default(0.0),
   primary key (id_bateria, id_surfista)
)

CREATE OR ALTER TRIGGER ST_BATERIA_SURFISTA 
ON TB_BATERIA AFTER INSERT
AS 
BEGIN
DECLARE @ID_BATERIA INT,
		@ID_SURFISTA_1 INT,
		@ID_SURFISTA_2 INT,
		@NOME_SURFISTA1 VARCHAR(100),
		@NOME_SURFISTA2 VARCHAR(100)

DECLARE C_SURFISTA CURSOR FOR SELECT ID_BATERIA, ID_SURFISTA_1, ID_SURFISTA_2 FROM inserted
OPEN C_SURFISTA
FETCH C_SURFISTA INTO @ID_BATERIA, @ID_SURFISTA_1, @ID_SURFISTA_2
WHILE(@@FETCH_STATUS = 0)
BEGIN
		SELECT @NOME_SURFISTA1 = NOME_SURFISTA 
		FROM tb_surfista
		WHERE id_surfista = @ID_SURFISTA_1
		SELECT @NOME_SURFISTA2 = NOME_SURFISTA
		FROM tb_surfista
		WHERE id_surfista = @ID_SURFISTA_2
		INSERT INTO tb_ondas_placar(id_bateria,id_surfista,nome_surfista)
		VALUES(@ID_BATERIA, @ID_SURFISTA_1,@NOME_SURFISTA1)
		INSERT INTO tb_ondas_placar(id_bateria,id_surfista,nome_surfista)
		VALUES(@ID_BATERIA, @ID_SURFISTA_2,@NOME_SURFISTA2)
		FETCH C_SURFISTA INTO @ID_BATERIA, @ID_SURFISTA_1, @ID_SURFISTA_2
END
CLOSE C_SURFISTA
DEALLOCATE C_SURFISTA
END

CREATE OR ALTER TRIGGER ST_BATERIA_DELETE 
ON TB_BATERIA AFTER DELETE
AS
BEGIN
DECLARE @ID_BATERIA INT

DECLARE C_BATERIA CURSOR FOR SELECT ID_BATERIA FROM DELETED
OPEN C_BATERIA 
FETCH C_BATERIA INTO @ID_BATERIA
WHILE(@@FETCH_STATUS = 0)
BEGIN
	DELETE FROM TB_ONDAS_PLACAR WHERE ID_BATERIA = @ID_BATERIA
	 FETCH C_BATERIA INTO @ID_BATERIA
END
CLOSE C_BATERIA
DEALLOCATE C_BATERIA
END

CREATE OR ALTER TRIGGER ST_BATERIA_PLACAR_UPDATE 
ON TB_ONDAS_BATERIA
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @ID_ONDA INT,
            @ID_BATERIA INT,
            @ID_SURFISTA INT,
            @NOTA_1 NUMERIC(10,2),
            @NOTA_2 NUMERIC(10,2),
            @NOTA_3 NUMERIC (10,2),
            @NOTA_4 NUMERIC(10,2),
            @NOTA_FINAL_ONDA NUMERIC(10,2),
            @NOTA_FINAL_ONDA1_A NUMERIC(10,2),
            @NOTA_FINAL_ONDA2_A NUMERIC(10,2)


    DECLARE C_ONDA CURSOR FOR 
    SELECT ID_ONDA, ID_BATERIA, ID_SURFISTA, NOTA_1, NOTA_2, NOTA_3, NOTA_4 
    FROM inserted

    OPEN C_ONDA
    FETCH C_ONDA INTO @ID_ONDA, @ID_BATERIA, @ID_SURFISTA, @NOTA_1, @NOTA_2, @NOTA_3, @NOTA_4

    WHILE @@FETCH_STATUS = 0
    BEGIN 

        SET @NOTA_FINAL_ONDA = (@NOTA_1 + @NOTA_2 + @NOTA_3 + @NOTA_4) / 4
        

        SELECT @NOTA_FINAL_ONDA1_A = NOTA_FINAL_ONDA1, 
               @NOTA_FINAL_ONDA2_A = NOTA_FINAL_ONDA2
        FROM tb_ondas_placar
        WHERE id_bateria = @ID_BATERIA AND id_surfista = @ID_SURFISTA


        IF @NOTA_FINAL_ONDA > @NOTA_FINAL_ONDA1_A
        BEGIN
   
            UPDATE tb_ondas_placar
            SET nota_final_onda1 = @NOTA_FINAL_ONDA
            WHERE id_bateria = @ID_BATERIA AND id_surfista = @ID_SURFISTA
        END
        ELSE IF @NOTA_FINAL_ONDA > @NOTA_FINAL_ONDA2_A
        BEGIN

            UPDATE tb_ondas_placar
            SET nota_final_onda2 = @NOTA_FINAL_ONDA
            WHERE id_bateria = @ID_BATERIA AND id_surfista = @ID_SURFISTA
        END

       
        FETCH C_ONDA INTO @ID_ONDA, @ID_BATERIA, @ID_SURFISTA, @NOTA_1, @NOTA_2, @NOTA_3, @NOTA_4
    END

    CLOSE C_ONDA
    DEALLOCATE C_ONDA
END

DELETE FROM tb_bateria
WHERE id_surfista_1 = 10
DROP TABLE tb_ondas_bateria
SELECT * FROM tb_ondas_placar

SELECT * FROM tb_bateria

SELECT * FROM tb_ondas_bateria
SELECT * FROM tb_ondas_placar
-- Testes

INSERT INTO tb_ondas_placar VALUES (1,10,'Gabriel',0,0)
insert into tb_bateria values (10,17)


-- Primeira onda Gabriel
insert into tb_ondas_bateria values (1, 10, 9, 9.5, 9.3, 9.2)    

-- Segunda onda Gabriel
insert into tb_ondas_bateria values (1, 10, 5, 5, 5, 5)

-- Terceira onda Gabriel
insert into tb_ondas_bateria values (1, 10, 10, 10, 10, 10)

-- Primeira Onda Julian
insert into tb_ondas_bateria values (1, 17, 8.7, 8, 8.3, 8.1)

-- Segunda Onda Julian
insert into tb_ondas_bateria values (1, 17, 9.4, 9, 9.1, 9.2)

-- Terceira Onda Julian
insert into tb_ondas_bateria values (1, 17, 10, 10, 10, 10)




 
