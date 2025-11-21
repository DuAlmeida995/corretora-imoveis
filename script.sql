-- Criando as tabelas
CREATE TABLE usuario
(
	CPF char(11) NOT NULL,
	prenome varchar(15) NOT NULL,
	sobrenome varchar(20) NOT NULL,
	data_nasc date NOT NULL CHECK (EXTRACT(YEAR FROM AGE(CURRENT_DATE, data_nasc)) >= 18),
	email varchar(50) NOT NULL,
	profile_image_url varchar(255),
	CONSTRAINT UPK
		PRIMARY KEY(CPF)
);

CREATE TABLE login
(
	CPF char(11) NOT NULL,
	senha varchar(255) NOT NULL,
	CONSTRAINT LPK
		PRIMARY KEY(CPF,senha),
	CONSTRAINT LFK
		FOREIGN KEY (CPF) REFERENCES usuario(CPF)
		ON DELETE cascade ON UPDATE cascade
);

CREATE TABLE proprietario
(
	CPF char(11) NOT NULL,
	CONSTRAINT PropPK
		PRIMARY KEY(CPF),
	CONSTRAINT PropFK
		FOREIGN KEY (CPF) REFERENCES usuario(CPF)
		ON DELETE cascade ON UPDATE cascade
);

CREATE TABLE adquirente
(
	CPF char(11) NOT NULL,
	pontuacao_credito int,
	CONSTRAINT AdqPK
		PRIMARY KEY(CPF),
	CONSTRAINT AdqFK
		FOREIGN KEY (CPF) REFERENCES usuario(CPF)
		ON DELETE cascade ON UPDATE cascade
);

CREATE TABLE corretor
(
	CPF char(11) NOT NULL,
	especialidade varchar(15),
	creci_codigo varchar(6) NOT NULL,
	regiao_atuacao varchar(30),
	CONSTRAINT CPK
		PRIMARY KEY(CPF),
	CONSTRAINT CFK
		FOREIGN KEY (CPF) REFERENCES usuario(CPF)
		ON DELETE cascade ON UPDATE cascade,
	CONSTRAINT unique_corr
		UNIQUE(creci_codigo)
);

CREATE TABLE otp_codes
(
    CPF CHAR(11) NOT NULL UNIQUE, -- Apenas um OTP ativo por CPF
    otp_code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL, -- Hora de expiração

    CONSTRAINT OTP_PK PRIMARY KEY(CPF),
    CONSTRAINT OTP_CPF_FK
        FOREIGN KEY(CPF)
        REFERENCES usuario(CPF)
        ON DELETE CASCADE
);

CREATE TABLE tel_usuario
(
	CPF char(11) NOT NULL,
	telefone char(11) NOT NULL,
	CONSTRAINT TelPK
		PRIMARY KEY(CPF,telefone),
	CONSTRAINT TelFK
		FOREIGN KEY (CPF) REFERENCES usuario(CPF)
		ON DELETE cascade ON UPDATE cascade
);

CREATE TABLE imovel
(
	matricula char(16) NOT NULL,
	n_quartos int,
	valor_venal float,
	metragem float,
	tipo varchar(20),
	mobiliado boolean,
	possui_garagem boolean,
	n_reformas int,
	finalidade varchar(20),
	logradouro varchar(50) NOT NULL,
	complemento varchar(20),
	numero varchar(10) NOT NULL,
	cep char(8) NOT NULL,
	cidade varchar(50) NOT NULL,
	CPF_prop char(11) NOT NULL,
	CONSTRAINT IPK
		PRIMARY KEY(matricula),
	CONSTRAINT IFK
		FOREIGN KEY (CPF_prop) REFERENCES proprietario(CPF)
		ON DELETE cascade ON UPDATE cascade
);

ALTER TABLE imovel ADD COLUMN descricao varchar(250);
ALTER TABLE imovel ADD COLUMN bairro varchar(50);

CREATE TABLE imagem_imovel
(
	matricula char(16) NOT NULL,
	imovel_image_url varchar(255) NOT NULL,
	CONSTRAINT IIPK
		PRIMARY KEY(matricula,imovel_image_url),
	CONSTRAINT IIFK
		FOREIGN KEY(matricula) REFERENCES imovel(matricula)
		ON DELETE cascade ON UPDATE cascade
);

CREATE TABLE comodidades_imovel
(
	matricula char(16) NOT NULL,
	comodidade varchar(30) NOT NULL,
	CONSTRAINT CIPK
		PRIMARY KEY(matricula,comodidade),
	CONSTRAINT CIFK
		FOREIGN KEY (matricula) REFERENCES imovel(matricula)
		ON DELETE cascade ON UPDATE cascade
);

CREATE TABLE contrato
(
	codigo SERIAL,
	valor float NOT NULL,
	status varchar(15),
	data_inicio date,
	data_fim date,
	tipo varchar(20) NOT NULL,
	matricula_imovel char(16) NOT NULL,
	CPF_prop char(11) NOT NULL,
	CPF_corretor char(11) NOT NULL,
	CONSTRAINT ContratoPK
		PRIMARY KEY(codigo),
	CONSTRAINT ContratoFK_matricula
		FOREIGN KEY (matricula_imovel) REFERENCES imovel(matricula)
		ON DELETE cascade ON UPDATE cascade,
	CONSTRAINT ContratoFK_prop
		FOREIGN KEY (CPF_prop) REFERENCES proprietario(CPF)
		ON DELETE cascade ON UPDATE cascade,
	CONSTRAINT ContratoFK_corretor
		FOREIGN KEY (CPF_corretor) REFERENCES corretor(CPF)
		ON DELETE cascade ON UPDATE cascade
);

CREATE TABLE pagamento
(
	codigo_c int NOT NULL,
	n_pagamento int NOT NULL,
	data_vencimento date NOT NULL,
	data_pagamento date,
	valor float NOT NULL,
	status varchar(15) NOT NULL,
	forma_pagamento varchar(15) NOT NULL,
	tipo varchar(15),
	CONSTRAINT PagPK
		PRIMARY KEY(codigo_c,n_pagamento),
	CONSTRAINT PagFK
		FOREIGN KEY (codigo_c) REFERENCES contrato(codigo)
		ON DELETE cascade ON UPDATE cascade
);

CREATE TABLE assina
(
	CPF_adq char(11) NOT NULL,
	codigo_c int NOT NULL,
	CONSTRAINT APK
		PRIMARY KEY(codigo_c,CPF_adq),
	CONSTRAINT AFK_contrato
		FOREIGN KEY (codigo_c) REFERENCES contrato(codigo)
		ON DELETE cascade ON UPDATE cascade,
	CONSTRAINT AFK_adq
		FOREIGN KEY (CPF_adq) REFERENCES adquirente(CPF)
		ON DELETE cascade ON UPDATE cascade
);

-- Preenchendo tabelas
INSERT INTO usuario(CPF, prenome, sobrenome, data_nasc,email) VALUES
('12345678901', 'Ana', 'Silva', '1990-05-15', 'ana_s@gmail.com'),
('98765432109', 'Bruno', 'Costa', '1985-11-01', 'bruno_c@gmail.com'),
('31750890034', 'Samuel', 'Cavalcanti', '1991-04-16','samuel_c@gmail.com'),
('55566677788', 'Daniel', 'Fernandes', '1977-07-22', 'daniel_f@gmail.com'),
('10230450611', 'Fátima', 'Souza', '1965-04-12', 'fatima_s@gmail.com'),
('20540670822', 'Gabriel', 'Lima', '1998-02-25', 'gabriel_l@gmail.com'),
('30750890033', 'Helena', 'Ribeiro', '1982-09-08', 'helena_r@gmail.com'),
('80700890088', 'Marcelo', 'Gomes', '1979-10-27', 'marcelo_g@gmail.com'),
('40960010244', 'Isabel', 'Almeida', '2000-12-01', 'isabel_a@gmail.com'),
('50170230455', 'Júlia', 'Monteiro', '1993-07-18', 'julia_m@gmail.com'),
('60380450666', 'Lucas', 'Nogueira', '1988-11-14', 'lucas_n@gmail.com'),
('70590670877', 'Manuela', 'Barros', '2002-06-03', 'manuela_b@gmail.com'),
('52170230456', 'Tiago', 'Ferreira', '1975-12-11', 'tiago_f@gmail.com'),
('90910010299', 'Paula', 'Mendes', '1995-08-19', 'paula_m@gmail.com'),
('01120230400', 'Pedro', 'Henrique', '2005-01-05', 'pedro_h@mgail.com'),
('11330450612', 'Diego', 'Moreira', '1960-03-30', 'diego_m@gmail.com'),
('21540670823', 'Raquel', 'Freitas', '1987-05-21', 'raquel_f@gmail.com'),
('41960010245', 'Tatiana', 'Pinheiro', '2003-08-07', 'tatiana_p@gmail.com'),
('11122233344', 'Carla', 'Dias', '2001-01-30', 'carla_d@gmail.com'),
('60590810211', 'Rodrigo', 'Oliveira', '1983-04-10', 'rodrigo_o@gmail.com'),
('70710020422', 'Vanessa', 'Pereira', '1992-08-20', 'vanessa_p@gmail.com'),
('80920230633', 'Fernando', 'Santos', '1976-11-05', 'fernando_s@gmail.com'),
('91130450844', 'Patrícia', 'Rodrigues', '1989-02-14', 'patricia_r@gmail.com'),
('02340670055', 'Ricardo', 'Martins', '1968-07-30', 'ricardo_m@gmail.com'),
('12550890266', 'Sandra', 'Alves', '1971-12-12', 'sandra_a@gmail.com'),
('22760010477', 'Vítor', 'Araujo', '1995-03-28', 'vitor_a@gmail.com'),
('32970230688', 'Mônica', 'Correia', '1980-09-19', 'monica_c@gmail.com'),
('43180450899', 'Eduardo', 'Cardoso', '2000-06-25', 'eduardo_c@gmail.com'),
('53390670000', 'Carolina', 'Teixeira', '1997-10-03', 'carolina_t@gmail.com'),
('63510890212', 'Gustavo', 'Melo', '1984-01-15', 'gustavo_m@gmail.com'),
('73720010423', 'Beatriz', 'Pinto', '1999-05-09', 'beatriz_p@gmail.com'),
('83930230634', 'Leonardo', 'Azevedo', '1973-08-22', 'leonardo_a@gmail.com'),
('94140450845', 'Laís', 'Carvalho', '1990-11-30', 'lais_c@gmail.com'),
('05350670056', 'Rafael', 'Castro', '1986-04-05', 'rafael_c@gmail.com'),
('15560890267', 'Cíntia', 'Cunha', '1981-07-17', 'cintia_c@gmail.com'),
('25770010478', 'Marcos', 'Campos', '1963-12-08', 'marcos_c@gmail.com'),
('35980230689', 'Juliana', 'Barbosa', '1994-02-27', 'juliana_b@gmail.com'),
('46190450801', 'André', 'Rocha', '1978-06-13', 'andre_r@gmail.com'),
('56310670012', 'Lúcia', 'Neves', '1969-09-01', 'lucia_n@gmail.com'),
('66520890223', 'Carlos', 'Sampaio', '1985-10-24', 'carlos_s@gmail.com'),
('76730010434', 'Viviane', 'Farias', '1993-01-19', 'viviane_f@gmail.com'),
('86940230645', 'Felipe', 'Miranda', '2001-08-11', 'felipe_m@gmail.com'),
('97150450856', 'Amanda', 'Tavares', '1996-03-06', 'amanda_t@gmail.com'),
('08360670067', 'Roberto', 'Vasconcelos', '1970-05-18', 'roberto_v@gmail.com'),
('18570890278', 'Bruna', 'Lemos', '1987-12-29', 'bruna_l@gmail.com'),
('28780010489', 'Antônio', 'Naves', '1966-10-10', 'antonio_n@gmail.com'),
('38990230690', 'Débora', 'Morais', '1991-04-02', 'debora_m@gmail.com'),
('49110450802', 'Francisco', 'Dantas', '1959-11-23', 'francisco_d@gmail.com'),
('59320670013', 'Eliane', 'Pires', '1974-07-07', 'eliane_p@gmail.com'),
('69530890224', 'Joaquim', 'Peixoto', '1982-02-18', 'joaquim_p@gmail.com'),
('79740010435', 'Letícia', 'Meireles', '2004-09-14', 'leticia_m@gmail.com'),
('89950230646', 'Sérgio', 'Guerra', '1977-01-26', 'sergio_g@gmail.com'),
('00160450857', 'Cláudia', 'Chaves', '1988-08-08', 'claudia_c@gmail.com'),
('11223344556', 'Vinícius', 'Brandão', '1999-12-31', 'vinicius_b@gmail.com');

INSERT INTO proprietario(CPF) VALUES
('12345678901'),
('10230450611'),
('60380450666'),
('90910010299'),
('11330450612'),
('40960010244'),
('31750890034'),
('52170230456'),
('55566677788'),
('60590810211'),
('70710020422'),
('80920230633'),
('91130450844'),
('02340670055'),
('12550890266'),
('22760010477'),
('32970230688'),
('43180450899'),
('53390670000'),
('63510890212'),
('73720010423'),
('83930230634'),
('94140450845'),
('05350670056'),
('15560890267'),
('25770010478');

INSERT INTO adquirente(CPF, pontuacao_credito) VALUES
('12345678901', 810),
('98765432109', 725),
('20540670822', 680),
('70590670877', 512),
('01120230400', 404),
('41960010245', 710),
('40960010244', 740),
('50170230455', 880),
('52170230456', 930),
('55566677788', 790),
('73720010423', 480),
('83930230634', 620),
('94140450845', 305),
('05350670056', 900),
('15560890267', 970),
('25770010478', 555),
('35980230689', 690),
('46190450801', 715),
('56310670012', 100),
('66520890223', 478),
('76730010434', 590),
('86940230645', 840),
('97150450856', 790),
('08360670067', 925),
('18570890278', 150);


INSERT INTO corretor(CPF, especialidade, creci_codigo, regiao_atuacao) VALUES
('30750890033', 'Casa', '078501', 'Jardins'),
('80700890088', 'galpão', '092302', 'Brás'),
('21540670823', 'Apartamento', '115403', 'Tatuapé'),
('50170230455', 'Studio', '180904', 'Butantã'),
('31750890034', 'Sala comercial', '150105', 'Santana'),
('11122233344', 'Apartamento', '157321', 'Vila Prudente'),
('28780010489', 'Casa', '066429', 'Tremembé'),
('38990230690', 'Apartamento', '555555', 'Belém'),
('49110450802', 'Apartamento', '101010', 'Mooca'),
('59320670013', 'Casa', '010101', 'Ipiranga'),
('69530890224', 'Apartamento', '987654', 'Pinheiros'),
('79740010435', 'Casa', '107283', 'Jabaquara'),
('89950230646', 'Studio', '293817', 'República'),
('00160450857', 'Sala Comercial', '001002', 'Tatuapé'),
('11223344556', 'Apartamento', '012944', 'Brás'),
('53390670000', 'Apartamento', '509211', 'República'),
('43180450899', 'Casa', '111104', 'Ipiranga'),
('70710020422', 'Studio', '150012', 'Tatuapé'),
('80920230633', 'Apartamento', '002516', 'Tucuruvi'),
('91130450844', 'Casa', '506910', 'Tucuruvi'),
('02340670055', 'galpão', '591050', 'Campo Belo'),
('12550890266', 'galpão', '105911', 'Santo Amaro'),
('22760010477', 'Apartamento', '256022', 'Pinheiros'),
('32970230688', 'Apartamento', '790181', 'República'),
('60590810211', 'galpão', '358100', 'Tremembé'); 


INSERT INTO tel_usuario(CPF,telefone) VALUES
('12345678901','11987654321'),
('98765432109','11976543210'),
('11122233344','11988887777'),
('11122233344','11256789011'),
('31750890034','11998765432'),
('31750890034','11988487577'),
('55566677788','11991234567'),
('10230450611','11973216549'),
('20540670822','11982345678'),
('30750890033','11994567890'),
('80700890088','11975678901'),
('40960010244','11986789012'),
('50170230455','11997890123'),
('50170230455','11979012345'),
('60380450666','11980123456'),
('70590670877','11991112222'),
('52170230456','11972223333'),
('90910010299','11988765332'),
('01120230400','11983334444'),
('01120230400','11994445555'),
('11330450612','11975556776'),
('21540670823','11986667777'),
('41960010245','11997778888'),
('41960010245','11978889999'),
('60590810211','11981112233'),
('70710020422','21982223344'),
('70710020422','21245678901'),
('80920230633','31983334455'),
('91130450844','61984445566'),
('02340670055','11985556677'),
('12550890266','41986667788'),
('12550890266','41332211441'),
('22760010477','11987778899'),
('32970230688','21988889900'),
('43180450899','11989990011'),
('53390670000','19991112233'),
('53390670000','19345678901'),
('63510890212','31992223344'),
('73720010423','11993334455'),
('83930230634','11994445566'),
('94140450845','71995556677'),
('05350670056','11996667788'),
('05350670056','11234567891'),
('15560890267','21997778899'),
('25770010478','11998889900'),
('35980230689','48999990011'),
('46190450801','11980001122'),
('56310670012','31981112233'),
('56310670012','31334455661'),
('66520890223','11982223344'),
('76730010434','21983334455'),
('86940230645','11984445566'),
('97150450856','81985556677'),
('08360670067','11986667788'),
('18570890278','11987778899'),
('18570890278','11223344551'),
('28780010489','11988889900'),
('38990230690','51989990011'),
('49110450802','11971112233'),
('59320670013','11972223344'),
('59320670013','11345678901'),
('69530890224','11973334455'),
('79740010435','11974445566'),
('89950230646','11975556677'),
('00160450857','11976667788'),
('11223344556','11977778899'),
('11223344556','11234598761');

INSERT INTO imovel(matricula, n_quartos, valor_venal, metragem, tipo, mobiliado, possui_garagem, 
n_reformas, finalidade, logradouro, complemento, numero, cep, cidade, CPF_prop,descricao,bairro) VALUES
('1001001001001001', 2, 850000.00, 80.5, 'Apartamento',true, true, 1, 'Residencial', 
'Rua Itapura', 'Apto 101', '500', '03310000', 'São Paulo', '12345678901',
'Apartamento de 2 quartos bem localizado no Tatuapé, próximo ao metrô.','Tatuapé'),
('1001001001001002', 0, 450000.00, 42.0, 'Sala Comercial', false, true, 0, 'Comercial', 
'Rua Voluntários da Pátria', 'Sala 802', '2140', '02011000', 'São Paulo', '55566677788',
'Sala comercial de 42m² em Santana, com 1 vaga de garagem.','Santana'),
('1001001001001003', 3, 2200000.00, 150.0, 'Apartamento', false, true, 2, 'Residencial', 
'Rua Orfanato', 'Apto 121', '700', '03131010', 'São Paulo', '10230450611',
'Amplo apartamento na Vila Prudente com 3 quartos','Vila Prudente'),
('1001001001001004', 1, 380000.00, 35.5, 'Studio', true, false, 0, 'Residencial', 
'Avenida Vital Brasil', 'Apto 2205', '1000', '05503001', 'São Paulo', '60380450666',
'Studio mobiliado no Butantã, ideal para estudantes, próximo à USP.','Butantã'),
('1001001001001005', 2, 1100000.00, 75.0, 'Apartamento', true, true, 1, 'Residencial', 
'Rua Tuiuti', 'Apto 55', '2000', '03307000', 'São Paulo', '90910010299',
'Apartamento mobiliado na Rua Tuiuti (Tatuapé), com 2 quartos e lazer completo.','Tatuapé'),
('1001001001001006', 4, 3500000.00, 300.0, 'Casa', false, true, 3, 'Residencial', 
'Alameda Jaú', NULL, '1177', '01420002', 'São Paulo', '11330450612',
'Casa espaçosa nos Jardins, 4 quartos, 300m²', 'Jardins'),
('1001001001001007', 2, 650000.00, 68.0, 'Apartamento', true, true, 1, 'Residencial', 
'Rua Ibitirama', 'Apto 401', '1500', '03133000', 'São Paulo', '40960010244',
'Apartamento 2 quartos (1 suíte) na Vila Prudente.','Vila Prudente'),
('1001001001001008', 4, 4200000.00, 350.0, 'Casa', false, true, 1, 'Residencial', 
'Rua Haddock Lobo', NULL, '1400', '01414002', 'São Paulo', '52170230456',
'Casa de alto padrão nos Jardins, próxima à Rua Oscar Freire.','Jardins'),
('1001001001001009', 0, 1800000.00, 450.0, 'Galpão',false, false, 2, 'Comercial', 
'Rua Bresser', NULL, '1200', '03017000', 'São Paulo', '55566677788',
'Galpão comercial de 450m² no Brás, com pé direito alto.','Brás'),
('1001001001001010', 0, 600000.00, 45.0, 'Sala Comercial', false, true, 0, 'Comercial',
'Rua Azevedo Macedo', 'Sala 1010', '80', '02013000', 'São Paulo', '31750890034',
'Sala comercial reformada em Santana, 45m², pronta para uso.','Santana'),
('1001001001001011', 3, 950000.00, 180.0, 'Casa', false, true, 1, 'Residencial', 
'Rua Maria Amália Lopes de Azevedo', NULL, '3000', '02350001', 'São Paulo', '60590810211',
'Casa espaçosa no Tremembé, 3 quartos, perto da serra.','Tremembé'),
('1001001001001012', 2, 550000.00, 60.0, 'Apartamento', false, true, 0, 'Residencial', 
'Rua Herval', 'Apto 33', '1100', '03062000', 'São Paulo', '70710020422', 
'Apartamento no Belém, 2 quartos, próximo ao metrô Belém.','Belém'),
('1001001001001013', 3, 1300000.00, 110.0, 'Apartamento', true, true, 1, 'Residencial', 
'Rua da Mooca', 'Apto 82', '4000', '03104002', 'São Paulo', '80920230633', 
'Apartamento de 3 quartos na Mooca, varanda gourmet, mobiliado.','Mooca'),
('1001001001001014', 2, 780000.00, 120.0, 'Casa', false, true, 2, 'Residencial', 
'Rua dos Patriotas', NULL, '900', '04207040', 'São Paulo', '91130450844', 
'Casa (sobrado) no Ipiranga, 2 suítes, reformada.','Ipiranga'),
('1001001001001015', 1, 900000.00, 50.0, 'Apartamento', true, true, 0, 'Residencial',
'Rua Cardeal Arcoverde', 'Apto 1501', '2500', '05408003', 'São Paulo', '02340670055', 
'Apartamento de 1 quarto em Pinheiros, moderno, mobiliado, perto do metrô.','Pinheiros'),
('1001001001001016', 3, 880000.00, 160.0, 'Casa', false, true, 1, 'Residencial',
'Avenida Engenheiro George Corbisier', NULL, '1200', '04345000', 'São Paulo', '12550890266', 
'Casa térrea no Jabaquara, 3 quartos, com edícula.','Jabaquara'),
('1001001001001017', 1, 320000.00, 28.0, 'Studio', true, false, 0, 'Residencial',
'Avenida Ipiranga', 'Apto 1010', '900', '01039000', 'São Paulo', '22760010477', 
'Studio mobiliado no centro (República), próximo ao metrô.','República'),
('1001001001001018', 0, 400000.00, 38.0, 'Sala Comercial', false, true, 0, 'Comercial',
'Rua Apucarana', 'Sala 505', '1500', '03311000', 'São Paulo', '32970230688', 
'Sala comercial 38m² no Tatuapé, com 1 vaga.','Tatuapé'),
('1001001001001019', 2, 450000.00, 50.0, 'Apartamento', false, true, 0, 'Residencial', 
'Rua Piratininga', 'Apto 701', '800', '03042001', 'São Paulo', '43180450899', 
'Apartamento novo no Brás, 2 quartos, lazer completo.','Brás'),
('1001001001001020', 1, 390000.00, 40.0, 'Apartamento', false, false, 1, 'Residencial',
'Praça da República', 'Apto 1204', '150', '01045903', 'São Paulo', '53390670000', 
'Apartamento 1 quarto na República, reformado, vista livre.','República'),
('1001001001001021', 4, 1500000.00, 250.0, 'Casa', false, true, 2, 'Residencial', 
'Rua Tabor', NULL, '600', '04205001', 'São Paulo', '63510890212', 
'Casa (sobrado) no Ipiranga, 4 quartos, piscina.','Ipiranga'),
('1001001001001022', 1, 410000.00, 30.0, 'Studio', true, true, 0, 'Residencial', 
'Rua Emília Marengo', 'Apto 1108', '500', '03336000', 'São Paulo', '73720010423',
'Studio de luxo no Tatuapé, mobiliado, 1 vaga.','Tatuapé'),
('1001001001001023', 2, 480000.00, 55.0, 'Apartamento', false, true, 0, 'Residencial', 
'Avenida Tucuruvi', 'Apto 21', '300', '02305000', 'São Paulo', '83930230634',
'Apartamento 2 quartos no Tucuruvi, perto do metrô.','Tucuruvi'),
('1001001001001024', 3, 800000.00, 150.0, 'Casa', false, true, 1, 'Residencial',
'Avenida Nova Cantareira', NULL, '4500', '02340002', 'São Paulo', '94140450845', 
'Casa 3 quartos no Tucuruvi, próxima à serra.','Tucuruvi'),
('1001001001001025', 0, 3500000.00, 600.0, 'Galpão', false, false, 0, 'Comercial',
'Rua Doutor Jesuíno Maciel', NULL, '1000', '04615001', 'São Paulo', '05350670056',
'Galpão de 600m² no Campo Belo, fácil acesso ao aeroporto.','Campo Belo'),
('1001001001001026', 0, 2800000.00, 500.0, 'Galpão', false, false, 1, 'Comercial', 
'Avenida Santo Amaro', NULL, '7000', '04701200', 'São Paulo', '15560890267', 
'Galpão 500m² em Santo Amaro, pé direito de 7m.','Santo Amaro'),
('1001001001001027', 2, 1200000.00, 85.0, 'Apartamento', false, true, 1, 'Residencial', 
'Rua dos Pinheiros', 'Apto 91', '1000', '05422001', 'São Paulo', '25770010478', 
'Apartamento 2 quartos em Pinheiros, reformado, excelente localização.','Pinheiros'),
('1001001001001028', 1, 350000.00, 35.0, 'Apartamento', true, false, 1, 'Residencial', 
'Rua Sete de Abril', 'Apto 502', '300', '01044000', 'São Paulo', '32970230688', 
'Apartamento/Studio na República, mobiliado, centro.','República'),
('1001001001001029', 0, 1500000.00, 300.0, 'Galpão', false, false, 0, 'Comercial', 
'Avenida Coronel Sezefredo Fagundes', NULL, '5000', '02306000', 'São Paulo', '94140450845', 
'Galpão pequeno no Tremembé, 300m².','Tremembé'),
('1001001001001030', 5, 8000000.00, 500.0, 'Casa', false, true, 2, 'Residencial',
'Rua Groenlândia', NULL, '700', '01434000', 'São Paulo', '11330450612', 
'Casa de luxo nos Jardins, 5 suítes, piscina, 500m².','Jardins'),
('1001001001001031', 0, 2500000.00, 700.0, 'Galpão', false, false, 1, 'Comercial', 
'Rua Maria Marcolina', NULL, '100', '03011001', 'São Paulo', '12550890266', 
'Galpão 700m² no Brás, ideal para confecção.','Brás'),
('1001001001001032', 4, 2800000.00, 180.0, 'Apartamento', true, true, 1, 'Residencial', 
'Rua Serra de Bragança', 'Apto 201', '1200', '03318000', 'São Paulo', '70710020422', 
'Apartamento de alto padrão no Tatuapé, 4 quartos, mobiliado.','Tatuapé'),
('1001001001001033', 1, 360000.00, 32.0, 'Studio', true, true, 0, 'Residencial',
'Rua Alvarenga', 'Apto 305', '1500', '05509003', 'São Paulo', '60380450666', 
'Studio novo no Butantã, 1 vaga, próximo ao portão da USP.','Butantã'),
('1001001001001034', 0, 500000.00, 50.0, 'Sala Comercial', false, true, 1, 'Comercial',
'Rua Doutor César', 'Sala 1102', '100', '02013000', 'São Paulo', '31750890034', 
'Sala comercial 50m² em Santana, com ar condicionado e 1 vaga.','Santana'),
('1001001001001035', 2, 680000.00, 70.0, 'Apartamento', false, true, 0, 'Residencial',
'Rua do Oratório', 'Apto 64', '3000', '03116000', 'São Paulo', '40960010244', 
'Apartamento 2 quartos na Vila Prudente, com varanda.','Vila Prudente');

INSERT INTO comodidades_imovel(matricula,comodidade) VALUES
('1001001001001001', 'Elevador'),
('1001001001001001', 'Portaria_24h'),
('1001001001001001', 'Salao_De_Festa'),
('1001001001001001', 'Academia'),
('1001001001001001', 'Varanda'),

('1001001001001002', 'Elevador'),
('1001001001001002', 'Portaria_24h'),
('1001001001001002', 'Ar_Condicionado'),

('1001001001001003', 'Elevador'),
('1001001001001003', 'Portaria_24h'),
('1001001001001003', 'Salao_De_Festa'),
('1001001001001003', 'Churrasqueira'),
('1001001001001003', 'Piscina'),
('1001001001001003', 'Academia'),
('1001001001001003', 'Varanda'),
('1001001001001003', 'Playground'),

('1001001001001004', 'Elevador'),
('1001001001001004', 'Academia'),
('1001001001001004', 'Pet_Friendly'),

('1001001001001005', 'Elevador'),
('1001001001001005', 'Portaria_24h'),
('1001001001001005', 'Salao_De_Festa'),
('1001001001001005', 'Playground'),

('1001001001001006', 'Piscina'),
('1001001001001006', 'Churrasqueira'),
('1001001001001006', 'Ar_Condicionado'),

('1001001001001007', 'Elevador'),
('1001001001001007', 'Portaria_24h'),
('1001001001001007', 'Varanda'),
('1001001001001007', 'Pet_Friendly'),
('1001001001001007', 'Academia'),

('1001001001001008', 'Piscina'),
('1001001001001008', 'Churrasqueira'),
('1001001001001008', 'Ar_Condicionado'),

('1001001001001009', 'Ar_Condicionado'),

('1001001001001010', 'Elevador'),
('1001001001001010', 'Portaria_24h'),
('1001001001001010', 'Ar_Condicionado'),

('1001001001001011', 'Churrasqueira'),

('1001001001001012', 'Elevador'),
('1001001001001012', 'Portaria_24h'),
('1001001001001012', 'Salao_De_Festa'),
('1001001001001012', 'Playground'),

('1001001001001013', 'Elevador'),
('1001001001001013', 'Portaria_24h'),
('1001001001001013', 'Varanda'),
('1001001001001013', 'Academia'),
('1001001001001013', 'Salao_De_Festa'),

('1001001001001014', 'Churrasqueira'),
('1001001001001014', 'Ar_Condicionado'),
('1001001001001014', 'Pet_Friendly'),

('1001001001001017', 'Elevador'),
('1001001001001017', 'Portaria_24h'),

('1001001001001018', 'Elevador'),
('1001001001001018', 'Portaria_24h'),
('1001001001001018', 'Ar_Condicionado'),

('1001001001001019', 'Elevador'),
('1001001001001019', 'Portaria_24h'),
('1001001001001019', 'Playground'),
('1001001001001019', 'Salao_De_Festa'),

('1001001001001020', 'Elevador'),
('1001001001001020', 'Portaria_24h'),
('1001001001001020', 'Ar_Condicionado'),

('1001001001001021', 'Piscina'),
('1001001001001021', 'Churrasqueira'),

('1001001001001022', 'Elevador'),
('1001001001001022', 'Portaria_24h'),
('1001001001001022', 'Academia'),
('1001001001001022', 'Piscina'),
('1001001001001022', 'Varanda'),
('1001001001001022', 'Salao_De_Festa'),

('1001001001001023', 'Elevador'),
('1001001001001023', 'Playground'),
('1001001001001023', 'Salao_De_Festa'),
('1001001001001023', 'Portaria_24h'),

('1001001001001024', 'Churrasqueira'),

('1001001001001027', 'Elevador'),
('1001001001001027', 'Portaria_24h'),
('1001001001001027', 'Academia'),
('1001001001001027', 'Pet_Friendly'),
('1001001001001027', 'Ar_Condicionado'),

('1001001001001028', 'Elevador'),
('1001001001001028', 'Portaria_24h'),

('1001001001001030', 'Piscina'),
('1001001001001030', 'Churrasqueira'),
('1001001001001030', 'Ar_Condicionado'),
('1001001001001030', 'Pet_Friendly'),

('1001001001001032', 'Elevador'),
('1001001001001032', 'Portaria_24h'),
('1001001001001032', 'Piscina'),
('1001001001001032', 'Academia'),
('1001001001001032', 'Varanda'),
('1001001001001032', 'Salao_De_Festa'),

('1001001001001033', 'Elevador'),
('1001001001001033', 'Portaria_24h'),
('1001001001001033', 'Academia'),
('1001001001001033', 'Pet_Friendly'),

('1001001001001034', 'Elevador'),
('1001001001001034', 'Portaria_24h'),
('1001001001001034', 'Ar_Condicionado'),

('1001001001001035', 'Elevador'),
('1001001001001035', 'Portaria_24h'),
('1001001001001035', 'Varanda'),
('1001001001001035', 'Academia'),
('1001001001001035', 'Playground'),
('1001001001001035', 'Salao_De_Festa');

INSERT INTO contrato(valor, status,	data_inicio, data_fim, tipo,
matricula_imovel, CPF_prop, CPF_corretor) VALUES
(850000.00, 'Vendido', NULL, NULL, 'Venda',
'1001001001001001', '12345678901', '21540670823'),
(2500.00, 'Ativo', '2025-01-15', '2027-01-14', 'Aluguel',
'1001001001001002', '55566677788', '31750890034'),
(3500000.00, 'Em Negociação', NULL, NULL, 'Venda',
'1001001001001006', '11330450612', '30750890033'),
(1800.00, 'Ativo', '2025-03-01', '2026-08-31', 'Aluguel',
'1001001001001004', '60380450666', '50170230455'),
(1800000.00, 'Vendido', NULL, NULL, 'Venda',
'1001001001001009', '55566677788', '80700890088'),
(2200.00, 'Finalizado', '2023-01-10', '2025-07-09', 'Aluguel',
'1001001001001007', '40960010244', '11122233344'),
(4500.00, 'Ativo', '2025-05-10', '2027-11-09', 'Aluguel',
'1001001001001011', '60590810211', '28780010489'),
(550000.00, 'Em Negociação', NULL, NULL, 'Venda',
'1001001001001012', '70710020422', '38990230690'),
(1300000.00, 'Vendido', NULL, NULL, 'Venda',
'1001001001001013', '80920230633', '49110450802'),
(3800.00, 'Ativo', '2025-02-01', '2027-07-31', 'Aluguel',
'1001001001001014', '91130450844', '59320670013'),
(5000.00, 'Finalizado', '2023-01-01', '2025-06-30', 'Aluguel',
'1001001001001015', '02340670055', '69530890224'),
(880000.00, 'Vendido', NULL, NULL, 'Venda',
'1001001001001016', '12550890266', '79740010435'),
(1600.00, 'Ativo', '2025-10-01', '2027-03-31', 'Aluguel',
'1001001001001017', '22760010477', '89950230646'),
(2100.00, 'Ativo', '2025-01-20', '2027-01-19', 'Aluguel',
'1001001001001018', '32970230688', '00160450857'),
(1900.00, 'Ativo', '2025-08-15', '2027-02-14', 'Aluguel',
'1001001001001019', '43180450899', '11223344556'),
(390000.00, 'Em Negociação', NULL, NULL, 'Venda',
'1001001001001020', '53390670000', '53390670000'),
(1500000.00, 'Vendido', NULL, NULL, 'Venda',
'1001001001001021', '63510890212', '43180450899'),
(2300.00, 'Ativo', '2025-11-01', '2027-04-30', 'Aluguel',
'1001001001001022', '73720010423', '70710020422'),
(480000.00, 'Vendido', NULL, NULL, 'Venda',
'1001001001001023', '83930230634', '80920230633'),
(3900.00, 'Ativo', '2025-06-05', '2027-12-04', 'Aluguel',
'1001001001001024', '94140450845', '91130450844'),
(15000.00, 'Ativo', '2025-03-10', '2029-03-09', 'Aluguel',
'1001001001001025', '05350670056', '02340670055'),
(2800000.00, 'Em Negociação', NULL, NULL, 'Venda',
'1001001001001026', '15560890267', '12550890266'),
(1200000.00, 'Vendido', NULL, NULL, 'Venda',
'1001001001001027', '25770010478', '22760010477'),
(8000.00, 'Ativo', '2025-09-01', '2028-08-31', 'Aluguel',
'1001001001001029', '94140450845', '60590810211'),
(8000000.00, 'Em Negociação', NULL, NULL, 'Venda',
'1001001001001030', '11330450612', '30750890033'),
(1950.00, 'Ativo', '2025-04-12', '2026-10-11', 'Aluguel',
'1001001001001033', '60380450666', '50170230455'),
(2200000.00, 'Em Negociação', NULL, NULL, 'Venda',
'1001001001001003', '10230450611', '11122233344'),
(4800.00, 'Ativo', '2025-07-15', '2027-01-14', 'Aluguel',
'1001001001001005', '90910010299', '21540670823'),
(3000.00, 'Finalizado', '2023-01-01', '2024-12-31', 'Aluguel',
'1001001001001010', '31750890034', '31750890034'),
(15000.00, 'Ativo', '2025-01-05', '2027-07-04', 'Aluguel',
'1001001001001008', '52170230456', '30750890033');

INSERT INTO pagamento(codigo_c,	n_pagamento, data_vencimento, data_pagamento, 
valor, status, forma_pagamento, tipo) VALUES
(2, 1, '2025-08-15', '2025-08-14', 2500.00, 'Pago', 'PIX', 'Aluguel'),
(2, 2, '2025-09-15', '2025-09-15', 2500.00, 'Pago', 'Boleto', 'Aluguel'),
(2, 3, '2025-10-15', '2025-10-17', 2550.00, 'Atrasado', 'PIX', 'Aluguel'),
(2, 4, '2025-11-15', NULL, 2500.00, 'Pendente', 'Boleto', 'Aluguel'),
(4, 1, '2025-09-01', '2025-09-01', 1800.00, 'Pago', 'Débito', 'Aluguel'),
(4, 2, '2025-10-01', '2025-09-30', 1800.00, 'Pago', 'Débito', 'Aluguel'),
(4, 3, '2025-11-01', NULL, 1800.00, 'Pendente', 'Débito', 'Aluguel'),
(6, 1, '2025-05-10', '2025-05-10', 2200.00, 'Pago', 'Boleto', 'Aluguel'),
(6, 2, '2025-06-10', '2025-06-12', 2200.00, 'Pago', 'Boleto', 'Aluguel'),
(1, 1, '2025-07-01', '2025-07-01', 85000.00, 'Pago', 'TED', 'Sinal'),
(1, 2, '2025-08-01', '2025-08-01', 765000.00, 'Pago', 'Financiamento', 'Principal'),
(5, 1, '2025-09-10', '2025-09-10', 1800000.00, 'Pago', 'TED', 'Integral'),
(7, 1, '2025-09-10', '2025-09-10', 4500.00, 'Pago', 'PIX', 'Aluguel'),
(7, 2, '2025-10-10', '2025-10-11', 4500.00, 'Pago', 'Boleto', 'Aluguel'),
(7, 3, '2025-11-10', '2025-11-10', 4500.00, 'Pago', 'PIX', 'Aluguel'),
(9, 1, '2025-10-05', '2025-10-05', 130000.00, 'Pago', 'TED', 'Sinal'),
(9, 2, '2025-11-05', '2025-11-04', 1170000.00, 'Pago', 'Financiamento', 'Principal'),
(12, 1, '2025-10-20', '2025-10-20', 880000.00, 'Pago', 'TED', 'Integral'),
(13, 1, '2025-10-01', '2025-10-01', 1600.00, 'Pago', 'Débito', 'Aluguel'),
(13, 2, '2025-11-01', NULL, 1600.00, 'Pendente', 'Boleto', 'Aluguel'),
(14, 1, '2025-09-20', '2025-09-19', 2100.00, 'Pago', 'PIX', 'Aluguel'),
(14, 2, '2025-10-20', '2025-10-22', 2121.00, 'Atrasado', 'Boleto', 'Aluguel'),
(14, 3, '2025-11-20', NULL, 2100.00, 'Pendente', 'Boleto', 'Aluguel'),
(15, 1, '2025-09-15', '2025-09-15', 1900.00, 'Pago', 'Crédito', 'Aluguel'),
(15, 2, '2025-10-15', '2025-10-14', 1900.00, 'Pago', 'Crédito', 'Aluguel'),
(15, 3, '2025-11-15', NULL, 1900.00, 'Pendente', 'Crédito', 'Aluguel'),
(19, 1, '2025-11-01', '2025-11-01', 480000.00, 'Pago', 'PIX', 'Integral'),
(21, 1, '2025-09-10', '2025-09-10', 15000.00, 'Pago', 'TED', 'Aluguel'),
(21, 2, '2025-10-10', '2025-10-10', 15000.00, 'Pago', 'TED', 'Aluguel'),
(21, 3, '2025-11-10', '2025-11-10', 15000.00, 'Pago', 'TED', 'Aluguel'),
(23, 1, '2025-10-15', '2025-10-15', 120000.00, 'Pago', 'PIX', 'Sinal'),
(23, 2, '2025-11-15', NULL, 1080000.00, 'Pendente', 'Financiamento', 'Principal'),
(26, 1, '2025-09-12', '2025-09-11', 1950.00, 'Pago', 'PIX', 'Aluguel'),
(26, 2, '2025-10-12', '2025-10-12', 1950.00, 'Pago', 'PIX', 'Aluguel'),
(26, 3, '2025-11-12', NULL, 1950.00, 'Pendente', 'Boleto', 'Aluguel');

INSERT INTO assina(CPF_adq, codigo_c) VALUES
('98765432109', 1),
('50170230455', 2),
('12345678901', 3),
('01120230400', 4),
('52170230456', 5),
('20540670822', 6),
('70590670877', 7),
('41960010245', 8),
('40960010244', 9),
('55566677788', 10),
('73720010423', 11),
('83930230634', 12),
('94140450845', 13),
('05350670056', 14),
('15560890267', 15),
('25770010478', 16),
('35980230689', 17),
('46190450801', 18),
('56310670012', 19),
('66520890223', 20),
('76730010434', 21),
('86940230645', 22),
('97150450856', 23),
('08360670067', 24),
('52170230456', 25),
('18570890278', 26),
('15560890267', 27),
('50170230455', 28), 
('12345678901', 29), 
('05350670056', 30); 
