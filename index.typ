#import "@preview/touying:0.6.1": *
#import themes.university: *

#import "@preview/numbly:0.1.0": numbly

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Presentazione progetto HPC],
    author: [Claudio Marchini],
    date: datetime.today(),
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

= Descrizione del problema
==
Sia data la matrice $A^(n times n)$, l'obbiettivo del programma è quello di calcolare la matrice $T^(n times n)$ tale che:
$ t_(i j)=cases(1 "se" a_(i j)>m_(i j),0 "se" a_(i j)<=m_(i j)) $
dove 
$ m_(i j)=1/9 sum_(x=i-1)^(i+1)sum_(y=j-1)^(j+1)a_(x y) $\ \
Dato che i valori di $A$ sono di sola lettura, il problema è facilmente parallelizzabile in quanto non sono necessarie condizioni di sincronizzazione per prevenire race conditions.
Ogni "nodo" di esecuzione può perciò effettuare i calcoli sulla sua porzione di matrice in maniera indipendente, gli unici punti di sincronizzazione sono
- All'inizio del programma per la creazione della matrice $A$
- Alla fine del programma per la collezione dei pezzi della matrice $T$
= Soluzione MPI
==
Dato che MPI utilizza una comunicazione tramite scambio di messaggi, il singolo nodo non predispone di tutta la matrice, ma solo della parte di sua competenza.
Questo porta a certi problemi nel calcolo degli elementi al bordo della matrice.\
L'algoritmo ideato effettua i seguenti passaggi:
1. Data una matrice di dimensione $n$, il programma crea una matrice $n$ colonne e $n'$ righe, dove $n'$ è il primo multiplo di $p$, i valori aggiunti sono inizalizzati a $-1$
2. Vengono aggiunte altre due righe in cima e in fondo alla matrice, sempre inizalizzate a $-1$
3. Ogni nodo riceve dal master $m$ righe, dove $m=n'/p+2$ tramite una MPI_Scatter
4. I singoli nodi effettuano il calcolo di $T$ nella loro sottomatrice $m times n$, la prima e l'ultima riga sono utilizzate per i valori dell'intorno nel caso particolare in cui una cella sia al bordo della sottomatrice
5. Il risultato finale è riassemblato tramite una MPI_Gather, scartando eventuali valori ridondanti
I valori speciali $-1$ sono utilizzati dal sistema come valori invalidi, in questo caso il valore non viene sommato e il fattore di divisione per la media è opportunamente modificato
#image("ScatterMPI.svg", alt: "Schema dell'algoritmo di divisone delle sottomatrici", width: auto)
= Soluzione OMP
==
Al contrario di MPI, OMP è un sistema a memoria condivisa, non è necessario quindi effettuare particolari operazioni per la divisone delle sottomatrici in quanto ogni nodo ha accesso a tutti i valori della matrice originaria.\
L'algoritmo è quello di una soluzione sequenziale, con l'aggiunta delle opportune direttive di preprocessore:
- ```c #pragma omp num_threads(threads)``` indica al compilatore omp di utilizzare un numero massimo di threads pari a threads
- ```c #pragma omp for``` indica al compilatore di creare un thread per ogni iterazione del ciclo, in modo di parallelizzare l'esecuzione
Sono inoltre disponibili direttive per indicare quali variabili sono condivise e private per ogni thread, ma in generale il compilatore riesce a dedurle, e in questo caso non impattano significativamente sulle performace.
= Analisi della scalabilità
== 
#image("ScalabilitaStrong.png", alt: "Grafico della strong scalability", width: auto)
#image("ScalabilitaWeak.png", alt: "Grafico della weak scalability", width: auto)
I test della weak e strong scalability sono stati eseguiti con una dimensione della matrice pari a 4096, il numero di threads/nodi varia da 1 a 32
- L'analisi della scalabilita strong mostra, come previsto, un andamento asintotico dello speedup in quanto il programma è limitato da una sezione non parallelizzabile per la creazione della matrice A e dalla raccolta dei risultati
- L'analisi della scalabilita weak mostra un andamento lineare, in entrambi i casi le rette hanno coefficienti angolari inferiori a 1, sempre a causa delle sezioni non parallelizzabili del codice
- In entrambe le analisi la soluzione OMP risulta più performante dato che non è necessario effettuare operazioni di comunicazione tra i nodi, riducendo la complessita algoritmica e evitando operazioni di rete con un elevato costo