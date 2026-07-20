-- English translations: EmilyEmmi
-- Spanish translations: Alons0x

function translate_roundsleft()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Rounds left: "
	else
		return "Rondas restantes: "
	end
end

function translate_deadlynumber()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "\\#ff5555\\DEADLY NUMBER: \\#dcdcdc\\"
	else
		return "\\#ff5555\\NÚMERO MORTAL: \\#dcdcdc\\"
	end
end

function translate_role()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Role: "
	else
		return "Rol: "
	end
end

function translate_sheriffdied()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "\\#ff0000\\The sheriff was murdered!"
	else
		return "\\#ff0000\\El sheriff ha sido asesinado!"
	end
end

function translate_murdererdied()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "\\#00ffff\\The murderer died! It's over!"
	else
		return "\\#00ffff\\El asesino ha muerto! Se acabó!"
	end
end

function translate_youdied()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "\\#7a7aff\\You died. Good game."
	else
		return "\\#7a7aff\\Moriste. Buena partida."
	end
end

function murder_role_calc(IsSheriff, IsMurderer)
	if IsSheriff == true then
		return "\\#7affff\\Sheriff"
	elseif IsMurderer == true then
		if smlua_text_utils_get_language() ~= "Spanish" then
			return "\\#ff7a7a\\Murderer"
		else
			return "\\#ff7a7a\\Asesino"
		end
	elseif IsMurderer == false and IsSheriff == false then
		if smlua_text_utils_get_language() ~= "Spanish" then
			return "\\#7aff7a\\Innocent"
		else
			return "\\#7aff7a\\Inocente"
		end
	end
end

function murder_instructions_calc(IsSheriff, IsMurderer)
	if IsSheriff == true then
		if smlua_text_utils_get_language() ~= "Spanish" then
			return "As the Sheriff, you must find the murderer and kill it. If done correctly, the game ends and the murderer will gain less points. But, if you fail to do so, and you hit an innocent, you die. If you die, you drop your suit."
		else
			return "Como el Sheriff, tienes que encontrar al asesino y matarlo. Si lo haces correctamente, el asesino gana menos puntos y termina la partida. Si te equivocas y golpeas a un inocente, morirás. Si mueres, soltarás tu traje."
		end
	elseif IsMurderer == true then
		if smlua_text_utils_get_language() ~= "Spanish" then
			return "As the Murderer, you need to hit people to kill them. When they die, they get less points, but be careful with the Sheriff, because he can kill you. If you die, you gain less points."
		else
			return "Como el Asesino, tienes que golpear a la gente para matarlos. Cuando mueren, ganan menos puntos, pero ten cuidado con el Sheriff, ya que te puede matar a ti. Si mueres, ganas menos puntos."
		end
	elseif IsMurderer == false and IsSheriff == false then
		if smlua_text_utils_get_language() ~= "Spanish" then
			return "As an Innocent, you need to run away from the murderer. You don't know who it is, but trust no one. If the Sheriff dies, you can become a Sheriff if you grab the heart."
		else
			return "Como un Inocente, tienes que esconderte del asesino. No sabes quién es, pero no confíes en nadie. Si el Sheriff muere, puedes volverte en Sheriff si agarras el corazón."
		end
	end
end

function translate_pickedsymbol()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Picked symbol: "
	else
		return "Símbolo elegido: "
	end
end

function rps_calc_symbol()
	local sMario = gPlayerSyncTable[gMarioStates[0].playerIndex]
	if smlua_text_utils_get_language() ~= "Spanish" then
		if sMario.rpsHandSymbol == 1 then
			return "\\#99562f\\Rock\\#dcdcdc\\"
		elseif sMario.rpsHandSymbol == 2 then
			return "\\#309426\\Paper\\#dcdcdc\\"
		elseif sMario.rpsHandSymbol == 3 then
			return "\\#fb8025\\Scissors\\#dcdcdc\\"
		end
	else
		if sMario.rpsHandSymbol == 1 then
			return "\\#99562f\\Piedra\\#dcdcdc\\"
		elseif sMario.rpsHandSymbol == 2 then
			return "\\#309426\\Papel\\#dcdcdc\\"
		elseif sMario.rpsHandSymbol == 3 then
			return "\\#fb8025\\Tijera\\#dcdcdc\\"
		end
	end
end

function rps_get_name_by_number(num)
	if smlua_text_utils_get_language() ~= "Spanish" then
		if num == 1 then
			return "\\#99562f\\Rock\\#dcdcdc\\"
		elseif num == 2 then
			return "\\#309426\\Paper\\#dcdcdc\\"
		elseif num == 3 then
			return "\\#fb8025\\Scissors\\#dcdcdc\\"
		end
	else
		if num == 1 then
			return "\\#99562f\\Piedra\\#dcdcdc\\"
		elseif num == 2 then
			return "\\#309426\\Papel\\#dcdcdc\\"
		elseif num == 3 then
			return "\\#fb8025\\Tijera\\#dcdcdc\\"
		end
	end
end

function translate_rps_yourhandis()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Your hand is "
	else
		return "Tu forma es "
	end
end

function translate_rps_theirhandis()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return " (their hand: "
	else
		return " (su forma: "
	end
end

function translate_rps_youwin()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "\\#7aff7a\\You won!"
	else
		return "\\#7aff7a\\Ganaste!"
	end
end

function translate_rps_youlost()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "\\#ff7a7a\\You lost..."
	else
		return "\\#ff7a7a\\Perdiste..."
	end
end

-- 1: rock
-- 2: paper
-- 3: scissors
-- this is for the victim
function calc_rps_victory(a, v)
	if v == 1 then -- rock
		if a == 2 then
			return translate_rps_youlost() -- paper
		elseif a == 3 then
			return translate_rps_youwin() -- scissors
		end
	elseif v == 2 then -- paper
		if a == 1 then
			return translate_rps_youwin() -- rock
		elseif a == 3 then
			return translate_rps_youlost() -- scissors
		end
	elseif v == 3 then -- scissors
		if a == 1 then
			return translate_rps_youlost() -- rock
		elseif a == 2 then
			return translate_rps_youwin() -- paper
		end
	end
end

function translate_rps_tied()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "\\#ffff7a\\It's a tie!"
	else
		return "\\#ffff7a\\Es un empate!"
	end
end

function translate_you_are_infected()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "\\#2eb249\\You were infected!"
	else
		return "\\#2eb249\\Fuiste infectado!"
	end
end

function translate_simon_says()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "\\#5555ff\\Simon\\#dcdcdc\\: "
	else
		return "\\#5555ff\\Simón\\#dcdcdc\\: "
	end
end

function translate_simon_connected()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "\\#5555ff\\Simon\\#dcdcdc\\ connected"
	else
		return "\\#5555ff\\Simón\\#dcdcdc\\ se ha conectado"
	end
end

function translate_simon_do()
	local sS = gGlobalSyncTable.simonSays
	if smlua_text_utils_get_language() ~= "Spanish" then
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
	else
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
	end
end

function get_translated_desc_glass()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Get across the bridge without falling! Only one glass pane is safe in each row. Will you push your luck, or let someone else take the fall?"
	else
		return "Cruza el puente sin caerte! Solo un panel de vidrio es seguro en cada línea. Jugarás a la suerte, o vas a dejar que alguien más se deje caer?"
	end
end

function get_translated_desc_lights_out()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "This is a simple game: Stay alive. You'll earn 10 points for surviving this game. You could attack other players for some extra points... but wouldn't that be risky?"
	else
		return "Esto es un juego simple: Mantente vivo. Vas a ganar 10 puntos por sobrevivir este juego. Puedes atacar a los demás por algunos puntos extra, pero eso no sería peligroso?"
	end
end

function get_translated_descelim_lights_out()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "This is a simple game: Stay alive. There's nothing to hurt you here unless you start attacking each other or something. But why would you do that?"
	else
		return "Este es un juego simple: Mantente vivo. No hay nada que te haga daño, a no ser de que ustedes se golpeen entre sí o algo parecido. Pero, por qué harían eso?"
	end
end

function get_translated_desc_red_green_light()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return 'Reach the finish line! When Toad shouts "Red Light!", don\'t let him see you moving! You can move behind obstacles to avoid being seen. Tread carefully!'
	else
		return 'Llega a la meta! Cuando Toad diga "Red Light!", no dejes que te vea! Puedes esconderte detrás de obstáculos para evitar que te vean. Avanza con cuidado!'
	end
end

function get_translated_desc_mingle()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Stay on the carousel ride! When Waluigi calls a number, enter a room with EXACTLY that many players--no more, no less. Use the switch inside of the room to lock players out. Cooperation is key!"
	else
		return "Mantente dentro del carrusel! Cuando Waluigi diga un número, entra a una sala con EXACTAMENTE la cantidad de personas--ni más, ni menos. Usa el interruptor dentro de la sala para cerrar la puerta. La cooperación es clave!"
	end
end

function get_translated_desc_star_steal()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Get the Star, and hold it to increase your score! Hit a player to take the Star from them! You'll be eliminated if your score is too low! Hmm, this seems familiar..."
	else
		return "Consigue la Estrella y mantenla para aumentar tu puntaje! Golpea a un jugador para robarles la Estrella! Serás eliminado si tu puntaje es muy bajo! Hmm, esto me suena..."
	end
end

function get_translated_desc_bomb_tag()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Don't hold a Bob-Omb! Tag another player to pass your Bob-Omb to them. If you're holding a Bob-Omb when time runs out... you can probably guess what happens."
	else
		return "Evita tener una Bob-omba! Golpea a otro jugador para pasarle tu Bob-omba a él. Si tienes una Bob-omba cuando el tiempo se acaba... probablemente ya sabes qué va a pasar."
	end
end

function get_translated_desc_koth()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Get to the top of the hill! Stand in the circle to increase your score. If your score is too low when time runs out, you'll be eliminated! Stand your ground!"
	else
		return "Llega a la cima de la colina! Mantente en el círculo para aumentar tu puntaje. Si tu puntaje es muy bajo cuando el tiempo se acabe, serás eliminado! Cuida tu territorio!"
	end
end

function get_translated_desc_duel()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Defeat your opponent(s)! Have the most health or be the last one standing to earn a point. Get 2 points to win the minigame! It's time to LOCK IN."
	else
		return "Derrota tu(s) oponente(s)! Ten la mayor cantidad de vida o sé el último en sobrevivir para ganar un punto. Consigue dos puntos para ganar! Es hora de CONCENTRARSE."
	end
end

function get_translated_descelim_duel()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Defeat your opponent(s)! Have the most health or be the last one standing to earn a point. Get 2 points to win it ALL. It's time to LOCK IN."
	else
		return "Derrota tu(s) oponente(s)! Ten la mayor cantidad de vida o sé el último en sobrevivir para ganar un punto. Consigue dos puntos ganarlo TODO. Es hora de GANAR."
	end
end

function get_translated_descteam_duel()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "It's team versus team! Have the most health or be the last one standing to earn your team a point. Get 2 points to win the minigame! It's time to LOCK IN."
	else
		return "Es equivo contra equipo! Ten la mayor cantidad de vida o sé el último en sobrevivir para ganar un punto. Consigue dos puntos para ganar! Es hora de CONCENTRARSE."
	end
end

function get_translated_descteamelim_duel()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "It's team versus team! Have the most health or be the last one standing to earn your team a point. Get 2 points to win it ALL. It's time to LOCK IN."
	else
		return "Es equivo contra equipo! Ten la mayor cantidad de vida o sé el último en sobrevivir para ganar un punto. Consigue dos puntos ganarlo TODO. Es hora de GANAR."
	end
end

function get_translated_desc_dice()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Ready to test your luck? You have a 5% chance to kill a player when you hit them, but each failed hit will increase your odds by 10%! Also, getting hit will increase your odds by 5%. Be the last one standing to win!"
	else
		return "Listo para probar suerte? Tienes un 5% de probabilidades de eliminar a alguien cuando le golpeas, pero cada golpe fallido aumenta tus chances en un 10%! Recibir un golpe aumentará tus chances en un 5%. Sé el último en sobrevivir para ganar!"
	end
end

function get_translated_descelim_dice()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Ready to test your luck? You have a 5% chance to kill a player when you hit them, but each failed hit will increase your odds by 10%! Also, getting hit will increase your odds by 5%. Who will survive?"
	else
		return "Listo para probar suerte? Tienes un 5% de probabilidades de eliminar a alguien cuando le golpeas, pero cada golpe fallido aumenta tus chances en un 10%! Recibir un golpe aumentará tus chances en un 5%. Quién sobrevivirá?"
	end
end

function get_translated_desc_hit()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Hit your opponents! For each successful hit, you will get +0.5 points, but if you get hit, you will lose -0.1 points. At the end, the one who has the most amount of points wins. Hit everyone!"
	else
		return "Golpea a tus oponentes! Por cada golpe asestado, ganarás +0.5 puntos, pero si te golpean, perderás -0.1 puntos. Al final, el que tenga más puntos gana. Golpéalos a todos!"
	end
end

function get_translated_desc_bombthrower()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "There's Bob-ombs falling from the sky! If you lose all your health, you lose the minigame! At the end of each round, coins will spawn in the middle of the stage. Survive the longest!"
	else
		return "Hay Bob-ombas cayendo del cielo! Si pierdes toda tu vida, perderás el minijuego! Al final de cada ronda, monedas caerán en el centro del escenario. Sobrevive hasta el final!"
	end
end

function get_translated_desc_coinrain()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Grab every coin you see! This time, when you grab coins, you get points, and, if your score is too low, you will be eliminated! You can disturb others by launching them far. Who will become rich?"
	else
		return "Agarra todas las monedas que veas! Esta vez, cuando agarras monedas, consigues puntos, si tu puntaje es muy bajo, serás eliminado! Puedes molestar a los demás, lanzándolos lejos. Quién se volverá rico?"
	end
end

function get_translated_desc_rope()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Spam the A and Z buttons! For every time you pull the rope with these buttons, you get points. The one who gets the highest score by using their full strength will win! Who is the strongest one?"
	else
		return "Spammea los botones A y Z! Por cada vez que jales la cuerda con estos botones, consigues puntos. El que consiga el mejor puntaje al usar toda su fuerza va a ganar! Quién es el mas fuerte?"
	end
end

function get_translated_desc_fiery()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Burning Meteors are falling from the sky, burning everything! You need to dodge them, otherwise you will get burned! If you lose all your health, you will be disqualified, plus the blue fire is permanent! Endure until the end!"
	else
		return "Meteoritos ardientes caen del cielo, quemando todo! Tienes que esquivarlos, o te vas a quemar! Si pierdes toda tu vida, serás descalificado, además que el fuego azul es permanente! Aguanta hasta el final!"
	end
end

function get_translated_desc_murder()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Who is the murderer? The minigame consists of three main roles: Innocent, Sheriff and Murderer. The innocents must survive, the sheriff is metallic and must kill the murderer and the murderer must kill everyone! Who will survive?"
	else
		return "Quién es el asesino? El minijuego consiste en que hay tres roles principales: Inocente, Sheriff y Asesino. Los inocentes tienen que sobrevivir, el sheriff, cual es metálico, ha de matar al asesino y el asesino debe matar a todos! Quién sobrevivirá?"
	end
end

function get_translated_desc_russian_roulette()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Pick your favorite number from 1 to 6 with the L button! At the end of each round, you pull the trigger. If your number is the same one as the deadly number, you die. The sooner you die, the less points you get! Who will survive?"
	else
		return "Elige tu número preferido de 1 a 6 con el botón L! Al final de cada ronda, jalas el gatillo. Si tu número es el mismo que el número mortal, mueres. Mientras antes mueras, menos puntos vas a tener! Quién sobrevivirá?"
	end
end

function get_translated_desc_submerged()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "It's a battle... underwater?! Yes, you will be battling eachother under the water! If you lose all your health, you will be disqualified! Kill someone to recover health, and survive to the end! Make sure you don't drown!"
	else
		return "Es una batalla... debajo del agua?! Sí, ustedes van a estar luchando entre sí debajo del agua! Si pierdes toda tu vida, serás descalificado! Mata a alguien para recuperar vida y sobrevive hasta el final! Asegúrate de no ahogarte!"
	end
end

function get_translated_desc_rps()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "It's rock, paper or scissors! Change your symbol with the L button. If you hit an opponent, you will gain +0.1 points if you win, and -0.1 if you lose. The one who gets the higher amount of points wins!"
	else
		return "Es piedra, papel o tijera! Cambia tu forma con el botón L. Si golpeas a un oponente, ganarás +0.1 puntos si ganas y -0.1 si pierdes. El jugador que tenga la mayor cantidad de puntos gana!"
	end
end

function get_translated_desc_health_steal()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Steal your opponent's health! In this gamemode, each time you hit someone, you sometimes recover +1 health, but they lose -1 health. If you die, you will be disqualified! Survive until the end to win!"
	else
		return "Róbate la vida de tus oponentes! En este juego, cada vez que golpees a alguien, a veces recuperas +1 de vida, pero pierden -1 de vida. Si mueres, serás descalificado! Sobrevive hasta el final para ganar!"
	end
end

function get_translated_desc_hot_ring()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Stay inside the ring! If you stay outside of it, you lose health. The ring will get smaller over time, plus you can push your opponents to get them out! The one who survives will win!"
	else
		return "Mantente dentro del anillo! Si te quedas fuera, perderás vida. El anillo se va haciendo cada vez más pequeño, además de que puedes empujar a los demás para sacarlos del anillo! Gana el que sobreviva!"
	end
end

function get_translated_desc_body_swap()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Swap your health with the opponents! When you hit someone, you will swap your health with theirs, and you will deal one additional point of damage. If you die, you are disqualified! Who will survive?"
	else
		return "Intercambia tu vida con los oponentes! Cuando golpeas a alguien, intercambiarás tu vida con la de ellos e inflingirás un punto de daño adicional. Si mueres, serás descalificado! Quién sobrevivirá?"
	end
end

function get_translated_desc_run()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Race to the top! There are coins at the end, grab them to get points and spawn Bob-ombs to try to disturb your opponents. If you get hit or fall off, you will teleport back to the start! Be the fastest!"
	else
		return "Corre hasta la cima! Hay monedas al final, agárralas para conseguir puntos y spawnear Bob-ombas para intentar molestar a tus oponentes. Si te golpean o te caes, te teletrasportarás al inicio! Sé el más rápido!"
	end
end

function get_translated_desc_lava()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "The floor is lava! If you stay under the lava, you will lose health constantly. Stay in high ground and push your opponents to avoid them from pushing you! The more rounds you survive, the more points you earn."
	else
		return "El suelo es lava! Si te mantienes debajo de la lava, perderás vida constantemente. Mantente en un lugar elevado y empuja a tus oponentes para evitar que te empujen a ti! Mientras más rondas sobrevivas, más puntos tendrás."
	end
end

function get_translated_desc_virus()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "There's a dangerous virus! If you get infected, you will start losing health, but you can hit someone to get rid of your infection! You can also hit eachother to deal damage. The longest you survive, better."
	else
		return "Hay un virus peligroso! Si te infectan, empezarás a perder vida, pero puedes golpear a alguien para deshacerte de tu infección! También se pueden golpear entre sí para hacer daño. Mientras más sobrevivas, mejor."
	end
end

function get_translated_desc_simon()
	if smlua_text_utils_get_language() ~= "Spanish" then
		return "Listen to Simon! He will write things in the chat and you must do them for points! For example, if he says you must jump into lava, or do a backflip, do it! The one who gets the highest amount of points wins!"
	else
		return "Presta atención a Simón! Él va a escribir cosas en el chat y tienes que hacerlas por puntos! Por ejemplo, si dice que tienes que irte a la lava o hacer un backflip, hazlo! El que tenga la mayor cantidad de puntos gana!"
	end
end
