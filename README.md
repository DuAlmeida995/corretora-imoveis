# Aura - Sistema de Gestão para Corretoras de Imóveis

**Aura** é um aplicativo multiplataforma desenvolvido como projeto da disciplina **Banco de Dados I**, ministrada pela professora **Patrícia** na **EACH USP**.  
O sistema foi criado para atender **companias corretoras com grande volume de corretores**, oferecendo uma plataforma moderna e organizada para gestão imobiliária deles.

---

## Sistema

O objetivo do Aura é centralizar e automatizar o fluxo de trabalho de funcionário de uma corretora de imóveis, permitindo:

### Gestão de Imóveis e Contratos
- Cada corretor possui seu próprio painel.
- Visualização de todos os contratos firmados.
- Registro e acompanhamento de vendas e locações.

### Mapa Interativo de Imóveis
- Visão geográfica de todos os imóveis disponíveis na região.
- Pesquisa por localização, tipo, preço, tamanho e outros filtros combinados.

### Indicadores Financeiros
- Consulta de pagamentos realizados.
- Identificação de pagamentos atrasados.
- Análise de inadimplência/vacância com gráficos intuitivos.

### Painel Administrativo
- Gestão do perfil de cada corretor.
- Acompanhamento geral da operação da corretora.
- Organização dos dados de forma centralizada.

### Segurança
- Tela de login com autenticação segura e criptografada (hash).
- Armazenamento estruturado e otimizado no banco de dados do projeto.

---

## Instalação no Windows (Recomendado)

### **1. Baixe o pacote para Windows** 
Na aba **Releases**, baixe o arquivo aura-windows-release.zip
 
### **2. Extraia o conteúdo**
Descompacte o `.zip` em qualquer pasta.

O arquivo extraído conterá:
- `Aura.exe`  
- DLLs necessárias  
- Pasta `data` (assets e arquivos de configuração)

### **3. Execute**
Abra o arquivo aura.exe


---



## Instalação no Android

### **1. Baixe o APK**
Acesse a aba **Releases** do repositório e faça download do arquivo app-release.apk

### **2. Instale no dispositivo**
No seu celular:
1. Abra o arquivo `.apk`
2. Aceite a instalação de fontes externas, se solicitado
3. Aguarde a instalação

### **3. Execute o app**
Procure por **Aura** na lista de aplicativos e abra normalmente.

---

## Lembrando que o backend é necessário

1. **Inicie o servidor PostgreSQL**  
   Certifique-se de que o PostgreSQL está rodando e acessível (localhost por padrão).

2. **Crie um banco de dados `imobiliaria`**  
   CREATE DATABASE imobiliaria;

3. **Rode o script de população fornecido em script.sql**  
    psql -U postgres -d imobiliaria -f populacao.sql

4. **Instale as dependências Python**  
    pip install -r requirements.txt

5. **Execute o servidor**  
    python main.py