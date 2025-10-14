#define SIZE 36
#define SIZE_COM 3

/*VETTORE del MorseCode per le lettere inglesi dalla A alla Z + 0 a 9*/
String MORSE[SIZE] = {
  // A to I
  ".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..",
  // J to R
  ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.",
  // S to Z
  "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--..",
  // 0 to 9
  "-----", ".----", "..---", "...--", "....-", ".....", "-....", "--...", "---..", "----."
};

/*VETTORE dei COMANDI*/
String COMANDI[SIZE_COM] {
  // spazio, cancella, indietro
  "?.", "?-", "?"
};

/*VETTORE corrispondente del MorseCode per le lettere inglesi dalla A alla Z + 0 a 9*/
String CARATTERE[SIZE] = {
  // A to I
  "A", "B", "C", "D", "E", "F", "G", "H", "I",
  // J to R
  "J", "K", "L", "M", "N", "O", "P", "Q", "R",
  // S to Z
  "S", "T", "U", "V", "W", "X", "Y", "Z",
  // 0 to 9
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
};

#define pinLEDgo 3     //sincronizzazione: pinledgo
#define pinLEDdot 9      //identificazione soffio "." oppure "-"
#define pinLEDdash 11     //tempo per "-"
#define pinLEDlungo 13      //tempo per "cancella"
#define pinTHERM A0

void setup() {
  Serial.begin(9600);    //comunicazione seriale (9600 bit al secondo, standard)
  pinMode(pinTHERM, INPUT);  //pin A0 del THERMISTOR
  pinMode(pinLEDgo, OUTPUT);   //pin 3 del LED rosso, se voglio mettere un led (o un buzzer) per identificare il lasso di tempo in cui soffiare una lettera
  pinMode(pinLEDdot, OUTPUT); //pin 11 del LED blu, se voglio mettere un led per identificare il soffio
  pinMode(pinLEDdash, OUTPUT); //pin 12 del LED bianco, se voglio mettere un led per identificare che si è raggiunta la durata del soffio lungo
  pinMode(pinLEDlungo, OUTPUT); //pin 10 del LED verde, per identificare quando si raggiunge la durata per cancellare di un soffio molto lungo
  analogReference(EXTERNAL);   //voltaggio di riferimento esterno
  // Serial.println("FUNZIONAMENTO: attendere qualche istante, dopo che il LED rosso si sia spento, per comunicare la lettera volta per volta");
  // Serial.println("Il punto '.' deve essere un soffio rapido (<500ms)");
  // Serial.println("Il trattino '-' deve essere un soffio lungo (>700ms)");
  // Serial.println("Per cancellare bisogna fare un soffio lungo (>1200ms)");
}

/*inizializzazione variabili*/
unsigned long attesa;
float filtro;
float filtro_old = 1000;
float filtro_d = 0;
float temp;
unsigned long inizio; //per i tempi utilizzare unsigned long altrimenti le durate assumono valori negativi
unsigned long durata;
int der;
int pausa;
unsigned long millis_old;

String codice = "";
String frase = "";  //voglio metterlo come output della MODALITA' COMUNICAZIONE TESTO che comprende tutto il codice sottostante
int accettato;    //codice accettato: utile per scandire anche gli spazi tra una parola e l'altra

//aggiunta chia
String carattere = ""; // la uso per passare le info sulla seriale
String inizioGO = "GO";
//String fineGO = "fineGO";
//aggiunta vero
String startBlow = "sb";
String endBlow = "eb";

void loop() {
  //Serial.println(filtro_d);    //per mostrare andamento filtrato della temperatura
  //Serial.println(temp);     //per mostrare andamento non filtrato della temperatura

  /*La funzione millis() conta il tempo in millisecondi..
    non si puo/non riesco ad azzerarla quindi per calcolare il tempo si usa la differenza
    tra diversi istanti*/

  /*Il segnale di start per ricevere il codice di ingresso*/
  if (millis() > 5000) {
    digitalWrite(pinLEDgo, HIGH);
    delay(5);
    Serial.println(inizioGO);
  }

  delay(1000);
  digitalWrite(pinLEDgo, LOW);

  /*Il codice è identificato dalla pausa finale*/
  codice = "";
  pausa = 0;

  while (pausa == 0) {

    if ((millis() - millis_old) > 10) { //ogni 10 ms controllo la temperatura e calcolo la derivata
      filtro_old = filtro;  //aggiorno la temperatura vecchia
      temp = analogRead(A0);
      filtro = (0.9 * filtro + 0.05 * temp);
      millis_old = millis();  //aggiorno i millisecondi
    }

    filtro_d = (0.9 * (filtro_d + 0.05 * ((filtro - filtro_old) * 10))); //Ho messo il filtro anche per la derivata.. così è più rilassata (x10 per aumentarla un po..)
    //Serial.println(filtro_d);
    if (millis() < 5000) { //for the start
      filtro_d = 0;
    }

    if (filtro_d > 0.75) { //0.75
      pausa = 0;  //identificare la pausa tra due lettere (vedi ultima parte)
      attesa = millis();
      if (der == 0) {
        der = 1;
        inizio = millis();
        // inizio soffio: aggiunta chia
        delay(5);
        Serial.println(startBlow);
      }
      if ((millis() - inizio) > 150 && der) {
        digitalWrite(pinLEDdot, HIGH);  //maggiore di 2 (valore sperimentale accendo led o buzzer o altro..
      }
      if ((millis() - inizio) > 500 && der) {
        digitalWrite(pinLEDdash, HIGH);
      }
      if ((millis() - inizio) > 1000 && der) {
        digitalWrite(pinLEDlungo, HIGH);
      }
    } else {
      if (der == 1) {
        der = 0;
        durata = millis() - inizio;
        attesa = millis();
        // a questo punto dovrebbe finire il soffio
        delay(5);
        Serial.println(endBlow);
      }
      digitalWrite(pinLEDdot, LOW);   //minore di 2 (valore sperimentale spengo led o buzzer o altro..ù
      digitalWrite(pinLEDdash, LOW);
      digitalWrite(pinLEDlungo, LOW);
    }

    if ((durata > 150) && (durata < 500)) { //Se la durata del soffio è compresa tra 50 e 500ms allora è "." ATTENZIONE: ho lasciato il range [500-700] in qui non è nulla
      codice.concat(".");           //per evitare soffi "incerti"
      delay(5);
      Serial.println(".");
      durata = 0;
      delay(500);                    // attendo 500ms .. PENSO che possa servire a evitare che due soffi vicinissimi vengano segnati per errore come due "."
    }

    if ((durata > 500 && durata < 1000)) {           //Se la durata del soffio è maggiore di 700ms allora è "-"
      codice.concat("-");
      delay(5);
      Serial.println("-");
      durata = 0;
      delay(500);
    }

    if ((durata > 1000)) {             //Se la durata del soffio è maggiore di 1200ms allora è "cancella"
      codice.concat("?");
      delay(5);
      Serial.println("?");
      durata = 0;
      delay(500);
      //delay(1000);
    }

    if (((millis() - attesa) > 3000) && !pausa) { //Se dopo l'ultimo segno sono passati più di 4 secondi c'è il cambio lettera
      pausa = 1;  //Serve a fare in modo che se aspetto piu di 4 secondi ho finito il codice
      attesa = millis();
    }
  }

  //sono nella situazione in cui (pausa,cancella)=(0,1) oppure (1,0) gli altri casi non si possono verificare

  accettato = 0; //codice da accettare ancora, che può essere un carattere od uno spazio
  //si può pensare di distinguere l'errore segnato così "_" dallo spazio segnato così " "

  /*Verifico se il codice è un comando*/
  for (int i = 0 && !accettato; i < SIZE_COM; i++) {
    if (COMANDI[i].compareTo(codice) == 0) {
      switch (i) {
        case 0: //spazio
          if (frase.charAt(frase.length() - 1) == '_') {
            frase = frase.substring(0, frase.length() - 1);
          }
          accettato = 1;
          if (frase.charAt(frase.length() - 1) != ' ') {
            frase.concat(" ");
            carattere = frase.charAt(frase.length() - 1);
            delay(5);
            Serial.println(carattere);
          }
          break;
        case 1: //cancella
          accettato = 1;
          if (frase.charAt(frase.length() - 1) == ' ') {
            frase = frase.substring(0, frase.length() - 2);
            carattere = "//";
            delay(5);
            Serial.println(carattere);
          } else {
            frase = frase.substring(0, frase.length() - 1);
            carattere = "/";
            delay(5);
            Serial.println(carattere);
          }
          break;
        case 2: //indietro
          accettato = 1;
          carattere = "indietro";
          delay(5);
          Serial.println(carattere);
          break;
      }
    }
  }

  /*Verifico se il codice è presente nel dizionario*/
  for (int i = 0 && !accettato; i < SIZE; i++) {
    if (MORSE[i].compareTo(codice) == 0) {
      //Serial.println("il codice è: ");
      //Serial.println(codice);
      //Serial.println(CARATTERE[i]);
      if (frase.charAt(frase.length() - 1) == '_') {
        frase = frase.substring(0, frase.length() - 1);
      }
      frase.concat(CARATTERE[i]);
      accettato = 1;  //la lettera è stata accettata
      carattere = frase.charAt(frase.length() - 1);
      Serial.println(carattere);
    }
  }

  /*Verifico cosa succede negli altri casi*/
  if (codice.compareTo("") != 0 && !accettato) {
    if (frase.charAt(frase.length() - 1) != '_') {
      frase.concat("_");
      carattere = frase.charAt(frase.length() - 1);
      Serial.println(carattere);
    }
  }

  /*Stampa la frase solo per vedere il corretto funzionamento*/
  //  Serial.println("la frase per adesso è: ");
  //  Serial.println(frase);
}
