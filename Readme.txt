Assumpcions
- Considerem una distribució normal en el temps entre arribades de persones, i equiprobable la planta d'arribada. Per simplificar, suposarem que les persones arriben d'una en una.
- A cada planta hi ha un únic botó, que serveix per cridar l'ascensor. La primera persona que arriba és la que crida l'ascensor.
- A dins l'ascensor, hi ha un botó per anar a cada planta. Cada persona premerà la tecla corresponent al seu destí un cop sigui dins de l'ascensor.
- Per les persones que criden l'ascensor a la planta 0, considerem equiprobable la seva planta de destí (diferent de 0). Per les persones que criden l'ascensor a una planta > 0, considerem que volen anar a la planta 0 amb probabilitat p0, i a la resta amb la probabilitat complementària, repartida uniformement.
- L'ascensor no canvia de sentit (ascens/descens) fins que ha esgotat totes les peticions en el sentit de viatge. Quan no hi ha peticions queda aturat.
- Les peticions internes i externes tenen la mateixa prioritat.
- A l'inici de la simulació l'ascensor es troba a la planta 0, amb les portes tancades.

Paràmetres
- Capacitat de l'ascensor en nombre de persones.
- Número de plantes de l'edifici.
- Temps d'obrir/tancar la porta de l'ascensor.
- Temps d'entrar/sortir una persona de l'ascensor.
- Temps de baixar/pujar un pis.
- Temps mig i desviació estàndard entre arribades de persones que volen usar l'ascensor (a qualsevol planta).
- Probabilitat p0 de voler anar a la planta 0.
- Número de persones per fer la simulació.

Per executar el fitxer, no es demanarà cap paràmetre. Només cal compilar-ho i executar-ho.

Si es vol modificar algun paràmetre, haurem de modificar el codi. Es simple.

Aquí disposo d'unes instruccions per modificar el codi:

A l'inici del codi, es pot visualitzar un apartat «PARÀMETRES D'ENTRADA»
on trobarem:
- p0
- tObrirTancarPortes
- tPujarBaixarPis
- tEntrarSortirAscensor
- tMig
- capacitatAscensor
- numPlantes
- personesSimulacio

* p0 és la probabilitat de voler anar a la planta 0 (%).
* tObrirTancarPortes és el temps d'obrir/tancar la porta de l'ascensor (segons).
* tPujarBaixarPis és el temps de baixar/pujar un pis (segons).
* tEntrarSortirAscensor és el temps d'entrar/sortir una persona de l'ascensor (segons).
* tMig és el temps mig entre arribades de persones que volen usar l'ascensor (a qualsevol planta) (segons).
* capacitatAscensor és la capacitat de l'ascensor en nombre de persones.
* numPlantes és el número de plantes de l'edifici.
* personesSimulacio és el nombre de persones per fer la simulació.