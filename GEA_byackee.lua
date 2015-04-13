	--[[
	%% autostart
	%% properties
	65 value
	78 value
	97 value
	104 value
	108 value
	110 value
	118 value
	%% globals
	--]]


	-- v 5.33
	-- Fix a bug with inc+ and dec+
	-- Add StopScenario, EnableScenario and DisableScenario
	--
	-- ==================================================
	-- GEA : Gestionnaire d'Ev�nements Automatique
	-- ==================================================
	-- [FR] Sc�nario permettant de contr�ler si une p�riph�rique est 
	-- activ� depuis trop longtemps ou lancer un push d'avertissement
	-- Ce sc�nario permet une annotation plus simple que le code LUA
	-- il n�cessite n�anmoins quelques connaissances
	--
	-- [EN] This scene allow you to check every X second the status
	-- of a module and send actions if the module is activated since too long.
	-- This scene allow you a more simple annotation than LUA
	-- it requires some knowledge
	--
	-- Auteur : Steven P. with modification of Hansolo and Shyrka973
	-- Version : 5.33
	-- Special Thanks to :
	-- jompa68, Fredric, Diuck, Domodial, moicphil, lolomail, byackee,
	-- JossAlf, Did,  sebcbien, chris6783, carfnann and all other guy from Domotique-fibaro.fr
	-- ------------------------------------------------------------
	-- Historique / History
	-- ------------------------------------------------------------
	-- L'historique complet est diponible ici :
	-- http://www.domotique-fibaro.fr/index.php/topic/1082-gea-gestionnaire-d�v�nements-automatique/?p=12428

	function yourcode()
		-- ==================================================
		-- [FR] A VOUS DE JOUER
		-- [EN] YOUR TIME TO PLAY
		-- ==================================================
		GEA.isVersionFour = true --- On est en version 4.017 Beta ou supp�rieur
		
		-- [FR] Votre langue : FR (default)
		-- [EN] Your language : EN
		GEA.language = "FR";
		
		-- [FR] On v�rifie toutes les X secondes  (default : 30)
		-- [EN] Check every X seconds
		GEA.checkEvery = 30 
		
		-- [FR] Liste des portables devant recevoir une notification {70, 71}
		-- [EN] Smarphones you want to be notified {XX, XX} for more than one
		GEA.portables = {234} 
		
		-- [FR] Affichage des traces dans la console (default : false)
		-- [EN] Show trace in the debug window
		GEA.debug = false
		--GEA.catchError=false

		-- [FR] Tableau d'identifiant (facultatif)
		-- [EN] ID table (optional) 

	-- IDs g�n�r�s le : 07/04/15 � 21:37:21

	local id = {
	--inconnu
	VARIABLES_GLOBALES = 220, SMS = 247, GRAPHIQUES = 205, NEW_CAMERA = 248, FRESMS = 209, 
	--Salon/Cuisine
	ONKYO = 6, PLAQUE_ELECTRIQUE = 129, LAMPE_DECO = 135, FENETRE_COTE_CANAPE = 260, RADIATEUR = 196, PANNEAU_CHAUFFAGE = 185, FENETRE_COTE_FRIGO = 258, LAMPE_HOTTE = 144, FENETRE_COTE_HOTTE = 254, LUMINOSITE = 125, LAVE_VAISSELLE = 212, DETECTEUR = 123, FENETRE_COTE_TV = 262, TV = 9, AMPLI_AUDIO = 10, TEMPERATURE = 40, FRIGO = 47, SUBWOFER = 11, THERMOSTAT = 39, NEON = 49, LAMPE = 45, PLAFONIER = 42, 
	--Chambre
	VOLET_ROULANT = 188, TEMPERATURE_CHAMBRE = 203, DETECTEUR_CHAMBRE = 240, THERMOSTAT_CHAMBRE = 202, SONOS_PLAYER = 210, PANNEAU_CHAUFFAGE_CHAMBRE = 186, LUMINOSITE_CHAMBRE = 242, PORTE = 99, FENETRE = 97, PLAFONIER_CHAMBRE = 82, RADIATEUR_CHAMBRE = 51, 
	--SDB
	GRANDE_FENETRE = 110, PORTE_SDB = 104, RADIATEUR_SDB = 190, VMC_GV = 137, PANNEAU_CHAUFFAGE_SDB = 204, CHAUFFE_EAU = 236, VMC_PV = 139, SONOS_PLAYER_SDB = 208, RADIATEUR_SOUFFLANT = 61, CAPTEUR_INONDATION = 158, PLAFONIER_SDB = 65, HUMIDITE = 68, THERMOMETRE = 67, LAVE_LINGE = 76, 
	--WC
	PLAFONIER_WC = 63, PORTE_WC = 108, 
	--Entree/Couloir
	DETECTEUR_FUMEE = 228, PORTE_ENTRE_COULOIR = 214, ALARME_FEU = 230, NON_UTILISE = 153, SONOSNET = 154, LUMINOSITE_ENTRE_COULOIR = 120, TEMPERATURE_ENTRE_COULOIR = 119, DETECTEUR_ENTRE_COULOIR = 118, PLAFONIER_ENTRE = 78, PLAFONIER_ENTRE_COULOIR = 80, FIBARO_HC2 = 150, NAS = 149, ROUTEUR = 152, SERVEUR = 151, 
	--system
	PRESENCE_VINCE = 168, MY_BATTERIES = 218, DAY_PHASE = 142, METEOALERTE = 221, CHECK_INTERNET = 155, PRESENCE_SO = 169, UPDATE_NOTIFIER_1_0_8 = 140, 
	}
	  
		-- ------------------------------------------------------------
		-- [FR] Variable Globale optionnel pour autoris� GEA de s'ex�cut�
		-- [FR] Usage : GEA.getGlobalForActivation = {"<globalvar>", "<value pour autoriser l'execution>"}
		-- [EN] Optional Global Variable to allow GEA to run
		-- [EN] Usage : GEA.getGlobalForActivation = {"<globalvar>", "<value for activation>"}
		-- ------------------------------------------------------------
		--GEA.getGlobalForActivation = {"SuspendreGEA", "non"}

		-- ----------------------------------------------------------------
		-- [FR] A partir d'ici vous trouverez ma propre configuration
		-- [FR] vous permettant ainsi d'avoir une s�rie d'exemple
		-- [EN] From here are ma own configuration
		-- [EN] just to allow you to see some examples
		-- ----------------------------------------------------------------
		
	-- VARIABLES
		local hc2prefixe = "HC2: "
		local sendsms_vince = {"VirtualDevice", id["SMS"], "1"}
		local sendsms_solene = {"VirtualDevice", id["SMS"], "2"}
		local sendfreesms = {"VirtualDevice", id["FRESMS"], "1"}
		local testpush = GEA.add(true, 60, hc2prefixe .. "Test des notifications push")


	-- boucle 1 fois par jour
		-- a 12:00
		GEA.add( true , 59, "", {
			{"Time", "12:00", "12:00"},
			{"Global", "mysms", hc2prefixe .."test notification par FREE SMS"},sendfreesms,
			{"Global", "sms", hc2prefixe .."test notification par SMS Gateway"},sendsms_vince,sendsms_solene,
			{"RestartTask", testpush}
		})
		-- a minuit
		GEA.add( true , 59, "", {
			{"Time", "00:00", "00:00"},
			{"VirtualDevice", 264, 3}
		})



	-- SALON/CUISINE
		-- veille automatique Multimedia	
			GEA.add({"Sensor-", id["TV"], 40}, 5*60, "Consommation #value# inf�rieur � 40W depuis 5 minutes",  {{"turnOff", id["SUBWOFER"]}})
			GEA.add({"Sensor+", id["TV"], 40}, 30, "",  {{"turnOn", id["SUBWOFER"]}})
			GEA.add({"Global", "Lave_Vaisselle", "En Attente"}, -1, "Le Lave_Vaisselle est arr�t� depuis #duration#",{{"Repeat"},sendsms_vince})
			GEA.add({"Sensor-", id["LAVE_VAISSELLE"], 3}, 30*60, "Le Lave_Vaisselle est arr�t� depuis #duration#", {{"Global", "Lave_Vaisselle", "Arret"},sendsms_vince})   	
			GEA.add({"Sensor+", id["LAVE_VAISSELLE"], 4}, 2*60, "Lave_Vaisselle encours de lavage", {{"Global", "Lave_Vaisselle", "Lavage"}, sendsms_vince}) 
			GEA.add({{"Sensor+", id["LAVE_VAISSELLE"], 1},{"Sensor-", id["LAVE_VAISSELLE"], 3}, {"Global", "Lave_Vaisselle", "Lavage"}}, 1*60, "", {{"Global", "Lave_Vaisselle", "En Attente"},sendsms_vince})
		-- Alerte si refrigerateur ne consomme plus pendant 1 heure	
				--GEA.add({"Sensor-", id["FRIGO"], 50}, 60*60, "Le frigo ne consomme plus depuis #duration# (#date# #time#)",{
				--{"Global", "sms", hc2prefixe .."Le frigo ne consomme plus depuis #duration#"},sendsms_vince, sendsms_solene,
				--{"Global", "mysms", hc2prefixe .."Le frigo ne consomme plus depuis #duration#"},sendfreesms,{"Repeat"}
			--}) 

	-- SDB
		-- Eteindre automatiquement le local technique apr�s 10 mn
			GEA.add(id["PLAFONIER_SDB"], 50*60, "Extinction automatique des lumieres de la SDB", {{"turnOff"}}) 
		-- Allumage automatique � l'ouverture de la porte
			GEA.add(id["PORTE_SDB"], -1, "Test VMC SDB", {{"turnOn", id["PLAFONIER_SDB"]}, {"turnOff", id["VMC_PV"]}, {"turnOff", id["VMC_GV"]}})
		-- === Lave-Linge == --
			GEA.add({"Global", "Lave_Linge", "En Attente"}, -1, "Le lave-linge est arr�t� depuis #duration#",{{"Repeat"}})
			GEA.add({"Sensor-", id["LAVE_LINGE"], 2.8}, 30*60, "Le lave-linge est arr�t� depuis #duration#", {{"Global", "Lave_Linge", "Arret"}})   	
			GEA.add({"Sensor+", id["LAVE_LINGE"], 3}, 2*60, "Lave-linge encours de lavage", {{"Global", "Lave_Linge", "Lavage"}}) 
			GEA.add({{"Sensor+", id["LAVE_LINGE"], 1},{"Sensor-", id["LAVE_LINGE"], 2.8}, {"Global", "Lave_Linge", "Lavage"}}, 1*60, "", {{"Global", "Lave_Linge", "En Attente"}})
		-- Gestion chauffage lors de l'allumage lampe de la piece
			GEA.add(id["PLAFONIER_SDB"], -1, "", {{"VirtualDevice", id["PANNEAU_CHAUFFAGE_SDB"], "8"}, {"turnOn",id["RADIATEUR_SOUFFLANT"]}})
			GEA.add(id["PLAFONIER_SDB"], -1, "", {{"Inverse"},{"VirtualDevice", id["PANNEAU_CHAUFFAGE_SDB"], "5"},{"turnOff",id["RADIATEUR_SOUFFLANT"]}})
		-- Gestion chauffage lors ouverture/fermeture de la fenetre	
			GEA.add(id["GRANDE_FENETRE"], -1, "Fenetre chambre ouverte", {{"VirtualDevice", id["PANNEAU_CHAUFFAGE_SDB"], "7"}})
			GEA.add(id["GRANDE_FENETRE"], -1, "Fenetre chambre ferm�e", {{"Inverse"},{"VirtualDevice", id["PANNEAU_CHAUFFAGE_SDB"], "5"}})
		-- Alerte si le chauffe-eau ne consomme plus pendant plus de 13h	
			GEA.add({"Sensor-", id["CHAUFFE_EAU"], 50}, 20*60*60, "Le chauffe-eau ne consomme plus depuis #duration# (#date# #time#)",{
				{"Global", "sms", hc2prefixe .."Le chauffe-eau ne consomme plus depuis #duration#"},sendsms_vince, sendsms_solene,
				{"Global", "mysms", hc2prefixe .."Le chauffe-eau ne consomme plus depuis #duration#"},sendfreesms,{"Repeat"}
			}) 
	  
	--WC
		-- Eteindre automatiquement apr�s 10 mn
			GEA.add( id["PLAFONIER_WC"], 10*60, "Extinction automatique de la lumiere des WC", {{"turnOff"}}) 
		-- Allumage automatique � l'ouverture de la porte 
			GEA.add( id["PORTE_WC"], -1, "", {{"turnOn", id["PLAFONIER_WC"]}})
		
	--ENTREE
		-- Chaque d�tection red�marre le time de la lampe
			local myTask = GEA.add(id["PLAFONIER_ENTRE"], 1*60, "", {{"turnOff"}})
			local myTask2 = GEA.add(id["PLAFONIER_ENTRE_COULOIR"], 1*60, "", {{"turnOff"}})
			GEA.add(id["PORTE_ENTRE_COULOIR"], -1, "", {{"turnOn", id["PLAFONIER_ENTRE"]},{"turnOn", id["PLAFONIER_ENTRE_COULOIR"]}})
			--GEA.add(id["DETECTEUR_ENTRE_COULOIR"], -1, "", {{"turnOn", id["PLAFONIER_ENTRE"]},{"turnOn", id["PLAFONIER_ENTRE_COULOIR"]}})
			GEA.add(id["PLAFONIER_ENTRE"], -1, "", {{"RestartTask", myTask},{"RestartTask", myTask2}})
		-- Sureillance de la porte
			GEA.add( id["PORTE_ENTRE_COULOIR"], 2*60, "", {
				{"Global", "sms", hc2prefixe .."Porte entr�e ouverte depuis #duration#"},sendsms_vince, sendsms_solene,
				{"Global", "mysms", hc2prefixe .."Porte entr�e ouverte depuis #duration#"},sendfreesms,{"Repeat"}
			}) 
		
	--CHAMBRE
		--Volet roulant chambre
			GEA.add(true, 1*60, "", {{"Time", "Sunset", "Sunset+5"}, {"Close",id["VOLET_ROULANT"],100}})
		-- Gestion chauffage lors ouverture/fermeture de la fenetre	
			GEA.add(id["FENETRE"], -1, "Fenetre chambre ouverte", {{"VirtualDevice", id["PANNEAU_CHAUFFAGE_CHAMBRE"], "7"}})
			GEA.add(id["FENETRE"], -1, "Fenetre chambre ferm�e", {{"Inverse"},{"VirtualDevice", id["PANNEAU_CHAUFFAGE_CHAMBRE"], "5"}})

	--SYSTEM
		-- Gestion des pr�sences
			GEA.add(true , 5*60, "", {
				{"VirtualDevice", id["PRESENCE_SO"], "1"},
				{"VirtualDevice", id["PRESENCE_VINCE"], "1"},
			})
		
			local condition = {"If",{{"Global", "presence_vince", "0"},{"Global", "presence_so", "0"}}}
			GEA.add(true, 30, "personne dans la maison", {condition})
			GEA.add({"Global", "presence_vince", "1"}, 30, "Pr�sence vincent")
			GEA.add({"Global", "presence_so", "1"}, 30, "Pr�sence solene")

	  
	--TEST INTERNET
		GEA.add({"Global", "internet", "NOK"} , 5*60, hc2prefixe.."Pas de connexion internet depuis #duration#", {
			{"Global", "sms", hc2prefixe.."Pas de connexion internet depuis #duration#"},sendsms_vince,sendsms_solene,
			{"Global", "mysms", hc2prefixe.."Pas de connexion internet depuis #duration#"},sendfreesms
		})
		
	--REVEIL DES NOEUX MORTS MODULES SUR SECTEUR	
		GEA.add({"Dead", id["PLAQUE_ELECTRIQUE"]}, 1*60, "Le p�riph�rique #name# ne r�pond plus", {{"WakeUp", id["PLAQUE_ELECTRIQUE"]}})
		GEA.add({"Dead", id["FRIGO"]}, 1*60, "Le p�riph�rique #name# ne r�pond plus", {{"WakeUp", id["FRIGO"]}})
		
		
		-- ==================================================
		-- [FR] NE PLUS RIEN TOUCHER
		-- [EN] DON'T TOUCH UNDER THIS POINT
		-- ==================================================
	end

	if (not GEA) then
		
		GEA = {}
		GEA.version = "5.33"
		GEA.language = "FR";
		GEA.checkEvery = 30
		GEA.index = 0
		GEA.isVersionFour = true
		
		GEA.globalTasks = "GEA_Tasks"
		GEA.regexFullAllow = false
		GEA.portables = {}
		
		GEA.todo = {}
		GEA.power = "valueSensor"
		GEA.suspended = ""
		
		GEA.translate = {}
		GEA.translate["FR"] = {
			ADDED_FOR 	= "ajout de la tache pour",
			SECONDS 		= "secondes",
			ADDED_DIRECT 	= "ajout de la tache pour lancement instantan�",
			WILL_SUSPEND 	=  "entrainera la supsension de",
			SUSPEND_ERROR 	= "ERROR GEA.Suspend demande un tableau en param�tre 2",
			CHECKING_DATE 	= "v�rification des dates",
			CHECKING_TIME 	= "v�rification plage horaire",
			TODAY 		= "Aujourd'hui ",
			NOT_INCLUDED 	= "n'est pas inclus dans",
			TODAY_NOT_DST = "Aujourd'hui n'est pas en mode DST",
			DATE_NOT_ALLOWED = "n'est pas dans la plage de dates sp�cifi�es",
			CURRENT_TIME 	= "L'heure actuelle",
			TIME_NOT_ALLOWED = "n'est pas autoris�e",
			TIME_OUT 		= "v�rification ignor� car en dehors de la plage horaire : ",
			TIME_IN 		= "v�rification contr�l� car dans la plage horaire sp�cifi�e ",
			CHECK_STARTED = "d�marrage v�rification",
			DONE 		= "tache effectu�e et suspendue",
			CHECK_MAIN	 = "v�rification de l'activation",
			CHECK_IF		= "v�rification de l'exception",
			CHECK_IF_FAILED = "d�sactiv� par exception",
			ERROR 		= "!!! ERREUR !!!",
			ERROR_IF 		= "IF malform�",
			ACTIVATED 	= "activ�",
			DESACTIVATED 	= "d�sactiv�",
			HOUR			= "heure",
			HOURS		= "heures",
			MINUTE		= "minute",
			MINUTES		= "minutes",
			SECOND		= "seconde",
			ACTIONS		= "traitement des actions",
			GEA_SUSPENDED = "Sc�nario suspendu par la variable globale ",
			VALUE 		= "valeur",
			REQUERIED		= "attendu",
			NOTHING_TODO 	= "aucun traitement a effectuer",
			CHECKING		= "v�rification",
			SLEEPING		= "Endormi pendant",
			RUN_FOR		= "Dur�e des traitements : ",
			RUN_NEW		= "nouveau d�lai : ",
			RUN_SINCE		= "tourne depuis",
			RUN 			= "En cours",
			RUNING		= "en ex�cution",
			BATTERIE		= "Pile faible",
			ALWAYS		= "Toujours",
			RESTART		= "Red�marrage",
			SUPSENDED	= "Arr�t�e",
			NOTHING_TODOID  = "aucun traitement a effectuer pour l'ID:"
		}
		GEA.translate["EN"] = {
			ADDED_FOR 	= "task added for",
			SECONDS 		= "seconds",
			ADDED_DIRECT 	= "task added for instant run",
			WILL_SUSPEND 	= "will suspend ",
			SUSPEND_ERROR 	= "ERROR GEA.Suspend require a table as second parameter",
			CHECKING_DATE 	= "checking dates",
			CHECKING_TIME 	= "checking time range",
			TODAY 		= "Today ",
			NOT_INCLUDED 	= "is not included in",
			TODAY_NOT_DST = "Today is not in DST mode",
			DATE_NOT_ALLOWED = "is not in the specify dates range",
			CURRENT_TIME 	= "Current hour",
			TIME_NOT_ALLOWED = "is not allowed",
			TIME_OUT 		= "checking abort because out of time range: ",
			TIME_IN 		= "checking done time range is ok ",
			CHECK_STARTED = "starting checking",
			DONE 		= "task done and suspended",
			CHECK_MAIN	 = "activation checking",
			CHECK_IF		= "'if' checking",
			CHECK_IF_FAILED = "'if' stop the check",
			ERROR 		= "!!! ERROR !!!",
			ERROR_IF 		= "IF malformed",
			ACTIVATED 	= "activate",
			DESACTIVATED 	= "d�sactivate",
			HOUR			= "hour",
			HOURS		= "hours",
			MINUTE		= "minute",
			MINUTES		= "minutes",
			SECOND		= "second",
			ACTIONS		= "doing actions",
			GEA_SUSPENDED = "Scene suspended by the global variable ",
			VALUE 		= "value",
			REQUERIED		= "excpeted",
			NOTHING_TODO 	= "nothing to do",
			CHECKING		= "checking",
			SLEEPING		= "Sleeping for",
			RUN_FOR		= "Duration : ",
			RUN_NEW		= "new delay : ",
			RUN_SINCE		= "runing since",
			RUN 			= "Run",
			RUNING		= "Running",
			BATTERIE		= "Low batterie",
			ALWAYS		= "Always",
			RESTART		= "Restart",
			SUPSENDED	= "Stopped",
			NOTHING_TODOID = "nothing to do for ID:"
		}	

		
		GEA.keys = {ID=1, SECONDES=2, MESSAGE=3, ISREPEAT=4, PARAMS=5, NAME=6, NBRUN=7, DONE=8, VALUE=9, GROUPS=10, OK=11, TOTALRUNS=12, INDEX=13, MAXTIME=14, ROOM=15}
		
		GEA.debug = false			-- mode de d�buggage par d�faut
		GEA.catchError = true		-- capture des errors par d�faut
		GEA.pos = 1				-- compteur du nombre d'�l�ments principales
		GEA.useTasksGlobal = true		-- utilise ou non une variable globale pour stocker les Restart/Stop Task
		GEA.tasks = ""				-- variable pour remplacer la variable global si GEA.useTasksGlobal =false
		
		GEA.getGlobalForActivation = {}

		GEA.source = fibaro:getSourceTrigger()
		
		-- ---------------------------------------------------------------------------
		-- Ajout un p�riph�rique dans la liste des �l�ments � traiter
		-- ---------------------------------------------------------------------------
		GEA.add = function(id, secondes, message, arg)
			local repeating = false
			local notstarted = false
			local maxtime = -1
			local groups = {}
			local params = {}
			local name = {}
			local room = {}
			if (arg and #arg > 0) then 
				for i = 1, #arg do 
					if (string.lower(arg[i][1]) == "repeat") then repeating = true end
					if (string.lower(arg[i][1]) == "maxtime") then maxtime = tonumber(arg[i][2]) end
					if (string.lower(arg[i][1]) == "group") then groups[tonumber(arg[i][2])] =  true end
					if (string.lower(arg[i][1]) == "notstarted") then notstarted =  true end
				end
				params = arg
			end
			if (maxtime > -1) then repeating = true end
			
			GEA.index = GEA.index + 1
			
			if (type(id) == "table") then
				if (type(id[1]) == "number" or type(id[1]) == "table") then
					local conditions = {}
					for i = 2, #id do 
						table.insert(conditions, id[i])
						name[i], room[i] = GEA.getName(id[i])
					end
					id = id[1]
					if (type(id) == "table" and type(id[1]) == "string" and string.lower(id[1]) == "alarm") then
						repeating = false
						secondes = 1
					end
					table.insert(params, {"If", conditions})
				elseif (type(id[1]) == "string") then
					if (string.lower(id[1]) == "global" and #id > 2 and id[2] == "" and id[3] == "") then
						id = true
					elseif (string.lower(id[1]) == "alarm") then
						repeating = false
						secondes = 1
					end
					
				end
			end
			
			name[1], room[1] = GEA.getName(id)
			
			local entry = {id, secondes, message, repeating, params, name, 0, false, {}, groups, false, 0, GEA.index, maxtime, room}

			if (GEA.source["type"] == "autostart" and tonumber(entry[GEA.keys["SECONDES"]]) >= 0) then
				GEA.insert(entry)
				GEA.log("Add Autostart", entry, GEA.translate[GEA.language]["ADDED_FOR"].. " " .. secondes .. " " .. GEA.translate[GEA.language]["SECONDS"], true, "grey")
				if (notstarted) then 
					local cIndex = GEA.getCode("S", entry[GEA.keys["INDEX"]])
					if (GEA.suspended ~= nil) then
						GEA.suspended = string.gsub(GEA.suspended, cIndex, "")
					end
					GEA.suspended = GEA.suspended .. cIndex			
				end
			elseif (GEA.source["type"] == "global" and tonumber(entry[GEA.keys["SECONDES"]]) < 0) then
				if (type(entry[GEA.keys["ID"]]) == "table" and GEA.match(string.lower(entry[GEA.keys["ID"]][1]), "global|global.") and entry[GEA.keys["ID"]][2] == GEA.source["name"]) then
					GEA.insert(entry)
					GEA.log("Add Global", entry, GEA.translate[GEA.language]["ADDED_DIRECT"], true, "grey")
				end
			elseif (GEA.source["type"] == "property" and tonumber(entry[GEA.keys["SECONDES"]]) < 0) then
				local id = 0
				if (type(entry[GEA.keys["ID"]]) == "number") then
					id = entry[GEA.keys["ID"]]
				elseif (type(entry[GEA.keys["ID"]]) == "table") then
					id = entry[GEA.keys["ID"]][2]
					if (string.lower(entry[GEA.keys["ID"]][1]) == "sceneactivation" and #entry[GEA.keys["ID"]] > 2) then
						if ( tonumber(fibaro:getValue(id, "sceneActivation")) ~= tonumber(entry[GEA.keys["ID"]][3]) ) then
							id = -1
						end
					end
				end
				if (tonumber(id) == tonumber(GEA.source["deviceID"])) then
					GEA.insert(entry)
					GEA.log("Add Property", entry, GEA.translate[GEA.language]["ADDED_DIRECT"], true, "grey")
				end
			end
			return entry[GEA.keys["INDEX"]]
		end
		
		-- ---------------------------------------------------------------------------
		-- Ajoute une op�ration dans la liste
		-- ---------------------------------------------------------------------------
		GEA.insert = function(entry) 
			GEA.todo[GEA.pos] = entry;
			--table.insert(GEA.todo, entry)
			--entry[GEA.keys["INDEX"]] = #GEA.todo	
			GEA.pos = GEA.pos + 1
			return entry[GEA.keys["INDEX"]]
		end
		
		-- ---------------------------------------------------------------------------
		-- Ajoute ou supprime un code dans la variable global GEA_Tasks
		-- ---------------------------------------------------------------------------
		GEA.addOrRemoveTask = function(code, index, add)
			local glob = nil
			if (GEA.useTasksGlobal) then 
				glob = fibaro:getGlobalValue(GEA.globalTasks)
			else
				glob = GEA.tasks
			end
			local cIndex = GEA.getCode(code, index)
			if (glob ~= nil) then
				glob = string.gsub(glob, cIndex, "")
			end
			if (add) then
				if (GEA.useTasksGlobal) then 
					fibaro:setGlobal(GEA.globalTasks, glob .. cIndex)
				else
					GEA.tasks = glob .. cIndex
				end
			else
				if (GEA.useTasksGlobal) then 
					fibaro:setGlobal(GEA.globalTasks, glob)
				else
					GEA.tasks = glob
				end
			end
		end
		
		-- ---------------------------------------------------------------------------
		-- V�rifie l'existance d'un code dans la variable global GEA_Tasks
		-- ---------------------------------------------------------------------------	
		GEA.isTask = function(code, index)
			local glob = nil
			if (GEA.useTasksGlobal) then 
				glob = fibaro:getGlobalValue(GEA.globalTasks)
			else
				glob = GEA.tasks
			end
			local cIndex = GEA.getCode(code, index)
			if (glob ~= nil) then
				return string.match(glob, cIndex)
			end
			return nil
		end

		GEA.getCode = function(code, index)
			return "|"..code.."_"..index.."|"
		end
			
		-- ---------------------------------------------------------------------------
		-- Obtention d'un nom pour le syst�me
		-- ---------------------------------------------------------------------------
		GEA.getName = function(id)
			local room = ""
			if (type(id) == "nil" or type(id) == "boolean") then
				return GEA.translate[GEA.language]["ALWAYS"], ""
			elseif (type(id) == "number") then
				return fibaro:getName(tonumber(id)), GEA.getRoom(tonumber(id))
			elseif (type(id) == "table" and GEA.match(string.lower(id[1]), "global|global.")) then
				return id[2], ""
			elseif (type(id) == "table" and string.lower(id[1]) == "batteries") then
				return "Batteries <= " .. id[1], ""
			elseif (type(id) == "table" and string.lower(id[1]) == "sceneactivation") then
				return "Scene [" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "] = " ..id[3], GEA.getRoom(tonumber(id[2]))		
			elseif (type(id) == "table" and string.lower(id[1]) == "sensor") then
				return "Sensor [" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "] = " ..id[3], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "sensor+") then
				return "Sensor [" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "] > " ..id[3], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "sensor-") then
				return "Sensor [" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "] < " ..id[3], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "sensor!") then
				return "Sensor [" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "] ~= " ..id[3], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "battery") then
				return "[" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "] <= " ..id[3]	, GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "value") then
				return "Value [" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "] = " ..id[3], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "value+") then
				return "Value [" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "] > " ..id[3], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "value-") then
				return "Value [" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "] < " ..id[3], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "value!") then
				return "Value [" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "] ~= " ..id[3], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "dead") then
				return "Dead [" .. id[2].."|"..fibaro:getName(tonumber(id[2])) .. "]", GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "slider") then
				return "Slider [" .. id[2].."|"..id[3].. "] = " ..id[4]	, GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "slider+") then
				return "Slider [" .. id[2].."|"..id[3].. "] > " ..id[4]	, GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "slider-") then
				return "Slider [" .. id[2].."|"..id[3].. "] < " ..id[4]	, GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "slider!") then
				return "Slider [" .. id[2].."|"..id[3].. "] ~= " ..id[4], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "label") then
				return "Label [" .. id[2].."|"..id[3].. "] = " ..id[4], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "label!") then
				return "Label [" .. id[2].."|"..id[3].. "] ~= " ..id[4], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "function") then
				return "Function", ""
			elseif (type(id) == "table" and string.lower(id[1]) == "weather") then
				return "Weather", ""
			elseif (type(id) == "table" and string.lower(id[1]) == "alarm") then
				return "Alarm " .. fibaro:getValue(tonumber(id[2]), "ui.lblAlarme.value"), ""
			elseif (type(id) == "table" and string.lower(id[1]) == "property") then
				return "Property [" .. id[2].."|"..id[3].. "] = " ..id[4], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "property!") then
				return "Property [" .. id[2].."|"..id[3].. "] ~= " ..id[4], GEA.getRoom(tonumber(id[2]))
			elseif (type(id) == "table" and string.lower(id[1]) == "group") then
				return "Group [" .. id[2].. "]", ""
			else
				-- autre � venir
			end
		end
		
		-- ---------------------------------------------------------------------------
		-- Retourne la pi�ce contenant le module
		-- ---------------------------------------------------------------------------
		GEA.getRoom = function(id)
			if (type(fibaro:getRoomID(id)) == "number") then
				if (type(fibaro:getRoomName(fibaro:getRoomID(id))) == "string") then
					return fibaro:getRoomName(fibaro:getRoomID(id))
				end
			end
			return ""
		end

		-- ---------------------------------------------------------------------------
		-- V�rifie si le jour en cours est dans la liste
		-- ---------------------------------------------------------------------------
		GEA.checkDay = function(days)
			local dayfound = false
			jours = days
			jours = string.gsub(jours, "All", "Weekday,Weekend")
			jours = string.gsub(jours, "Weekday", "Monday,Tuesday,Wednesday,Thursday,Friday")
			jours = string.gsub(jours, "Weekend", "Saturday,Sunday")
			if (string.find(string.lower(jours), string.lower(os.date("%A")))) then
				dayfound = true
			end
			return dayfound
		end
		
		-- ---------------------------------------------------------------------------
		-- V�rification des plages de date
		-- ---------------------------------------------------------------------------
		GEA.checkTimes = function(entry)
		
			GEA.log("Check", entry, GEA.translate[GEA.language]["CHECKING_DATE"], false)
			
			if (not entry[GEA.keys["PARAMS"]]) then
				return true
			end
			local notfound = true
			local dayfound = true
			local datefound = true
			local dst = true
			local jours = ""
			if (type(entry[GEA.keys["PARAMS"]]) == "table") then
				for i = 1, #entry[GEA.keys["PARAMS"]] do
					if (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "days") then
						dayfound = GEA.checkDay(entry[GEA.keys["PARAMS"]][i][2])
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "dst") then
						dst = os.date("*t", os.time()).isdst
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "nodst") then
						dst = not os.date("*t", os.time()).isdst
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "dates") then
						datefound = false
						local now = os.date("%Y%m%d")
						-- todo check
						local from = entry[GEA.keys["PARAMS"]][i][2]
						if (string.len(from) == 5) then from = from .. "/".. os.date("%Y") end
						from = string.format ("%04d", GEA.split(from, "/")[3]) ..string.format ("%02d", GEA.split(from, "/")[2])..string.format ("%02d", GEA.split(from, "/")[1])
						local to = entry[GEA.keys["PARAMS"]][i][3]
						if (string.len(to) == 5) then to = to .. "/".. os.date("%Y") end
						to = string.format ("%04d", GEA.split(to, "/")[3]) ..string.format ("%02d", GEA.split(to, "/")[2])..string.format ("%02d", GEA.split(to, "/")[1])
						datefound = tonumber(now) >= tonumber(from) and tonumber(now) <= tonumber(to)
					end
					
				end
			end
			if (dayfound and dst) then
				local found = false
				for i = 1, #entry[GEA.keys["PARAMS"]] do
					if (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "dates") then
						if (not found) then datefound = false end
						local now = os.date("%Y%m%d")
						-- todo check
						local from = entry[GEA.keys["PARAMS"]][i][2]
						if (string.len(from) == 5) then from = from .. "/".. os.date("%Y") end
						from = string.format ("%04d", GEA.split(from, "/")[3]) ..string.format ("%02d", GEA.split(from, "/")[2])..string.format ("%02d", GEA.split(from, "/")[1])
						local to = entry[GEA.keys["PARAMS"]][i][3]
						if (string.len(to) == 5) then to = to .. "/".. os.date("%Y") end
						to = string.format ("%04d", GEA.split(to, "/")[3]) ..string.format ("%02d", GEA.split(to, "/")[2])..string.format ("%02d", GEA.split(to, "/")[1])
						if (tonumber(from) > tonumber(to) and tonumber(from) > tonumber(now)) then
							from = tonumber(from) - 10000
						end
						if (tonumber(now) >= tonumber(from) and tonumber(now) <= tonumber(to)) then
							datefound = true
							found = true
						end
					end
				end
			end
			if (dayfound and dst and datefound) then
				for i = 1, #entry[GEA.keys["PARAMS"]] do
					if (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "time") then 
						notfound = false
						if (GEA.checkTime(entry, GEA.flatTime(entry[GEA.keys["PARAMS"]][i][2]).."-"..GEA.flatTime(entry[GEA.keys["PARAMS"]][i][3]))) then
							return true
						end
					end
				end
			else
				if (not dayfound) then
					GEA.log("!CANCEL! CheckTimes", entry, GEA.translate[GEA.language]["TODAY"].." "..os.date("%A") .. " "..GEA.translate[GEA.language]["NOT_INCLUDED"].." " .. jours, false, "yellow")
				elseif (not dst) then
					GEA.log("!CANCEL! CheckTimes", entry, GEA.translate[GEA.language]["TODAY_NOT_DST"], false, "yellow")
				elseif (not datefound) then
					GEA.log("!CANCEL! CheckTimes", entry, GEA.translate[GEA.language]["TODAY"].." ".. os.date("%x") .. " " ..GEA.translate[GEA.language]["DATE_NOT_ALLOWED"], false, "yellow")
				end
			end
			if (not notfound) then
				GEA.log("!CANCEL! CheckTimes", entry, GEA.translate[GEA.language]["CURRENT_TIME"].." "..os.date("%H:%M") .. " "..GEA.translate[GEA.language]["TIME_NOT_ALLOWED"], false, "yellow")
			end
			return notfound and datefound and dayfound and dst
		end
		
		-- ---------------------------------------------------------------------------
		-- Contr�le des heures
		-- ---------------------------------------------------------------------------
		GEA.flatTime = function(time)
		
			local t = string.lower(time)
			t = string.gsub(t, " ", "")
			t = string.gsub(t, "h", ":")
			t = string.gsub(t, "sunset", fibaro:getValue(1, "sunsetHour"))
			t = string.gsub(t, "sunrise", fibaro:getValue(1, "sunriseHour"))
			
			if (string.find(t, "<")) then
				t = GEA.flatTime(GEA.split(t, "<")[1]).."<"..GEA.flatTime(GEA.split(t, "<")[2])
			end
			if (string.find(t, ">")) then
				t = GEA.flatTime(GEA.split(t, ">")[1])..">"..GEA.flatTime(GEA.split(t, ">")[2])
			end

			if(string.find(t, "+")) then
				local time = GEA.split(t, "+")[1]
				local add = GEA.split(t, "+")[2]
				local td = os.date("*t")
				local minutes = GEA.split(time, ":")[2]
				local sun = os.time{year=td.year, month=td.month, day=td.day, hour=tonumber(GEA.split(time, ":")[1]), min=tonumber(GEA.split(time, ":")[2]), sec=0}
				sun = sun + (add *60)
				t = os.date("*t", sun)
				t =  string.format("%02d", t.hour) ..":"..string.format("%02d", t.min)
			elseif(string.find(t, "-")) then
				local time = GEA.split(t, "-")[1]
				local add = GEA.split(t, "-")[2]
				local td = os.date("*t")
				local sun = os.time{year=td.year, month=td.month, day=td.day, hour=tonumber(GEA.split(time, ":")[1]), min=tonumber(GEA.split(time, ":")[2]), sec=0}
				sun = sun - (add *60)
				t = os.date("*t", sun)
				t =  string.format("%02d", t.hour) ..":"..string.format("%02d", t.min)			
			elseif (string.find(t, "<")) then
				local s1 = GEA.split(t, "<")[1]
				local s2 = GEA.split(t, "<")[2]
				s1 =  string.format("%02d", GEA.split(s1, ":")[1]) ..":"..string.format("%02d", GEA.split(s1, ":")[2])
				s2 =  string.format("%02d", GEA.split(s2, ":")[1]) ..":"..string.format("%02d", GEA.split(s2, ":")[2])
				if (s1 < s2) then t = s1 else t = s2 end
			elseif (string.find(t, ">")) then
				local s1 = GEA.split(t, ">")[1]
				local s2 = GEA.split(t, ">")[2]
				s1 =  string.format("%02d", GEA.split(s1, ":")[1]) ..":"..string.format("%02d", GEA.split(s1, ":")[2])
				s2 =  string.format("%02d", GEA.split(s2, ":")[1]) ..":"..string.format("%02d",GEA. split(s2, ":")[2])
				if (s1 > s2) then t = s1 else t = s2 end
			else
				t =  string.format("%02d", GEA.split(t, ":")[1]) ..":"..string.format("%02d", GEA.split(t, ":")[2])  
			end
		
			return t
		end
		
		-- ---------------------------------------------------------------------------
		-- V�rification d'une plage de date
		-- ---------------------------------------------------------------------------
		GEA.checkTime = function(entry, times)

			GEA.log("CheckTime", entry, GEA.translate[GEA.language]["CHECKING_TIME"].." "..times, false)
			if (not times or times == "") then
				return true
			end
			
			local from = string.sub(times, 1, 5)
			local to = string.sub(times, 7, 11)
			local now = os.date("%H:%M")

			local inplage = false
			if (to < from) then
				inplage = (now >= from) or (now <= to)
			else
				inplage = (now >= from) and (now <= to)
			end
			if (not inplage) then
				GEA.log("CheckTime", entry, GEA.translate[GEA.language]["TIME_OUT"] .. times, false, "yellow")
			else
				GEA.log("CheckTime", entry, GEA.translate[GEA.language]["TIME_IN"] .. times, false)
			end
			return inplage
		end
		
		-- ---------------------------------------------------------------------------
		-- Split une cha�ne selon un d�limiteur
		-- ---------------------------------------------------------------------------
		GEA.split = function(text, sep)
			local sep, fields = sep or ":", {}
			local pattern = string.format("([^%s]+)", sep)
			text:gsub(pattern, function(c) fields[#fields+1] = c end)
			return fields
		end
		
		-- ---------------------------------------------------------------------------
		-- Supprime les espaces avant et apr�s
		-- ---------------------------------------------------------------------------
		GEA.trim = function(s)
			return (s:gsub("^%s*(.-)%s*$", "%1"))
		end
		
		-- ---------------------------------------------------------------------------
		-- Utilisation des regex
		-- ---------------------------------------------------------------------------	
		GEA.match = function(s, p)
			if (type(s) == "nil") then
			   return type(p) == "nil"
			end
			s = tostring(s)
			p = tostring(p):gsub("%%", "%%%%"):gsub("-", "%%-")
			local words = GEA.split(p, "|")
			for i = 1, #words do
				if (not GEA.regexFullAllow) then
					words[i] = "^"..words[i].."$"
				end
				if (string.match(s, GEA.trim(words[i]))) then 
					return true 
				end
			end	
			return false
		end
		
		-- ---------------------------------------------------------------------------
		-- On v�rifie pour un p�rph�rique
		-- ---------------------------------------------------------------------------
		GEA.check = function(entry, index)
		
			GEA.log("Check", entry, GEA.translate[GEA.language]["CHECK_STARTED"], false)

			if (GEA.isTask("R", entry[GEA.keys["INDEX"]]) ~= nil) then
				GEA.log("Check", entry, GEA.translate[GEA.language]["RESTART"], true)
				entry[GEA.keys["NBRUN"]] = 0
				entry[GEA.keys["TOTALRUNS"]] = 0
				entry[GEA.keys["DONE"]] = false
				entry[GEA.keys["OK"]] = false
				GEA.addOrRemoveTask("R", entry[GEA.keys["INDEX"]], false)
				GEA.addOrRemoveTask("S", entry[GEA.keys["INDEX"]], false)
			end
			
			if (GEA.isTask("S", entry[GEA.keys["INDEX"]]) ~= nil) then
				GEA.log("Check", entry, GEA.translate[GEA.language]["SUPSENDED"], true)
				return
			end

			if (not entry[GEA.keys["DONE"]]) then entry[GEA.keys["OK"]] = false end
			
			if (GEA.checkTimes(entry)) then
				if (GEA.isActivate(entry, 1, entry) ) then
					-- le p�riph�rique est actif on incl�mente le compteur
					
					if (entry[GEA.keys["SECONDES"]] < 0) then
						local maxglob =  GEA.isTask("M", entry[GEA.keys["INDEX"]].."{(%d+)}") 
						if (maxglob ~= nil) then
							entry[GEA.keys["TOTALRUNS"]] = tonumber(maxglob)
							GEA.addOrRemoveTask("M", entry[GEA.keys["INDEX"]].."{(%d+)}", false)
						end
					end
					
					if (entry[GEA.keys["NBRUN"]]) then
						entry[GEA.keys["NBRUN"]] = entry[GEA.keys["NBRUN"]] + 1
						entry[GEA.keys["TOTALRUNS"]] = entry[GEA.keys["TOTALRUNS"]] + 1		
					else
						entry[GEA.keys["NBRUN"]] = 0
						entry[GEA.keys["TOTALRUNS"]] = 0
					end
					if (not entry[GEA.keys["DONE"]]) then
						GEA.log("Check", entry, "activ� depuis " .. (entry[GEA.keys["TOTALRUNS"]] * GEA.checkEvery)  .. "/"..entry[GEA.keys["SECONDES"]], false)
					end
					
					if (entry[GEA.keys["SECONDES"]] < 0 and (entry[GEA.keys["MAXTIME"]] == -1 or  (entry[GEA.keys["TOTALRUNS"]]-1) < entry[GEA.keys["MAXTIME"]])) then
						GEA.sendActions(entry)			
					end
					
					if (entry[GEA.keys["SECONDES"]] < 0 and entry[GEA.keys["MAXTIME"]] > -1) then
						GEA.addOrRemoveTask("M", entry[GEA.keys["INDEX"]].."{(%d+)}", false)
						if (entry[GEA.keys["TOTALRUNS"]] >= entry[GEA.keys["MAXTIME"]] ) then
							GEA.addOrRemoveTask("S", entry[GEA.keys["INDEX"]], true)
						else
							GEA.addOrRemoveTask("M", entry[GEA.keys["INDEX"]].."{".. entry[GEA.keys["TOTALRUNS"]] .."}", true)					
						end
					end
				else
					-- le p�riph�rique est inactif on remet le compteur � 0
					entry[GEA.keys["NBRUN"]] = 0
					entry[GEA.keys["TOTALRUNS"]] = 0
					entry[GEA.keys["DONE"]] = false
					entry[GEA.keys["OK"]] = false
				end			
				if ( GEA.source["type"] == "autostart" and ((entry[GEA.keys["NBRUN"]] * GEA.checkEvery) >= entry[GEA.keys["SECONDES"]]) and not entry[GEA.keys["DONE"]] and  (entry[GEA.keys["MAXTIME"]] == -1 or  (entry[GEA.keys["TOTALRUNS"]]-1) < entry[GEA.keys["MAXTIME"]])) then
					-- Envoi du messsage au destinataires
					GEA.sendActions(entry)
					entry[GEA.keys["OK"]] = true 
					if (entry[GEA.keys["ISREPEAT"]] and entry[GEA.keys["MAXTIME"]] == -1 ) then
					   --- nothing
					else
						if (entry[GEA.keys["MAXTIME"]] == -1 or (entry[GEA.keys["TOTALRUNS"]] >= entry[GEA.keys["MAXTIME"]]))  then
							GEA.log("Done", entry, GEA.translate[GEA.language]["DONE"], true, "DarkSlateBlue")
							entry[GEA.keys["DONE"]] = true
						end
					end
					entry[GEA.keys["NBRUN"]] = 0
				end
			else
				entry[GEA.keys["NBRUN"]] = 0
				entry[GEA.keys["TOTALRUNS"]] = 0
				entry[GEA.keys["DONE"]] = false
				entry[GEA.keys["OK"]] = false
			end
		end
		
		-- ---------------------------------------------------------------------------
		-- V�rification sp�cifique pour savoir si un p�riph�rique est activ� 
		-- ou non
		-- ---------------------------------------------------------------------------
		GEA.isActivate = function(entry, nb, master)
		
			if (nb == 1) then
				GEA.log("isActivate", entry, GEA.translate[GEA.language]["CHECK_MAIN"], false)
			else
				GEA.log("isActivate", entry, GEA.translate[GEA.language]["CHECK_IF"], false)
			end
			
			local mainid = -1
			local id = entry[GEA.keys["ID"]]
			local result = true
				
			if (type(id) == "nil") then 
				result = true
				master[GEA.keys["VALUE"]][nb] = "true"
			elseif (type(id) == "boolean") then 
				result = id
				if (result) then
					master[GEA.keys["VALUE"]][nb] = "true"
				else
					master[GEA.keys["VALUE"]][nb] = "false"
				end
			elseif (type(id) == "number") then
			
				local type = fibaro:getType(tonumber(id))
				GEA.log("isActivate", entry, "type : " .. type, false)

				if (GEA.match(type, "door_sensor|water_sensor|motion_sensor|com.fibaro.FGMS001|com.fibaro.doorSensor|com.fibaro.waterSensor|com.fibaro.motionSensor"))  then
					result = tonumber(fibaro:getValue(tonumber(id), "value")) >= 1
					if not result and (GEA.source["type"] == "autostart") and (fibaro:getValue(tonumber(id), "lastBreached")) ~= "" then
						result = ((os.time() - tonumber(fibaro:getValue(tonumber(id), "lastBreached"))) < GEA.checkEvery)
					else
						if not result and (GEA.source["type"] == "autostart") and (fibaro:getModificationTime(tonumber(id), "value") ) then
							result  = ((os.time() - tonumber(fibaro:getModificationTime(tonumber(id), "value"))) < GEA.checkEvery)
						end
					end
				elseif (GEA.match(type, "dimmable_light|binary_light|rgb_driver|com.fibaro.FGRGBW441M|com.fibaro.multilevelSwitch|com.fibaro.binarySwitch")) then
					if (GEA.match(type, "rgb_driver")) then
						-- verison 3.x
						result = (tonumber(fibaro:getValue(tonumber(id), "value")) > 0 ) or tonumber(fibaro:getValue(tonumber(id), "currentProgramID")) > 0
					elseif (GEA.match(type, "com.fibaro.FGRGBW441M")) then
						-- verison 4.x
						result = (tonumber(fibaro:getValue(tonumber(id), "value")) > 0 and not fibaro:getValue(tonumber(id), "color") == "0,0,0,0") or tonumber(fibaro:getValue(tonumber(id), "currentProgramID")) > 0
					else
						result = tonumber(fibaro:getValue(tonumber(id), "value")) > 0
					end
					if not result and (GEA.source["type"] == "autostart") and (fibaro:getModificationTime(tonumber(id), "value") ) then
						result  = ((os.time() - tonumber(fibaro:getModificationTime(tonumber(id), "value"))) < GEA.checkEvery)
					end
				elseif (type == "blind") then
					result = tonumber(fibaro:getValue(tonumber(id), "value")) > 0
				else
					result =  tonumber(fibaro:getValue(tonumber(id), "value")) == 1
				end
				
				mainid = tonumber(id)
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id), "value")
			elseif (type(id) == "table" and string.lower(id[1]) == "global" and #id > 2) then
				GEA.log("isActivate", entry, "type : global variable", false)
				result = GEA.match(fibaro:getGlobalValue(id[2]), id[3])
				master[GEA.keys["VALUE"]][nb] = fibaro:getGlobalValue(id[2])
			elseif (type(id) == "table" and string.lower(id[1]) == "global+" and #id > 2) then
				GEA.log("isActivate", entry, "type : Global+", false)
				result = tonumber(fibaro:getGlobalValue(id[2])) > tonumber(id[3])
				--mainid = tonumber(id[2])
				 master[GEA.keys["VALUE"]][nb] = fibaro:getGlobalValue(id[2]) 
			elseif (type(id) == "table" and string.lower(id[1]) == "global-" and #id > 2) then
				GEA.log("isActivate", entry, "type : Global-", false)
				result = tonumber(fibaro:getGlobalValue(id[2])) < tonumber(id[3])
				--mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getGlobalValue(id[2]) 
			elseif (type(id) == "table" and string.lower(id[1]) == "global!" and #id > 2) then
				GEA.log("isActivate", entry, "type : Global!", false)
				result = not GEA.match(fibaro:getGlobalValue(id[2]), id[3])
				--mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getGlobalValue(id[2])
			elseif (type(id) == "table" and string.lower(id[1]) == "slider" and #id > 3) then
				GEA.log("isActivate", entry, "type : Slider", false)
				result = tonumber(fibaro:getValue(id[2], "ui."..id[3]..".value")) == tonumber(id[4])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(id[2], "ui."..id[3]..".value")
			elseif (type(id) == "table" and string.lower(id[1]) == "slider-" and #id > 3) then
				GEA.log("isActivate", entry, "type : Slider-", false)
				result = tonumber(fibaro:getValue(id[2], "ui."..id[3]..".value")) < tonumber(id[4])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(id[2], "ui."..id[3]..".value")
			elseif (type(id) == "table" and string.lower(id[1]) == "slider!" and #id > 3) then
				GEA.log("isActivate", entry, "type : Slider!", false)
				result = tonumber(fibaro:getValue(id[2], "ui."..id[3]..".value")) ~= tonumber(id[4])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(id[2], "ui."..id[3]..".value") 
			elseif (type(id) == "table" and string.lower(id[1]) == "slider+" and #id > 3) then
				GEA.log("isActivate", entry, "type : Slider+", false)
				result = tonumber(fibaro:getValue(id[2], "ui."..id[3]..".value")) > tonumber(id[4])
				--mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(id[2], "ui."..id[3]..".value") 
			elseif (type(id) == "table" and string.lower(id[1]) == "label" and #id > 3) then
				GEA.log("isActivate", entry, "type : Label", false)
				result = GEA.match(fibaro:getValue(id[2], "ui."..id[3]..".value"), id[4])
				--mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(id[2], "ui."..id[3]..".value") 
			elseif (type(id) == "table" and string.lower(id[1]) == "label!" and #id > 3) then
				GEA.log("isActivate", entry, "type : Label!", false)
				result = not GEA.match(fibaro:getValue(id[2], "ui."..id[3]..".value"), id[4])
				--mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(id[2], "ui."..id[3]..".value") 
			elseif (type(id) == "table" and string.lower(id[1]) == "property" and #id > 3) then
				GEA.log("isActivate", entry, "type : Property", false)
				result = GEA.match(fibaro:getValue(id[2], id[3]), id[4])
				--mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(id[2], id[3]) 			
			elseif (type(id) == "table" and string.lower(id[1]) == "property!" and #id > 3) then
				GEA.log("isActivate", entry, "type : Property", false)
				result = not GEA.match(fibaro:getValue(id[2], id[3]), id[4])
				--mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(id[2], id[3]) 			
			elseif (type(id) == "table" and string.lower(id[1]) == "batteries" and #id > 1) then
				GEA.log("isActivate", entry, "type : batteries", false)
				local msg = ""
				for i = 1, 1000 do
					local batt = fibaro:getValue(i, 'batteryLevel')
					if (type(batt) ~= nil and (tonumber(batt) ~= nil) and (tonumber(batt) <= tonumber(id[2])) or (tonumber(batt) == 255)) then 
						GEA.log("isActivate", entry, "checking : batteries " .. fibaro:getName(i), false)
						if (not string.find(fibaro:getName(i), "Zwave_")) then
							msg = msg .. GEA.translate[GEA.language]["BATTERIE"].. " [" .. fibaro:getName(i) .. "] " ..batt.."%\n" 
							result = true	
						end
					end
				end
				master[GEA.keys["VALUE"]][nb] = id[2] 
				entry[GEA.keys["MESSAGE"]] = msg 
			elseif (type(id) == "table" and (string.lower(id[1]) == "sensor" or string.lower(id[1]) == "power") and #id > 2) then
				GEA.log("isActivate", entry, "type : Sensor", false)
				result = tonumber(fibaro:getValue(tonumber(id[2]), GEA.power)) ==tonumber(id[3])
				mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id[2]), GEA.power) 
			elseif (type(id) == "table" and(string.lower(id[1]) == "sensor+" or string.lower(id[1]) == "power+") and #id > 2) then
				GEA.log("isActivate", entry, "type : Sensor+", false)
				result = tonumber(fibaro:getValue(tonumber(id[2]), GEA.power)) > tonumber(id[3])
				mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id[2]), GEA.power) 
			elseif (type(id) == "table" and (string.lower(id[1]) == "sensor-" or string.lower(id[1]) == "power-") and #id > 2) then
				GEA.log("isActivate", entry, "type : Sensor-", false)
				result = tonumber(fibaro:getValue(tonumber(id[2]), GEA.power)) < tonumber(id[3])
				mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id[2]), GEA.power)
			elseif (type(id) == "table" and (string.lower(id[1]) == "sensor!" or string.lower(id[1]) == "power!") and #id > 2) then
				GEA.log("isActivate", entry, "type : Sensor!", false)
				result = tonumber(fibaro:getValue(tonumber(id[2]), GEA.power)) ~= tonumber(id[3])
				mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id[2]), GEA.power) 
			elseif (type(id) == "table" and string.lower(id[1]) == "battery" and #id > 2) then
				GEA.log("isActivate", entry, "type : Battery", false)
				result = false
				local batt = fibaro:getValue(tonumber(id[2]), 'batteryLevel')
				if (type(batt) ~= nil and tonumber(batt) <= tonumber(id[3]) or tonumber(batt) == 255) then 
					result = true 
					master[GEA.keys["VALUE"]][nb] = batt
				end
				mainid = tonumber(id[2])
			elseif (type(id) == "table" and string.lower(id[1]) == "value" and #id > 2) then
				GEA.log("isActivate", entry, "type : Value", false)
				result = tonumber(fibaro:getValue(tonumber(id[2]), "value")) == tonumber(id[3])
				mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id[2]), "value") 
			elseif (type(id) == "table" and string.lower(id[1]) == "value+" and #id > 2) then
				GEA.log("isActivate", entry, "type : Value+", false)
				result = tonumber(fibaro:getValue(tonumber(id[2]), "value")) > tonumber(id[3])
				mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id[2]), "value") 
			elseif (type(id) == "table" and string.lower(id[1]) == "value-" and #id > 2) then
				GEA.log("isActivate", entry, "type : Value-", false)
				result = tonumber(fibaro:getValue(tonumber(id[2]), "value")) < tonumber(id[3])
				mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id[2]), "value") 
			elseif (type(id) == "table" and string.lower(id[1]) == "value!" and #id > 2) then
				GEA.log("isActivate", entry, "type : Value!", false)
				result = tonumber(fibaro:getValue(tonumber(id[2]), "value")) ~= tonumber(id[3])
				mainid = tonumber(id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id[2]), "value")
			elseif (type(id) == "table" and string.lower(id[1]) == "dead" and #id > 1) then
				GEA.log("isActivate", entry, "type : isDead", false)
				result = tonumber(fibaro:getValue(tonumber(id[2]), "dead")) >= 1	
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id[2]), "dead")
			elseif (type(id) == "table" and string.lower(id[1]) == "weather" and #id > 1) then
				GEA.log("isActivate", entry, "type : weather", false)
				result = GEA.match(fibaro:getValue(3, "WeatherConditionConverted"), id[2])
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(3, "WeatherConditionConverted")			
			elseif (type(id) == "table" and string.lower(id[1]) == "function" and #id > 1) then
				GEA.log("isActivate", entry, "type : Function", false)
				local status, err, value = pcall(id[2])
				if (status) then
					result = err
					if (value) then master[GEA.keys["VALUE"]][nb] = value end	
				else
					result = false
				end
			elseif (type(id) == "table" and string.lower(id[1]) == "group" and #id > 1) then
				GEA.log("isActivate", entry, "type : Group", false)
				for i = 1, #GEA.todo do
					if (GEA.todo[i][GEA.keys["GROUPS"]][tonumber(id[2])]) then
						if (not GEA.todo[i][GEA.keys["OK"]]) then
							result = false
						end
					end
				end
				master[GEA.keys["VALUE"]][nb] = fibaro:getValue(tonumber(id[2]), "")
			elseif (type(id) == "table" and string.lower(id[1]) == "alarm") then
				GEA.log("isActivate", entry, "type : alarm", false)
				local time = fibaro:getValue(tonumber(id[2]), "ui.lblAlarme.value")
				if (not (type(time) == "nil" or time == "" or time == "--:--")) then
					result = GEA.checkTime(entry, GEA.flatTime(time).."-"..GEA.flatTime(time))
					if (result) then
						local jours = fibaro:getValue(tonumber(id[2]), "ui.lblJours.value")
						local days = ""
						if (string.find(jours, "Lu") or string.find(jours, "Mo")) then days = days .. "Monday" end
						if (string.find(jours, "Ma") or string.find(jours, "Tu")) then days = days .. "Tuesday" end
						if (string.find(jours, "Me") or string.find(jours, "We")) then days = days .. "Wednesday" end
						if (string.find(jours, "Je") or string.find(jours, "Th")) then days = days .. "Thursday" end
						if (string.find(jours, "Ve") or string.find(jours, "Fr")) then days = days .. "Friday" end
						if (string.find(jours, "Sa") or string.find(jours, "Sa")) then days = days .. "Saturday" end
						if (string.find(jours, "Di") or string.find(jours, "Su")) then days = days .. "Sunday" end
						result = GEA.checkDay(days)
					end
					master[GEA.keys["VALUE"]][nb] = time
				else
					result = false
				end
			else
				-- autre a venir
			end
			
			if (nb == 1) then
				for i = 1, #entry[GEA.keys["PARAMS"]] do
					if (string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "inverse") then
						result = not result
					end
				end
				if (mainid > -1 and type(entry[GEA.keys["PARAMS"]]) == "table") then
					for i = 1, #entry[GEA.keys["PARAMS"]] do
						if (string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "armed") then
							result = result and tonumber(fibaro:getValue(mainid, "armed")) > 0
							if (#entry[GEA.keys["PARAMS"]][i] > 1) then
								result = result and tonumber(fibaro:getValue(entry[GEA.keys["PARAMS"]][i][2], "armed")) > 0
							end
						elseif (string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "disarmed") then
							result = result and tonumber(fibaro:getValue(mainid, "armed")) == 0
							if (#entry[GEA.keys["PARAMS"]][i] > 1) then
								result = result and tonumber(fibaro:getValue(entry[GEA.keys["PARAMS"]][i][2], "armed")) == 0
							end
						end
					end
				end
				if (result) then
					for i = 1, #entry[GEA.keys["PARAMS"]] do
						if (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "if") then
							local ok = true
							for j = 1, #entry[GEA.keys["PARAMS"]][i][2] do
								if (type(entry[GEA.keys["PARAMS"]][i][2]) == "table") then
									if ( not GEA.isActivate({entry[GEA.keys["PARAMS"]][i][2][j]}, j+1, entry) ) then
										ok = false
										GEA.log("!CANCEL! isActivate", entry, GEA.translate[GEA.language]["CHECK_IF_FAILED"], false, "yellow")
									end
								else
									GEA.log(GEA.translate[GEA.language]["ERROR"], entry, GEA.translate[GEA.language]["ERROR_IF"], true, "red")
								end
							end
							result = ok
						end
					end
				end
			end
			if (result) then 
				GEA.log("isActivate", entry, GEA.translate[GEA.language]["ACTIVATED"], false)
			else
				GEA.log("!CANCEL! isActivate", entry, GEA.translate[GEA.language]["DESACTIVATED"], false, "yellow")
			end
			return result
		end
		
		-- ---------------------------------------------------------------------------
		-- Permet de d�finir / sp�cifier un message pr�cis qui sera envoy�
		-- par la m�thode sendWarning
		-- ---------------------------------------------------------------------------	
		GEA.getMessage = function(entry, message)
			local msg = ""
			if (entry[GEA.keys["MESSAGE"]]) then
				msg = entry[GEA.keys["MESSAGE"]]
			end
			if (message and message ~= "") then
				msg = message
			end		
			
			if (entry[GEA.keys["VALUE"]][1]) then 
				msg = string.gsub(msg, "#value#", entry[GEA.keys["VALUE"]][1]) 
				msg = string.gsub(msg, "#value%[1%]#", entry[GEA.keys["VALUE"]][1])
			end
			if (entry[GEA.keys["VALUE"]][2]) then msg = string.gsub(msg, "#value%[2%]#", entry[GEA.keys["VALUE"]][2]) end
			if (entry[GEA.keys["VALUE"]][3]) then msg = string.gsub(msg, "#value%[3%]#", entry[GEA.keys["VALUE"]][3]) end
			if (entry[GEA.keys["VALUE"]][4]) then msg = string.gsub(msg, "#value%[4%]#", entry[GEA.keys["VALUE"]][4]) end
			if (entry[GEA.keys["VALUE"]][5]) then msg = string.gsub(msg, "#value%[5%]#", entry[GEA.keys["VALUE"]][5]) end
			if (entry[GEA.keys["VALUE"]][6]) then msg = string.gsub(msg, "#value%[6%]#", entry[GEA.keys["VALUE"]][6]) end
			if (entry[GEA.keys["VALUE"]][7]) then msg = string.gsub(msg, "#value%[7%]#", entry[GEA.keys["VALUE"]][7]) end
			if (entry[GEA.keys["VALUE"]][8]) then msg = string.gsub(msg, "#value%[8%]#", entry[GEA.keys["VALUE"]][8]) end
			if (entry[GEA.keys["VALUE"]][9]) then msg = string.gsub(msg, "#value%[9%]#", entry[GEA.keys["VALUE"]][9]) end
			msg = string.gsub(msg, "#time#", os.date("%X"))
			msg = string.gsub(msg, "#date#", os.date("%x"))
			if (entry[GEA.keys["NAME"]][1]) then 		
				msg = string.gsub(msg, "#name#", entry[GEA.keys["NAME"]][1])
				msg = string.gsub(msg, "#name%[1%]#", entry[GEA.keys["NAME"]][1])
			end
			if (entry[GEA.keys["NAME"]][2]) then msg = string.gsub(msg, "#name%[2%]#", entry[GEA.keys["NAME"]][2]) end
			if (entry[GEA.keys["NAME"]][3]) then msg = string.gsub(msg, "#name%[3%]#", entry[GEA.keys["NAME"]][3]) end
			if (entry[GEA.keys["NAME"]][4]) then msg = string.gsub(msg, "#name%[4%]#", entry[GEA.keys["NAME"]][4]) end
			if (entry[GEA.keys["NAME"]][5]) then msg = string.gsub(msg, "#name%[5%]#", entry[GEA.keys["NAME"]][5]) end
			if (entry[GEA.keys["NAME"]][6]) then msg = string.gsub(msg, "#name%[6%]#", entry[GEA.keys["NAME"]][6]) end
			if (entry[GEA.keys["NAME"]][7]) then msg = string.gsub(msg, "#name%[7%]#", entry[GEA.keys["NAME"]][7]) end
			if (entry[GEA.keys["NAME"]][8]) then msg = string.gsub(msg, "#name%[8%]#", entry[GEA.keys["NAME"]][8]) end
			if (entry[GEA.keys["NAME"]][9]) then msg = string.gsub(msg, "#name%[9%]#", entry[GEA.keys["NAME"]][9]) end
			if (entry[GEA.keys["ROOM"]][1]) then 	
				msg = string.gsub(msg, "#room#", entry[GEA.keys["ROOM"]][1])
				msg = string.gsub(msg, "#room%[1%]#", entry[GEA.keys["ROOM"]][1])
			end
			if (entry[GEA.keys["ROOM"]][2]) then msg = string.gsub(msg, "#room%[2%]#", entry[GEA.keys["ROOM"]][2]) end
			if (entry[GEA.keys["ROOM"]][3]) then msg = string.gsub(msg, "#room%[3%]#", entry[GEA.keys["ROOM"]][3]) end
			if (entry[GEA.keys["ROOM"]][4]) then msg = string.gsub(msg, "#room%[4%]#", entry[GEA.keys["ROOM"]][4]) end
			if (entry[GEA.keys["ROOM"]][5]) then msg = string.gsub(msg, "#room%[5%]#", entry[GEA.keys["ROOM"]][5]) end
			if (entry[GEA.keys["ROOM"]][6]) then msg = string.gsub(msg, "#room%[6%]#", entry[GEA.keys["ROOM"]][6]) end
			if (entry[GEA.keys["ROOM"]][7]) then msg = string.gsub(msg, "#room%[7%]#", entry[GEA.keys["ROOM"]][7]) end
			if (entry[GEA.keys["ROOM"]][8]) then msg = string.gsub(msg, "#room%[8%]#", entry[GEA.keys["ROOM"]][8]) end
			if (entry[GEA.keys["ROOM"]][9]) then msg = string.gsub(msg, "#room%[9%]#", entry[GEA.keys["ROOM"]][9]) end	
			msg = string.gsub(msg, "#seconds#", entry[GEA.keys["SECONDES"]])
			
			local durees = GEA.getDureeInString( entry[GEA.keys["TOTALRUNS"]] * GEA.checkEvery)
			
			msg = string.gsub(msg, "#duration#", durees[1])
			msg = string.gsub(msg, "#durationfull#", durees[2])
			msg = string.gsub(msg, "#runs#", entry[GEA.keys["TOTALRUNS"]] )
			
			return msg
		end
		
		-- ---------------------------------------------------------------------------
		-- Converti une dur�e en cha�ne de carat�res
		-- ---------------------------------------------------------------------------
		GEA.getDureeInString = function(duree) 
		
			local duree = duree
			local dureefull = ""
			nHours = math.floor(duree/3600)
			nMins = math.floor(duree/60 - (nHours*60))
			nSecs = math.floor(duree - nHours*3600 - nMins *60)
			duree = ""
			local dureefull = ""
			if (nHours > 0) then 
				duree = duree.. nHours .."h " 
				dureefull = dureefull .. nHours
				if (nHours > 1) then dureefull = dureefull .." "..GEA.translate[GEA.language]["HOURS"] else dureefull = dureefull .." "..GEA.translate[GEA.language]["HOUR"] end
			end
			if (nMins > 0) then 
				duree = duree.. nMins .."m " 
				if (nHours > 0) then dureefull = dureefull .. " " end
				if (nSecs == 0 and nHours > 0) then dureefull = dureefull .. "et " end
				dureefull = dureefull .. nMins
				if (nMins > 1) then dureefull = dureefull .." "..GEA.translate[GEA.language]["MINUTES"] else dureefull = dureefull .." "..GEA.translate[GEA.language]["MINUTE"] end
			end
			if (nSecs > 0) then 
				duree = duree.. nSecs .."s" 
				if (nMins > 0) then dureefull = dureefull .. " et " end
				dureefull = dureefull .. nSecs
				if (nSecs > 1) then dureefull = dureefull .." "..GEA.translate[GEA.language]["SECONDS"] else dureefull = dureefull .." "..GEA.translate[GEA.language]["SECOND"] end
			end
		
			return {duree, dureefull}
		end
		
		-- ---------------------------------------------------------------------------
		-- Envoi le message en push
		-- ---------------------------------------------------------------------------
		GEA.sendActions = function(entry)
		
			GEA.log("sendActions", entry, GEA.translate[GEA.language]["ACTIONS"] , true)

			local pushed = false
			
			if (type(entry[GEA.keys["PARAMS"]]) == "table") then
			
				for i = 1, #entry[GEA.keys["PARAMS"]] do
					if (type(entry[GEA.keys["PARAMS"]][i]) == "table" and (string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "turnoff" or string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "turnon" or string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "switch")) then 
						local id = GEA.getId(entry, entry[GEA.keys["PARAMS"]][i])
						if (id > 0) then 
							local etat = fibaro:getValue(tonumber(id), "value")
							local typef = fibaro:getType(tonumber(id))
							if (GEA.match(typef, "rgb_driver") and  ((tonumber(fibaro:getValue(tonumber(id), "value")) > 0 ) or tonumber(fibaro:getValue(tonumber(id), "currentProgramID")) > 0)) then
								-- verison 3.x
								etat = 1
							elseif (GEA.match(typef, "com.fibaro.FGRGBW441M")) then
								if (fibaro:getValue(tonumber(id), "color") ~= "0,0,0,0" or tonumber(fibaro:getValue(tonumber(id), "currentProgramID")) > 0) then
								-- verison 4.x
									etat = 1
								end
							end						
							if (tonumber(etat) >= 1 and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "turnoff") or (tonumber(etat) == 0 and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "turnon") then 
								fibaro:call(tonumber(id), entry[GEA.keys["PARAMS"]][i][1])
							elseif (string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "switch") then 
								local mode = "turnOff"
								if (tonumber(etat) == 0) then
									mode = "turnOn"
								end
								fibaro:call(tonumber(id), mode)
							end
							GEA.log("sendActions", entry, "!ACTION! : " .. entry[GEA.keys["PARAMS"]][i][1] , true)
						end
					end
					if (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "global" and #entry[GEA.keys["PARAMS"]][i] > 2) then
						local value = string.match(entry[GEA.keys["PARAMS"]][i][3], "(%d+)")
						if (GEA.match(entry[GEA.keys["PARAMS"]][i][3], "inc%+")) then
							local number = tonumber(fibaro:getGlobalValue(entry[GEA.keys["PARAMS"]][i][2]))
							if (type(value) ~= "nil") then fibaro:setGlobal(entry[GEA.keys["PARAMS"]][i][2], number + value) else fibaro:setGlobal(entry[GEA.keys["PARAMS"]][i][2], number + 1) end
						elseif (GEA.match(entry[GEA.keys["PARAMS"]][i][3], "dec%-")) then
							local number = tonumber(fibaro:getGlobalValue(entry[GEA.keys["PARAMS"]][i][2]))
							if (type(value) ~= "nil") then fibaro:setGlobal(entry[GEA.keys["PARAMS"]][i][2], number - value) else fibaro:setGlobal(entry[GEA.keys["PARAMS"]][i][2], number - 1) end
						else
							fibaro:setGlobal(entry[GEA.keys["PARAMS"]][i][2], GEA.getMessage(entry,entry[GEA.keys["PARAMS"]][i][3]))
						end
						GEA.log("sendActions", entry, "!ACTION! : setGlobal " .. entry[GEA.keys["PARAMS"]][i][2] ..",".. GEA.getMessage(entry, entry[GEA.keys["PARAMS"]][i][3]) , true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "portable" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						fibaro:call(tonumber(entry[GEA.keys["PARAMS"]][i][2]), "sendPush", GEA.getMessage(entry, nil))
						GEA.log("sendActions", entry, "!ACTION! : pushed to " .. entry[GEA.keys["PARAMS"]][i][2], true)
						pushed = true
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "email" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						local sujet = "GEA Notification"
						if (#entry[GEA.keys["PARAMS"]][i] > 2) then
							sujet = entry[GEA.keys["PARAMS"]][i][3]
						end
						fibaro:call(tonumber(entry[GEA.keys["PARAMS"]][i][2]), "sendEmail", GEA.getMessage(entry, sujet), GEA.getMessage(entry, nil))
						GEA.log("sendActions", entry, "!ACTION! : email to " .. entry[GEA.keys["PARAMS"]][i][2], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "picture" and #entry[GEA.keys["PARAMS"]][i] > 2) then
						local destinataire = tonumber(entry[GEA.keys["PARAMS"]][i][3])
						local camera = tonumber(entry[GEA.keys["PARAMS"]][i][2])
						fibaro:call(camera, "sendPhotoToUser", destinataire)
						GEA.log("sendActions", entry, "!ACTION! : email picture from camera " .. camera .. " to " .. destinataire, true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "scenario" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						fibaro:startScene(entry[GEA.keys["PARAMS"]][i][2])
						GEA.log("sendActions", entry, "!ACTION! : Scene " .. entry[GEA.keys["PARAMS"]][i][2], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "stopscenario" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						if (fibaro:countScenes(entry[GEA.keys["PARAMS"]][i][2])) then
							fibaro:killScene(entry[GEA.keys["PARAMS"]][i][2])
							GEA.log("sendActions", entry, "!ACTION! : Stop Scene " .. entry[GEA.keys["PARAMS"]][i][2], true)
						else
							GEA.log("sendActions", entry, "!ACTION! : No Stop Scene " .. entry[GEA.keys["PARAMS"]][i][2], true)
						end
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "enablescenario" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						fibaro:setSceneEnabled(entry[GEA.keys["PARAMS"]][i][2], true)
						GEA.log("sendActions", entry, "!ACTION! : Scene enabled " .. entry[GEA.keys["PARAMS"]][i][2], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "disablescenario" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						fibaro:setSceneEnabled(entry[GEA.keys["PARAMS"]][i][2], false)
						GEA.log("sendActions", entry, "!ACTION! : Scene disabled " .. entry[GEA.keys["PARAMS"]][i][2], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "function") then
						local status, err = pcall(entry[GEA.keys["PARAMS"]][i][2])
						if (status) then
							GEA.log("sendActions", entry, "!ACTION! : Function OK",  true)
						else
							GEA.log("sendActions", entry, "!ACTION! : Function " .. tostring(err or "Inconnu."), true)
						end
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "setarmed" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "setArmed", 1)
						GEA.log("sendActions", entry, "!ACTION! : setArmed " .. entry[GEA.keys["PARAMS"]][i][2], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "setdisarmed" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "setArmed", 0)
						GEA.log("sendActions", entry, "!ACTION! : setDisarmed " .. entry[GEA.keys["PARAMS"]][i][2], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "currenticon" and #entry[GEA.keys["PARAMS"]][i] > 2) then
						fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "setProperty", "currentIcon", tostring(entry[GEA.keys["PARAMS"]][i][3]) )
						GEA.log("sendActions", entry, "!ACTION! : CurrentIcon " .. entry[GEA.keys["PARAMS"]][i][2], true)					
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "copyglobal" and #entry[GEA.keys["PARAMS"]][i] > 2) then
						fibaro:setGlobal(entry[GEA.keys["PARAMS"]][i][3], fibaro:getGlobalValue(entry[GEA.keys["PARAMS"]][i][2]) )
						GEA.log("sendActions", entry, "!ACTION! : CopyGlobal " .. entry[GEA.keys["PARAMS"]][i][2], true)					
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "restarttask" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						GEA.addOrRemoveTask("R", entry[GEA.keys["PARAMS"]][i][2], true)
						GEA.log("sendActions", entry, "!ACTION! : Restart " .. entry[GEA.keys["PARAMS"]][i][2], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "stoptask" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						GEA.addOrRemoveTask("S", entry[GEA.keys["PARAMS"]][i][2], true)
						GEA.log("sendActions", entry, "!ACTION! : StopTask " .. entry[GEA.keys["PARAMS"]][i][2], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "wakeup" and #entry[GEA.keys["PARAMS"]][i] > 1) then
						fibaro:wakeUpDeadDevice(entry[GEA.keys["PARAMS"]][i][2])
						GEA.log("sendActions", entry, "!ACTION! : WakeUp " .. entry[GEA.keys["PARAMS"]][i][2], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "virtualdevice" and #entry[GEA.keys["PARAMS"]][i] > 2) then
						fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "pressButton", tostring(entry[GEA.keys["PARAMS"]][i][3]))
						GEA.log("sendActions", entry, "!ACTION! : VirtualDevice " .. entry[GEA.keys["PARAMS"]][i][2] ..",".. entry[GEA.keys["PARAMS"]][i][3], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "slider" and #entry[GEA.keys["PARAMS"]][i] > 3) then
						fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "setSlider", entry[GEA.keys["PARAMS"]][i][3], entry[GEA.keys["PARAMS"]][i][4])
						GEA.log("sendActions", entry, "!ACTION! : Slider " .. entry[GEA.keys["PARAMS"]][i][2] ..",".. entry[GEA.keys["PARAMS"]][i][3] .."=".. entry[GEA.keys["PARAMS"]][i][4], true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "label" and #entry[GEA.keys["PARAMS"]][i] > 3) then
						fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "setProperty", "ui."..entry[GEA.keys["PARAMS"]][i][3]..".value", GEA.getMessage(entry, entry[GEA.keys["PARAMS"]][i][4]))
						GEA.log("sendActions", entry, "!ACTION! : Label " .. entry[GEA.keys["PARAMS"]][i][2] ..",".. entry[GEA.keys["PARAMS"]][i][3]  .." = "..  GEA.getMessage(entry, entry[GEA.keys["PARAMS"]][i][4]), true)
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "rgb" and #entry[GEA.keys["PARAMS"]][i] > 5) then
						-- added by Shyrka973
						if (entry[GEA.keys["PARAMS"]][i][3] == -1 or entry[GEA.keys["PARAMS"]][i][4] == -1 or entry[GEA.keys["PARAMS"]][i][5] == -1 or entry[GEA.keys["PARAMS"]][i][6] == -1) then
							if (entry[GEA.keys["PARAMS"]][i][3] ~= -1) then
								fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "setR", entry[GEA.keys["PARAMS"]][i][3])
							end
							if (entry[GEA.keys["PARAMS"]][i][4] ~= -1) then
								fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "setG", entry[GEA.keys["PARAMS"]][i][4])
							end
							if (entry[GEA.keys["PARAMS"]][i][5] ~= -1) then
								fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "setB", entry[GEA.keys["PARAMS"]][i][5])
							end
							if (entry[GEA.keys["PARAMS"]][i][6] ~= -1) then
								fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "setW", entry[GEA.keys["PARAMS"]][i][6])
							end
						else
							fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "setColor", entry[GEA.keys["PARAMS"]][i][3], entry[GEA.keys["PARAMS"]][i][4], entry[GEA.keys["PARAMS"]][i][5], entry[GEA.keys["PARAMS"]][i][6])
						end
						GEA.log("sendActions", entry, "!ACTION! : RGB " .. entry[GEA.keys["PARAMS"]][i][2] ..", Color = ".. entry[GEA.keys["PARAMS"]][i][3]  ..",".. entry[GEA.keys["PARAMS"]][i][4]..",".. entry[GEA.keys["PARAMS"]][i][5]..",".. entry[GEA.keys["PARAMS"]][i][6])
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "program" and #entry[GEA.keys["PARAMS"]][i] > 2) then
						if (tonumber(fibaro:getValue(tonumber(entry[GEA.keys["PARAMS"]][i][2]), "currentProgramID")) ~= tonumber(entry[GEA.keys["PARAMS"]][i][3])) then			
							fibaro:call(entry[GEA.keys["PARAMS"]][i][2], "startProgram", entry[GEA.keys["PARAMS"]][i][3])
						end
						GEA.log("sendActions", entry, "!ACTION! : startProgram " .. entry[GEA.keys["PARAMS"]][i][2] ..", program = ".. entry[GEA.keys["PARAMS"]][i][3] )
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "value") then
						local id = GEA.getId(entry, entry[GEA.keys["PARAMS"]][i])
						if (id > 0) then
							if (#entry[GEA.keys["PARAMS"]][i] > 2) then
								fibaro:call(id, "setValue", entry[GEA.keys["PARAMS"]][i][3])
								GEA.log("sendActions", entry, "!ACTION! : setValue " .. entry[GEA.keys["PARAMS"]][i][3], true)
							else
								fibaro:call(id, "setValue", entry[GEA.keys["PARAMS"]][i][2])
								GEA.log("sendActions", entry, "!ACTION! : setValue " .. entry[GEA.keys["PARAMS"]][i][2], true)					
							end
						end
					elseif (type(entry[GEA.keys["PARAMS"]][i]) == "table" and string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "open" or string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "close") then
						local id = GEA.getId(entry, entry[GEA.keys["PARAMS"]][i])
						if (id > 0) then
							local pourc = 100
							if (#entry[GEA.keys["PARAMS"]][i] > 2) then
								if (string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "close") then pourc = pourc - entry[GEA.keys["PARAMS"]][i][3] else pourc = entry[GEA.keys["PARAMS"]][i][3] end 
								fibaro:call(id, "setValue", pourc)
								GEA.log("sendActions", entry, "!ACTION! : setValue " .. pourc, true)
							elseif (#entry[GEA.keys["PARAMS"]][i] > 1) then
								if (string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "close") then pourc = pourc - entry[GEA.keys["PARAMS"]][i][2] else pourc = entry[GEA.keys["PARAMS"]][i][2] end 
								fibaro:call(id, "setValue", pourc)
								GEA.log("sendActions", entry, "!ACTION! : setValue " .. pourc, true)
							else
								fibaro:call(id, entry[GEA.keys["PARAMS"]][i][1])
								GEA.log("sendActions", entry, "!ACTION! :  " .. entry[GEA.keys["PARAMS"]][i][1], true)					
							end
						end
					end
				end
			end
			if (entry[GEA.keys["MESSAGE"]] ~= "" and not pushed) then
				if (entry[GEA.keys["MESSAGE"]] == "debug") then
					fibaro:debug("==============" .. os.time() .. "=====================")
				else
					for i = 1, #GEA.portables do
						fibaro:call(tonumber(GEA.portables[i]), "sendPush",GEA.getMessage(entry, nil))
						GEA.log("sendActions", entry, "!ACTION! : sendPush " .. GEA.getMessage(entry, nil), true)
					end
				end
			end
		end
		
		-- ---------------------------------------------------------------------------
		-- Chercher l'id du p�riph�rique
		-- ---------------------------------------------------------------------------	
		GEA.getId = function(entry, param)
			local id = 0
			if (param and type(param)=="table" and #param > 1 and (string.lower(param[1])=="turnoff" or string.lower(param[1])=="turnon" or string.lower(param[1])=="switch") ) then
				id = tonumber(param[2])
			elseif (param and type(param)=="table" and #param > 2 and (string.lower(param[1])=="value" or string.lower(param[1])=="open" or string.lower(param[1]) == "close") ) then
				id  = tonumber(param[2])
			elseif (type(entry[GEA.keys["ID"]]) == "number") then
				id = entry[GEA.keys["ID"]]
			elseif ( type(entry[GEA.keys["ID"]])=="table" and string.lower(entry[GEA.keys["ID"]][1]) == "sensor+" or string.lower(entry[GEA.keys["ID"]][1]) == "sensor-" or string.lower(entry[GEA.keys["ID"]][1]) == "value-" or string.lower(entry[GEA.keys["ID"]][1]) == "value+" or string.lower(entry[GEA.keys["ID"]][1]) == "dead") then
				id = tonumber(entry[GEA.keys["ID"]][2])
			end

			if (id == 0) then
				fibaro:debug("pas trouve")
			end
			return id
		end
		
		
		-- ---------------------------------------------------------------------------
		-- Le syst�me est-il en pause
		-- ---------------------------------------------------------------------------	
		GEA.pause = function()
			local continue = true
			if (#GEA.getGlobalForActivation > 0) then
				continue = false
				if (fibaro:getGlobalValue(GEA.getGlobalForActivation[1]) == GEA.getGlobalForActivation[2]) then
					continue = true
				else 
					GEA.log("Run", nil, GEA.translate[GEA.language]["GEA_SUSPENDED"] .. " " .. GEA.getGlobalForActivation[1] .. " "..GEA.translate[GEA.language]["VALUE"].." " .. fibaro:getGlobalValue(GEA.getGlobalForActivation[1]) .. " "..GEA.translate[GEA.language]["REQUERIED"].." " ..GEA.getGlobalForActivation[2], true)
				end
			end
			return not continue
		end
		
		-- ---------------------------------------------------------------------------
		-- Contr�le tous les p�riph�rique d�clar�s toutes les X secondes
		-- ---------------------------------------------------------------------------	
		GEA.run = function() 
		
			if (yourcode) then
				yourcode()
			end
			
			if (GEA.isVersionFour) then 
				GEA.power = "power"
			end
			
			GEA.log("GEA Version " .. GEA.version, nil, " "..GEA.translate[GEA.language]["RUNING"].."...", true, "green")
			
			if (#GEA.todo == 0) then
				if (GEA.source["type"] ~= "property") then
					GEA.log(GEA.translate[GEA.language]["RUN"], nil, GEA.translate[GEA.language]["NOTHING_TODO"], true)
				else
					GEA.log(GEA.translate[GEA.language]["RUN"], nil, GEA.translate[GEA.language]["NOTHING_TODOID"] .. GEA.source["deviceID"], true)
				end
				return false
			end		
			
			local nbElement = #GEA.todo
			
			if (GEA.source["type"] == "autostart") then
			
			
				if (GEA.useTasksGlobal) then
					fibaro:setGlobal(GEA.globalTasks, GEA.suspended)
				else
					GEA.tasks = GEA.suspended
				end
			
				local delai = GEA.checkEvery
				local first = 1
				local firstofall = true
				local allstart = os.time()
				
				while true do
					GEA.log(GEA.translate[GEA.language]["RUN"], nil, GEA.translate[GEA.language]["SLEEPING"] .. " " .. GEA.checkEvery .. " "..GEA.translate[GEA.language]["SECONDS"], false)
					fibaro:sleep(delai * 1000)
					local start = os.time()
					if (not GEA.pause()) then	
						for i = 1, nbElement do
							GEA.log(GEA.translate[GEA.language]["RUN"], GEA.todo[i], GEA.translate[GEA.language]["CHECKING"], false)
							if (GEA.catchError) then
								if (not pcall(function() GEA.check(GEA.todo[i], i) end)) then
									GEA.log(GEA.translate[GEA.language]["ERROR"], GEA.todo[i], GEA.translate[GEA.language]["CHECKING"], true)
								end
							else
								GEA.check(GEA.todo[i], i)
							end
						end
					end
					local stop = os.time()
					local diff = (stop - start) -- / 1000
					if (firstofall) then 
						diff = diff * 2 
						firstofall = false
					end
					delai = GEA.checkEvery -  diff
					if (first >= 10) then 
						local msg = GEA.translate[GEA.language]["RUN_FOR"] .. diff .. "s "..GEA.translate[GEA.language]["RUN_NEW"] .. delai .. "s / ".. GEA.translate[GEA.language]["RUN_SINCE"] .. " " .. GEA.getDureeInString(os.time() - allstart)[1]
						fibaro:debug("<span style=\"color:CadetBlue; padding-left: 125px; display:inline-block; width:80%; margin-top:-18px; padding-top:-18px; text-align:left;\">"..msg.."</span>")
						first = 0
					end
					first = first + 1
				end
			else
				if (not GEA.pause()) then	
					for i = 1, nbElement do
						GEA.log(GEA.translate[GEA.language]["RUN"], GEA.todo[i], GEA.translate[GEA.language]["CHECKING"], false)
						if (GEA.catchError) then
							if (not pcall(function() GEA.check(GEA.todo[i], i) end)) then
								GEA.log(GEA.translate[GEA.language]["ERROR"], GEA.todo[i], GEA.translate[GEA.language]["CHECKING"], true, red)
							end
						else
							GEA.check(GEA.todo[i], i) 
						end
					end
				end		
			end
		end
		
		-- ---------------------------------------------------------------------------
		-- Contr�le tous les p�riph�rique d�clar�s toutes les X secondes
		-- ---------------------------------------------------------------------------		
		GEA.log = function(method, entry, message, force, color) 
			if (force or GEA.debug) then
				local msg  = ""
				local name = "If"
				if (not entry and not force) then return end

				if (entry and entry[GEA.keys["NAME"]]) then 
					name =  entry[GEA.keys["NAME"]] 
					if type(name) == "table" then
						name = name[1]
					end
				end
				if (entry and (type(entry[GEA.keys["ID"]]) == "nil" or type(entry[GEA.keys["ID"]]) == "boolean" or type(entry[GEA.keys["ID"]]) == "number" or type(entry[GEA.keys["ID"]]) == "table")) then
					if (type(entry[GEA.keys["ID"]]) == "nil" or type(entry[GEA.keys["ID"]]) == "boolean") then
						msg = msg .. "[ ".. name .." ] "
					elseif (type(entry[GEA.keys["ID"]]) == "number") then
						msg = msg .. "[ ".. entry[GEA.keys["ID"]] .. " | ".. name .." ] "
					elseif (type(entry[GEA.keys["ID"]]) == "table" and (GEA.match(string.lower(entry[GEA.keys["ID"]][1]), "global|global."))) then 
						msg = msg .. "[ ".. entry[GEA.keys["ID"]][2] .. "=".. entry[GEA.keys["ID"]][3] .. " ] "
					elseif (type(entry[GEA.keys["ID"]]) == "table" and string.lower(entry[GEA.keys["ID"]][1]) == "batteries") then 
						msg = msg .. "[ ".. entry[GEA.keys["ID"]][2] .. " ] "
					elseif (type(entry[GEA.keys["ID"]]) == "table" and string.lower(entry[GEA.keys["ID"]][1]) == "group") then 
						msg = msg .. "[ " .. name .." ] "
					elseif (type(entry[GEA.keys["ID"]]) == "table" and (GEA.match(string.lower(entry[GEA.keys["ID"]][1]), "sensor|sensor.|value|value.|dead|sceneactivation|battery"))) then 
						msg = msg .. "[ ".. name .." ] "
					elseif (type(entry[GEA.keys["ID"]]) == "table" and (GEA.match(string.lower(entry[GEA.keys["ID"]][1]), "slider|slider.|label|label.|property|property."))) then 
						msg = msg .. "[ ".. name .." ] "
					elseif (type(entry[GEA.keys["ID"]]) == "table" and (string.lower(entry[GEA.keys["ID"]][1]) == "weather")) then 
						msg = msg .. "[ Weather ] "					
					elseif (type(entry[GEA.keys["ID"]]) == "table" and (string.lower(entry[GEA.keys["ID"]][1]) == "function")) then 
						msg = msg .. "[ Function ] "
					elseif (type(id) == "table" and string.lower(entry[GEA.keys["ID"]][1]) == "alarm") then
						msg = msg .. "Alarm " .. fibaro:getValue(tonumber(entry[GEA.keys["ID"]][2]), "ui.lblAlarme.value")
					else 
						-- autre � venir
					end
				end
				if (method and method ~= "") then
					msg = msg .. string.format("%-20s", method) .. ": "
				end
				if (message and message ~= "") then
					msg = msg .. string.format("%-20s", message)
				end
				if (entry and entry[GEA.keys["INDEX"]]) then
					msg = msg .. " (ID:"..entry[GEA.keys["INDEX"]] ..")"
				end
				if (entry and entry[GEA.keys["PARAMS"]] and type(entry[GEA.keys["PARAMS"]]) == "table" and #entry[GEA.keys["PARAMS"]] > 0) then 
					for i = 1, #entry[GEA.keys["PARAMS"]] do 
						msg = msg .. " ["
						if (type(entry[GEA.keys["PARAMS"]][i]) == "table" ) then
							for j = 1, #entry[GEA.keys["PARAMS"]][i] do
								if (string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "if") then
									if (j == 1) then msg = msg .. "If..." end
								elseif (string.lower(entry[GEA.keys["PARAMS"]][i][1]) == "function") then
									if (j == 1) then msg = msg .. "Function..." end
								else
									msg = msg .. entry[GEA.keys["PARAMS"]][i][j] .. ","
								end
							end
						end
						msg = msg:sub(1, msg:len()-1) .. "]"
					end		
				end
				fibaro:debug("<span style=\"color:"..(color or "white").."; padding-left: 125px; display:inline-block; width:80%; margin-top:-18px; padding-top:-18px; text-align:left;\">"..msg.."</span>")
			end
		end
		
		
	end


	-- Les param�tres disponibles sont 
	-- {"turnOff"} -- Eteint le p�riph�rique concenn�  // Switch off the module
	-- {"turnOn"} -- Allume le p�riph�rique concern�  // Switch on the module
	-- {"Inverse"} -- On v�rifie si le p�riph�rique est DESACTIVE au lieu d'activ� // Check if the module is NOT activate instead of activated
	-- {"Repeat"} -- On r�pete les avertissements tant que le p�riph�rique n'a pas chang� d'�tat. // Repeating the actions as long as the condition is ok
	-- {"Portable", <id>} -- {"Portable", 70} -- Le message associ� � ce p�riph�rique sera envoy� � ce portable au lieu de ceux par d�faut // Push message will be send to this(these) smartphone instead of default one
	-- {"Scenario", <id>} -- {"Scenario", 2} -- Lance le sc�nario avec l'identifiant 2 // Start the scene XXX
	-- {"StopScenario", <id>} -- {"StopScenario", 2} -- Arr�te le sc�nario avec l'identifiant 2 // Stop the scene XXX
	-- {"EnableScenario", <id>} -- {"EnableScenario", 2} -- Active le sc�nario avec l'identifiant 2 // Enable the scene XXX
	-- {"DisableScenario", <id>} -- {"DisableScenario", 2} -- D�sactive le sc�nario avec l'identifiant 2 // Disable the scene XXX
	-- {"Value", <value>} -- {"Value", 20} -- Met la valeur 20 dans le p�riph�rique - dimmer une lampe. // Change the value of the dimmer
	-- {"Value", <id>, <value>} -- {"Value", 30, 20} -- Met la valeur 20 dans le p�riph�rique 30 - dimmer une lampe. // Change the value of the dimmer ID 30
	-- {"Open"} -- Ouvre le volet. // Open the shutter
	-- {"Open", <value>} -- {"Open", 20} -- Ouvre le volet de 20%. // Open the shutter for 20%
	-- {"Open", <id>, <value>} -- {"Open", 30, 20} -- Ouvre le volet 30 de 20%. // Open the shutter (id 30) for 20%
	-- {"Close"} -- Ferme le volet. // Close the shutter
	-- {"Close", <value>} -- {"Close", 20} -- Ferme le volet de 20%. // Close the shutter for 20%
	-- {"Close", <id>, <value>} -- {"Close", 30, 20} -- Ferme le volet 30 de 20%. // Close the shutter (id 30) for 20 %
	-- {"Global", <variable>, <valeur>} -- {"Global", "Maison", "Oui"} -- Met la valeur "Oui" dans la variable globale "Maison" // Update the global variable, put "Oui" in the variable called "Maison"
	-- *{"Time", <from>, <to>} -- {"Time", "22:00", "06:00"} -- Ne v�rifie le p�riph�rique QUE si nous sommes dans la/les tranches horaires // Check only if the time is in range
	-- {"Armed"} -- Uniquement si le module est arm� // Check only it the module is armed
	-- {"Disarmed"} -- Uniquement si le module est d�sarm� // Check only if the module is disarmed
	-- {"setArmed", <id_module>} -- Arme le module // Armed the module
	-- {"setDisarmed", <id_module>} -- D�sarme le module // Disarmed the module
	-- {"DST"} -- En mode "saving time" uniquement - en mode heure d'�t� // Only if we are un summer time
	-- {"NOTDST"} -- En mode "spending time" - en mode heure d'hiver // Only if we are un winter time
	-- {"VirtualDevice", <id,_module>, <id_bouton>} -- {"VirtualDevice", 2, 1} -- Press le bouton (id 1) du module virtuel (id 2) // Press the button 1 from the virtual device Id 2
	-- {"Label", <id_module>, <name>, <message>} -- {"Label", 21, "Label1", "activ�"} -- Affiche "activ�" dans le label ""ui.Label1.value" du module virtuel 21 // Update the value of a label
	-- {"WakeUp", <id,_module>} -- {"WakeUp", 54} -- Essai de r�veill� le module 54 // Try to wake up a module
	-- {"Email", <id_user>,} -- {"Email", 2} -- Envoi le message par email � l'utilisateur 2 // Send an email to a specific usermodule
	-- {"picture", <id_camera>, <id_user>,} -- {"picture", 2, 3} -- Envoi une capture de la cam�ra 2 � l'utilisateur 3 // Send a capture of camera 2 to user 3
	-- {"Group", <numero>} -- {"Group", 2} -- Attribut cet �v�nement au groupe 2 // Group attribution
	-- {"Slider", <id_module>, <id_slider>, <valeur>} -- {"Slider", 19, "1", 21} -- Met 21 dans le slider 1 du module 19 // Update de slider, put 21 into the slider 1 from the virtual device id 19
	-- {"Program", <id_module>, <no>} -- {"Program", 19, 5} -- Ex�cute le programme 5 du module RGB 19 // Start the program 5 from the RBG module id 19
	-- {"RGB", <id_module>, <col1>, <col2>, <col3>, <col4>} -- {"RGB", 19, 100, 100, 0, 100} -- Modifie la couleur RGB du module 19 // Change the color of a RGBW module id 19
	-- {"Days", "Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, All, Weekday, Weekend"} -- {"Days", "Weekday"} -- uniquement les jours de semaines // add days condition 
	-- {"Dates", "01/01[/2014]", "31/06[/2014]"} -- Seulement si la date est comprise entre le 1er janvier et le 31 juin inclus // Add date range !! French date format
	-- {"StopTask", <id_task>} -- Stop  la t�che // stop the task
	-- {"RestartTask", <id_task>} -- Red�marre la t�che // Restart the task
	-- {"MaxTime", <number>} -- Stop apr�s X execution // Stop after X run
	-- {"CurrentIcon", <id_module>, <id_icone>} -- modifie l'icone d'un module virtuel
	-- {"If", {<condition>[,<condition>[,...]}} -- Uniquement si toutes les conditions sont respect�e // Add more condition 

	-- * Sample : {"Times", "06:30", "18:30"} , {"Times", "Sunrise", "Sunset"} , {"Times", "Sunrise+30", "Sunset-15"}, {"Times", "Sunrise>07:30", "Sunset<21:00"}

	-- ==================================================
	-- [FR]
	-- Si vous n'avez pas mis votre code en haut du script
	-- vous avez toujours la possibilit� de le mettre ici
	-- A VOUS DE JOUER
	-- [EN]
	-- If you don't have put your own code up this scrip, 
	-- you can put it here
	-- YOUR TURN TO PLAY
	-- ==================================================


	-- [FR] NE PAS OUBLIER - D�marrage du sc�nario
	-- [EN] DON'T FORGET - Starting the scene
	GEA.run()