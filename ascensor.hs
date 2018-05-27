import Control.Concurrent.STM
import Control.Concurrent
import Control.Monad
import System.Random
import GHC.Types (IO (..))

main = do
    -------------------------------------------- PARÀMETRES D'ENTRADA ----------------------------------------
    let p0 = 60
    let tObrirTancarPortes = 1
    let tPujarBaixarPis = 2
    let tEntrarSortirAscensor = 2
    let tMig = 5
    let capacitatAscensor = 3
    let numPlantes = 23
    let personesSimulacio = 10
    ----------------------------------------------------------------------------------------------------------
    llistaPeticions <- newPeticions numPlantes
    pis <- newPis 0
    persones_ascencor <- newPeticions capacitatAscensor
    probabilitats <- newPeticions 100
    calculProbabilitats probabilitats p0 numPlantes
    llistaP <- readPeticions llistaPeticions
    llistaA <- readPeticions persones_ascencor
    llistaProbabilitats <- readPeticions probabilitats
    direccio <- newPis 1
    g <- newStdGen
    ----------------------------------------------------------------------------------------------------------
    sequence_ [ person llistaPeticions personesSimulacio numPlantes tMig g]
    Main.forever personesSimulacio (run direccio llistaPeticions persones_ascencor probabilitats pis tObrirTancarPortes tPujarBaixarPis tEntrarSortirAscensor capacitatAscensor) 
  where
    person llistaPeticions personesSimulacio m tMig g = forkIO (peticionsGenerades llistaPeticions (take (personesSimulacio) (randomRs (1, m) g)) tMig)

-- Per cada element x de la llista (x:xs) s'afegeix a la llista de la peticio llistaPeticions cada tMig segons. 
peticionsGenerades::Peticio -> [Int] ->  Int -> IO()
peticionsGenerades llistaPeticions (x:xs) tMig = (do 
   person1 x llistaPeticions
   list <- readPeticions llistaPeticions
   delay tMig
   putStr ("Ascensor puja \n")
   ex llistaPeticions xs tMig)
 where 
  ex llistaPeticions [] tMig = (do putStr (""))
  ex llistaPeticions (x:xs) tMig = (do person1 x llistaPeticions
                                       list <- readPeticions llistaPeticions
                                       delay tMig
                                       ex llistaPeticions xs tMig)
--Mostra l'element seguit d'un espai
showSpaces::Int -> String
showSpaces x = (show x) ++ " "

-- Controla l'ascensor a partir de la direcció que anem, de les peticions que arriben, de les persones que hi han a l'ascensor, de les probabilitats per anar un pis o un altre, del pis en que estem, del temps que tarda en obrir/tancar portes, del temps que tarda en pujar/baixar un pis, del temps que tarda en entrar/sortir de l'ascensor i de la capacitat de l'ascensor.
run :: Pis -> Peticio  -> Peticio -> Peticio -> Pis -> Int -> Int -> Int -> Int -> IO ()
run direccio llistaPeticions persones_ascencor probabilitats pis tObrirTancarPortes tPujarBaixarPis tEntrarSortirAscensor capacitatAscensor = do 
    dir <- readPis direccio
    pis_actual <- readPis pis
    llistaP <- readPeticions llistaPeticions
    llistaA <- readPeticions persones_ascencor
    executaPeticions direccio dir llistaP llistaA llistaPeticions persones_ascencor probabilitats pis pis_actual tObrirTancarPortes tPujarBaixarPis tEntrarSortirAscensor capacitatAscensor

-- En cas que hi hagi una petició en el pis on estem, para en el pis, obrir portes, puja a l'ascensor amb una destinació X, tanca portes. 
-- En cas que hi hagi una persona que vol baixar en el pis on estem, para en el pis, obrir portes, baixa de l'ascensor i tanca les portes.
-- Si l'ascensor va cap amunt i hi han peticions o algu que vol baixar en un pis més amunt del que estem, l'ascensor va cap amunt
-- Si l'ascensor va cap amunt, no hi han peticions o algu que vol baixar en un pis més amunt del que estem i hi han peticions o algu que vol baixar en un pis més avall del que estem, l'ascensor va cap avall
-- Si l'ascensor va cap avall i no hi han peticions o algu que vol baixar en un pis més cap avall del que estem i hi han peticions o algu que vol baixar en un pis més amunt del que estem, l'ascensor va cap amunt
executaPeticions::Pis -> Int -> [Int]  -> [Int]  -> Peticio -> Peticio -> Peticio -> Pis -> Int -> Int -> Int -> Int -> Int ->IO ()
executaPeticions direccio dir llistaPeticions persones_ascencor peticio_pers persona_asc probabilitats pis p tObrirTancarPortes tPujarBaixarPis tEntrarSortirAscensor capacitatAscensor
 | (((length (filter (pisEqualHigh p) llistaPeticions))>0 || (length (filter (pisEqualHigh p) persones_ascencor))>0) && dir==1) = (do 
                                           peticioPlantaActual llistaPeticions peticio_pers persones_ascencor persona_asc probabilitats dir p tObrirTancarPortes tEntrarSortirAscensor capacitatAscensor
                                           incrPis pis
                                           p <- readPis pis
                                           delay tPujarBaixarPis
                                           llistaPeticions <- readPeticions peticio_pers
                                           persones_ascencor <- readPeticions persona_asc
                                           dir <- readPis direccio
                                           direccioAscensor direccio dir llistaPeticions persones_ascencor peticio_pers persona_asc pis p
                                           run direccio peticio_pers persona_asc probabilitats pis tObrirTancarPortes tPujarBaixarPis tEntrarSortirAscensor capacitatAscensor)
 | (((length (filter (pisEqualLow p) llistaPeticions))>0 || (length (filter (pisEqualLow p) persones_ascencor))>0) && dir==0) = (do 
                                           peticioPlantaActual llistaPeticions peticio_pers persones_ascencor persona_asc probabilitats dir p tObrirTancarPortes tEntrarSortirAscensor capacitatAscensor
                                           decrPis pis
                                           p <- readPis pis
                                           delay tPujarBaixarPis
                                           llistaPeticions <- readPeticions peticio_pers
                                           persones_ascencor <- readPeticions persona_asc
                                           dir <- readPis direccio
                                           direccioAscensor direccio dir llistaPeticions persones_ascencor peticio_pers persona_asc pis p
                                           run direccio peticio_pers persona_asc probabilitats pis tObrirTancarPortes tPujarBaixarPis tEntrarSortirAscensor capacitatAscensor)
 | (otherwise) = (do putStr (""))

-- Si la direcció de l'ascensor és cap amunt, no hi han peticions o persones a l'ascensor que vagin cap amunt del pis on estem i hi han peticions o persones a l'ascensor que van cap avall, llavors canviem de direccio i executem peticionsBuides
-- Si la direcció de l'ascensor és cap avall, no hi han peticions o persones a l'ascensor que vagin cap avall del pis on estem i hi han peticions o persones a l'ascensor que van cap amunt, llavors canviem de direccio i executem peticionsBuides
direccioAscensor::Pis->Int->[Int]->[Int]->Peticio->Peticio->Pis->Int->IO()
direccioAscensor direccio dir llistaPeticions persones_ascencor peticio_pers persona_asc pis p
 | (((length (filter (pisEqualHigh p) llistaPeticions))>0 || (length (filter (pisEqualHigh p) persones_ascencor))>0) && dir==1) = (do putStr (""))
 | (((length (filter (pisEqualLow p) llistaPeticions))>0 || (length (filter (pisEqualLow p) persones_ascencor))>0) && dir==0) =  (do putStr (""))
 | (((length (filter (pisEqualHigh p) llistaPeticions))>0 || (length (filter (pisEqualHigh p) persones_ascencor))>0) && dir==0) = (do 
                                           incrPis direccio
                                           dir <- readPis direccio
                                           peticionsBuides llistaPeticions persones_ascencor dir p)
 | (((length (filter (pisEqualLow p) llistaPeticions))>0 || (length (filter (pisEqualLow p) persones_ascencor))>0) && dir==1) = (do 
                                           decrPis direccio
                                           dir <- readPis direccio
                                           peticionsBuides llistaPeticions persones_ascencor dir p)
 | ((length llistaPeticions)==0 && (length persones_ascencor)==0) = (do putStr (""))

 --Si hi ha alguna persona a l'ascensor que vol baixar en aquest pis, o alguna peticio per voler pujar en aquest pis, l'ascensor es para, s'obren portes, baixa una persona en cas que n'hagi de baixar i/o pujen les persones que han demanar pujar en aquest pis. En cas que no hi hagi espai a l'ascensor no puja ningú.
peticioPlantaActual llistaPeticions peticio_pers persones_ascencor persona_asc probabilitats dir p tObrirTancarPortes tEntrarSortirAscensor capacitatAscensor
 | (((length (filter (pisEqual p) persones_ascencor)>0) && dir==1) || ((length (filter (pisEqual p) llistaPeticions)>0) && dir==1))= (do
                                                                        putStr ("Ascensor para a la planta " ++ (showSpaces p) ++"\n")
                                                                        putStr ("Ascensor obre portes\n")
                                                                        delay tObrirTancarPortes
                                                                        personaBaixa persones_ascencor persona_asc p tEntrarSortirAscensor
                                                                        llistaPeticions <- readPeticions peticio_pers
                                                                        persones_ascencor <- readPeticions persona_asc
                                                                        personaPuja llistaPeticions peticio_pers persona_asc persones_ascencor probabilitats dir p tEntrarSortirAscensor capacitatAscensor
                                                                        putStr ("Ascensor tanca portes")
                                                                        capacitatFull persones_ascencor capacitatAscensor
                                                                        delay tObrirTancarPortes
                                                                        llistaPeticions <- readPeticions peticio_pers
                                                                        persones_ascencor <- readPeticions persona_asc
                                                                        peticionsBuides llistaPeticions persones_ascencor dir p)
 | (((length (filter (pisEqual p) persones_ascencor)>0) && dir==0) || ((length (filter (pisEqual p) llistaPeticions)>0) && dir==0)) = (do 
                                                                        putStr ("Ascensor para a la planta " ++ (showSpaces p) ++"\n")
                                                                        putStr ("Ascensor obre portes\n")
                                                                        delay tObrirTancarPortes
                                                                        personaBaixa persones_ascencor persona_asc p tEntrarSortirAscensor
                                                                        llistaPeticions <- readPeticions peticio_pers
                                                                        persones_ascencor <- readPeticions persona_asc
                                                                        personaPuja llistaPeticions peticio_pers persona_asc persones_ascencor probabilitats dir p tEntrarSortirAscensor capacitatAscensor
                                                                        putStr ("Ascensor tanca portes")
                                                                        capacitatFull persones_ascencor capacitatAscensor
                                                                        delay tObrirTancarPortes
                                                                        llistaPeticions <- readPeticions peticio_pers
                                                                        persones_ascencor <- readPeticions persona_asc
                                                                        peticionsBuides llistaPeticions persones_ascencor dir p)
 | (otherwise) = (do putStr (""))

 -- Si l'asensor està ple, mostra per pantalla que no pot pujar ningú perquè l'ascensor està ple.
capacitatFull::[Int]->Int->IO()
capacitatFull persones_ascencor capacitatAscensor
 | ((length persones_ascencor)>=capacitatAscensor) = (do putStr (" #No pot pujar ningú perquè l'ascensor està ple \n"))
 | (otherwise) = (do putStr ("\n"))

-- Si hi han peticions superiors al pis on estem o algu de l'ascensor vol anar a un pis superior al pis on estem i la direccio és cap amunt, s'escriu «Ascensor puja»
-- Si hi han peticions inferiors al pis on estem o algu de l'ascensor vol anar a un pis inferior al pis on estem i la direccio és cap avall, s'escriu «Ascensor baixa»
peticionsBuides::[Int] -> [Int] -> Int -> Int -> IO()
peticionsBuides llistaPeticions persones_ascencor direccio p
 | ((length llistaPeticions)==0 && (length persones_ascencor)==0) = (do putStr (""))
 | (direccio==0 && ((length (filter (pisEqualLow p) llistaPeticions))>0 || (length (filter (pisEqualLow p) persones_ascencor))>0)) = (do putStr ("Ascensor baixa\n"))
 | (direccio==1 && ((length (filter (pisEqualHigh p) llistaPeticions))>0 || (length (filter (pisEqualHigh p) persones_ascencor))>0)) = (do putStr ("Ascensor puja\n"))
 | (otherwise) = (do putStr (""))

--Si hi ha alguna persona que vol baixar en aquest pis, l'ascensor és para, obre les portes, baixa i tanca les portes
personaBaixa::[Int]->Peticio->Int->Int->IO()
personaBaixa persones_ascencor persona_asc p tEntrarSortirAscensor
 | ((length (filter (pisEqual p) persones_ascencor)>0)) = (do baixenPersonesAscensor (length (filter (pisEqual p) persones_ascencor)) persona_asc p tEntrarSortirAscensor)
 | (otherwise) = (do putStr (""))

--Si hi ha alguna persona que vol pujar en aquest pis, l'ascensor és para, obre les portes, puja la persona amb una destinació, on aquesta destinació té una serie de probabilitats i tanca les portes. Només entrerà si l'ascensor no està ple. 
personaPuja::[Int]->Peticio->Peticio->[Int]->Peticio->Int->Int->Int->Int->IO()
personaPuja llistaPeticions peticio_pers persona_asc persones_ascencor probabilitats dir p tEntrarSortirAscensor capacitatAscensor
 | ((length (filter (pisEqual p) llistaPeticions)>0)) = (do pujenPersonesAscensor (length (filter (pisEqual p) llistaPeticions)) persona_asc peticio_pers persones_ascencor  probabilitats p tEntrarSortirAscensor capacitatAscensor)
 | (otherwise) = (do putStr (""))

--Si la capacitat de l'ascensor no està plena, entraran n persones a l'ascensor amb una destinació X, on X és un valor random de la llista de probabilitats. Per entrar/sortir de l'ascensor s'esperaran un temps tEntrarSortirAscensor.
pujenPersonesAscensor::Int->Peticio->Peticio->[Int]->Peticio ->Int->Int->Int->IO()
pujenPersonesAscensor 0 persona_asc peticio_pers persones_ascencor probabilitats pis tEntrarSortirAscensor capacitatAscensor = (do putStr (""))
pujenPersonesAscensor n persona_asc peticio_pers persones_ascencor probabilitats pis tEntrarSortirAscensor capacitatAscensor 
 | ((length persones_ascencor) < capacitatAscensor) = (do 
                                                           g <- newStdGen 
                                                           let valor_random = (head (randomRs (0, 99) (g)))
                                                           llista_probabilitats <- readPeticions probabilitats
                                                           let pis_destinacio = llista_probabilitats!!valor_random
                                                           joinPeticions persona_asc pis_destinacio 
                                                           eliminaPeticions peticio_pers pis
                                                           putStr ("Persona puja a la planta " ++ (showSpaces pis) ++ "amb destinacio planta " ++ (showSpaces pis_destinacio) ++ "\n")
                                                           delay tEntrarSortirAscensor --Temps baixar persona
                                                           persones_ascencor <- readPeticions persona_asc
                                                           pujenPersonesAscensor (n-1) persona_asc peticio_pers persones_ascencor probabilitats pis tEntrarSortirAscensor capacitatAscensor)
 | (otherwise) = (do putStr (""))

-- Baixa n persones de l'ascensor i s'espera tEntrarSortirAscensor segons
baixenPersonesAscensor::Int->Peticio->Int->Int->IO()
baixenPersonesAscensor 0 persona_asc pis tEntrarSortirAscensor= (do putStr (""))
baixenPersonesAscensor n persona_asc pis tEntrarSortirAscensor= (do eliminaPeticions persona_asc pis
                                                                    putStr ("Persona baixa\n")
                                                                    delay tEntrarSortirAscensor --Temps baixar persona
                                                                    baixenPersonesAscensor (n-1) persona_asc pis tEntrarSortirAscensor)

-- Retorna cert si el pis i la peticio són iguals, altrament és false
pisEqual::Int -> Int -> Bool
pisEqual pis peticio = (comprovar pis peticio)
  where
     comprovar pis peticio
        | (pis == peticio) = True
        | (otherwise) = False

-- Retorna cert si la peticio és igual o més gran que el pis, altrament és false
pisEqualHigh::Int -> Int -> Bool
pisEqualHigh pis peticio = (comprovar pis peticio)
  where
     comprovar pis peticio
        | (pis <= peticio) = True
        | (otherwise) = False

-- Retorna cert si el pis és igual o més gran que la petició, altrament és false
pisEqualLow::Int -> Int -> Bool
pisEqualLow pis peticio = (comprovar pis peticio)
  where
     comprovar pis peticio
        | (pis >= peticio) = True
        | (otherwise) = False

-- Mostra per pantalla la id i l'afageix a la llista de peticions
helper1 :: Int -> Peticio -> IO ()
helper1 id llista = do
    putStr ("Petició a la planta " ++ show id ++ "\n")
    joinPeticions llista id

-- Mostra per pantalla la petició de la persona i l'afageix a la llista de peticions
person1 ::Int -> Peticio -> IO ()
person1 id llista = helper1 id llista

-- Insereix ordenadament a la llista, l'element id
inserirOrdenadament::[Int] -> Int -> [Int]
inserirOrdenadament [] id = [id]
inserirOrdenadament l@(inici:xs) id  | id <= inici = (id:l)
                                     | otherwise = (inici:(inserirOrdenadament xs id))

----------------------------------------------------------------------------------------------

-- Repeteix personesSimulacio vegades l'acció act
forever :: Int -> IO () -> IO ()
forever personesSimulacio act = forever' act personesSimulacio
  where -- cheating here to make it stop eventually
    forever' :: IO () -> Int -> IO ()
    forever' act 0 = return ()
    forever' act n = do
        act
        forever' act (n - 1)

-- S'espera m segons
delay :: Int -> IO ()
delay m = do
    threadDelay (1000000*m)

----------------------------------------------------------------------------------------------

data Peticio = MkPeticio Int (TVar ([Int]))

-- Crea una peticio
newPeticions :: Int -> IO Peticio
newPeticions n = atomically (do tv <- newTVar ([])
                                return (MkPeticio n tv))

-- Afegeix un element a la llista de la petició
joinPeticions :: Peticio -> Int -> IO ()
joinPeticions (MkPeticio n tv) id
  = atomically (do list <- readTVar tv
                   check (n > 0)
                   writeTVar tv (inserirOrdenadament list id))

-- Llegeix la llista de la petició
readPeticions:: Peticio -> IO [Int]
readPeticions (MkPeticio n tv) = atomically ( do
    list <- readTVar tv
    writeTVar tv list
    return (list))

-- Elimina l'element pis de la llista de la petició
eliminaPeticions:: Peticio -> Int -> IO()
eliminaPeticions (MkPeticio n tv) pis = atomically ( do
    list <- readTVar tv
    writeTVar tv (elimina pis list))
 where 
  elimina::Int->[Int]->[Int]
  elimina p [] = []
  elimina p (x:xs)
   | (x==p) = elimina p xs
   | (otherwise) = (x:(elimina p xs))

-- Crea una peticio amb una llista de p0 vegades 0 i (100-p0)/numPlantes vegades cada número de 1 a numPlantes
calculProbabilitats::Peticio->Int->Int->IO()
calculProbabilitats (MkPeticio n tv) p0 numPlantes
 = atomically ( do list <- readTVar tv
                   writeTVar tv (calculaProbabilitats list p0 (ceiling (fromIntegral (100-p0) / fromIntegral (numPlantes))) numPlantes))

-- Insereixo p0 vegades 0 i pResta vegades el numero de planta a la llista list
calculaProbabilitats list p0 pResta 0 = (insereix p0 0 list)
calculaProbabilitats list p0 pResta numPlantes =  (insereix pResta numPlantes list) ++ (calculaProbabilitats list p0 pResta (numPlantes-1))

-- Insereixo n vegades x a list.
insereix::Int->Int->[Int]->[Int]
insereix 0 _ _ = []
insereix n x list = (x:list) ++ (insereix (n-1) x list)

---------------
data Pis = MkPis Int (TVar (Int))

-- Creo un Pis
newPis :: Int -> IO Pis
newPis n = atomically (do tv <- newTVar (n)
                          return (MkPis n tv))

-- Llegeix un Pis
readPis :: Pis -> IO (Int)
readPis (MkPis n tv) 
  = atomically (do (pis) <- readTVar tv 
                   writeTVar tv (pis)
                   return (pis))

-- Incremento el pis en 1
incrPis :: Pis -> IO (Int)
incrPis (MkPis n tv) 
  = atomically (do (pis) <- readTVar tv 
                   writeTVar tv (pis+1)
                   return (pis+1))

-- Decremento el pis en 1
decrPis :: Pis -> IO (Int)
decrPis (MkPis n tv) 
  = atomically (do (pis) <- readTVar tv 
                   writeTVar tv (pis-1)
                   return (pis-1))