/*
Arquivo com as consultas embutidas na aplicacao. Para cada uma delas, havera um 
enunciado, seguido do codigo SQL.

 1. Cadastra um usuario (sem ainda colocar de qual/quais tipos ele é).
 A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

INSERT INTO usuario (CPF, prenome, sobrenome, data_nasc, email)
VALUES (%s, %s, %s, %s, %s);
*/

INSERT INTO usuario (CPF, prenome, sobrenome, data_nasc, email)
VALUES ('99988877766', 'Novo', 'Usuario', '1995-03-20', 'novo.usuario@email.com');

/*
 2. Cadastra um usuário como adquirente. 
 A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

INSERT INTO adquirente (CPF,pontuacao_credito)
VALUES (%s, %s);
*/

INSERT INTO adquirente (CPF,pontuacao_credito)
VALUES ('99988877766', 820);

/*
3. Cadastra um usuário como proprietário. A seguir apresentamos um exemplo de
uso, substituindo os %s por valores.

INSERT INTO proprietario (CPF)
VALUES (%s);
*/


INSERT INTO proprietario (CPF)
VALUES ('99988877766');

/*
4. Cadastra um usuário como corretor. A seguir apresentamos um exemplo de uso, 
substituindo os %s por valores.

INSERT INTO corretor (CPF, especialidade, creci_codigo, regiao_atuacao)
VALUES (%s, %s, %s, %s);
*/

INSERT INTO corretor (CPF, especialidade, creci_codigo, regiao_atuacao)
VALUES ('99988877766', 'Apartamento', '123456', 'Moema');

/*
5. Insere a senha com hash na tabela login (de forma segura).
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

INSERT INTO login (CPF, senha)
VALUES (%s, %s);
*/

INSERT INTO login (CPF, senha)
VALUES ('99988877766', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3');

/*
6. Insere um ou mais telefones para um usuário. A consulta é construída
dinamicamente para inserir múltiplas linhas de uma vez.
(A lógica em Python primeiro verifica se o usuário ultrapassará
o limite de 3 telefones antes de executar esta consulta).
A seguir apresentamos um exemplo de uso para 2 telefones,
substituindo os %s por valores.

INSERT INTO tel_usuario(CPF, telefone) VALUES (%s, %s), (%s, %s);
*/

INSERT INTO tel_usuario(CPF, telefone)
VALUES ('99988877766', '11988887777'), ('99988877766', '11955554444');

/*
7. Obtém o total de telefones cadastrados para um usuário específico.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT COUNT(*) AS total
FROM tel_usuario
WHERE CPF = %s;
*/

SELECT COUNT(*) AS total
FROM tel_usuario
WHERE CPF = '99988877766';

/*
8. Remove um ou mais telefones de um usuário, especificados em uma lista.
(A lógica em Python primeiro verifica se a remoção deixará o usuário
com menos de um telefone antes de executar esta consulta).
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

DELETE FROM tel_usuario
WHERE CPF = %s AND telefone = ANY(%s);
*/

DELETE FROM tel_usuario
WHERE CPF = '99988877766' AND telefone = ANY(ARRAY['11955554444']);

/*
9. Deleta um usuário. A seguir apresentamos um exemplo de uso,
substituindo os %s por valores.

DELETE FROM usuario
WHERE CPF = %s;
*/

DELETE FROM usuario
WHERE CPF = '99988877766';

/*
10. Obtém um perfil dos interesses de um adquirente, contando quantos
contratos ele assinou, agrupados por tipo de imóvel (ex: Apartamento),
finalidade (ex: Residencial) e tipo de contrato (ex: Venda).
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT u.prenome, u.sobrenome, i.tipo AS tipo_de_imovel,
i.finalidade, c.tipo AS tipo_de_contrato, COUNT(*) AS total_de_contratos
FROM usuario u
JOIN assina a ON u.CPF = a.CPF_adq
JOIN contrato c ON a.codigo_c = c.codigo
JOIN imovel i ON c.matricula_imovel = i.matricula
WHERE u.CPF = %s
GROUP BY u.CPF, i.tipo, i.finalidade, c.tipo
ORDER BY u.prenome, total_de_contratos DESC;
*/

SELECT u.prenome, u.sobrenome, i.tipo AS tipo_de_imovel, i.finalidade, c.tipo AS tipo_de_contrato,
	COUNT(*) AS total_de_contratos
FROM usuario u
JOIN assina a ON u.CPF = a.CPF_adq
JOIN contrato c ON a.codigo_c = c.codigo
JOIN imovel i ON c.matricula_imovel = i.matricula
WHERE u.CPF = '99988877766'
GROUP BY u.CPF, i.tipo, i.finalidade, c.tipo
ORDER BY u.prenome, total_de_contratos DESC;

/*
11. Lista todos os imóveis de um proprietário e inclui informações do contrato
associado (como status e data de fim), se houver. (A consulta SQL é apenas
a primeira etapa. O código Python subsequente itera sobre os resultados para:
verificar se contratos 'Ativos' já expiraram (comparando data_fim com a data
atual), atualizar o status no banco se um contrato tiver expirado).
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT i.matricula, i.logradouro, i.numero, c.codigo, c.status, c.valor, c.data_fim
FROM imovel i
LEFT JOIN contrato c ON i.matricula = c.matricula_imovel
WHERE i.CPF_prop = %s;
*/

SELECT i.matricula, i.logradouro, i.numero, c.codigo, c.status, c.valor, c.data_fim
FROM imovel i
LEFT JOIN contrato c ON i.matricula = c.matricula_imovel
WHERE i.CPF_prop = '99988877766';

/*
12. Filtra imóveis com base nos parâmetros fornecidos, permitindo
uma filtragem flexível. A seguir apresentamos um exemplo de uso,
substituindo os %s por valores.

Cenário A: Filtro Simples (Sem Comodidades). Busca imóveis que
correspondam a um ou mais critérios simples (ex: por bairro, tipo,
faixa de valor). A cláusula WHERE é montada dinamicamente.
O GROUP BY é usado para agrupar as múltiplas imagens de cada imóvel.

SELECT DISTINCT i.*, array_agg(DISTINCT img.imovel_image_url) AS imagens
FROM imovel i
LEFT JOIN comodidades_imovel c ON i.matricula = c.matricula
LEFT JOIN imagem_imovel img ON i.matricula = img.matricula
WHERE i.tipo = %s AND i.bairro = %s AND i.valor_venal >= %s
GROUP BY i.matricula;
*/

SELECT i.*, array_agg(DISTINCT img.imovel_image_url) AS imagens
FROM imovel i
LEFT JOIN comodidades_imovel c ON i.matricula = c.matricula
LEFT JOIN imagem_imovel img ON i.matricula = img.matricula
WHERE i.tipo = 'Apartamento'
  AND i.bairro = 'Tatuapé'
  AND i.valor_venal >= 800000
GROUP BY i.matricula;

/*
Cenário B: Filtro por Comodidades (Lógica Especial). Busca imóveis
que possuam todas as comodidades que o usuário queira.

SELECT i.*, array_agg(DISTINCT img.imovel_image_url) AS imagens
FROM imovel i
LEFT JOIN comodidades_imovel c ON i.matricula = c.matricula
LEFT JOIN imagem_imovel img ON i.matricula = img.matricula
WHERE i.bairro = %s AND c.comodidade = ANY(%s)
GROUP BY i.matricula
HAVING COUNT(DISTINCT c.comodidade) = %s;
*/

SELECT i.*, array_agg(DISTINCT img.imovel_image_url) AS imagens
FROM imovel i
LEFT JOIN comodidades_imovel c ON i.matricula = c.matricula
LEFT JOIN imagem_imovel img ON i.matricula = img.matricula
WHERE i.bairro = 'Tatuapé' AND c.comodidade = ANY(ARRAY['Elevador', 'Academia'])
GROUP BY i.matricula
HAVING COUNT(DISTINCT c.comodidade) = 2;

/*
13. Obtém os status de um imóvel (o código em python confere se a data de
fim de um contrato já passou. Se tiver, altera o status do contrato para
finalizado e o status do imóvel para disponível).
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT c.codigo, c.status, c.data_fim FROM imovel i
LEFT JOIN contrato c ON i.matricula = c.matricula_imovel
WHERE i.matricula = %s
ORDER BY c.codigo DESC;
*/

SELECT c.codigo, c.status, c.data_fim FROM imovel i
LEFT JOIN contrato c ON i.matricula = c.matricula_imovel
WHERE i.matricula = '1001001001001002'
ORDER BY c.codigo DESC;

/*
14. Atualiza os dados cadastrais básicos (nome, email, imagem de perfil)
de um usuário. A seguir apresentamos um exemplo de uso,
substituindo os %s por valores.

UPDATE usuario
SET prenome = %s, sobrenome = %s, email = %s, profile_image_url = %s
WHERE CPF = %s;
*/

UPDATE usuario
SET prenome = 'Ana Maria',
    sobrenome = 'Silva Souza',
    email = 'ana.nova@email.com',
    profile_image_url = 'https://exemplo.com/fotos/ana_silva_v2.jpg'
WHERE CPF = '12345678901';

/*
15. Cadastra um novo imóvel no sistema, associando-o a um proprietário
existente. A seguir apresentamos um exemplo de uso,
substituindo os %s por valores.

INSERT INTO imovel (matricula, n_quartos, valor_venal, metragem, tipo,
mobiliado, possui_garagem, n_reformas, finalidade, logradouro, complemento,
numero, CEP, cidade, CPF_prop, descricao, bairro)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
*/

INSERT INTO imovel (matricula, n_quartos, valor_venal, metragem, tipo, mobiliado, possui_garagem, 
	n_reformas, finalidade, logradouro, complemento, numero, CEP, cidade, CPF_prop, descricao, bairro)
VALUES ('1001001001001011', 3, 950000.00, 180.0, 'Casa', false, true, 1, 'Residencial',
'Rua Maria Amália Lopes de Azevedo', NULL, '3000', '02350001', 'São Paulo', '60590810211',
'Casa espaçosa no Tremembé, 3 quartos, perto da serra.','Tremembé');

/*
16. Atualiza características de um imóvel. A consulta UPDATE é construída
dinamicamente para alterar apenas os campos que foram fornecidos (não nulos).
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

EXEMPLO: Se o usuário quiser alterar apenas o valor_venal e o n_reformas
UPDATE imovel
SET valor_venal = %s, n_reformas = %s
WHERE matricula = %s;
*/

UPDATE imovel
SET valor_venal = 1050000.00, n_reformas = 2
WHERE matricula = '1001001001001011';

/*
17. Altera o proprietário associado a um imóvel específico.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

UPDATE imovel
SET CPF_prop = %s
WHERE matricula = %s;
*/

UPDATE imovel
SET CPF_prop = '98765432109'
WHERE matricula = '1001001001001011';

/*
18. Adiciona uma ou mais comodidades a um imóvel. A consulta é construída
dinamicamente para inserir múltiplas linhas de uma vez.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

Exemplo para 2 itens
INSERT INTO comodidades_imovel(matricula, comodidade)
VALUES (%s, %s), (%s, %s);
*/

INSERT INTO comodidades_imovel(matricula, comodidade)
VALUES ('1001001001001011', 'Churrasqueira'),
       ('1001001001001011', 'Quintal');

/*
19. Remove uma ou mais comodidades de um imóvel específico.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

DELETE FROM comodidades_imovel
WHERE matricula = %s AND comodidade = ANY(%s);
*/

DELETE FROM comodidades_imovel
WHERE matricula = '1001001001001011' AND comodidade = ANY(ARRAY['Quintal']);

/*
20. Deleta um imóvel do sistema. A seguir apresentamos um exemplo de uso,
substituindo os %s por valores.

DELETE FROM imovel
WHERE matricula = %s;
*/

DELETE FROM imovel
WHERE matricula = '1001001001001011';

/*
21. Vincula uma URL de imagem a um imóvel específico.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

INSERT INTO imagem_imovel (matricula, imovel_image_url)
VALUES (%s, %s);
*/

INSERT INTO imagem_imovel (matricula, imovel_image_url)
VALUES ('1001001001001011', 'http://localhost:5000/static/uploads/imoveis/1001001001001011_0.jpg');

/*
22. Remove o vinculo de uma imagem especifica com um imovel no banco de dados.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

DELETE FROM imagem_imovel
WHERE matricula = %s AND imovel_image_url = %s;
*/

DELETE FROM imagem_imovel
WHERE matricula = '1001001001001011'
  AND imovel_image_url = 'http://localhost:5000/static/uploads/imoveis/1001001001001011_0.jpg';

/*
23. Obtém contratos de aluguel ativos que estão perto de vencer
(dentro de um intervalo de 30 dias a partir da data atual).
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT * FROM contrato
WHERE tipo='Aluguel' AND status = 'Ativo' AND
data_fim BETWEEN %s AND %s;
*/

SELECT * FROM contrato
WHERE tipo='Aluguel' AND status = 'Ativo' AND
data_fim BETWEEN '2025-11-19' AND '2025-12-19';

/*
24. Insere um novo contrato (Venda ou Aluguel) no sistema,
vinculando um imóvel a um proprietário e a um corretor responsável.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

INSERT INTO contrato (codigo, valor, status, data_inicio, data_fim, tipo,
matricula_imovel, CPF_prop, CPF_corretor)
VALUES (DEFAULT, %s, %s, %s, %s, %s, %s, %s, %s)
RETURNING codigo;
*/

INSERT INTO contrato (codigo, valor, status, data_inicio, data_fim, tipo, matricula_imovel,
	CPF_prop, CPF_corretor)
VALUES (DEFAULT, 2500.00, 'Ativo', '2025-12-01', '2027-12-01', 'Aluguel', '1001001001001011',
	'12345678901', '28780010489')
RETURNING codigo;

/*
25. Registra a assinatura de um contrato por um adquirente,
vinculando o CPF do cliente ao código do contrato.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

INSERT INTO assina(CPF_adq, codigo_c)
VALUES (%s, %s);
*/

INSERT INTO assina(CPF_adq, codigo_c)
VALUES ('50170230455', 31);

/*
26. Deleta um contrato do sistema.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

DELETE FROM contrato
WHERE codigo = %s;
*/

DELETE FROM contrato
WHERE codigo = 31;

/*
27. Atualiza o status de um contrato existente.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

UPDATE contrato
SET status = %s
WHERE codigo = %s;
*/

UPDATE contrato
SET status = 'Finalizado'
WHERE codigo = 4;

/*
28. Obtém o histórico de períodos (data de início e fim)
de todos os contratos de aluguel associados a um imóvel
específico, ordenados do mais recente para o mais antigo.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT codigo, matricula_imovel, data_inicio, data_fim FROM contrato
WHERE tipo='Aluguel' AND matricula_imovel=%s
ORDER BY data_inicio DESC
*/

SELECT codigo, matricula_imovel, data_inicio, data_fim FROM contrato
WHERE tipo='Aluguel' AND matricula_imovel='1001001001001007'
ORDER BY data_inicio DESC;

/*
29. Retorna a lista completa de contratos (Venda e Aluguel, Ativos ou não),
ordenada do mais recente para o mais antigo.
*/

SELECT c.codigo, c.status, c.tipo, c.data_inicio, c.data_fim, c.valor,  c.CPF_prop, c.CPF_corretor,
	i.matricula, i.logradouro, i.numero
FROM contrato c
JOIN imovel i ON c.matricula_imovel = i.matricula
ORDER BY c.codigo DESC; 

/*
30. Obtém o histórico de valores negociados (seja de venda ou aluguel)
de todos os contratos associados a um imóvel específico,
ordenados do mais recente para o mais antigo.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT codigo, matricula_imovel, valor FROM contrato
WHERE matricula_imovel = %s
ORDER BY codigo DESC;
*/

SELECT codigo, matricula_imovel, valor FROM contrato
WHERE matricula_imovel = '1001001001001002'
ORDER BY codigo DESC;

/*
31. Gera um relatório dos imóveis ordenados pelo número de vezes que foram
alugados (contagem de contratos do tipo 'Aluguel'), do mais popular
para o menos popular.
*/

SELECT i.matricula, i.logradouro, i.numero,
        COUNT(c.codigo) AS nr_de_vezes_alugado
        FROM contrato c JOIN imovel i ON c.matricula_imovel = i.matricula
        WHERE c.tipo='Aluguel'
		GROUP BY i.matricula
        ORDER BY nr_de_vezes_alugado DESC;

/*
32. Devolve o histórico de proprietários e adquirentes (ou inquilinos)
associados a um imóvel através de seus contratos. A consulta recupera
o nome do proprietário no momento do contrato e, se houver, o nome
da pessoa que assinou (comprou ou alugou).
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT c.codigo, c.tipo, c.status,
prop.prenome AS proprietario_nome, prop.sobrenome AS proprietario_sobrenome,
adq.prenome AS adquirente_nome, adq.sobrenome AS adquirente_sobrenome
FROM contrato c
JOIN usuario prop ON c.CPF_prop = prop.CPF
LEFT JOIN assina a ON c.codigo = a.codigo_c
LEFT JOIN usuario adq ON a.CPF_adq = adq.CPF
WHERE c.matricula_imovel = %s
ORDER BY c.codigo DESC;
*/

SELECT c.codigo, c.tipo, c.status,
       prop.prenome AS proprietario_nome, prop.sobrenome AS proprietario_sobrenome,
       adq.prenome AS adquirente_nome, adq.sobrenome AS adquirente_sobrenome
FROM contrato c
JOIN usuario prop ON c.CPF_prop = prop.CPF
LEFT JOIN assina a ON c.codigo = a.codigo_c
LEFT JOIN usuario adq ON a.CPF_adq = adq.CPF
WHERE c.matricula_imovel = '1001001001001001'
ORDER BY c.codigo DESC;

/*
33. Insere um registro de pagamento (parcela ou valor total)
referente a um contrato específico.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

INSERT INTO pagamento (codigo_c, n_pagamento, data_vencimento, data_pagamento,
valor, status, forma_pagamento, tipo)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
*/

INSERT INTO pagamento (codigo_c, n_pagamento, data_vencimento, data_pagamento, valor, status, 
	forma_pagamento, tipo)
VALUES (31, 1, '2026-01-01', NULL, 2500.00, 'Pendente', 'Boleto', 'Aluguel');

/*
34. Atualiza o status de uma parcela ou pagamento específico de um contrato.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

UPDATE pagamento
SET status = %s
WHERE codigo_c = %s AND n_pagamento = %s;
*/

UPDATE pagamento
SET status = 'Pago'
WHERE codigo_c = 31 AND n_pagamento = 1;

/*
35. Consulta o status e a data de vencimento de uma parcela específica.
A lógica Python verifica se o status é 'Pendente' e se a data de vencimento
é anterior à data atual. Se ambas as condições forem verdadeiras,
o sistema chama internamente a função "Atualizar Status de Pagamento"
para mudar o status para 'Atrasado' no banco de dados antes de
retornar o valor).

SELECT status, data_vencimento FROM pagamento
WHERE codigo_c = %s AND n_pagamento = %s;
*/

SELECT status, data_vencimento FROM pagamento
WHERE codigo_c = 31 AND n_pagamento = 1;

/*
36. Obtém o histórico detalhado de pagamentos (realizados, pendentes ou
atrasados) referentes a todos os contratos associados a um imóvel específico,
ordenados pela data de vencimento mais recente.

SELECT p.codigo_c, p.n_pagamento, p.status, p.valor, p.data_vencimento,
p.data_pagamento
FROM pagamento p
JOIN contrato c ON p.codigo_c = c.codigo
WHERE c.matricula_imovel = %s
ORDER BY p.data_vencimento DESC;
*/

SELECT p.codigo_c, p.n_pagamento, p.status, p.valor, p.data_vencimento, p.data_pagamento
FROM pagamento p
JOIN contrato c ON p.codigo_c = c.codigo
WHERE c.matricula_imovel = '1001001001001001'
ORDER BY p.data_vencimento DESC;

/*
37. Obtém o histórico completo de pagamentos (realizados ou pendentes)
de um adquirente específico, listando o valor, status e o endereço
do imóvel referente a cada pagamento.

SELECT p.codigo_c, p.n_pagamento, p.status, p.valor, i.logradouro, i.numero,
p.data_vencimento, p.data_pagamento
FROM pagamento p
JOIN contrato c ON p.codigo_c = c.codigo
JOIN imovel i ON c.matricula_imovel = i.matricula
JOIN assina a ON c.codigo = a.codigo_c
WHERE a.CPF_adq = %s
ORDER BY p.data_vencimento DESC;
*/

SELECT p.codigo_c, p.n_pagamento, p.status, p.valor, i.logradouro, i.numero, p.data_vencimento, 
	p.data_pagamento
FROM pagamento p
JOIN contrato c ON p.codigo_c = c.codigo
JOIN imovel i ON c.matricula_imovel = i.matricula
JOIN assina a ON c.codigo = a.codigo_c
WHERE a.CPF_adq = '50170230455'
ORDER BY p.data_vencimento DESC;

/*
38. Busca os dados específicos de um corretor (Especialidade, CRECI, Região)
e agrupa todos os seus telefones cadastrados em uma única string
separada por vírgulas.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT
c.especialidade, c.creci_codigo AS creci, c.regiao_atuacao,
STRING_AGG(t.telefone, ',') AS telefone_contato
FROM corretor c
LEFT JOIN tel_usuario t ON c.CPF = t.CPF
WHERE c.CPF = %s
GROUP BY c.CPF, c.especialidade, c.creci_codigo, c.regiao_atuacao;
*/

SELECT
    c.especialidade,
    c.creci_codigo AS creci,
    c.regiao_atuacao,
    STRING_AGG(t.telefone, ',') AS telefone_contato
FROM corretor c
LEFT JOIN tel_usuario t ON c.CPF = t.CPF
WHERE c.CPF = '28780010489'
GROUP BY c.CPF, c.especialidade, c.creci_codigo, c.regiao_atuacao;

/*
39. Busca todos os telefones cadastrados para um usuário específico
e os retorna em uma única string, separados por vírgula.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT STRING_AGG(telefone, ',') AS telefone_contato
FROM tel_usuario
WHERE CPF = %s;
*/

SELECT STRING_AGG(telefone, ',') AS telefone_contato
FROM tel_usuario
WHERE CPF = '31750890034';

/*
40. Busca a senha criptografada (hash) de um usuário específico na tabela
de login para realizar a validação de acesso.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT senha FROM login WHERE CPF = %s;
*/

SELECT senha FROM login WHERE CPF = '12345678901';

/*
41. Busca os dados cadastrais básicos (nome, email, nascimento, foto)
de um usuário. A seguir apresentamos um exemplo de uso,
substituindo os %s por valores.

SELECT prenome, sobrenome, email, data_nasc, profile_image_url
FROM usuario WHERE CPF = %s;
*/

SELECT prenome, sobrenome, email, data_nasc, profile_image_url
FROM usuario WHERE CPF = '12345678901';

/*
42. Obtém o endereço de e-mail de um usuário específico através do CPF.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

SELECT email FROM usuario WHERE CPF = %s;
*/

SELECT email FROM usuario WHERE CPF = '12345678901';

/*
43. Salva um código de 6 dígitos (OTP) e sua data de expiração para um usuário.
Se o usuário já possuir um código salvo anteriormente, a cláusula ON CONFLICT
atualiza o registro existente com o novo código e novo prazo, garantindo apenas
um código ativo por CPF.

INSERT INTO otp_codes (CPF, otp_code, expires_at)
VALUES (%s, %s, %s)
ON CONFLICT (CPF) DO UPDATE
SET otp_code = EXCLUDED.otp_code, expires_at = EXCLUDED.expires_at;
*/

INSERT INTO otp_codes (CPF, otp_code, expires_at)
VALUES ('12345678901', '123456', '2025-11-20 14:30:00')
ON CONFLICT (CPF) DO UPDATE
SET otp_code = EXCLUDED.otp_code, expires_at = EXCLUDED.expires_at;

/*
44. Busca o código OTP atual e sua data de expiração para um determinado CPF.
O código Python usa esses dados para verificar se o token fornecido
pelo usuário está correto e dentro do prazo.

SELECT otp_code, expires_at
FROM otp_codes
WHERE CPF = %s;
*/

SELECT otp_code, expires_at
FROM otp_codes
WHERE CPF = '12345678901';

/*
45. Remove o registro de OTP de um usuário.
A seguir apresentamos um exemplo de uso, substituindo os %s por valores.

DELETE FROM otp_codes WHERE CPF = %s;
*/

DELETE FROM otp_codes WHERE CPF = '12345678901';

/*
46. Atualiza o hash da senha de um usuário na tabela de login.
Esta operação geralmente ocorre após uma recuperação de senha bem-sucedida.

UPDATE login
SET senha = %s
WHERE CPF = %s;
*/

UPDATE login
SET senha = 'novohashseguro123456789...'
WHERE CPF = '12345678901';

/*
47. Calcula estatísticas para o dashboard em uma única consulta otimizada.
Conta contratos ativos, atrasados (data fim < hoje) e vencendo em 30 dias.
*/

SELECT
COUNT(*) FILTER (WHERE status = 'Ativo') as ativos,
COUNT(*) FILTER (WHERE status = 'Ativo' AND data_fim < CURRENT_DATE) as atrasados,
COUNT(*) FILTER (WHERE status = 'Ativo' AND data_fim BETWEEN CURRENT_DATE AND 
	(CURRENT_DATE + INTERVAL '30 day')) as vencendo
FROM contrato;

/*
48. Atualiza todos os dados cadastrais de um imóvel específico de uma única vez.

UPDATE imovel
SET n_quartos = %s, 
 valor_venal = %s, 
metragem = %s, 
tipo = %s, 
mobiliado = %s, 
possui_garagem = %s, 
n_reformas = %s, 
finalidade = %s, 
logradouro = %s, 
complemento = %s, 
numero = %s, 
cep = %s, 
cidade = %s, 
descricao = %s, 
bairro = %s
WHERE matricula = %s;
*/

UPDATE imovel
SET n_quartos = 3, 
    valor_venal = 1100000.00, 
    metragem = 180.0, 
    tipo = 'Casa', 
    mobiliado = true, 
    possui_garagem = true, 
    n_reformas = 2, 
    finalidade = 'Residencial', 
    logradouro = 'Rua Maria Amália Lopes de Azevedo', 
    complemento = NULL, 
    numero = '3000', 
    cep = '02350001', 
    cidade = 'São Paulo', 
    descricao = 'Casa recém-reformada no Tremembé, agora mobiliada.', 
    bairro = 'Tremembé'
WHERE matricula = '1001001001001011';
