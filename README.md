Paràmetres
	Capacitat de l'ascensor en nombre de persones.
	Número de plantes de l'edifici.
	Temps d'obrir/tancar la porta de l'ascensor.
	Temps d'entrar/sortir una persona de l'ascensor.
	Temps de baixar/pujar un pis.
	Temps mig i desviació estàndard entre arribades de persones que volen usar l'ascensor (a qualsevol planta).
	Probabilitat p0 de voler anar a la planta 0.
	Número de persones per fer la simulació.


Assumpcions
	Considerem una distribució normal en el temps entre arribades de persones, i equiprobable la planta d'arribada. Per simplificar, suposarem que les persones arriben d'una en una.
	A cada planta hi ha un únic botó, que serveix per cridar l'ascensor. La primera persona que arriba és la que crida l'ascensor.
	A dins l'ascensor, hi ha un botó per anar a cada planta. Cada persona premerà la tecla corresponent al seu destí un cop sigui dins de l'ascensor.
	Per les persones que criden l'ascensor a la planta 0, considerem equiprobable la seva planta de destí (diferent de 0). Per les persones que criden l'ascensor a una planta > 0, considerem que volen anar a la planta 0 amb probabilitat p0, i a la resta amb la probabilitat complementària, repartida uniformement.
	L'ascensor no canvia de sentit (ascens/descens) fins que ha esgotat totes les peticions en el sentit de viatge. Quan no hi ha peticions queda aturat.
	Les peticions internes i externes tenen la mateixa prioritat.
	A l'inici de la simulació l'ascensor es troba a la planta 0, amb les portes tancades.


Sortida (exemple suposant capacitat 5, i altres paràmetres no especificats)
Petició a la planta 23
Ascensor puja
Petició a la planta 10
Ascensor para a la planta 10
Ascensor obre portes
Persona puja amb destinació planta 0
Persona puja amb destinació planta 0
Persona puja amb destinació planta 1
Ascensor tanca portes
Ascensor puja
Petició a la planta 5
Ascensor para a la planta 23
Ascensor obre portes
Persona puja amb destinació planta 0
Persona puja amb destinació planta 0
Ascensor tanca portes
Ascensor baixa
Ascensor para a la planta 5
Ascensor obre portes
Ascensor tanca portes #No pot pujar ningú perquè l'ascensor està ple
Ascensor baixa
Ascensor para a la planta 1
Ascensor obre portes
Persona baixa
Ascensor tanca portes
Ascensor baixa
Ascensor para a la planta 0
Ascensor obre portes
Persona baixa
Persona baixa
Persona baixa
Persona baixa
Ascensor tanca portes
Ascensor puja
Ascensor para a la planta 5
Ascensor obre portes
Persona puja amb destinació planta 0
Ascensor tanca portes
Ascensor baixa
Ascensor para a la planta 0
Ascensor obre portes
Persona baixa
Ascensor tanca portes
