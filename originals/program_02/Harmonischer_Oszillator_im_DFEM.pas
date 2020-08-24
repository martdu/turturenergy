
Program Harmonischer_Oszillator_im_DFEM;
{$APPTYPE CONSOLE}

Uses
Windows,
Messages,
SysUtils,
Classes,
Graphics,
Controls,
Forms,
Dialogs;

Var epo,muo : Double; {Naturkonstanten}
  v : Double; {Propagationsgeschwindigkeit der Ströme}
  CA,CD,C : Double;
  {Platten-Kondensator: Plattenfläche, Plattenabstand, Kapazität}
  GG3 : Double;
 {Gleichgewichtsposition der flexiblen Platten, Teil 3,
Federkraft=Coulombkraft}
  SP3 : Double;
  {Plattenabstand mit flexiblen Platten, Teil 3, mechanische Vorspannung}
  UC,UL{,UR} : Double; {Spannung über Kondensator, Spule, Widerstand}
  SN,SL,SA,SR : Double;
  {Luft-Spule: Windungszahl, Spulenlänge, Querschnittsfläche, Spulen-Radius}
  L : Double; {Induktivität der Luft-Spule}
  DL : Double; {Drahtlänge des Spulendrahtes}
  epr,mur : Double; {Epsilon_r und Mü_r für Kondensator und Spule}
  rho,R : Double; {spezifischer und Ohm`scher Widerstand des Spulendrahtes}
  AD : Double; {Querschnittsfläche des Spulendrahtes}
  Q,Qp,Qpp : Array[0..200000] Of Double;
  {Ladung auf dem Kondensator als Fkt der Zeit}
  x,xp,xpp : Array[0..200000] Of Double;
  {Auslenkung jeder einzelnen Kondensatorplatte}
  dt : Double; {Zeitschritte}
  N : LongInt; {Anzahl der Zeitschritte insgesamt}
  i : LongInt; {Laufvariable zum Durchzählen der Zeitschritte}
  Abstd : Integer; {Jeder wievielte Punkte soll geplottet werden}
  rhoAL,rhoFol: Double; {Dichte von Aluminium und Folie}
  dAL,dFol : Double; {Dicke der Aluminium-Kondensatorplatten und der Folie}
  D : Double; {Federsteifigkeit der Federn zwischen den Kondensatorplatten}
  m : Double; {(mechanische) Masse der Aluminium-Kondensatorplatten}
  omfol,fFol : Double;
  {Eigenkreisfrequenz und Eigenfrequenz der Kondensatorplatten-Schwingung}
  F : Double; {Anziehungskraft zwischen den Kondensatorplatten}
  Stern1 : Double; {Hilfsvariable}
  Fc,Fd : Double; {Kräfte: Coulombkraft und Federkraft}
  MacheFiles : Boolean;
  {Sollen die Ergebnisse auf die Magnetplatte geschrieben werden ?}
  om : Double; {Kreisfrequenz Omega}
  Rlast : Double; {Elektrischer Lastwiderstand}
Procedure Wait;

Var Ki : Char;
Begin
  Write('<W>');
  Read(Ki);
  Write(Ki);
  If Ki='e' Then Halt;
End;
Procedure Excel_Datenausgabe(Name:String);

Var fout : Text; {Daten-File zum Aufschreiben der Ergebnisse}
  Zahl : String;
  lv,j : Integer; {Laufvariable}
  A0 : Double; {abklingende Amplitude der gedämpften Schwingung}
Begin {Daten für Excel aufbereiten und ausgeben:}
  Assign(fout,Name);
  Rewrite(fout); {File öffnen}
  For lv:=0 To N Do {von "plotanf" bis "plotend"}
    Begin
      If (lv Mod Abstd)=0 Then
        Begin
{ Zuerst die Zeit als Argument:}
          Str(lv*dt*1e6{nafo_sec.}:14:10,Zahl);
          For j:=1 To Length(Zahl) Do
            Begin {Keine Dezimalpunkte verwenden, sondern Kommata}
              If Zahl[j]<>'.' Then write(fout,Zahl[j]);
              If Zahl[j]='.' Then write(fout,',');
            End;
          Write(fout,chr(9)); {Daten-Trennung}
{ Dann als (erste) Funktion die Spannung über dem Kondensator:}
          Str(Q[lv]/C{Volt}:14:7,Zahl);
          For j:=1 To Length(Zahl) Do
            Begin {Keine Dezimalpunkte verwenden, sondern Kommata}
              If Zahl[j]<>'.' Then write(fout,Zahl[j]);
              If Zahl[j]='.' Then write(fout,',');
            End;
          Write(fout,chr(9)); {Daten-Trennung}
{ Dann als (zweite) Funktion die Einhüllende der abklingenden Schwingung:}
          A0 := Q[0]/C/sin(arctan(sqrt(1/L/C-R*R/4/L/L)/(R/2/L))); {klassische}
          Str(A0*exp(-R/2/L*lv*dt){Volt}: 20: 10,Zahl); {Formeln}
          For j:=1 To Length(Zahl) Do
            Begin {Keine Dezimalpunkte verwenden, sondern Kommata}
              If Zahl[j]<>'.' Then write(fout,Zahl[j]);
              If Zahl[j]='.' Then write(fout,',');
            End;
          Writeln(fout,''); {Zeilen-Trennung}
        End;
    End;
  Close(fout);
End;
Procedure Excel_andere_Ausgabe(Name:String);

Var fout : Text; {Daten-File zum Aufschreiben der Ergebnisse}
  Zahl : String;
  lv,j : Integer; {Laufvariable}
Begin {Daten für Excel aufbereiten und ausgeben:}
  Assign(fout,Name);
  Rewrite(fout); {File öffnen}
  For lv:=0 To N Do {von "plotanf" bis "plotend"}
    Begin
      If (lv Mod Abstd)=0 Then
        Begin
{ Zuerst die Zeit als Argument:}
          Str(lv*dt*1e6{nano_sec.}:14:10,Zahl);
          For j:=1 To Length(Zahl) Do
            Begin {Keine Dezimalpunkte verwenden, sondern Kommata}
              If Zahl[j]<>'.' Then write(fout,Zahl[j]);
              If Zahl[j]='.' Then write(fout,',');
            End;
          Write(fout,chr(9)); {Daten-Trennung}
{ Erste Funktion: }
          Str(x[lv]{Volt}:20:14,Zahl);
          For j:=1 To Length(Zahl) Do
            Begin {Keine Dezimalpunkte verwenden, sondern Kommata}
              If Zahl[j]<>'.' Then write(fout,Zahl[j]);
              If Zahl[j]='.' Then write(fout,',');
            End;
          Write(fout,chr(9)); {Daten-Trennung}
{ Zweite Funktion: }
          Str(Q[lv]*1E6{Volt}:20:14,Zahl);
          For j:=1 To Length(Zahl) Do
            Begin {Keine Dezimalpunkte verwenden, sondern Kommata}
              If Zahl[j]<>'.' Then write(fout,Zahl[j]);
              If Zahl[j]='.' Then write(fout,',');
            End;
          Writeln(fout,''); {Zeilen-Trennung}
        End;
    End;
  Close(fout);
End;
Procedure Excel_Raumenergieausgabe(Name:String);

Var fout : Text; {Daten-File zum Aufschreiben der Ergebnisse}
  Zahl : String;
  lv,j : Integer; {Laufvariable}
Begin {Daten für Excel aufbereiten und ausgeben:}
  Assign(fout,Name);
  Rewrite(fout); {File öffnen}
  For lv:=0 To N Do {von "plotanf" bis "plotend"}
    Begin
      If (lv Mod Abstd)=0 Then
        Begin
{ Zuerst die Zeit als Argument:}
          Str(lv*dt*1e6{nano_sec.}:14:10,Zahl);
          For j:=1 To Length(Zahl) Do
            Begin {Keine Dezimalpunkte verwenden, sondern Kommata}
              If Zahl[j]<>'.' Then write(fout,Zahl[j]);
              If Zahl[j]='.' Then write(fout,',');
            End;
          Write(fout,chr(9)); {Daten-Trennung}
{ Dann als (erste) Funktion die Spannung über dem Kondensator:}
          Str(x[lv]{Volt}:14:7,Zahl);
          For j:=1 To Length(Zahl) Do
            Begin {Keine Dezimalpunkte verwenden, sondern Kommata}
              If Zahl[j]<>'.' Then write(fout,Zahl[j]);
              If Zahl[j]='.' Then write(fout,',');
            End;
          Writeln(fout,''); {Zeilen-Trennung}
        End;
    End;
  Close(fout);
End;
Procedure Excel_eine_Kolumne(Name:String);

Var fout : Text; {Daten-File zum Aufschreiben der Ergebnisse}
  Zahl : String;
  lv,j : Integer; {Laufvariable}
Begin {Daten für Excel aufbereiten und ausgeben:}
  Assign(fout,Name);
  Rewrite(fout); {File öffnen}
  For lv:=0 To N Do {von "plotanf" bis "plotend"}
    Begin
      If (lv Mod Abstd)=0 Then
        Begin
          Str(x[lv]{Volt}:20:14,Zahl);
          {Hier trage ich das zu plottende Feld ein.}
          For j:=1 To Length(Zahl) Do
            Begin {Keine Dezimalpunkte verwenden, sondern Kommata}
              If Zahl[j]<>'.' Then write(fout,Zahl[j]);
              If Zahl[j]='.' Then write(fout,',');
            End;
          Writeln(fout,''); {Zeilen-Trennung}
        End;
    End;
  Close(fout);
End;
Function Plapos(z:LongInt): Double;
{Iterative Ermittlung der Position der Kondensatorplatten.}

Var xs : Double; {Startwert}
  sw : Double; {Schrittweite}
  an,ab : Boolean;
Begin
  xs := 0;
  If z=0 Then xs := CD/2; {Die Position der beiden Platten liegt bei +/-xs.}
  If z>0 Then xs := x[z-1];
  {Dies kann ggf. vom vorigen Arbeitsschritt übernommen werden.}
  sw := xs/20;
  Repeat
    sw := sw/10;
    an := false;
    ab := false;
    Repeat
      Fc := 1/4/pi/epo*q[z]*q[z]/(2*xs)/(2*xs);
      Fd := D*(xs-CD/2); {Die Feder wird gegenüber CD ausgelenkt.}
      If Fc+Fd>0 Then
        Begin
          xs := xs-sw;
          an := true;
        End;
      If Fc+Fd<0 Then
        Begin
          xs := xs+sw;
          ab := true;
        End;
      If xs<=1e-10 Then
        Begin
          Writeln (
        'Plattenberuehrung. Coulombkraft ist zu stark. Algorithmus abgebrochen.'
          );
          Wait;
          Wait;
          Halt;
        End;
    Until (an And ab);
  Until (sw<xs/1e14);
  Plapos := xs;
End;
Procedure Amplituden_anzeigen;

Var i : Integer;
  schreibe : Boolean;
  SteigX,SteigQ : Boolean;
  BildX,BildQ : Array[0..200] Of Double;
  zvx,zvQ : Integer;
  eq,lq,ex,lx : Double;
  Wmech1,Wmech2,Wel1,Wel2: Double;
Begin
{ Zuerst die x-Amplituden:}
  SteigX := false;
  If x[1]>x[0] Then SteigX := true;
  schreibe := false;
  zvx := 0;
  Writeln(' I: t/[sec.] | x/[m] | Q[i]');
  For i:=1 To N Do
    Begin
      If SteigX Then
        Begin
          If x[i]<x[i-1] Then
            Begin
              schreibe := true;
              SteigX := Not(SteigX);
              Write('X-Max:');
            End;
        End;
      If Not(SteigX) Then
        Begin
          If x[i]>x[i-1] Then
            Begin
              schreibe := true;
              SteigX := Not(SteigX);
              Write('X-Min:');
            End;
        End;
      If schreibe Then
        Begin
          Writeln(i:6,': ',i*dt:7:5,' | ',x[i],' |',Q[i]); {Wait;}
          BildX[zvx] := x[i];
          zvx := zvx+1;
        End;
      schreibe := false;
    End;
  zvx := zvx-1;
{ Danach die Q-Amplituden:}
  SteigQ := false;
  If Q[1]>Q[0] Then SteigQ := true;
  schreibe := false;
  zvQ := 0;
  Writeln(' I: t/[sec.] | x/[m] | Q[i]');
  For i:=1 To N Do
    Begin
      If SteigQ Then
        Begin
          If Q[i]<Q[i-1] Then
            Begin
              schreibe := true;
              SteigQ := Not(SteigQ);
              Write('Q-Max:');
            End;
        End;
      If Not(SteigQ) Then
        Begin
          If Q[i]>Q[i-1] Then
            Begin
              schreibe := true;
              SteigQ := Not(SteigQ);
              Write('Q-Min:');
            End;
        End;
      If schreibe Then
        Begin
          Writeln(i:6,': ',i*dt:7:5,' | ',x[i],' |',Q[i]); {Wait;}
          BildQ[zvQ] := Q[i];
          zvQ := zvQ+1;
        End;
      schreibe := false;
    End;
  zvQ := zvQ-1;
{ Jetzt der Überblick über "Spitze-Spitze":}
  Writeln('Orte, Spitze-Spitze:');
  i := 2;
  ex := BildX[i]-BildX[i-1];
  Repeat
    Writeln(i,': ',BildX[i]-BildX[i-1]);
    lx := BildX[i]-BildX[i-1];
    i := i+2;
  Until (i>=zvx);
  Writeln('Ladungen, Spitze-Spitze:');
  i := 2;
  eq := BildQ[i]-BildQ[i-1];
  Repeat
    Writeln(i,': ',BildQ[i]-BildQ[i-1]);
    lq := BildQ[i]-BildQ[i-1];
    i := i+2;
  Until (i>=zvQ);
  Write('Gesamtaenderung, Orts-Amplitude: ');
  If Abs(lx)>Abs(ex) Then Write('+');
  If Abs(lx)<Abs(ex) Then Write('-');
  om := pi*zvx/N/dt;
  Writeln('Kreisfrequenz omega= ',om);
  Writeln(Abs(lx-ex));
  Wmech1 := m/2*(ex*ex)*om*om;
  Wmech2 := m/2*(lx*lx)*om*om;
  Writeln('Mechanische Energie zu Beginn: ',Wmech1,' Joule');
  Writeln('Mechanische Energie am Ende: ',Wmech2,' Joule');
  Writeln('Mechan. Energie-Veränderung: ',Wmech2-Wmech1,' Joule');
  Write('Gesamtaenderung, Ladg-Amplitude: ');
  If Abs(lq)>Abs(eq) Then Write('+');
  If Abs(lq)<Abs(eq) Then Write('-');
  Writeln(Abs(lq-eq));
  Wel1 := L/2*(eq*eq)*om*om;
  Wel2 := L/2*(lq*lq)*om*om;
  Writeln('Elektrische Energie zu Beginn: ',Wel1,' Joule');
  Writeln('Elektrische Energie am Ende: ',Wel2,' Joule');
  Writeln('Elektr. Energie-Veränderung: ',Wel2-Wel1,' Joule');
  Writeln;
  Writeln('Summe: Gesamt-Energiegewinn: ',Wmech2-Wmech1+Wel2-Wel1,' Joule');
  Writeln;
End;
Procedure Leistung_berechnen;
{Über dem Lastwiderstand "Rlast", als Integralmittelwert}

Var i : Integer;
  P : Double; {Leistung im Zeitintervall dt}
  Eges: Double; {Gesamtenergie über den gesamten Zeitraum}
Begin
  Eges := 0;
  For i:=0 To N Do
    Begin
      P := +Rlast*Qp[i]*Qp[i];
      Eges := Eges+P*dt;
    End;
  Writeln('Eges= ',Eges, ' Joule in ',N*dt,' sec.');
  Writeln('=> Leistung Pmittel= ',Eges/(N*dt),' Watt');
End;
Begin {Hauptprogramm}
{ Initialisierung - Vorgabe der Werte: }
{ Allgemeine Werte: }
  epo := 8.854187817E-12{As/Vm}; {Magnetische Feldkonstante}
  muo := 4*pi*1E-7{Vs/Am}; {Elektrische Feldkonstante}
  v := Sqrt(1/muo/epo){m/s};
  {Zunächst Lichtgeschw. als Bewegungsgeschw. der Ladungen}
  Abstd := 1; {Jeder wievielte Punkte soll geplottet werden}
{ Kondensator: }
  CA := 0.1*0.1{m²};
  CD := 0.002{m}; {Kondensator-Geometrie, Plattenfläche, Plattenabstand}
  epr := 3; {Dielektrikum im Kondensator}
  C := epo*epr*CA/CD; {Kapazität des unverformten Platten-Kondensators}
{ Spule: }
  SN := 34600;
  SL := 0.08{m};
  SR := 0.05{m};
  SA := pi*SR*SR{m²}; {Spulen-Geometrie}
{}
  mur := 12534; {Spulenkern ist nötig, zur Abstimmung der Frequenz}
  L := muo*mur*SN*SN*SA/SL; {Induktivität}
  rho := 1.7E-8{Ohm*m};
  {Spez. Widerstand von Kupfer, je nach Temperatur, Kohlrausch,T193}
  AD := pi*0.0002*0.0002{m²}; {Querschnittsfläche des Spulendrahtes}
  R := rho*2*pi*SR*SN/AD{Ohm}; {Ohm`scher Widerstand des Spulendrahtes}
  DL := SN*2*pi*SR; {Drahtlänge des Spulendrahtes}
{ Mechanische Schwingung der Kondensatorplatten:}
  rhoAL := 2700{kg/m³}; {Dichte von Aluminium}
  rhoFol := 1500{kg/m³}; {Dichte der Kunststoff-Folie}
{}
  dAL := 2e-6{m}; {Dicke der Aluminium-Kondensatorplatten: 10_Mü}
  dFol := 10e-6{m}; {Dicke der Kunststoff-Folie: 10_Mü}
{}
  D := 1.0{N/m}; {Federsteifigkeit der Federn zwischen den Kondensatorplatten}
  m := CA*dAL*rhoAL+CA*dFol*rhoFol;
  {(mechanische) Masse der Aluminium-Kondensatorplatten}
  omFol := Sqrt(D/m);
  {Schwingungs-Eigenkreisfrequenz der Kondensatorplatten_Folie}
  fFol := omFol/2/pi; {Schwingungseigenfrequenz der Kondensatorplatten_Folie}
{ Bewußte Erzeugung von Leistung:}
  Rlast := 0; {Ohm} {Elektrischer Lastwiderstand}
{ Start der elektrischen Schwingung: }
{}
  Q[0] := 2E-10{C};
  Qp[0] := 0;
  Qpp[0] := 0; {Ladung auf dem Kondensator zu Beginn}
  UC := Q[0]/C{V};
  {Spannung über dem Kondensator zu Beginn, das Dielektrikum isoliert}
  dt := 3.53E-4{sec.}; {Zeitschritte}
  N := 30000; {Anzahl der Zeitschritte insgesamt}
{ Start der mechanischen Schwingung: }
  x[0] := Plapos(0); {Iterative Ermittlung der Position der Kondensatorplatten.}
  GG3 := x[0];
 {Gleichgewichtsposition der flexiblen Platten, Teil 3, Federkraft=Coulombkraft}
  SP3 := CD/2;
 {Vorgabe:Plattenabstand mit flexiblen Platten, Teil 3, mechanische Vorspannung}
  F := 1/4/pi/epo*Q[0]*Q[0]/(2*x[0])/(2*x[0]);
  {Anziehung nach dem Coulomb-Gesetz}
{Der Ort jeder Platte liegt bei CD/2+x[i]}
  xp[0] := 0;
  xpp[0] := 0; {Festhalten der Platten bis zum Zeitpunkt t=0}
  MacheFiles := true;
  {Sollen die Ergebnisse auf die Magnetplatte geschrieben werden ?}
{ Anzeigen der Startwerte:}
  Writeln('DFEM-Berechnung des LC - Schwingkreises:');
  Writeln;
  Writeln('epo=',epo:20,'; muo=',muo:20,'; v=',v:20);
  Writeln('C=',C:20,' Farad; L=',L:20,' Henry');
  Writeln('Klass. Schwingkreis, Eingenfrequ. fo=2*pi/Sqrt(L*C)=',2*pi/Sqrt(L*C),
  ' Hz');
  Writeln(' ==> Schwingungsdauer T=1/fo=',2*pi*Sqrt(L*C),' sec.');
  Writeln('Ohm`scher Widerstand des Spulendrahtes:',R,' Ohm');
  Writeln('Drahtlaenge des Spulendrahtes:',DL,' Meter');
  Writeln('Querschnittsfläche des Spulendrahtes:',AD*1e6:10:5,' mm^2');
  Writeln('Volumen der Spule: ',DL*AD*1E6:10:5,' cm^3');
  Writeln('Gewicht der Spule: ',DL*AD*1E6*8.92:10:5,' Gramm');
  {Dichte Cu: 8.92 g/cm^3}
  Writeln('Spannung ueber dem Kondensator zu Beginn:',UC:12:5,' Volt');
  Writeln('Ges. Zeitspanne der Berechnung: ',N*dt,' sec. in ',N,' Schritten');
  Writeln;
  Writeln('Daten der mechanischen Schwingung der Kondensatorplatten:');
  Writeln('Masse der Kondensatorplatten m= ',m*1000:10:5,' Gramm');
  Writeln('Schwingungseigenfrequenz der Kondensatorplatten: fFol= ',fFol:10:7,
          ' Hz.');
  Writeln('Anziehung jeder Kondensatorplatte zu Beginn: Kraft F= ',F,' N');
  Writeln('Verformung jeder Kondensatorplatte zu Beginn: F/D= ',F/D,' m');
  Writeln('Plattenposition der ungeladenen Kondensatorplatten: ',CD/2);
  Writeln('Plattenposition, geladen, zu Beginn: X[0]: ',X[0]);
  Writeln('Genauigkeit der Plattenposition => Differenzkraft: ',Fc+Fd,' N');
  Writeln('Startposition der Platten für die Schwingg, Teil 3: ',SP3:10:7,' m')
  ;
  Writeln('Kapazitaet des unverformten Kondensators: C= ',epo*epr*CA/CD,' Farad'
  );
  Writeln('Kapazitaet des verformten Kondensators: C[0]= ',epo*epr*CA/(2*x[0]),
  ' Farad');
  Writeln('Dabei: Erhöhung der Kapazitaet um ',epo*epr*CA*(1/2/x[0]-1/CD),
  ' Farad');
  Writeln('Gesamtdauer der Berechnung: ',N*dt,' sec.');
  Writeln; {Wait;}
{ Beginn des Rechenprogramms.}
  Writeln('1.Teil -> Klassische Harmonische Schwingung, ohne Dämpfung:');
  Writeln(' t/[sec.] | Uc/[V] | ');
  For i:=1 To N Do
    Begin
      UC := Q[i-1]/C;
      UL := -UC;
      Qpp[i] := UL/L;
      Qp[i] := Qp[i-1]+Qpp[i]*dt;
      Q[i] := Q[i-1]+Qp[i]*dt;
{ Writeln(i*dt:11:9,' | ',Q[i]/C:7:2,' |'); }
    End;
  If MacheFiles Then Excel_Datenausgabe('Teil_01.dat');
  Writeln;
{---------------------------------------------------------------}
  Writeln(
         '2.Teil -> Klassische Gedaempfte Schwingung, mit Ohm`schem Widerstand:'
  );
  Writeln(' t/[sec.] | Uc/[V] | ');


  {R:=2000; {Erhöhter Widerstandswert zum Testen}
  For i:=1 To N Do
    Begin
      Qpp[i] := -1/L/C*Q[i-1]-R/2/L*Qp[i-1];
{ Qp[i]:=(Qp[i-1]+Qpp[i]*dt)/(1+R/L*dt); } {alternative einfachere Näherung}
      Qp[i] := Qp[i-1]+(Qpp[i]-R/2/L*Qp[i-1])*dt; {vgl. s=1/2*a*t^2}
      Q[i] := Q[i-1]+Qp[i]*dt;
{ Writeln(i*dt:11:9,' | ',Q[i]/C:7:2,' |'); }
    End;
  If MacheFiles Then Excel_Datenausgabe('Teil_02.dat');
  Writeln;
{---------------------------------------------------------------}
  Writeln(
       '3.Teil -> Schwingung mit geladenem Kondensator und Raumenergie-Wandlung'
  );
{ Writeln(' t/[sec.] | x/[m] | Q[i]'); }
  x[0] := SP3;
  {Startposition der Kondensatorplatten für die mechanische Schwingung}
  For i:=1 To N Do
    Begin
      Fd := -D*(x[i-1]-CD/2); {Federkraft gegenüber CD}
      Fc := -Q[0]*Q[0]/4/pi/epo/(2*x[i-1])/(2*x[i-1]); {Coulombkraft}
      xpp[i] := (Fc+Fd)/m; {Beschleunigung}
      xp[i] := xp[i-1]+xpp[i]*dt;
      x[i] := x[i-1]+xp[i]*dt;
      If x[i]<=1e-10 Then
        Begin
          Writeln (
        'Plattenberuehrung. Coulombkraft ist zu stark. Algorithmus abgebrochen.'
          );
          Wait;
          Wait;
          Halt;
        End;
      C := epo*epr*CA/(2*x[i]);
      Qpp[i] := -1/L/C*Q[i-1]-(R+Rlast)/2/L*Qp[i-1];
      Qp[i] := Qp[i-1]+(Qpp[i]-(R+Rlast)/2/L*Qp[i-1])*dt;
      Q[i] := Q[i-1]+Qp[i]*dt;
{ Writeln(i*dt:11:9,' | ',x[i],' |',Q[i]);}
    End;
  If MacheFiles Then Excel_andere_Ausgabe('Teil_03.dat');
  Writeln;
  Amplituden_anzeigen;
  Leistung_berechnen;
{---------------------------------------------------------------}
  Wait;
  Wait;
End.
