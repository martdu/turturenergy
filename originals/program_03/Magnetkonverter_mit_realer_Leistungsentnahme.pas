
Program Magnetkonverter_mit_realer_Leistungsentnahme;
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

Const AnzPmax = 10000; {Anzahl der Zeitschritte zur Lsg. der Dgl.}

Type Feld = Array[0..AnzPmax] Of Double;

Var epo,muo : Double; {Naturkonstanten}
  lichtgesch : Double; {Lichtgeschwindigkeit}
  n : LongInt; {Windungszahl der Spule}
  A : Double; {Querschnittsfläche der Spule}
  Bo : Double; {Magnetfeld (Amplitude) des Dauermagneten}
  ls : Double; {Länge der zylindrischen Spule}
  di : Double; {Durchmesser des Spulenkörpers}
  Dd : Double; {Drahtdurchmesser}
  rm : Double; {Radius des Dauermagneten}
  L : Double; {Induktivität der Spule}
  C : Double; {Kapazität des Kondensators}
  R : Double; {Ohm`scher Widerstand des Spulendrahtes}
  rho : Double; {Spez. Widerstand von Kupfer, je nach Temperatur, Kohlrausch,T193}
  phi,phip,phipp : Feld; {Drehwinkel und dessen Ableitungen}
  Q,Qp,Qpp : Feld; {Ladung und deren Ableitungen}
  i : LongInt; {Laufvariable}
  AnzP : LongInt; {Anzahl der tatsächlich berechneten Zeit-Schritte}
  dt : Double; {Dauer der Zeitschritte zur Lsg. der Dgl.}
  Abstd : Integer; {Jeder wievielte Punkte soll geplottet werden}
  omo : Double; {Kreis-Eigenfrequenz des elektrischen Schwingkreises}
  T : Double; {Schwingungsdauer des elektrischen Schwingkreises}
  UC,UL : Double; {Kondensatorspannung und Spulenspannung}
  rhom : Double; {Dichte des Magnetmaterials}
  dm : Double; {Dicke des zylindrischen Dauermagneten}
  mt : Double; {Träge Masse des zylindrischen Dauermagneten}
  J : Double; {Trägheitsmoment des zylindrischen Dauermagneten}
  K0,K1,K2,K3,K4,K5 : Feld; {Kontroll-Felder für Plot-Zwecke}
  EmA,EmE,siA,siE : Double; {Energie: Mittelwerte und Sigma "Anfang" und "Ende"}
  delE,sigdelE : Double; {Veränderung der Energie-Mittelwerte "Anfang" zu "Ende"}
  UmAn : Double; {Startwert: Umdrehungen pro Sekunde bei Anlaufen des Rotors}
  Eent : Double; {Entnommene Energie, elektrisch}
  Rlast : Double; {Ohm'scher Lastwiderstand}
Procedure Wait;

Var Ki : Char;
Begin
  Write('<W>');
  Read(Ki);
  Write(Ki);
  If Ki='e' Then Halt;
End;
Procedure ExcelAusgabe(Name:String;Spalten:Integer;KA,KB,KC,KD,KE,KF,KG,KH,KI,KJ,KK,KL:Feld);

Var fout : Text; {Bis zu 12 Spalten zum Aufschreiben der Ergebnisse}
  lv,j,k : Integer; {Laufvariable}
  Zahl : String; {Die ins Excel zu druckenden Zahlen}
Begin
  Assign(fout,Name);
  Rewrite(fout); {File öffnen}
  For lv:=0 To AnzP Do {von "plotanf" bis "plotend"}
    Begin
      If (lv Mod Abstd)=0 Then
        Begin
          For j:=1 To Spalten Do
            Begin {Kolumnen drucken}
              If j=1 Then Str(KA[lv]:19:14,Zahl);
              If j=2 Then Str(KB[lv]:19:14,Zahl);
              If j=3 Then Str(KC[lv]:19:14,Zahl);
              If j=4 Then Str(KD[lv]:19:14,Zahl);
              If j=5 Then Str(KE[lv]:19:14,Zahl);
              If j=6 Then Str(KF[lv]:19:14,Zahl);
              If j=7 Then Str(KG[lv]:19:14,Zahl);
              If j=8 Then Str(KH[lv]:19:14,Zahl);
              If j=9 Then Str(KI[lv]:19:14,Zahl);
              If j=10 Then Str(KJ[lv]:19:14,Zahl);
              If j=11 Then Str(KK[lv]:19:14,Zahl);
              If j=12 Then Str(KL[lv]:19:14,Zahl);
              For k:=1 To Length(Zahl) Do
                Begin {Keine Dezimalpunkte verwenden, sondern Kommata}
                  If Zahl[k]<>'.' Then write(fout,Zahl[k]);
                  If Zahl[k]='.' Then write(fout,',');
                End;
              Write(fout,chr(9)); {Daten-Trennung, Tabulator}
            End;
          Writeln(fout,''); {Zeilen-Trennung}
        End;
    End;
  Close(fout);
End;
Begin {Hauptprogramm}
{ Initialisierung - Vorgabe der Werte: } {Wir arbeiten in SI-Einheiten}
  Writeln('Raumenergie-Konverter mit Rotation.');
{ Vorgabe der Werte -> Input-Parameter:}
  epo := 8.854187817E-12{As/Vm}; {Magnetische Feldkonstante}
  muo := 4*pi*1E-7{Vs/Am}; {Elektrische Feldkonstante}
  lichtgesch := Sqrt(1/muo/epo){m/s};
  Writeln('Lichtgeschwindigkeit c = ',lichtgesch, ' m/s');
{ Spule, Magnet, Kondensator:}
  n := 1600; {Windungszahl der Spule}
  di := 0.09; {Spulenkörper-Durchmesser}
  Dd := 0.0010; {Drahtdurchmesser}
  Bo := 0.700; {Tesla} {Magnetfeld (Amplitude) des Dauermagneten}
  ls := 0.01; {Meter} {Länge des zylindrischen Spulenkörpers}
  C := 0.23E-6; {Farad} {Kapazität des Kondensators}
  rm := 0.039; {Meter} {Radius des zylindrischen Dauermagneten}
  dm := 0.01; {Meter} {Dicke des zylindrischen Dauermagneten}
  rhom := 7.8E3; {Dichte des Magnet-Materials, Eisen, Kohlrausch Bd.3}
{ Abgeleitete Parameter, keine Eingabe möglich:}
  A := di*di; {Meter * Meter} {Querschnittsfläche der Spule}
  L := muo*a*n*n/ls; {Induktivität der Spule}
  omo := 1/Sqrt(L*C); {Kreis-Eigenfrequenz des elektrischen Schwingkreises}
  T := 2*pi/omo; {Schwingungsdauer des elektrischen Schwingkreises}
  rho := 1.7E-8; {Ohm*m} {Spez. Widerstand von Kupfer, je nach Temperatur, Kohlrausch,T193}
  R := rho*(2*pi*di*n)/(pi*(Dd/2)*(Dd/2)); {Ohm} {Ohm`scher Widerstand des Spulendrahtes}
{ Sonstige:}
  UmAn := 100; {Startwert: Umdrehungen pro Sekunde bei Anlaufen des Rotors}
  Rlast := 28; {Ohm'scher Lastwiderstand}
  AnzP := AnzPmax; {Anzahl der Zeitschritte insgesamt}
  dt := 0.0001; {sec.} {Größe der Zeitschritte}
  Abstd := 1; {Jeder wievielte Punkte soll geplottet werden}
  mt := pi*rm*rm*dm*rhom; {Träge Masse des zylindrischen Dauermagneten}
  J := 1/2*mt*rm*rm; {Trägheitsmoment des zylindrischen Dauermagneten}
{ Anzeige der Werte:}
  Writeln('Induktivitaet der Luft-Spule: L = ',L,' Henry');
  Writeln('Eigen-Kreisfreq harmon.el.Osz.: omo = ',omo:8:4,' Hz => T = ',T:15,'sec.');
  Writeln('Laenge des Spulendrahts: ',(2*pi*di*n),' m');
  Writeln('Ohm`scher Widerstand des Spulendrahts: R = ',R:8:2,' Ohm');
  Writeln('Traege Masse des zylindrischen Dauermagneten: mt = ',mt,' kg');
  Writeln('Traegheitsmoment des Dauermagneten: J = ',J,' kg*m^2');
  Writeln('Gesamtdauer der Betrachtung: ',AnzP*dt,' sec.');
{ Hier beginnt das Rechenprogramm.}
  Writeln('Mechanisch und elektrisch gekoppelte Schwingung.');
  UC := 0;{Volt}
  Q[0] := C*UC;
  Qpp[0] := 0;
  Qp[0] := 0; {Elektrische Startwerte}
  phi[0] := 0;
  phip[0] := UmAn*2*pi;
  phipp[0] := 0; {Mechanische Startwerte}
  Eent := 0; {Reset für: Entnommene Energie, elektrisch}
  K0[0] := 0;
  K1[0] := 1/2*L*Sqrt(Qp[0]); {Spulen-Energie}
  K2[0] := 1/2*C*Sqr(Q[0]/C); {Kondensator-Energie}
  K3[0] := 1/2*J*Sqr(phip[0]); {Rotations-Energie}
  K4[0] := K1[0]+K2[0]+K3[0]; {Gesamt-Energie}
  K5[0] := 0;
  For i:=1 To AnzP Do
    Begin
      Qpp[i] := -1/L/C*Q[i-1]-(R+Rlast)/2/L*Qp[i-1]; {nach *5 von S.6}
      Qpp[i] := Qpp[i]+n*Bo*A*sin(phi[i-1])*phip[i-1]/L; {Induzierte Spannung in Spule bringen.}
      Qp[i] := Qp[i-1]+(Qpp[i]-R/2/L*Qp[i-1])*dt; {nach *3 & *4 von S.6}
      Q[i] := Q[i-1]+Qp[i]*dt;
      phipp[i] := -Bo*n*Qp[i]*A/J*sin(phi[i-1]); {Mechanisches Drehmoment, x-Komponente}
      phip[i] := phip[i-1]+phipp[i]*dt;
      phi[i] := phi[i-1]+phip[i]*dt;
      K0[i] := 0;
      K1[i] := 1/2*L*Sqr(Qp[i]); {Spulen-Energie}
      K2[i] := 1/2*C*Sqr(Q[i]/C); {Kondensator-Energie}
      K3[i] := 1/2*J*Sqr(phip[i]);{Rotations-Energie}
      K4[i] := K1[i]+K2[i]+K3[i]; {Gesamt-Energie}
      K5[i] := Rlast*Sqr(Qp[i]); {Am Lastwiderstand entnommene Leistung}
      Eent := Eent+K5[i]*dt; {Am Lastwiderstand entnommene Energie}
    End;
{ Gesamt-Energie-Bilanz und Anzeige:}
  EmA := 0;
  EmE := 0;
  siA := 0;
  siE := 0;
  For i:=1 To 10 Do
    EmA := EmA+K4[i]/10; {Mittelwert zu Beginn}
  For i:=AnzP-9 To AnzP Do
    EmE := EmE+K4[i]/10; {Mittelwert am Ende}
  For i:=1 To 10 Do
    siA := siA+Sqr(EmA-K4[i]); {Varianz zu Beginn}
  For i:=AnzP-9 To AnzP Do
    siE := siE+Sqr(EmE-K4[i]); {Varianz am Ende}
  siA := Sqrt(siA)/10;
  siE := Sqrt(siE)/10; {Standardabweichungen}
  Writeln('Energie-Werte: E_Anfang = (',EmA:11:7,' +/- ',siA:11:7,') Joule');
  Writeln(' E_Ende = (',EmE:11:7,' +/- ',siE:11:7,') Joule');
  delE := EmE-EmA;
  sigdelE := Sqrt(Sqr(siE)+Sqr(siA));
  Writeln('=> Veraenderung: delta_E = (',delE:11:7,' +/- ',sigdelE:11:7,') Joule');
  Writeln('=> Konvertierte Leistung = (',delE/(AnzP*dt): 11: 7,' +/- ',sigdelE/(AnzP*dt): 11: 7,')Watt');
  Writeln('An Rlast entnom.Leistung = ',Eent/(AnzP*dt): 11: 7,' Watt');
  ExcelAusgabe('test_04.dat',12,Q,Qp,Qpp,phi,phip,phipp,K0,K1,K2,K3,K4,K5);
  Wait;
  Wait;
End.
