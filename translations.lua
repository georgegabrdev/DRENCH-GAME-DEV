local smlua_text_utils_get_language = smlua_text_utils_get_language

local translations = {
	English = {
		deadlynumber = "\\#ff5555\\DEADLY NUMBER: \\#dcdcdc\\",
		role = "Role: ",

		sheriffdied = "\\#ff0000\\The sheriff was murdered!",
		murdererdied = "\\#00ffff\\The murderer died! It's over!",

		infected = "\\#2eb249\\You were infected!",

		simon = "\\#5555ff\\Simon\\#dcdcdc\\: ",
		simon_connected = "\\#5555ff\\Simon\\#dcdcdc\\ connected",

		-- Murder instructions
		murder_sheriff = "As the Sheriff, you must find the murderer and kill it. If done correctly, the game ends and the murderer will gain less points. But, if you fail to do so, and you hit an innocent, you die. If you die, you drop your suit.",
		murder_murderer = "As the Murderer, you need to hit people to kill them. When they die, they get less points, but be careful with the Sheriff, because he can kill you. If you die, you gain less points.",
		murder_innocent = "As an Innocent, you need to run away from the murderer. You don't know who it is, but trust no one. If the Sheriff dies, you can become a Sheriff if you grab the heart.",

		desc_glass = "Get across the bridge without falling! Only one glass pane is safe in each row. Will you push your luck, or let someone else take the fall?",

		desc_lights_out = "This is a simple game: Stay alive. You'll earn 10 points for surviving this game. You could attack other players for some extra points... but wouldn't that be risky?",

		desc_elim_lights_out = "This is a simple game: Stay alive. There's nothing to hurt you here unless you start attacking each other or something. But why would you do that?",

		desc_red_green_light = 'Reach the finish line! When Toad shouts "Red Light!", don\'t let him see you moving! You can move behind obstacles to avoid being seen. Tread carefully!',

		desc_mingle = "Stay on the carousel ride! When Waluigi calls a number, enter a room with EXACTLY that many players--no more, no less. Use the switch inside of the room to lock players out. Cooperation is key!",

		desc_star_steal = "Get the Star, and hold it to increase your score! Hit a player to take the Star from them! You'll be eliminated if your score is too low! Hmm, this seems familiar...",

		desc_bomb_tag = "Don't hold a Bob-Omb! Tag another player to pass your Bob-Omb to them. If you're holding a Bob-Omb when time runs out... you can probably guess what happens.",

		desc_koth = "Get to the top of the hill! Stand in the circle to increase your score. If your score is too low when time runs out, you'll be eliminated! Stand your ground!",

		desc_team_koth = "Get to the top of the hill! Stand in the circle to increase your score. You'll earn more points if only your team is in the circle. If your score is too low when time runs out, you'll be eliminated! Stand your ground!",

		desc_duel = "Defeat your opponent(s)! Have the most health or be the last one standing to earn a point. Get 2 points to win the minigame! It's time to LOCK IN.",

		desc_elim_duel = "Defeat your opponent(s)! Have the most health or be the last one standing to earn a point. Get 2 points to win it ALL. It's time to LOCK IN.",

		desc_team_duel = "It's team versus team! Have the most health or be the last one standing to earn your team a point. Get 2 points to win the minigame! It's time to LOCK IN.",

		desc_team_elim_duel = "It's team versus team! Have the most health or be the last one standing to earn your team a point. Get 2 points to win it ALL. It's time to LOCK IN.",

		desc_dice = "Ready to test your luck? You have a 5% chance to kill a player when you hit them, but each failed hit will increase your odds by 10%! Also, getting hit will increase your odds by 5%. Be the last one standing to win!",

		desc_elim_dice = "Ready to test your luck? You have a 5% chance to kill a player when you hit them, but each failed hit will increase your odds by 10%! Also, getting hit will increase your odds by 5%. Who will survive?",

		desc_coinrain = "Coins fall from the sky! Collect Yellow Coins for 1 point. Collect Blue Coins for 5 points. Credits to @naoki544 for the idea.",

		desc_death_hit = "Last player standing wins! It's self explanatory. If you get hit, you are ABSOLUTELY cooked. So don't get hit.",

		desc_broken_lamp = "Only 1 player has the lamp. Hit them to steal it. Without it, the darkness drains your health... It's pretty dark. Credits to @RetroGames and others.",

		desc_rope = "Spam the A and Z buttons! For every time you pull the rope with these buttons, you get points. The one who gets the highest score by using their full strength will win! Who is the strongest one?",

		desc_fiery = "Burning Meteors are falling from the sky, burning everything! You need to dodge them, otherwise you will get burned! If you lose all your health, you will be disqualified, plus the blue fire is permanent! Endure until the end!",

		desc_murder = "Who is the murderer? The minigame consists of three main roles: Innocent, Sheriff and Murderer. The innocents must survive, the sheriff is metallic and must kill the murderer and the murderer must kill everyone! Who will survive?",

		desc_russian_roulette = "Pick your favorite number from 1 to 6 with the L button! At the end of each round, you pull the trigger. If your number is the same one as the deadly number, you die. The sooner you die, the less points you get! Who will survive?",

		desc_run = "Race to the top! There are coins at the end, grab them to get points and spawn Bob-ombs to try to disturb your opponents. If you get hit or fall off, you will teleport back to the start! Be the fastest!",

		desc_lava = "The floor is lava! If you stay under the lava, you will lose health constantly. Stay in high ground and push your opponents to avoid them from pushing you! The more rounds you survive, the more points you earn.",

		desc_virus = "There's a dangerous virus! If you get infected, you will start losing health, but you can hit someone to get rid of your infection! You can also hit eachother to deal damage. The longest you survive, better.",

		desc_simon = "Listen to Simon! He will write things in the chat and you must do them for points! For example, if he says you must jump into lava, or do a backflip, do it! The one who gets the highest amount of points wins",

		minigame_text = "Minigame ",

		spectate_text = "Spectate",

		music_text = "Music",

		spectate_warning = "\\#ff5050\\WARNING: This will eliminate you! Press A again to continue.",

		colorblind_text = "Colorblind Mode",

		ready_text = "Ready!",

		waiting_text = "Waiting...",

		untilroundends = " until round ends",

		untilgameends = " until game ends",

		untilelimination = " until elimination",

		yourscore = "Your score: ",

		theirscore = "Their score: ",

		safescore = "Safe score: ",
	},

	Spanish = {
		-- Minigame descriptions

		deadlynumber = "\\#ff5555\\NÚMERO MORTAL: \\#dcdcdc\\",
		role = "Rol: ",

		sheriffdied = "\\#ff0000\\El sheriff fue asesinado!",
		murdererdied = "\\#00ffff\\El asesino murió! Se acabó!",

		infected = "\\#2eb249\\Fuiste infectado!",

		simon = "\\#5555ff\\Simón\\#dcdcdc\\: ",
		simon_connected = "\\#5555ff\\Simón\\#dcdcdc\\ se conectó",

		-- Murder instructions
		murder_sheriff = "Como Sheriff, debes encontrar al asesino y matarlo. Si lo haces correctamente, el juego termina y el asesino ganará menos puntos. Pero si fallas y golpeas a un inocente, morirás. Si mueres, dejarás caer tu traje.",

		murder_murderer = "Como Asesino, debes golpear a las personas para matarlas. Cuando mueren, obtienen menos puntos, pero ten cuidado con el Sheriff, porque puede matarte. Si mueres, ganas menos puntos.",

		murder_innocent = "Como Inocente, debes escapar del asesino. No sabes quién es, así que no confíes en nadie. Si el Sheriff muere, puedes convertirte en Sheriff si recoges el corazón.",

		desc_glass = "Cruza el puente sin caerte! Solo un panel de vidrio es seguro en cada fila. ¿Arriesgarás tu suerte o dejarás que alguien más caiga?",

		desc_lights_out = "Este es un juego simple: Sobrevive. Ganarás 10 puntos por sobrevivir este juego. Puedes atacar a otros jugadores por puntos extra... pero ¿realmente vale el riesgo?",

		desc_elim_lights_out = "Este es un juego simple: Sobrevive. No hay nada que pueda hacerte daño aquí, a menos que empiecen a atacarse entre ustedes. Pero, ¿por qué harían eso?",

		desc_red_green_light = 'Llega a la meta! Cuando Toad grite "Luz Roja!", no dejes que te vea moverte! Puedes moverte detrás de obstáculos para evitar ser visto. Avanza con cuidado!',

		desc_mingle = "Mantente en el carrusel! Cuando Waluigi diga un número, entra a una sala con EXACTAMENTE esa cantidad de jugadores, ni más ni menos. Usa el interruptor dentro de la sala para bloquear la entrada. La cooperación es clave!",

		desc_star_steal = "Consigue la Estrella y mantenla para aumentar tu puntuación! Golpea a un jugador para quitarle la Estrella! Serás eliminado si tu puntuación es demasiado baja! Hmm, esto parece familiar...",

		desc_bomb_tag = "No tengas una Bob-omb! Golpea a otro jugador para pasarle tu Bob-omb. Si tienes una Bob-omb cuando el tiempo termine... probablemente sabes lo que pasará.",

		desc_koth = "Llega a la cima de la colina! Quédate dentro del círculo para aumentar tu puntuación. Si tu puntuación es muy baja cuando el tiempo termine, serás eliminado! Defiende tu posición!",

		desc_team_koth = "Llega a la cima de la colina! Colócate dentro del círculo para aumentar tu puntuación. Ganarás más puntos si solo tu equipo está en el círculo. Si tu puntuación es demasiado baja cuando se acabe el tiempo, serás eliminado Mantén tu posición!",

		desc_duel = "Derrota a tu oponente(s)! Ten más vida o sé el último en pie para ganar un punto. Consigue 2 puntos para ganar el minijuego! Es hora de DARLO TODO.",

		desc_elim_duel = "Derrota a tu oponente(s)! Ten más vida o sé el último en pie para ganar un punto. Consigue 2 puntos para ganar TODO! Es hora de DARLO TODO.",

		desc_team_duel = "Es equipo contra equipo! Ten más vida o sé el último en pie para darle un punto a tu equipo. Consigue 2 puntos para ganar el minijuego! Es hora de DARLO TODO.",

		desc_team_elim_duel = "Es equipo contra equipo! Ten más vida o sé el último en pie para darle un punto a tu equipo. Consigue 2 puntos para ganar TODO! Es hora de DARLO TODO.",

		desc_dice = "¿Listo para probar tu suerte? Tienes un 5% de probabilidad de eliminar a un jugador al golpearlo, pero cada golpe fallido aumenta tus probabilidades un 10%! Además, recibir golpes aumenta tus probabilidades un 5%. Sé el último en sobrevivir!",

		desc_elim_dice = "¿Listo para probar tu suerte? Tienes un 5% de probabilidad de eliminar a un jugador al golpearlo, pero cada golpe fallido aumenta tus probabilidades un 10%! Además, recibir golpes aumenta tus probabilidades un 5%. ¿Quién sobrevivirá?",

		desc_coinrain = "Las monedas caen del cielo! Consigue monedas amarillas para obtener 1 punto. Consigue monedas azules para obtener 5 puntos. Créditos a @naoki544 por la idea.",

		desc_death_hit = "Gana el último jugador en pie! Se explica por sí solo. Si te golpean, estás ABSOLUTAMENTE acabado. Así que procura que no te golpeen.",

		desc_broken_lamp = "Only 1 player has the lamp. Hit them to steal it. Without it, the darkness drains your health... It's pretty dark. Credits to @RetroGames and others.",

		desc_rope = "Presiona los botones A y Z rápidamente! Cada vez que tires de la cuerda con estos botones, consigues puntos. El que consiga la mayor puntuación usando toda su fuerza ganará! ¿Quién es el más fuerte?",

		desc_fiery = "Meteoritos ardientes caen del cielo, quemándolo todo! Tienes que esquivarlos, de lo contrario te quemarás! Si pierdes toda tu vida, serás eliminado y el fuego azul será permanente! Resiste hasta el final!",

		desc_murder = "¿Quién es el asesino? El minijuego tiene tres roles principales: Inocente, Sheriff y Asesino. Los inocentes deben sobrevivir, el Sheriff debe matar al asesino y el asesino debe matar a todos! ¿Quién sobrevivirá?",

		desc_russian_roulette = "Elige tu número favorito del 1 al 6 con el botón L! Al final de cada ronda, aprietas el gatillo. Si tu número es igual al número mortal, mueres. Mientras antes mueras, menos puntos obtendrás! ¿Quién sobrevivirá?",

		desc_run = "Corre hasta la cima! Hay monedas al final, agárralas para conseguir puntos y genera Bob-ombs para intentar molestar a tus oponentes. Si te golpean o caes, volverás al inicio! Sé el más rápido!",

		desc_lava = "El suelo es lava! Si permaneces debajo de la lava, perderás vida constantemente. Mantente en lugares altos y empuja a tus oponentes para evitar que ellos te empujen! Mientras más rondas sobrevivas, más puntos ganarás.",

		desc_virus = "Hay un virus peligroso! Si te infectas, empezarás a perder vida, pero puedes golpear a alguien para deshacerte de la infección! También puedes golpear a otros para hacer daño. Mientras más sobrevivas, mejor.",

		desc_simon = "Presta atención a Simón! Él va a escribir cosas en el chat y tienes que hacerlas por puntos! Por ejemplo, si dice que tienes que irte a la lava o hacer un backflip, hazlo! El que tenga la mayor cantidad de puntos gana!",

		minigame_text = "Minijuego ",

		spectate_text = "Espectador",

		music_text = "Música",

		spectate_warning = "ADVERTENCIA: ¡Esto te eliminará! Pulsa A de nuevo para continuar.",

		colorblind_text = "Modo para daltónicos",

		ready_text = "¡Listo!",

		waiting_text = "Espera...",

		untilroundends = " hasta que termine la ronda",

		untilgameends = " hasta que termine el juego",

		untilelimination = " hasta la eliminación",

		yourscore = "Tu puntuación: ",

		theirscore = "Su puntuación: ",

		safescore = "Puntuación segura: ",
	},
	Portuguese = {
		deadlynumber = "\\#ff5555\\NÚMERO MORTAL: \\#dcdcdc\\",
		role = "Função: ",

		sheriffdied = "\\#ff0000\\O xerife foi assassinado!",
		murdererdied = "\\#00ffff\\O assassino morreu! Acabou!",

		infected = "\\#2eb249\\Você foi infectado!",

		simon = "\\#5555ff\\Simão\\#dcdcdc\\: ",
		simon_connected = "\\#5555ff\\Simão\\#dcdcdc\\ conectado",

		-- Murder instructions
		murder_sheriff = "Como Xerife, você precisa encontrar o assassino e matá-lo. Se fizer isso corretamente, o jogo acaba e o assassino ganhará menos pontos. Mas se errar e acertar um inocente, você morre. Se morrer, você solta sua roupa.",

		murder_murderer = "Como Assassino, você precisa acertar pessoas para matá-las. Quando elas morrem, ganham menos pontos, mas tome cuidado com o Xerife, pois ele pode matar você. Se você morrer, ganha menos pontos.",

		murder_innocent = "Como Inocente, você precisa fugir do assassino. Você não sabe quem é, então não confie em ninguém. Se o Xerife morrer, você pode virar Xerife se pegar o coração.",

		-- Minigame descriptions
		desc_glass = "Atravesse a ponte sem cair! Apenas um vidro em cada linha é seguro. Você vai arriscar sua sorte ou deixar outra pessoa cair?",

		desc_lights_out = "Este é um jogo simples: sobreviva. Você ganha 10 pontos por sobreviver. Você pode atacar outros jogadores por pontos extras... mas será que vale o risco?",

		desc_elim_lights_out = "Este é um jogo simples: sobreviva. Não há nada que possa machucar você aqui, a menos que vocês comecem a atacar uns aos outros. Mas por que fariam isso?",

		desc_red_green_light = 'Chegue até a linha de chegada! Quando Toad gritar "Luz Vermelha!", não deixe ele ver você se mexendo! Você pode usar obstáculos para não ser visto. Tenha cuidado!',

		desc_mingle = "Fique no carrossel! Quando Waluigi chamar um número, entre em uma sala com EXATAMENTE aquela quantidade de jogadores. Use o interruptor para impedir que outros entrem. Cooperação é essencial!",

		desc_star_steal = "Pegue a Estrela e segure-a para aumentar sua pontuação! Acerte um jogador para roubar a Estrela dele! Você será eliminado se sua pontuação for baixa demais!",

		desc_bomb_tag = "Não fique segurando uma Bob-omb! Acerte outro jogador para passar sua Bob-omb para ele. Se estiver segurando uma quando o tempo acabar... você já sabe o que acontece.",

		desc_koth = "Chegue ao topo da colina! Fique no círculo para aumentar sua pontuação. Se sua pontuação for baixa quando o tempo acabar, você será eliminado!",

		desc_team_koth = "Chegue ao topo da colina! Fique dentro do círculo para aumentar sua pontuação. Você ganhará mais pontos se apenas a sua equipe estiver no círculo. Se sua pontuação estiver muito baixa quando o tempo acabar, você será eliminado! Mantenha sua posição!",

		desc_duel = "Derrote seu oponente! Tenha mais vida ou seja o último sobrevivente para ganhar um ponto. Faça 2 pontos para vencer o minijogo!",

		desc_team_duel = "É time contra time! Tenha mais vida ou seja o último sobrevivente para dar um ponto ao seu time. Faça 2 pontos para vencer!",

		desc_elim_duel = "Derrote seu oponente! Tenha mais vida ou seja o último sobrevivente para ganhar um ponto. Faça 2 pontos para vencer tudo!",

		desc_team_elim_duel = "É time contra time! Tenha mais vida ou seja o último sobrevivente para dar um ponto ao seu time. Faça 2 pontos para vencer tudo!",

		desc_elim_dice = "Pronto para testar sua sorte? Você tem 5% de chance de eliminar alguém ao acertá-lo, mas cada erro aumenta suas chances em 10%! Ser atingido aumenta suas chances em 5%. Quem sobreviverá?",

		desc_dice = "Pronto para testar sua sorte? Você tem 5% de chance de eliminar alguém ao acertá-lo, mas cada erro aumenta suas chances em 10%! Ser atingido aumenta suas chances em 5%. Seja o último sobrevivente!",

		desc_coinrain = "Moedas caem do céu! Pegue Moedas Amarelas para ganhar 1 ponto. Pegue Moedas Azuis para ganhar 5 pontos.",

		desc_death_hit = "O último jogador vivo vence! É bem simples. Se você for atingido, está ABSOLUTAMENTE perdido. Então não seja atingido.",

		desc_broken_lamp = "Apenas 1 jogador tem a lanterna. Acerte-o para roubá-la. Sem ela, a escuridão drena sua vida... Está bem escuro. Créditos ao @RetroGames e outros.",

		desc_rope = "Aperte os botões A e Z rapidamente! Cada vez que puxar a corda, você ganha pontos. Quem conseguir a maior pontuação usando toda sua força vence!",

		desc_fiery = "Meteoros em chamas estão caindo do céu! Desvie deles ou você será queimado! Se perder toda sua vida, será eliminado e o fogo azul será permanente!",

		desc_murder = "Quem é o assassino? O minijogo possui três funções principais: Inocente, Xerife e Assassino. Os inocentes precisam sobreviver, o Xerife precisa matar o assassino e o assassino precisa matar todos!",

		desc_russian_roulette = "Escolha seu número favorito de 1 a 6 com o botão L! No final de cada rodada você puxa o gatilho. Se seu número for igual ao número mortal, você morre.",

		desc_run = "Corra até o topo! Existem moedas no final, pegue-as para ganhar pontos e gere Bob-ombs para atrapalhar seus oponentes. Se for atingido ou cair, você volta ao início!",

		desc_lava = "O chão é lava! Se ficar embaixo da lava, perderá vida constantemente. Fique em lugares altos e empurre seus oponentes!",

		desc_virus = "Existe um vírus perigoso! Se for infectado, começará a perder vida, mas pode acertar alguém para se livrar da infecção! Sobreviva o máximo possível.",

		desc_simon = "Compita contra seus amigos para realizar todos os comandos enviados no chat antes que o tempo acabe. Mantenha o foco, siga as regras e consiga a maior quantidade de pontos!",

		minigame_text = "Minijogo ",

		spectate_text = "Assistir",

		music_text = "Música",

		spectate_warning = "\\#ff5050\\AVISO: Isso eliminará você! Pressione A novamente para continuar.",

		colorblind_text = "Modo para Daltônicos",

		ready_text = "Preparar!",

		waiting_text = "Esperando...",

		untilroundends = " até o fim da rodada",

		untilgameends = " até o jogo terminar",

		untilelimination = " até a eliminação",

		yourscore = "Sua pontuação: ",

		theirscore = "A pontuação deles: ",

		safescore = "Pontuação segura: ",
	},
}

function murder_instructions_calc(IsSheriff, IsMurderer)
	if IsSheriff then
		return translate("murder_sheriff")
	elseif IsMurderer then
		return translate("murder_murderer")
	else
		return translate("murder_innocent")
	end
end

function translate_simon_do()
	local sS = gGlobalSyncTable.simonSays
	local lang = smlua_text_utils_get_language()

	if lang == "Spanish" then
		if sS == 1 then
			return "Salta!"
		elseif sS == 2 then
			return "Ataca!"
		elseif sS == 3 then
			return "No te muevas!"
		elseif sS == 4 then
			return "Camina!"
		elseif sS == 5 then
			return "Quémate en lava!"
		elseif sS == 6 then
			return "Agarra un borde!"
		elseif sS == 7 then
			return "Corre!"
		elseif sS == 8 then
			return "Haz un Backflip!"
		end
	elseif lang == "Portuguese" then
		if sS == 1 then
			return "Pule!"
		elseif sS == 2 then
			return "Ataque!"
		elseif sS == 3 then
			return "Não se mexa!"
		elseif sS == 4 then
			return "Ande!"
		elseif sS == 5 then
			return "Queime na lava!"
		elseif sS == 6 then
			return "Segure uma borda!"
		elseif sS == 7 then
			return "Corra!"
		elseif sS == 8 then
			return "Faça um Backflip!"
		end
	else
		if sS == 1 then
			return "Jump!"
		elseif sS == 2 then
			return "Attack!"
		elseif sS == 3 then
			return "Don't Move!"
		elseif sS == 4 then
			return "Walk!"
		elseif sS == 5 then
			return "Burn in lava!"
		elseif sS == 6 then
			return "Grab a ledge!"
		elseif sS == 7 then
			return "Run!"
		elseif sS == 8 then
			return "Do a Backflip!"
		end
	end
end

function translate(id)
	local lang = smlua_text_utils_get_language()

	if translations[lang] and translations[lang][id] then
		return translations[lang][id]
	end

	return translations.English[id] or id
end
