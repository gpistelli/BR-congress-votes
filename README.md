# BR-congress-votes
A project that provides a wrapper to the [Brazilian Congress API](https://dadosabertos.camara.leg.br/swagger/api.html) and explore that data through a Geometrical Data Analysis /
Um projeto que oferece um wrapper para a API de dados abertos da Câmara e explora estes dados através de uma Análise Geométrica de Dados. Nossa análise pode ser lida aqui: https://gpistelli.github.io/BR-congress-votes

# Objectives/Objetivos
- Facilitar a coleta e organização destes dados, sem precisar lidar diretamente com a API
- Oferecer uma base de dados das principais votações durante o primeiro governo de Bolsonaro
- Definir as posições dos partidos e dos deputados com relação às votações em questão
- Fornecer um esboço das divisões dentro do congresso brasileiro para acompanhar as mudanças dentro deste

# Files and documentation
- src/data: our source code, there is basically all our process to scrape and organize our data into the final dataset and references
- references: auxiliary data, with congressmen simplified data and our proposal summary
- models: MCAs and clusters models, can be used to define how people positions themselves in our space
- data: our main dataset, containing the congressmen votes, their parties and ID

# To-do list
- Passar os modelos para o formato RData
- Concluir a redação final de nosso texto de divulgação científica
- Separar as funções em um pacote que facilite nosso trabalho. Basicamente, uma versão do [CamaraPy](https://github.com/RodrigoMenegat/camaraPy) para R.
- Escrever um tutorial e vignette deste pacote para que outros pesquisadorxs se utilizem desta ferramenta
- Seguir com a pesquisa para os próximos anos, possivelmente realizando um estudo longitudinal