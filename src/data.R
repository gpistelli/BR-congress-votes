# Data collection

library(httr)
library(rvest)
library(plyr)
library(jsonlite)
library(dplyr)

### Criando funções para a coleta dos dados na API ###

# Coleta dos dados dos deputados de uma legislatura específica (a legislação atual é a 56)
congress.dep.search.all <- function(leg){
  deps <- content(GET(paste0("https://dadosabertos.camara.leg.br/api/v2/deputados?idLegislatura=", leg, "&ordem=ASC&ordenarPor=siglaPartido")), as = "text", encoding = "UTF-8") %>% fromJSON()
  deps <- deps[[1]]
}

# Coleta das frentes parlamentares que um deputa ocupa
congress.dep.frentes <- function(id){
  link <- paste0("https://dadosabertos.camara.leg.br/api/v2/deputados/", id, "/frentes")
  df <- content(GET(link), as = "text", encoding = "UTF-8") %>% fromJSON()
  df <- df[[1]]
}

# Coleta das falas de um deputado (o formato das datas é "YYYY-MM-DD")
congress.dep.talks <- function(id, d.in, d.fim){
  link <- paste0("https://dadosabertos.camara.leg.br/api/v2/deputados/", id, "/discursos?", d.in, "&dataFim=", d.fim, "&ordenarPor=dataHoraInicio&ordem=ASC")
  df <- content(GET(link), as = "text", encoding = "UTF-8") %>% fromJSON()
  df <- df[[1]]
}

# Coleta das propostas feitas por um deputado
congress.dep.props <- function(id, d.in, d.fim){
  link <- paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes?idDeputadoAutor=", id, "&dataApresentacaoInicio=", d.in, "&dataApresentacaoFim=", d.fim, "&ordem=ASC&ordenarPor=id")
  df <- content(GET(link), as = "text", encoding = "UTF-8") %>% fromJSON()
  df <- df[[1]]
}

# Ver quais foram as votações realizadas pelo congresso em um determinado período
congress.vot.search.date <- function(dat.in, dat.f){
  link <- paste0("https://dadosabertos.camara.leg.br/api/v2/votacoes?dataInicio=", dat.in, "&dataFim=", dat.f, "&ordem=DESC&ordenarPor=dataHoraRegistro")
  df <- content(GET(link), as = "text", encoding = "UTF-8")
  df <- fromJSON(df)
  df <- df[[1]]
  return(df)
}

congress.vot.search.date.plen <- function(dat.in, dat.f){
  link <- paste0("https://dadosabertos.camara.leg.br/api/v2/votacoes?dataInicio=", dat.in, "&dataFim=", dat.f, "&ordem=DESC&ordenarPor=dataHoraRegistro")
  df <- content(GET(link), as = "text", encoding = "UTF-8")
  df <- fromJSON(df)
  df <- as.data.frame(df[[1]])
  df <- df[which(df$siglaOrgao == "PLEN"), ]
  return(df)
}

# Ver quais foram os votos dos deputados em uma votação
congress.dep.votos.full.table <- function(id){
  link <- paste0("https://dadosabertos.camara.leg.br/api/v2/votacoes/", id, "/votos")
  df <- content(GET(link), as = "text", encoding = "UTF-8")
  df <- fromJSON(df)
  df <- df[[1]]
  df <- do.call(cbind, df)
  return(df)
}

# Versão menor da coleta de dados dos votos em uma votação
congress.dep.votos1 <- function(id){
  link <- paste0("https://dadosabertos.camara.leg.br/api/v2/votacoes/", id, "/votos")
  df <- content(GET(link), as = "text", encoding = "UTF-8")
  df <- fromJSON(df)
  df <- df[[1]]
  df <- do.call(cbind.data.frame, df)
  df <- df[, c(1, 3, 6)]
  df <- as.data.frame(df)
  names(df) <- c("voto", "id", "part")
  return(df)
}

# Versão menor da coleta de dados dos votos em uma votação
congress.dep.votos2 <- function(id){
  link <- paste0("https://dadosabertos.camara.leg.br/api/v2/votacoes/", id, "/votos")
  df <- content(GET(link), as = "text", encoding = "UTF-8")
  df <- fromJSON(df)
  df <- df[[1]]
  df <- do.call(cbind.data.frame, df)
  df <- df[, c(1, 3)]
  df <- as.data.frame(df)
  names(df) <- c("voto", "id")
  return(df)
}

#### Coletando os dados necessários para o MCA ####

deputados <- congress.dep.search.all(56)
deputados <- deputados[, c(1, 3, 4)]
write.csv(x = deputados, file = "deputados.csv", fileEncoding = "utf8")

# Para exemplo apenas, farei como se deu a procura pela MP 905 (Carteira Verde Amarela)

search.vote <- congress.vot.search.date("2020-04-12", "2020-04-18")
id_cartvdam <- search.vote$id[grep("905", search.vote$descricao)]

# Escolheu-se as seguintes votações e, a seguir, realizou-se a sua coleta com o código e arrumou os dados

search.vote <- congress.vot.search.date("2019-07-09", "2019-07-11")
id_refprev <- search.vote$id[grep("nº 6, de 2019", search.vote$descricao)]

search.vote <- congress.vot.search.date("2021-05-19", "2021-05-21")
id_telecom <- search.vote$id[grep("1\\.018", search.vote$descricao)]

search.vote <- congress.vot.search.date("2021-05-18", "2021-05-21")
id_eletrobras <- search.vote$id[grep("Subemenda Substitutiva", search.vote$descricao)]

search.vote <- congress.vot.search.date("2021-08-04", "2021-08-06")
id_correios <- search.vote$id[grep("591", search.vote$descricao)]

search.vote <- congress.vot.search.date("2021-08-16", "2021-08-18")
id_sisteleit <- search.vote$id[grep("Aprovada, em segundo turno, a Proposta de Emenda", search.vote$descricao)]

search.vote <- congress.vot.search.date("2021-08-09", "2021-08-10")
id_minireftrab <- search.vote$id[grep("Subemenda", search.vote$descricao)]

search.vote <- congress.vot.search.date("2021-08-02", "2021-08-04")
id_grilagem <- search.vote$id[grep("2\\.633", search.vote$descricao)]

search.vote <- congress.vot.search.date("2021-05-11", "2021-05-13")
id_lic_amb <- search.vote$id[grep("3\\.729", search.vote$descricao)]

# Não consigo encontrar a votação do voto impresso... Estranho!
#search.vote <- congress.vot.search.date.plen("2021-08-10", "2021-08-11")
#id_vot_imp <- search.vote$id[grep(" 35 ", search.vote$descricao)]
#rm(id_vot_imp)

search.vote <- congress.vot.search.date.plen("2019-11-04", "2019-11-06")
id_posse_armas <- search.vote$id[grep("3\\.723", search.vote$descricao)]

search.vote <- congress.vot.search.date.plen("2021-08-30", "2021-09-02")
id_imp_renda <- search.vote$id[grep("2\\.337", search.vote$descricao)]

search.vote <- congress.vot.search.date.plen("2021-10-19", "2021-10-21")
id_cons_mp <- search.vote$id[grep("PEC", search.vote$descricao)]

search.vote <- congress.vot.search.date.plen("2021-06-15", "2021-06-17")
id_improb_base <- search.vote$id[grep("10\\.887", search.vote$descricao)]

search.vote <- congress.vot.search.date.plen("2021-10-05", "2021-10-07")
id_improb_nep <- search.vote$id[grep("2\\.505", search.vote$descricao)][1]
id_improb_dolo <- search.vote$id[grep("2\\.505", search.vote$descricao)][2]

search.vote <- congress.vot.search.date.plen("2021-11-02", "2021-11-05")
id_precatorios <- search.vote$id[grep("Emenda Aglutinativa", search.vote$descricao)]

search.vote <- congress.vot.search.date.plen("2022-03-08", "2022-03-10")
id_mineracao_votourg <- search.vote[grep("REQ 227/2022", search.vote$proposicaoObjeto),1]

search.vote <- congress.vot.search.date.plen("2022-02-23", "2022-02-25")
View(search.vote[grep("15460", search.vote$id),])
id_jogazar <- search.vote[grep("15460", search.vote$id)[10],1]

search.vote <- congress.vot.search.date.plen("2021-08-10", "2021-08-13")
View(search.vote[grep("531331", search.vote$id),])
id_sisteleit_col <- search.vote[grep("531331", search.vote$id)[4], 1]
id_sisteleit_dist <- search.vote[grep("531331", search.vote$id)[5], 1]

search.vote <- congress.vot.search.date.plen("2021-08-07", "2021-08-10")
id_vot_imp <- search.vote[grep("2220292", search.vote$id)[1],1]

search.vote <- congress.vot.search.date.plen("2019-12-10", "2019-12-11")
id_lib_san_bas <- search.vote$id[grep("4.162", search.vote$descricao)]

search.vote <- congress.vot.search.date.plen("2020-12-09", "2020-12-11")
id_fundeb_igrej <- search.vote$id[grep("311", search.vote$descricao)]

search.vote <- congress.vot.search.date.plen("2021-05-17", "2021-05-18")
id_proib_desp_pand <- search.vote$id[grep("827", search.vote$descricao)]

search.vote <- congress.vot.search.date.plen("2020-12-08", "2020-12-09")
id_conv_interam_rac <- search.vote$id[grep("861", search.vote$descricao)[3]]

search.vote <- congress.vot.search.date.plen("2021-08-16", "2021-08-17")
id_div_fundpart <- search.vote$id[grep("344", search.vote$descricao)]

search.vote <- congress.vot.search.date.plen("2022-02-09", "2022-02-10")
id_agrotox <- search.vote$id[grep("6.299", search.vote$descricao)]

# Agora que temos os ids, vamos juntá-los com a descrição dos para fazer o df tabela_vot

Congress_get_prop_descr <- function(id_prop){
  descr_prop <- paste0("https://www.camara.leg.br/proposicoesWeb/fichadetramitacao?idProposicao=", gsub("-(.+)$", "", id_prop)) %>% 
    read_html(.) %>% html_nodes("#identificacaoProposicao") %>% html_text(trim = T)
  
  descr_prop <- gsub("Autor(.+)Ementa", "", descr_prop) %>% gsub("\r\n(.+)$", "", .) %>% gsub(" da RedaçãoNOVA EMENTA: ", "", .)
  return(descr_prop)
}

ids_total <- lapply(X = ls()[grep("^id_", ls())], FUN = get) %>% unlist()
names(ids_total) <- ls()[grep("^id_", ls())] %>% gsub("id_", "", .)

descr_prop <- unlist(lapply(X = ids_total, FUN = Congress_get_prop_descr))

tabela_vot <- cbind.data.frame(Ementa = descr_prop, Cód_ACM = names(ids_total), ID = ids_total)
row.names(tabela_vot) <- 1:nrow(tabela_vot)
write.csv(tabela_vot, "tabela_vot.csv", fileEncoding = "utf8")

# Construindo o df principal

vot <- lapply(ids_total, congress.dep.votos2)

vot2 <- lapply(X = vot, FUN = left_join, x = deputados[c(1, 3)], by = "id")

for (i in 2:length(vot2)){
  vot2[[i]] <- vot2[[i]][3]
}

df <- do.call(what = cbind, args = vot2)

names(df)[1:2] <- c("id", "Partido") 
names(df)[3:ncol(df)] <- gsub("id_", "", names(ids_total))

df[, 3:ncol(df)] <- lapply(df[, 3:ncol(df)], gsub, pattern = "Artigo 17|Abstenção", replacement = NA)
row.names(df) <- df$id 
df$id <- NULL
df[, 1:ncol(df)] <- lapply(df[, 1:ncol(df)], as.factor)

write.csv(df, "cong_vot_1922.csv", fileEncoding = "utf8")
