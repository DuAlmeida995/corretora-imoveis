-- Criando as tabelas
CREATE TABLE usuario
(
	CPF char(11) NOT NULL,
	prenome varchar(15) NOT NULL,
	sobrenome varchar(20) NOT NULL,
	data_nasc date NOT NULL CHECK (EXTRACT(YEAR FROM AGE(CURRENT_DATE, data_nasc)) >= 18),
	email varchar(50) NOT NULL,
	CONSTRAINT UPK
		PRIMARY KEY(CPF)
);

CREATE TABLE login
(
	CPF char(11) NOT NULL,
	senha varchar(15) NOT NULL,
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
	codigo int NOT NULL,
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
('12345678901', 'Ana', 'Silva', '1990-05-15', 'ana_s@mail.com'),
('98765432109', 'Bruno', 'Costa', '1985-11-01', 'bruno_c@mail.com'),
('31750890034', 'Samuel', 'Cavalcanti', '1991-04-16','samuel_c@mail.com'),
('55566677788', 'Daniel', 'Fernandes', '1977-07-22', 'daniel_f@mail.com'),
('10230450611', 'Fátima', 'Souza', '1965-04-12', 'fatima_s@mail.com'),
('20540670822', 'Gabriel', 'Lima', '1998-02-25', 'gabriel_l@mail.com'),
('30750890033', 'Helena', 'Ribeiro', '1982-09-08', 'helena_r@mail.com'),
('80700890088', 'Marcelo', 'Gomes', '1979-10-27', 'marcelo_g@mail.com'),
('40960010244', 'Isabel', 'Almeida', '2000-12-01', 'isabel_a@mail.com'),
('50170230455', 'Júlia', 'Monteiro', '1993-07-18', 'julia_m@mail.com'),
('60380450666', 'Lucas', 'Nogueira', '1988-11-14', 'lucas_n@mail.com'),
('70590670877', 'Manuela', 'Barros', '2002-06-03', 'manuela_b@mail.com'),
('52170230456', 'Tiago', 'Ferreira', '1975-12-11', 'tiago_f@mail.com'),
('90910010299', 'Paula', 'Mendes', '1995-08-19', 'paula_m@mail.com'),
('01120230400', 'Pedro', 'Henrique', '2005-01-05', 'pedro_h@mail.com'),
('11330450612', 'Diego', 'Moreira', '1960-03-30', 'diego_m@mail.com'),
('21540670823', 'Raquel', 'Freitas', '1987-05-21', 'raquel_f@mail.com'),
('41960010245', 'Tatiana', 'Pinheiro', '2003-08-07', 'tatiana_p@mail.com'),
('11122233344', 'Carla', 'Dias', '2001-01-30', 'carla_d@mail.com');

INSERT INTO proprietario(CPF) VALUES
('12345678901'),
('10230450611'),
('60380450666'),
('90910010299'),
('11330450612'),
('40960010244'),
('31750890034'),
('52170230456'),
('55566677788');

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
('55566677788', 790);

INSERT INTO corretor(CPF, especialidade, creci_codigo, regiao_atuacao) VALUES
('30750890033', 'Casa', '078501', 'Jardins'),
('80700890088', 'galpão', '092302', 'Brás'),
('21540670823', 'Apartamento', '115403', 'Tatuapé'),
('50170230455', 'Studio', '180904', 'Butantã'),
('31750890034', 'Sala comercial', '150105', 'Santana'),
('11122233344', 'Apartamento', '157321', 'Vila Prudente');

INSERT INTO tel_usuario(CPF,telefone) VALUES
('12345678901', '11987654321'),
('98765432109', '11976543210'),
('11122233344', '11988887777'),
('11122233344', '1125678901'),
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
('41960010245','11978889999');

INSERT INTO imovel(matricula, n_quartos, valor_venal, metragem, tipo, mobiliado, possui_garagem, 
n_reformas, finalidade, logradouro, complemento, numero, cep, cidade, CPF_prop,descricao) VALUES
('1001001001001001', 2, 850000.00, 80.5, 'Apartamento',true, true, 1, 'Residencial', 
'Rua Itapura', 'Apto 101', '500', '03310000', 'São Paulo', '12345678901','Apartamento de 2 quartos bem localizado no Tatuapé, próximo ao metrô.'),
('1001001001001002', 0, 450000.00, 42.0, 'Sala Comercial', false, true, 0, 'Comercial', 
'Rua Voluntários da Pátria', 'Sala 802', '2140', '02011000', 'São Paulo', '55566677788','Sala comercial de 42m² em Santana, com 1 vaga de garagem.'),
('1001001001001003', 3, 2200000.00, 150.0, 'Apartamento', false, true, 2, 'Residencial', 
'Rua Orfanato', 'Apto 121', '700', '03131010', 'São Paulo', '10230450611','Amplo apartamento na Vila Prudente com 3 quartos'),
('1001001001001004', 1, 380000.00, 35.5, 'Studio', true, false, 0, 'Residencial', 
'Avenida Vital Brasil', 'Apto 2205', '1000', '05503001', 'São Paulo', '60380450666','Studio mobiliado no Butantã, ideal para estudantes, próximo à USP.'),
('1001001001001005', 2, 1100000.00, 75.0, 'Apartamento', true, true, 1, 'Residencial', 
'Rua Tuiuti', 'Apto 55', '2000', '03307000', 'São Paulo', '90910010299','Apartamento mobiliado na Rua Tuiuti (Tatuapé), com 2 quartos e lazer completo.'),
('1001001001001006', 4, 3500000.00, 300.0, 'Casa', false, true, 3, 'Residencial', 
'Alameda Jaú', NULL, '1177', '01420002', 'São Paulo', '11330450612','Casa espaçosa nos Jardins, 4 quartos, 300m²'),
('1001001001001007', 2, 650000.00, 68.0, 'Apartamento', true, true, 1, 'Residencial', 
'Rua Ibitirama', 'Apto 401', '1500', '03133000', 'São Paulo', '40960010244','Apartamento 2 quartos (1 suíte) na Vila Prudente.'),
('1001001001001008', 4, 4200000.00, 350.0, 'Casa', false, true, 1, 'Residencial', 
'Rua Haddock Lobo', NULL, '1400', '01414002', 'São Paulo', '52170230456','Casa de alto padrão nos Jardins, próxima à Rua Oscar Freire.'),
('1001001001001009', 0, 1800000.00, 450.0, 'Galpão',false, false, 2, 'Comercial', 
'Rua Bresser', NULL, '1200', '03017000', 'São Paulo', '55566677788','Galpão comercial de 450m² no Brás, com pé direito alto.'),
('1001001001001010', 0, 600000.00, 45.0, 'Sala Comercial', false, true, 0, 'Comercial',
'Rua Azevedo Macedo', 'Sala 1010', '80', '02013000', 'São Paulo', '31750890034','Sala comercial reformada em Santana, 45m², pronta para uso.');

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
('1001001001001010', 'Ar_Condicionado');

INSERT INTO contrato(codigo, valor, status,	data_inicio, data_fim, tipo, 
matricula_imovel, CPF_prop, CPF_corretor) VALUES
(1, 850000.00, 'Vendido', NULL, NULL, 'Venda', 
'1001001001001001', '12345678901', '21540670823'),
(2, 2500.00, 'Ativo', '2025-01-15', '2027-01-14', 'Aluguel', 
'1001001001001002', '55566677788', '31750890034'),
(3, 3500000.00, 'Em Negociação', NULL, NULL, 'Venda', 
'1001001001001006', '11330450612', '30750890033'),
(4, 1800.00, 'Ativo', '2025-03-01', '2026-08-31', 'Aluguel', 
'1001001001001004', '60380450666', '50170230455'),
(5, 1800000.00, 'Vendido', NULL, NULL, 'Venda', 
'1001001001001009', '55566677788', '80700890088'),
(6, 2200.00, 'Finalizado', '2023-01-10', '2025-07-09', 'Aluguel', 
'1001001001001007', '40960010244', '11122233344');

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
(5, 1, '2025-09-10', '2025-09-10', 1800000.00, 'Pago', 'TED', 'Integral');

INSERT INTO assina(CPF_adq, codigo_c) VALUES
('98765432109', 1),
('50170230455', 2),
('12345678901', 3),
('01120230400', 4),
('52170230456', 5),
('20540670822', 6);

