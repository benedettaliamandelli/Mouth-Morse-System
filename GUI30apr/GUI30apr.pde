import processing.serial.*;       

// COSE DA FARE:
// non permane il carattere non riconosciuto
// comando fineGO: da implementare quando il lampeggio del led su arduino sarà approvato

// --- COMUNICAZIONE

Serial myPort;
String mySign=""; // (?)
String myCode=""; // (?)
String myText=""; // stringa di testo in linguaggio naturale aggiornata dalla seriale
String myChar=""; // carattere letto dalla seriale
String startBlow = "sb";
String endBlow = "eb";
String space=" ";
String inizioGO="GO";
String fineGO = "fineGO";
// -----------------

// --- FONT
PFont titoli;
PFont istruzioni;
PFont sottotitoli;
PFont grassetto;
//----------

// ----- COLORI
color sfondo = #F8FFFF; // OLD FCF7F8
color menuOpzioni = #036E99;
color tasti = #ffa300; // OLD CED3DC, EFE7F4
color ledOff = #0492CB;
color ledOffStroke = #D6EAF8;
color verde = #1AF503;
color bianco = #F3FAFD;
color giallo = #F8F312; // DA PROVARE F6D021
color rosso = #FF3F00;
color grigio = #E6E8EC;
color lavagna = color(57, 79, 97);
color nero = #000000;
color logo = #ffa300;
// ------

// ---- LOGO
int SPACE = 40; // punto
int DASH = 70; // linea
int PAUSE = 12;  // pausa tra un punto e una linea
int [] DURATE = {SPACE, DASH, PAUSE, DASH, SPACE, DASH, PAUSE, DASH, SPACE, SPACE, SPACE, SPACE}; // M M
int durataCorrente = 0;
int counter = 0;
boolean light = false; // luce spenta
int radius = 100;
int centerX = 1920/2;
int centerY = 1080/2;
int ledWidth = 100;
int ledHeight = 100;
int xlogo = 1770;
int ylogo = 950;
// ------

// ----- CASI, stato
int LOGO = 0; // logo iniziale 
int ISTRUZIONI = 1; // piccola spiegazione iniziale
int ISTRUZIONI2 = 2; // spiego i tempi!
int MODALITA = 3; // menu write, play, exit
int WRITE = 4; // scrittura con arduino, con exit
int LEARN = 5; // selezione del gioco, con exit
int LEARN_LETTERS = 6;
int LEARN_WORDS = 7;
int USCITA = 100;
int stato;
// -----------------

// ------ CONTROLLO
boolean control_bar = false;
int bar_height=0;
int pressMillis=0;
int depressMillis=0;
int dotMaxThreshold = 100; // 500ms/5
int dashMaxThreshold = 200; // 1000ms/5
int maxBarHeight = 300; // 1500ms/5
int GO = 0;
int counter_buttonGO = 0;
int DEL = 0;
int counter_buttonDEL = 0;
int BLINK = 50; // 95 per 2 secondi //int currentTime;
// -----------------

// --- APPRENDO
String LETTERS[]= {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
String MORSE[] = {".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--..", "......"};
String MORSEVOCABULARY[] = {".- .--. .--. .-.. .", "-... .- .-.. .-..", "-.-. .- -", "-.. --- --.", ". --. --.", "..-. .. ... ....", "--. --- .- -", ".... .- -", ".. --. .-.. --- ---", ".--- .- -.-. -.- . -", "-.- . -.--", ".-.. . .- ..-.", "-- --- ..- ... .", "-. . ... -", "--- -.-. - --- .--. ..- ...", ".--. .- .. -. -", "--.- ..- . . -.", ".-. .- -... -... .. -", "... --- -.-. -.- ...", "- ..- .-. - .-.. .", "..- -- -... .-. . .-.. .-.. .-", "...- .. --- .-.. .. -.", ".-- .- --. --- -.", "-..- -.-- .-.. --- .--. .... --- -. .", "-.-- .- .-. -.", "--.. .. .--. .--. . .-."};
String WORDSVOCABULARY[] = {"apple", "ball", "cat", "dog", "egg", "fish", "goat", "hat", "igloo", "jacket", "key", "leaf", "mouse", "nest", "octopus", "paint", "queen", "rabbit", "socks", "turtle", "umbrella", "violin", "wagon", "xylophone", "yarn", "zipper"};
int M=37; //massima lunghezza della stringa
int index;
int check=0;
int place;
int max_place;
color[] colore= new color[M];
String code;
String[] morse;
String[] voc;
int nframe;
int wait=0;
float occupied_space;
// ---------

// ICONE ---------
PImage windIcon;
PImage backIcon;
PImage morseAlphabet;
// -----------------

void setup()
{
  //fullScreen();
  size(1920, 1080);
  smooth();
  stato = LEARN_LETTERS;
  titoli = createFont("Georgia", 50);
  //istruzioni = createFont("Cooper Black", 35);
  istruzioni = createFont("Palatino Linotype Corsivo", 35);
  sottotitoli = createFont("Courier New", 35);
  grassetto = createFont("Cooper Black", 50);
  //myPort = new Serial(this, "COM3", 9600); // chia
  //myPort = new Serial(this, "COM4", 9600); // vero
  myPort = new Serial(this, "/dev/cu.usbmodem14301", 9600);
  windIcon = loadImage("wind.png");
  windIcon.resize(105, 105);
  backIcon = loadImage("backspace.png");
  backIcon.resize(105, 105);
  morseAlphabet = loadImage("Morse Alphabet.PNG");
  imageMode(CENTER);
}

// -----------------

void draw()
{
  if (stato == LOGO) {
    avvioDelGioco();
  } else if (stato == ISTRUZIONI) {
    schermata_ISTRUZIONI();
  } else if (stato == ISTRUZIONI2) {
    schermata_ISTRUZIONI2();
  } else if (stato == MODALITA) {
    schermata_MODALITA();
  } else if (stato == WRITE) { // comunicazione standard
    schermata_WRITE();
  } else if (stato == LEARN) {
    schermata_LEARN();
  } else if (stato == LEARN_LETTERS || stato == LEARN_WORDS) {
    schermata_GAMES(stato);
    ledGo_Disabled();
    lampeggioLedDelete();
  } else if (stato == USCITA) {
    schermata_USCITA();
  }
}

// --------------------
//      FUNZIONI
// --------------------

// ---- SCHERMATE -----------

void avvioDelGioco() {
  background(menuOpzioni);
  rectMode(CENTER);
  if (light) {
    fill (logo);
  } else if (!light) {
    fill(menuOpzioni);
  }
  noStroke();
  circle(centerX, centerY, 2*radius); // halo
  noStroke();
  rect(centerX, centerY+ledHeight/2, 2*ledWidth, ledHeight); // halo

  fill(grigio);
  circle(centerX, centerY, radius + 5); // bordino
  rect(centerX, centerY+ledHeight/2, radius + 5, ledHeight); // bordino
  fill(logo);
  circle(centerX, centerY, ledWidth); // led
  rect(centerX, centerY+ledHeight/2, ledWidth, ledHeight); // led
  fill(grigio);
  rect(centerX, centerY+ledHeight+5, 125, 10, 10); // base del led

  textFont(titoli);
  if (durataCorrente >= 4) {
    textSize(30);
    text("M", centerX-30, centerY+ledHeight+50);
  }
  if (durataCorrente >= 8) {
    textSize(30);
    text("M", centerX-30, centerY+ledHeight+50);
    text("M", centerX+3, centerY+ledHeight+50);
  }
  if (durataCorrente >= 10) {
    textSize(30);
    text("M", centerX-30, centerY+ledHeight+50);
    text("M", centerX+3, centerY+ledHeight+50);
    text("Mouth Morse System", centerX-140, centerY+ledHeight+120);
  }

  counter ++; // aggiorno il counter ogni frameRate
  if ((counter == DURATE[durataCorrente]) && (durataCorrente < DURATE.length)) {
    if (durataCorrente < DURATE.length-4) {
      light = !light; // accendo o spengo la luce
    }
    durataCorrente += 1; // passo al successivo
    counter = 0; // azzero il contatore
  }

  if (durataCorrente == DURATE.length) {
    stato = ISTRUZIONI;
    rectMode(CORNER);
  }
}

// ------------

void schermata_ISTRUZIONI() {       // schermata istruzioni START
  menu();

  fill(logo);
  textFont(titoli);
  textSize(90);
  String s1 = "WELCOME!";
  text(s1, 100, 270);
  fill(nero);
  textFont(sottotitoli);
  textSize(40);
  String s2 = "Here are some useful tips \nfor you to get to know MM!";
  text(s2, 100, 350);

  // ISTRUZIONI GO
  fill(grigio);
  rect(1620/2, 132.5, 650+100, 135, 7);
  triangle(1620/2+100+650, 172.5, 1620/2+100+650, 112.5+115, 1650, 200);
  fill(nero);
  textSize(35);
  String s3 = "When the GO button lights up, you can start blowing.";
  text(s3, 1620/2+10, 132.5+10, 750-10, 135);

  // ISTRUZIONI BACK
  fill(grigio);
  rect(1620/2, 132.5+150+71, 650+100, 180, 7);
  triangle(1620/2+100+650, 172.5+150+71, 1620/2+100+650, 112.5+115+150+71, 1650, 71+200+150);
  fill(nero);
  textSize(35);
  String s4 = "When the BACK (/DEL) button lights up, you've managed to blow \"a very long breath\".";
  text(s4, 1620/2+10, 132.5+150+10+71, 750-10, 180);

  // ISTRUZIONI BARRA
  fill(grigio);
  rect(1620/2, 477.5+71, 650+100, 350, 7);
  triangle(1620/2+100+650, 477.5+350/2-27.5+71, 1620/2+100+650, 477.5+350/2+27.5+71, 1650, 477.5+350/2+71);
  fill(nero);
  textSize(35);
  String s5 = "The bar shows you for how long you're blowing. \nIt will be yellow while you're blowing \"a short breath\". \nIt will turn white when your blowing becomes \"a long breath\"."; // It will become white when you reach \"a long breath\". 
  text(s5, 1620/2+10, 477.5+10+71, 750-10, 350);

  textFont(istruzioni);
  textSize(60);
  String s6 = "blow once to START";
  float l6 = textWidth(s6);
  text(s6, 3*1620/4-l6/2, ylogo+50);

  lampeggioLedGo();
  lampeggioLedDelete();
  back();

  if (myPort.available()>0)
  {
    myChar=myPort.readStringUntil('\n');
    myChar=removeExtraCharacter(myChar);

    if (myChar.equals(inizioGO)) {
      GO=1;
      counter_buttonGO=0;
    } else if (myChar.equals("E") || myChar.equals("T") ) {
      stato = ISTRUZIONI2; // un soffio
    } else if (myChar.equals("indietro")) {
      stato = USCITA;
      DEL = 1;
      counter_buttonDEL = 0;
    } else if (myChar.equals(startBlow)) {
      control_bar=true;
      pressMillis=millis(); //inizio soffio
    } else if (myChar.equals(endBlow)) {
      control_bar=false;
      bar_height=0;
      depressMillis=millis(); //fine soffio
    }
  }
  //sign(pressMillis, depressMillis, !control_bar); // scrive cosa è uscito
  bar();
}

void schermata_ISTRUZIONI2()          // schermata LIVELLO
{
  menu();
  fill(nero);
  textFont(titoli);
  String s1 = "Time Intervals";
  float l1 = textWidth(s1);
  text(s1, 1620/2-l1/2, 270);

  // LAVAGNA
  fill(lavagna);
  rect(100, 320, 1620-200, 400, 7);
  fill(bianco);
  textFont(titoli);
  String s2 = " time window for one  .  : 0 - 500 ms\n time window for one  -  : 500 - 1000 ms\n time window for __: 1000 - ∞ ms"; //testo in write
  text(s2, 100+10+10, 320+100+10, 1620-200-20-10, 820-320-20);    //text(s2, 100+10+10, 320+10+10, 1620-200-20-10, 1040-320-20);
  // tasto indietro
  back(); // soffio mooolto lungo
  next(); // soffio breve

  lampeggioLedGo();
  lampeggioLedDelete();


  // ora i menù di scelta
  if (myPort.available()>0)
  {
    myChar=myPort.readStringUntil('\n');
    myChar=removeExtraCharacter(myChar);

    if (myChar.equals(inizioGO)) {
      GO=1;
      counter_buttonGO=0;
    } else if (myChar.equals("E") || myChar.equals("T")) {
      stato = MODALITA; // un soffio
    } else if (myChar.equals("indietro")) {
      DEL = 1;
      counter_buttonDEL = 0;
      stato = ISTRUZIONI;
    } else if (myChar.equals(startBlow)) {
      control_bar=true;
      pressMillis=millis(); //inizio soffio
    } else if (myChar.equals(endBlow)) {
      control_bar=false;
      bar_height=0;
      depressMillis=millis(); //fine soffio
    }
  }
  bar();
}

void schermata_MODALITA()          // schermata MODALITA
{
  menu();
  fill(tasti);
  stroke(nero);
  strokeWeight(1.5);
  fill(tasti);
  rect(300, 490, 400, 200, 10);    //first option
  rect(920, 490, 400, 200, 10);    //second option
  fill(nero);
  textFont(titoli);
  text("Choose your activity", 600, 270);
  String s1 = "WRITE";
  float l1 = textWidth(s1);
  text(s1, 300+200-l1/2, 490+100);
  String s2 = "LEARN";
  float l2 = textWidth(s2);
  text(s2, 920+200-l2/2, 490+100);
  textFont(istruzioni);
  String s3 = "blow once"; // before: blow one short breath
  float l3 = textWidth(s3);
  text(s3, 500-l3/2, 490+100+35);
  String s4 = "blow twice"; // before: blow two short breaths
  float l4 = textWidth(s4);
  text(s4, 1120-l4/2, 490+100+35);
  back();

  lampeggioLedGo();
  lampeggioLedDelete();

  // ora i menù di scelta
  if (myPort.available()>0)
  {
    myChar=myPort.readStringUntil('\n'); //legge fino a che trova \n, cancellando dalla porta quello che ha letto ma non i dati accumulati successivamente
    myChar=removeExtraCharacter(myChar); //rimuovo il carattere \n

    if (myChar.equals("E") || myChar.equals("T")) {
      stato = WRITE; // un soffio
    } else if (myChar.equals("I") || myChar.equals("M") || myChar.equals("A") || myChar.equals("N")) {
      stato = LEARN; // qualsiasi combo di 2 soffi
    } else if (myChar.equals("indietro")) {
      stato = ISTRUZIONI2; // torno indietro alle istruzioni
      DEL = 1;
      counter_buttonDEL = 0;
    } else if (myChar.equals(inizioGO)) {
      GO = 1;
      counter_buttonGO=0;
    } else if (myChar.equals(startBlow)) {
      control_bar=true;
      pressMillis=millis(); //inizio soffio
    } else if (myChar.equals(endBlow)) {
      control_bar=false;
      bar_height=0;
      depressMillis=millis(); //fine soffio
    }
  }
  bar();
}

void schermata_WRITE() {
  menu();
  // TITOLO SCHERMATA
  fill(nero);
  textFont(titoli);
  String s1 = "Your message is:";
  float l1 = textWidth(s1);
  text(s1, 1620/2-l1/2, 270);

  // LAVAGNA
  fill(lavagna);
  rect(100, 320, 1620-200, 820-320, 7);    
  fill(255);
  rect(100+10, 320+10, 1620-200-20, 820-320-20, 7);    
  back();
  lampeggioLedGo();
  lampeggioLedDelete();

  if (myChar.equals("_")) {
    fill(nero);
    textFont(sottotitoli);
    textSize(40);
    text("non riconosciuto", 1000, 500); // non permane
  }

  if (myPort.available()>0)
  {
    myChar=myPort.readStringUntil('\n');
    myChar=removeExtraCharacter(myChar);

    if (myChar.equals(inizioGO)) {
      GO = 1;
      counter_buttonGO = 0;
    } else if (myChar.equals("indietro")) {
      myText="";
      myCode="";
      DEL = 1;
      counter_buttonDEL = 0;
      stato = MODALITA;
    } else if (myChar.equals("/")) {
      myText=removeLastCharacter(myText); //cancello un carattere
    } else if (myChar.equals("//")) {
      myText=removeExtraCharacter(myText); // cancello due caratteri
    } else if (myChar.equals(startBlow)) {
      control_bar=true;
      pressMillis=millis(); // inizio soffio
    } else if (myChar.equals(endBlow)) {
      control_bar=false;
      bar_height=0;
      depressMillis=millis(); // fine soffio
      //sign(pressMillis, depressMillis, !control_bar); // scrive cosa è uscito
    } else if (myChar.equals(".")||myChar.equals("-") || myChar.equals("?")) {
      // non scrivo, ma li devo mettere qui altrimenti li concatena al testo
    } else {
      myText += myChar; // concatena anche il carattere non riconosciuto
    }
  }
  bar();
  fill(nero);
  textFont(sottotitoli);
  textSize(40);
  text(myText, 100+10+10, 320+10+10, 1620-200-20-10, 820-320-20);
  // tasto indietro
}

void schermata_LEARN()          // schermata LEARN
{
  menu();
  fill(tasti);
  stroke(nero);
  strokeWeight(1.5);
  fill(tasti);
  rect(300, 490, 400, 200, 10);    // ABC option
  rect(920, 490, 400, 200, 10);    // MEMORY option
  fill(nero);
  // TITOLO
  textFont(titoli);
  String s6 = "What game do you want to play?";
  float l6 = textWidth(s6);
  text(s6, 1620/2-l6/2, 270);
  // ISTRUZIONI
  textFont(istruzioni);
  String s5 = "blow when GO lights up";
  float l5 = textWidth(s5);
  text(s5, 1620/2-l5/2, 305);
  // TITOLI OPZIONI
  textFont(titoli);
  String s1 = "LETTERS";
  float l1 = textWidth(s1);
  text(s1, 300+200-l1/2, 490+100);
  String s2 = "WORDS";
  float l2 = textWidth(s2);
  text(s2, 920+200-l2/2, 490+100);
  // ISTRUZIONI OPZIONI 
  textFont(istruzioni);
  String s3 = "blow once";
  float l3 = textWidth(s3);
  text(s3, 500-l3/2, 490+100+35);
  String s4 = "blow twice";
  float l4 = textWidth(s4);
  text(s4, 1120-l4/2, 490+100+35);

  back();
  lampeggioLedGo();
  lampeggioLedDelete();

  if (myPort.available()>0)
  {
    myChar=myPort.readStringUntil('\n');
    myChar=removeExtraCharacter(myChar);

    if (myChar.equals(inizioGO)) {
      GO = 1;
      counter_buttonGO = 0;
    } else if (myChar.equals("indietro")) {
      DEL = 1;
      counter_buttonDEL = 0;
      stato = MODALITA;
    } else if (myChar.equals("E") || myChar.equals("T")) {
      stato = LEARN_LETTERS;
    } else if (myChar.equals("I") || myChar.equals("M")) {
      stato = LEARN_WORDS;
    } else if (myChar.equals(startBlow)) {
      control_bar=true;
      pressMillis=millis(); //inizio soffio
    } else if (myChar.equals(endBlow)) {
      control_bar=false;
      bar_height=0;
      depressMillis=millis(); //fine soffio
    }
  }

  bar();
}

void schermata_GAMES(int substate) {     
  if (check==0)
  {
    if (substate==LEARN_LETTERS)
    {
      voc=LETTERS;
      morse=MORSE;
    } else
    {
      voc=WORDSVOCABULARY;
      morse=MORSEVOCABULARY;
    }
    index = int(random(voc.length-1));
    max_place=morse[index].length()-1;
    place=0;
    check=1;

    setup_learn();
  }  //fine check

  if (wait !=0)
  {
    if (myPort.available()>0)
    {
      myPort.readStringUntil('\n');
    }
    if (frameCount-nframe>=150)
    {
      if (wait==1)
      {
        check=0;
      }
      if (wait==2) // ho sbagliato
      {
        setup_learn();
      }
      wait=0;
    }
  }// fine attesa

  if (check==1 && wait==0)
  {
    if (myPort.available()>0)
    {
      myChar=myPort.readStringUntil('\n'); 
      myChar=removeExtraCharacter(myChar);
      if (myChar.equals("indietro"))
      {
        stato=LEARN;
        check=0;
        DEL = 1;
        counter_buttonDEL = 0;
      } else if ((myChar.equals(".")||myChar.equals("-")))
      {
        code=String.valueOf(morse[index].charAt(place));
        if (code.equals(" ") && substate==LEARN_WORDS)
        {
          place++;
          code=String.valueOf(morse[index].charAt(place));
        }
        if (myChar.equals(code))
        {
          colore[place]=verde;
          stamp(colore, morse, occupied_space);
          if (place==max_place)
          {
            wait=1; //caso attesa per lettera corretta
            nframe=frameCount;
            correct();
          }
          place++;
        } else
        {
          colore[place]=rosso;
          stamp(colore, morse, occupied_space);
          //place=0;
          wrong();
          nframe=frameCount;
          wait=2;
        }
      }
    }//fine myportavailable
  }//fine check
} //fine funzione totale

// ----------------------

void schermata_USCITA() {
  menu();
  ledGo_off();
  ledDelete_off();
  delay(2000);
  exit();
}

// -------------

void menu() {
  background(sfondo);   
  fill(menuOpzioni);
  noStroke();
  rect(1620, 0, 300, 1080);    //right menu
  logo();
}

// logo
void logo() {
  noStroke();
  fill(logo);
  circle(xlogo, ylogo, 80); // halo
  noStroke();
  rect(xlogo-40, ylogo, 80, 50); // halo

  fill(grigio);
  circle(xlogo, ylogo, 50 + 5); // bordino
  rect(xlogo-27.5, ylogo, 50 + 5, 50); // bordino
  fill(logo);
  circle(xlogo, ylogo, 50); // led
  rect(xlogo-25, ylogo, 50, 50); // led
  fill(grigio);
  rect(xlogo-30, ylogo+50, 60, 7, 10); // base del led
  textFont(titoli);
  fill(grigio);
  textSize(30);
  text("MM", xlogo-28, ylogo+50+40);
}

void setup_learn()
{
  for (int j=0; j<M; j++)
  {
    if (j < place) {
      colore[j]=verde;
    } else {
      colore[j]=nero;
    }
  }

  menu();
  // TITOLO SCHERMATA
  fill(nero);
  textFont(titoli);
  String s1 = "Try to replicate:";
  occupied_space = textWidth(s1);
  text(s1, 1620/2-occupied_space/2, 270);
  // LAVAGNA
  fill(nero);
  rect(100, 320, 1620-200, 820-320, 7);    
  fill(255);
  rect(100+10, 320+10, 1620-200-20, (820-320-20)/2-5, 7);      // bianco sopra
  rect(100+10, 565+10, 1620-200-20, 235, 7);    // bianco sotto
  back();

  //mostra lettera/parola da scrivere e codice da replicare
  fill(nero);
  textFont(titoli);
  float l2 = textWidth(voc[index]);
  text(voc[index], 110+1400/2-l2/2, 330+235/2); 
  occupied_space = 40*(morse[index].length());
  stamp(colore, morse, occupied_space);
}

void correct() {   //stampa il messaggio di correct
  fill(verde);
  textFont(grassetto);
  String s3 = "CORRECT! Wait for another try";
  float l3 = textWidth(s3);
  text(s3, 850+400/2-l3/2, 1040-200+100);
}
void wrong() {   //stampa il messaggio di errore
  fill(rosso);
  textFont(grassetto);
  String s3 = "WRONG! Wait and try again!";
  float l3 = textWidth(s3);
  text(s3, 850+400/2-l3/2, 1040-200+100);
}

/*
void correct() {  
 String s3 = "CORRECT!";
 float l3 = textWidth(s3);
 noStroke();
 fill(verde);
 rect(1120+400/2-l3/2-60, 1040-200+20, 2*l3+20, 120, 10);
 fill(lavagna);
 rect(1120+400/2-l3/2-50, 1040-200+30, 2*l3, 100, 10);
 fill(verde);
 textFont(titoli);
 text(s3, 1120+400/2-l3/2, 1040-200+100);
 }
 
 void wrong() {  
 String s3 = "WRONG! Try again!";
 float l3 = textWidth(s3);
 noStroke();
 fill(rosso);
 rect(1095-l3+50, 1040-200+20, 2*l3+20, 120, 10);
 fill(lavagna);
 rect(1095-l3+60, 1040-200+30, 2*l3, 100, 10);
 fill(rosso);
 textFont(titoli);
 text(s3, 1095-l3/2, 1040-200+100);
 }
 */

// -------------- LED ----------

// led GO
void ledGo_on() {
  stroke(nero);
  strokeWeight(1.5);
  fill(verde);
  circle(1770, 200-50, 150);    //red bigger circle
  textFont(titoli);
  textSize(35);
  fill(nero);
  text("GO", 1770-textWidth("GO")/2, 310-50);
  noTint();
  image(windIcon, 1770, 150);
}

void ledGo_Disabled() {
  strokeWeight(1.5);
  stroke(nero);
  fill(ledOff);
  circle(1770, 150, 150);
  tint(100, 50);
  image(windIcon, 1770, 150);
}

void ledGo_off() {
  strokeWeight(1.5);
  stroke(nero);
  fill(ledOff);
  circle(1770, 150, 150);
  noTint();
  image(windIcon, 1770, 150);
  fill(nero);
  textFont(titoli);
  textSize(35);
  text("GO", 1770-textWidth("GO")/2, 310-50);
}

void lampeggioLedGo() {
  if ((GO==1) && counter_buttonGO < BLINK) {
    ledGo_on();
    counter_buttonGO+=1;
  } else if (counter_buttonGO == BLINK || (GO == 0)) {
    ledGo_off();
    GO = 0;
  }
}

// led del cancella
void ledDelete_on() {
  stroke(nero);
  strokeWeight(1.5);
  fill(rosso);
  circle(1770, 425-50, 150);
  textFont(titoli);
  textSize(35);
  fill(nero);
  if (stato == WRITE) {
    //String s3 = "DEL";
    float l3 = textWidth("DEL");
    text("DEL", 1770-l3/2, 535-50);
    //text("DEL", 1735, 535-50);
  } else if (stato == ISTRUZIONI) {
    float l4 = textWidth("EXIT");
    text("EXIT", 1770-l4/2, 535-50);
  } else {
    float l4 = textWidth("BACK");
    text("BACK", 1770-l4/2, 535-50);
  }
  noTint();
  image(backIcon, 1765, 425-50);
}

void ledDelete_off() {
  stroke(nero);
  strokeWeight(1.5);
  fill(ledOff);
  circle(1770, 425-50, 150);
  textFont(titoli);
  textSize(35);
  fill(nero);
  if (stato == WRITE) {
    //String s3 = "DEL";
    float l3 = textWidth("DEL");
    text("DEL", 1770-l3/2, 535-50);
    //text("DEL", 1735, 535-50);
  } else if (stato == ISTRUZIONI) {
    float l4 = textWidth("EXIT");
    text("EXIT", 1770-l4/2, 535-50);
  } else {
    float l4 = textWidth("BACK");
    text("BACK", 1770-l4/2, 535-50);
  }
  noTint();
  image(backIcon, 1765, 425-50);
}

void lampeggioLedDelete() {
  if ((DEL == 1) && counter_buttonDEL < BLINK) {
    ledDelete_on();
    counter_buttonDEL+=1;
  } else if (counter_buttonDEL == BLINK || (DEL == 0)) {
    ledDelete_off();
    DEL = 0;
  }
}
// -------------------

// TASTO BACK -----
void back() {
  stroke(nero);
  strokeWeight(1.5);
  fill(tasti);
  rect(100, 1040-200, 400, 200, 10);    
  fill(nero);
  textFont(titoli);
  if (stato == ISTRUZIONI) {
    String s3 = "EXIT";
    float l3 = textWidth(s3);
    text(s3, 300-l3/2, 1040-200+100);
  } else {
    String s3 = "BACK";
    float l3 = textWidth(s3);
    text(s3, 300-l3/2, 1040-200+100);
  }
  textFont(istruzioni);
  String s4 = "blow one long breath";
  float l4 = textWidth(s4);
  text(s4, 300-l4/2, 1040-200+100+35);
}
// ----------------

// TASTO NEXT ---------
void next() {
  stroke(nero);
  strokeWeight(1.5);
  fill(tasti);
  rect(1120, 1040-200, 400, 200, 10);    
  fill(nero);
  textFont(titoli);
  String s3 = "NEXT";
  float l3 = textWidth(s3);
  text(s3, 1120+400/2-l3/2, 1040-200+100);
  textFont(istruzioni);
  String s4 = "blow one short breath";
  float l4 = textWidth(s4);
  text(s4, 1120+400/2-l4/2, 1040-200+100+35);
}
// --------------------

// ----- GESTIONE COM

void bar() // mettere una condizione di stop per evitare che la barra salga all'infinito
  // mettere un cambio di colore per corto = blu e lungo = bianco e super lungo = verde (?)
{
  stroke(nero);
  strokeWeight(1.5);
  fill(ledOff);
  rect(1700, 600-50, 140, 301, 10);
  noStroke();
  if (control_bar)
  {
    bar_height = int ((millis()-pressMillis)/5);
    if (bar_height < dotMaxThreshold) {
      fill(giallo);
    } else if ((bar_height > dotMaxThreshold) && (bar_height < dashMaxThreshold)) {
      fill(bianco);
    } else if ((bar_height > dashMaxThreshold) && (bar_height < maxBarHeight)) {
      fill(rosso);
    } else if (bar_height >= maxBarHeight) {
      bar_height = maxBarHeight;
    }
  }
  rect(1701, 900-50-bar_height, 138, bar_height); // barra
  stroke(nero);
  line(1700, 800-50, 1840, 800-50);
  line(1700, 700-50, 1840, 700-50);
}

// -------------

String removeExtraCharacter(String str) // tolgo i due caratteri di default
{
  if ((str != null) && (str.length() > 0)) 
  {
    return str.substring(0, str.length() - 2);
  } else
  {
    return "";
  }
}

// -------------

String removeLastCharacter(String str) // tolgo una sola lettera
{
  if ((str != null) && (str.length() > 0)) 
  {
    return str.substring(0, str.length() - 1);
  } else
  {
    return "";
  }
}

// ------------------

void sign(int start, int end, boolean go)
{
  if (go) {
    textFont(titoli);
    textSize(35);
    if ((end - start) < dotMaxThreshold) {
      fill(nero);
      text("DOT", 1695, 885);
    } else if (((end - start) < dashMaxThreshold) && ((end - start) > dotMaxThreshold)) {
      fill(nero);
      text("DASH", 1684, 885);
    } else if (((end - start) > dashMaxThreshold)) {
      fill(nero);
      text("LINE", 1660, 885);
    }
  }
}

// -------------------

void stamp(color col[], String[] print, float lung)  //stampa un segno alla volta così da settarne indipendentemente i colori
{
  for (int x=0; x<=max_place; x++)
  {
    fill(col[x]);
    textFont(titoli);
    text(String.valueOf(print[index].charAt(x)), 17+110+1400/2-lung/2+40*x, 565+10+235/2);
  }
}

// --------------------
