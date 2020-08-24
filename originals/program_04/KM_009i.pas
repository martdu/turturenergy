Program KM_009i;
{$APPTYPE CONSOLE}
uses
Windows,
Messages,
SysUtils,
Classes,
Graphics,
Controls,
Forms,
Dialogs;
Const Bn=7; {Schritt-Anzahl der Magnetfeld-Speicherung nach *2 von S.2}
Const SpNmax=200; {Maximal mögliche Anzahl der Stützpunkte der Spulen (Inupt und Turbo)}
Const FlNmax=2000; {Maximal mögliche Anzahl der Flächenelemente der Spulen (Inupt und Turbo)}
Const MESEanz=200; {Tatsächliche Anzahl der Magnetfeld-Emulations-Spulen-Elemente, gerade Anzahl wählen}
Const AnzPmax=35000; {Dimensionierung der Arrays für den Plot (für den Datenexport nach Excel)}
Var epo,muo : Double; {Naturkonstanten}
Bsw : Double; {Schritt-Weite der Magnetfeld-Speicherung nach *1 von S.2}
Spsw : Double; {Schritt-Weite der Spulen-Aufgliederung nach *2 von S.1}
SpN : Integer; {Anzahl der Stützpunkte der Spulen}
FlN : Integer; {Anzahl der Flächenelemente der Spulen}
LiGe : Double; {Lichtgeschwindigkeit}
xo,yo,zo : Integer; {Geometrieparameter nach Zeichnung *2 von S.1}
Ninput : Integer; {Zahl der Wicklungen der Input-Spule}
Nturbo : Integer; {Zahl der Wicklungen der Turbo-Spule}
PsiSFE : Double; {magnetischer Fluß durch ein Spulen-Flächenelement}
PsiGES : Double; {magnetischer Fluß durch die gesamte Spule}
B1,B2,B3,B4,B5 : Double; {Fourier-Koeffizienten, allgemein}
B1T,B2T,B3T,B4T,B5T : Double; {Fourier-Koeffizienten, Turbo-Spule}
B1I,B2I,B3I,B4I,B5I : Double; {Fourier-Koeffizienten, Input-Spule}
B1dreh,phase : Double; {Koeffizienten zur Drehmoments-Schnellberechnung}
MEyo, MEro, MEI : Double;{Abmessungen und Strom des Magnetfeld-Emulationsspulenpaares nach *1 von S.5}
Bx,By,Bz : Array [-Bn..Bn,-Bn..Bn,-Bn..Bn] of Double; {Kartes. Komp. der magn. Induktion, Dauermagnet}
MESEx,MESEy,MESEz : Array [1..MESEanz] of Double;{Orte der Magnetfeld-Emulations-Spulen-Elemente}
MESEdx,MESEdy,MESEdz : Array [1..MESEanz] of Double;{Laufrichtungen der Magnetfeld-Emulations-Spulen-
Elemente}
OrtBx,OrtBy,OrtBz : Array [-Bn..Bn,-Bn..Bn,-Bn..Bn] of Double; {Kartes. Komp. der Orte, an denen das
Feld Bx, By, Bz ist.}
SpIx,SpIy,SpIz : Array [1..SpNmax] of Double; {Stützpunkte der Polygonzüge der Input-Spule,
kartesische Koordinaten}
SpTx,SpTy,SpTz : Array [1..SpNmax] of Double; {Stützpunkte der Polygonzüge der Turbo-Spule,
kartesische Koordinaten}
SIx,SIy,SIz : Array [1..SpNmax] of Double; {Ort als Mittelpunkt der Leiterschleifen-Elemente}
STx,STy,STz : Array [1..SpNmax] of Double; {Ort als Mittelpunkt der Leiterschleifen-Elemente}
dSIx,dSIy,dSIz : Array [1..SpNmax] of Double; {Richtungsvektoren der Leiterschleifen-Elemente der
Input-Spule}
dSTx,dSTy,dSTz : Array [1..SpNmax] of Double; {Richtungsvektoren der Leiterschleifen-Elemente der
Turbo-Spule}
FlIx,FlIy,FlIz : Array [1..FlNmax] of Double; {Flächenelemente der Input-Spule, kartesische
Koordinaten}
FlTx,FlTy,FlTz : Array [1..FlNmax] of Double; {Flächenelemente der Turbo-Spule, kartesische
Koordinaten}
BxDR,ByDR,BzDR : Array [-Bn..Bn,-Bn..Bn,-Bn..Bn] of Double; {gedrehtes Magnetfeld}
OrtBxDR,OrtByDr,OrtBzDR : Array [-Bn..Bn,-Bn..Bn,-Bn..Bn] of Double; {gedrehte Ortsvektoren}
{Zum Lösen der Bewegungs-Differentialgleichung:}
phi,phip,phipp : Array[0..AnzPmax] of Double; {Drehwinkel und dessen Ableitungen}
Q,Qp,Qpp : Array[0..AnzPmax] of Double; {Ladung und deren Ableitungen in der Turbo-Spule}
QI,QpI,QppI : Array[0..AnzPmax] of Double; {Ladung und deren Ableitungen in der Input-Spule}
phio,phipo,phippo,phim,phipm,phippm : Double; {Winkel und dessen Ableitungen Index "io" und "io-1"}
qoT,qpoT,qppoT,qmT,qpmT,qppmT : Double; {Ladung und deren Ableitungen Index "io" und "io-1" in
Turbo-Spule}
qoI,qpoI,qppoI,qmI,qpmI,qppmI : Double;
{Ladung und deren Ableitungen Index "io" und "io-1" in Input-Spule}
PSIinput,PSIturbo : Array[0..AnzPmax] of Double; {Magnetischer Fluß in den Spulen: Input-Spule und
Turbo-Spule}
UindInput,UindTurbo : Array[0..AnzPmax] of Double; {Induzierte Spannung: Input-Spule und Turbo-Spule}
UinduzT,UinduzI : Double; {Induzierte Spannung zum "Jetzt-Zeitpunkt" in Input-Spule und Turbo-
Spule}
i : LongInt; {Laufvariable, u.a. zur Zählung der Zeitschritte beim Lösen der Dgl.}
AnzP,AnzPmerk : LongInt; {Anzahl der tatsächlich berechneten Zeit-Schritte beim Lösen der Dgl.}
dt : Double; {Dauer der Zeitschritte zur Lsg. der Dgl.}
PlotAnfang,PlotEnde,PlotStep : LongInt; {Zählung in "i": Anfang,Ende,Schrittweite des Daten-Exports
nach Excel}
Abstd : Integer; {Jeder wievielte Punkte soll geplottet werden}
znr : Integer; {Zählnummer für's Plotten der Daten ins Excel.}
LPP : Integer; {Letzter Plot-Punkt; der Wert wird für Datenausgabe benutzt.}
Zeit : Array[0..AnzPmax] of Double; {Zeitskala -> zum Transport der Ergebnisse ins Excel}
KG,KH,KI,KJ,KK,KL,KM,KN,KO,KP : Array[0..AnzPmax] of Double; {Felder zum Transport der Ergebnisse ins
Excel}
KQ,KR,KS,KT,KU,KV,KW,KX,KY,KZ : Array[0..AnzPmax] of Double; {Felder zum Transport der Ergebnisse ins
Excel}
BTx,BTy,BTz : Double; {Magnetfeld der Turbo-Spule an einem beliebigen Aufpunkt}
BIx,BIy,BIz : Double; {Magnetfeld der Input-Spule an einem beliebigen Aufpunkt}
merk : Double; {Für Test-Zwecke}
schonda : Boolean; {"schon da"-gewesen, die Daten wurden schon vorbereitet.}
DD,DLI,DLT : Double; {Durchmesser und Länge des Spulendrahtes zur Angabe der Drahtstärke}
rho : Double; {Ohm*m} {Spez. Widerstand von Kupfer, je nach Temperatur, Kohlrausch,T193}
RI,RT : Double; {Ohm'scher Widerstand der Spulen-Drähte}
CT : Double; {Farad} {Kapazität des Kondensators, er mit in der Turbo-Spule in Reihe
geschaltet}
CI : Double; {Farad} {Kapazität des Kondensators, er mit in der Input-Spule in Reihe
geschaltet}
LT,LI : Double; {Induktivität der Turbo-Spule und der Input-Spule}
nebeninput : Double; {Windungen nebeneinander in der Input-Spule}
ueberinput : Double; {Windungen uebereinander in der Input-Spule}
nebenturbo : Double; {Windungen nebeneinander in der Turbo-Spule}
ueberturbo : Double; {Windungen uebereinander in der Turbo-Spule}
BreiteI,HoeheI,BreiteT,HoeheT : Double; {Breite und Höhe der beiden Spulenlörper}
omT,TT : Double; {Kreis-Eigenfrequenz und Schwingungsdauer des Turbo-Spulen-Schwingkreises aus
LT & CT.}
UmAn,omAn : Double; {Umdrehungen pro Minute Startdrehzahl, und Winkelgeschwindigkeit rad/sec.
Startdrehzahl}
UmSec : Double; {Umdrehungen pro Sekunde Startdrehzahl}
J : Double; {Trägheitsmoment des Magneten bei Rotation}
rhoMag : Double; {Dichte des Magnet-Materials}
Mmag : Double; {Masse des Magneten}
Rlast : Double; {Ohm'scher Lastwiderstand im LC-Turbo-Schwingkreis}
Uc,Il : Double; {Anfangsbedingung elektrisch: Kondensatorspannung und Spulenstrom}
Tjetzt : Double; {Aktueller Zeitpunkt (beim Lösen der Dgl.)}
QTmax,QImax,QpTmax,QpImax,QppTmax,QppImax,phipomax : Double; {Maximalwerte finden für Strom-,
Drehzahl- und Spannungsangabe}
Wentnommen : Double; {entnommene Gesamtenergie}
AnfEnergie,EndEnergie : Double; {Energie-Vergleich im System}
steigtM,steigtO : Boolean; {steigt die Flanke eines Referenz-Signals (als und neu) ?}
Iumk : LongInt; {Lage des Umkehrpunktes als Referenz für das Input-Spannungs-Signal}
fkI,fkT : Double; {Korrekturfaktoren zur Induktivität lt. Stöcker S. 452}
Pzuf,Ezuf : Double; {Zugeführte Leistung und Energie über die Input-Spannung}
crAnfang,cr : Double; {Reibungs-Koeffizient für geschwindigkeits-proportionale Reibung}
phipZiel : Double; {Ziel-Drehzahl für die Reibungs-Nachregelung}
Preib : Double; {Über mechanische Reibung entnommene Leistung}
Ereib : Double; {Entnommene mechanische Energie, z.B. über Reibung}
Procedure Dokumentation_des_Ergebnisses;
Var fout : Text;
begin
Assign(fout,'Auswertung'); Rewrite(fout); {File öffnen}
Writeln(fout,'DFEM-Simulation eines EMDR-Motors.');
Writeln(fout,' ');
Writeln(fout,'Parameter zum Lösen der Dgl. und zur Darstellung der Ergebnisse:');
Writeln(fout,'AnzP = ',AnzP:12,' Zum Lösen der Dgl.: Anzahl der tatsächlich berechneten Zeit-Schritte');
Writeln(fout,'dt = ',dt:12,' {Sekunden} Dauer der Zeitschritte zur iterativen Lsg. der Dgl.');
Writeln(fout,'Abstd= ',Abstd:5,' {Nur Vorbereitung, nicht zum Lösen der Dgl.: Jeden wievielten Punkt
soll ich plotten ins Excel?');
Writeln(fout,'PlotAnfang = ',Round(PlotAnfang):10,' {Zum Lösen der Dgl.: Erster-Plot-Punkt: Anfang des
Daten-Exports nach Excel');
Writeln(fout,'PlotEnde = ',Round(PlotEnde):10,' {Zum Lösen der Dgl.: Letzter-Plot-Punkt: Ende des
Daten-Exports nach Excel');
Writeln(fout,'PlotStep = ',Round(PlotStep):10,' {Zum Lösen der Dgl.: Schrittweite des Daten-Exports
nach Excel');
Writeln(fout,' ');
Writeln(fout,'Es folgt die Eingabe der beiden Spulen, vgl. Zeichnung *2 von S.1 :');
Writeln(fout,'Die Spulen werden nach Vorgabe der Geometrieparameter automatisch vernetzt.');
Writeln(fout,'Spsw = ',Spsw:12:6,' Angabe in Metern: Die Spulen-Aufgliederung ist in Spsw-Schritten');
Writeln(fout,'xo = ',xo,', Angaben in Vielfachen von Spsw, Geometrieparameter nach *2 von S.1');
Writeln(fout,'yo = ',yo,', Angaben in Vielfachen von Spsw, Geometrieparameter nach *2 von S.1');
Writeln(fout,'zo = ',zo,', Angaben in Vielfachen von Spsw, Geometrieparameter nach *2 von S.1');
Writeln(fout,'Ninput = ',Ninput:9,' Zahl der Wicklungen der Input-Spule');
Writeln(fout,'Nturbo = ',Nturbo:9,' Zahl der Wicklungen der Turbo-Spule');
Writeln(fout,'nebeninput = ',Round(nebeninput):9,' Windungen nebeneinander in der Input-Spule');
Writeln(fout,'ueberinput = ',Round(ueberinput):9,' Windungen uebereinander in der Input-Spule');
Writeln(fout,'nebenturbo = ',Round(nebenturbo):9,' Windungen nebeneinander in der Turbo-Spule');
Writeln(fout,'ueberturbo = ',Round(ueberturbo):9,' Windungen uebereinander in der Turbo-Spule');
Writeln(fout,' ');
Writeln(fout,'Bsw = ',Bsw:9,' Magnetfeld-Speicherung nach *1 von S.2 in Zentimeter-Schritten');
Writeln(fout,'Ich emuliere hier das Magnetfeld eines 1T-Magneten durch ein Spulenpaar *1 von S.5:');
Writeln(fout,'MEyo = ',MEyo:14,' y-Koordinaten der Magnetfeld-Emulationsspulen nach *1 von S.5');
Writeln(fout,'MEro = ',MEro:14,' Radius der Magnetfeld-Emulationsspulen nach *1 von S.5');
Writeln(fout,'MEI = ',MEI:14,' Strom des Magnetfeld-Emulationsspulenpaares nach *1 von S.5, Ampere');
Writeln(fout,' ');
Writeln(fout,'Allgemeine technische Größen:');
Writeln(fout,'DD = ',DD:12:7,' {Meter} {Durchmesser des Spulendrahtes zur Angabe der Drahtstärke');
Writeln(fout,'rho = ',rho,' {Ohm*m} {Spez. elektr. Widerstand von Kupfer, je nach Temperatur,
Kohlrausch,T193');
Writeln(fout,'rhoMag = ',rhoMag,' {kg/m^3} {Dichte des Magnet-Materials, Eisen, Kohlrausch Bd.3');
Writeln(fout,'CT = ',CT:14,' {Farad} {Kapazität des Kondensators, der mit in der Turbo-Spule (!) in
Reihe geschaltet');
Writeln(fout,'CI = ',CI:14,' {Farad} {Kapazität des Kondensators, der mit in der Input-Spule (!) in
Reihe geschaltet');
Writeln(fout,' ');
Writeln(fout,'Sonstige (zur Eingabe):');
Writeln(fout,'Rlast = ',Rlast:15,' {Ohm} Ohm´scher Lastwiderstand im LC-Turbo-Schwingkreis');
Writeln(fout,'UmAn = ',UmAn:10:2,' {U/min} Anfangsbedingung mechanisch - Rotierender Magnet:
Startdrehzahl');
Writeln(fout,'Uc = ',Uc:10:2,' {Volt} Anfangsbedingung elektrisch - Kondensatorspannung am TURBOKondensator');
Writeln(fout,'Il = ',Il:10:2,' {Ampere} Anfangsbedingung elektrisch - Spulenstrom im TURBOSchwingkreis');
Writeln(fout,' ');
Writeln(fout,'Mechanische Leistungs-Entnahme, proportional zur Geschwindikeit, aber mit Nachregelung zur
konst. Drehzahl:');
Writeln(fout,'Koeffizient einer geschw-prop. mechan. Leistungs-Entnahme: ',crAnfang:17:12,'
Nm/(rad/s)');
Writeln(fout,'Ziel-Drehzahl,für mechanische Reibungs-Nachregelung: ',phipZiel:17:12,' U/min');
Writeln(fout,' ');
Writeln(fout,'Abgeleitete Parameter. Die Größen werden aus den obigen Parametern berechnet, es ist keine
Eingabe möglich:');
Writeln(fout,'DLI:=4*(yo+zo)*Spsw*Ninput = ',DLI:10:5,' {Meter} Länge des Spulendrahtes, Input-Spule');
Writeln(fout,'DLT:=4*(yo+zo)*Spsw*Nturbo = ',DLT:10:5,' {Meter} Länge des Spulendrahtes, Turbo-Spule');
Writeln(fout,'RI:=rho*(DLI)/(pi/4*DD*DD) = ',RI:10:5,' {Ohm} Ohm`scher Widerstand des Spulendrahtes,
Input-Spule');
Writeln(fout,'RT:=rho*(DLT)/(pi/4*DD*DD) = ',RT:10:5,' {Ohm} Ohm`scher Widerstand des Spulendrahtes,
Turbo-Spule');
Writeln(fout,'BreiteI:=nebeninput*DD = ',BreiteI:10:5,' Breite und Höhe des Input-Spulenlörpers');
Writeln(fout,'HoeheI:=ueberinput*DD = ',HoeheI:10:5,' Breite und Höhe des Input-Spulenlörpers');
Writeln(fout,'BreiteT:=nebenturbo*DD = ',BreiteT:10:5,' Breite und Höhe des Turbo-Spulenlörpers');
Writeln(fout,'HoeheT:=ueberturbo*DD = ',HoeheT:10:5,' Breite und Höhe des Turbo-Spulenlörpers');
Writeln(fout,'fkI:=Sqrt(HoeheI*HoeheI+4/pi*2*yo*2*zo)/HoeheI = ',fkI:10:5,' Korrekturfaktor zur
Induktivität der kurzen Input-Spule');
Writeln(fout,'fkT:=Sqrt(HoeheT*HoeheT+4/pi*2*yo*2*zo)/HoeheT = ',fkT:10:5,' Korrekturfaktor zur
Induktivität der kurzen Turbo-Spule');
Writeln(fout,'LI:=muo*(2*yo+BreiteI)*(2*zo+BreiteI)*Ninput*Ninput/(HoeheI*fkI) = ',LI,' Induktivität
Input-Spule');
Writeln(fout,'LT:=muo*(2*yo+BreiteT)*(2*zo+Breitet)*Nturbo*Nturbo/(HoeheT*fkT) = ',LT,' Induktivität
Turbo-Spule');
Writeln(fout,'omT:=1/Sqrt(LT*CT) = ',omT,' Kreis-Eigenfrequenz des Turbo-Spulen-Schwingkreises aus LT &
CT');
Writeln(fout,'TT:=2*pi/omT = ',TT,' Schwingungsdauer des Turbo-Spulen-Schwingkreises aus LT & CT.');
Writeln(fout,'Mmag:=rhoMag*(pi*MEro*MEro)*(2*MEyo) = ',Mmag:8:3,' kg Masse des Magneten {Rotation um
Querachse !!}');
Writeln(fout,'J:=Mmag/4*(MEro*MEro+4*MEyo*MEyo/3) = ',J,' Trägheitsmoment des Magneten bei Rotation um
Querachse');
Writeln(fout,' ');
Writeln(fout,'Anzeige einiger auszurechnender Parameter:');
Writeln(fout,'Magnet: Start-Winkelgeschw.: omAn = ',omAn:15:6,' rad/sec');
Writeln(fout,'Magnet: Startdrehzahl, Umdr./sec.: UmSec = ',UmSec:15:10,' Hz');
Writeln(fout,'Masse des Magnet = ',Mmag:10:6,' kg');
Writeln(fout,'Traegheitsmoment Magnet bei QUER-Rotation',J,' kg*m^2');
Writeln(fout,'Gesamtdauer der Betrachtung: ',AnzP*dt,' sec.');
Writeln(fout,'Excel-Export: ',PlotAnfang*dt:14,'...',PlotEnde*dt:14,' sec., Step ',PlotStep*dt:14,'
sec.');
Writeln(fout,'Das sind ',(PlotEnde-PlotAnfang)/PlotStep:8:0,' Datenpunkte (also Zeilen).');
Writeln(fout,' ');
Writeln(fout,'***************************************************************************************');
Writeln(fout,' ');
Writeln(fout,'Einige Ergebnisse der Berechnung:');
Writeln(fout,'Anfangs-Energie im System: ',AnfEnergie:14:8,' Joule');
Writeln(fout,'End-Energie im System: ',EndEnergie:14:8,' Joule');
Writeln(fout,'Leistungs-Aenderung im System:',(EndEnergie-AnfEnergie)/(AnzP*dt):14:8,' Watt');
Writeln(fout,'Am Lastwiderstand entnommene Gesamtenergie = ',Wentnommen:14:8,' Joule');
Writeln(fout,'entsprechend einer mittleren entnommenen Leistg:',Wentnommen/(AnzP*dt),' Watt');
Writeln(fout,'Ueber Input-Spannung zugefuehrte Gesamt-Energie: ',Ezuf,' Joule');
Writeln(fout,'entsprechend einer mittleren zugefuehrten Leistg:',Ezuf/(AnzP*dt),' Watt');
Writeln(fout,'Gesamte mechanisch entnommene Energie = ',Ereib:18:11,' Joule');
Writeln(fout,'entsprechend einer mittleren Leistung = ',Ereib/(AnzP*dt):18:11,' Watt');
Writeln(fout,'bei einer Betrachtungs-Dauer von',(AnzP*dt),' sec.');
Close(fout);
end;
Procedure Wait;
Var Ki : Char;
begin
Write('<W>'); Read(Ki); Write(Ki);
If Ki='e' then Halt;
If Ki='E' then Halt;
If Ki='d' then Dokumentation_des_Ergebnisses;
If Ki='D' then Dokumentation_des_Ergebnisses;
end;
Procedure ExcelAusgabe(Name:String;Spalten:Integer);
Var fout : Text; {Bis zu 14 Spalten zum Aufschreiben der Ergebnisse}
lv,j,k : Integer; {Laufvariablen}
Zahl : String; {Die ins Excel zu druckenden Zahlen}
begin
Assign(fout,Name); Rewrite(fout); {File öffnen}
For lv:=0 to AnzP do {von "plotanf" bis "plotend"}
begin
If (lv mod Abstd)=0 then
begin
For j:=1 to Spalten do
begin {Kolumnen drucken, zuerst 3*Ladung, dann 3*Winkel, dann 8 freie Felder}
If j=1 then Str(Q[lv]:19:14,Zahl);
If j=2 then Str(Qp[lv]:19:14,Zahl);
If j=3 then Str(Qpp[lv]:19:14,Zahl);
If j=4 then Str(phi[lv]:19:14,Zahl);
If j=5 then Str(phip[lv]:19:14,Zahl);
If j=6 then Str(phipp[lv]:19:14,Zahl);
If j=7 then Str(KG[lv]:19:14,Zahl);
If j=8 then Str(KH[lv]:19:14,Zahl);
If j=9 then Str(KI[lv]:19:14,Zahl);
If j=10 then Str(KJ[lv]:19:14,Zahl);
If j=11 then Str(KK[lv]:19:14,Zahl);
If j=12 then Str(KL[lv]:19:14,Zahl);
If j=13 then Str(KM[lv]:19:14,Zahl);
If j=14 then Str(KN[lv]:19:14,Zahl);
For k:=1 to Length(Zahl) do
begin {Keine Dezimalpunkte verwenden, sondern Kommata}
If Zahl[k]<>'.' then write(fout,Zahl[k]);
If Zahl[k]='.' then write(fout,',');
end;
Write(fout,chr(9)); {Daten-Trennung, Tabulator}
end;
Writeln(fout,''); {Zeilen-Trennung}
end;
end;
Close(fout);
end;
Procedure ExcelLangAusgabe(Name:String;Spalten:Integer);
Var fout : Text; {Zeit-Skala und bis zu 25 Daten-Spalten zum Aufschreiben der Ergebnisse}
lv,j,k : Integer; {Laufvariablen}
Zahl : String; {Die ins Excel zu druckenden Zahlen}
begin
If (Spalten>25) then
begin
Writeln('FEHLER: Zu viele Spalten. Soviele Daten-Arrays sind nicht vorhanden.');
Writeln(' => PROGRAMM WURDE ANGEHALTEN : STOP !');
Wait; Wait; Halt;
end;
Assign(fout,Name); Rewrite(fout); {File öffnen}
For lv:=0 to LPP do {von "plotanf" bis "plotend"}
begin
If (lv mod Abstd)=0 then
begin
For j:=0 to Spalten do
begin {Kolumnen drucken, zuerst 3*Ladung, dann 3*Winkel, dann 8 freie Felder}
If j=0 then Str(Zeit[lv]:19:14,Zahl); {Markieren der Zeit-Skala}
If j=1 then Str(Q[lv]:19:14,Zahl); {Turbo-Spule}
If j=2 then Str(Qp[lv]:19:14,Zahl); {Turbo-Spule}
If j=3 then Str(Qpp[lv]:19:14,Zahl); {Turbo-Spule}
If j=4 then Str(QI[lv]:19:14,Zahl); {Input-Spule}
If j=5 then Str(QpI[lv]:19:14,Zahl); {Input-Spule}
If j=6 then Str(QppI[lv]:19:14,Zahl); {Input-Spule}
If j=7 then Str(phi[lv]:19:14,Zahl); {Magnet}
If j=8 then Str(phip[lv]:19:14,Zahl); {Magnet}
If j=9 then Str(phipp[lv]:19:14,Zahl); {Magnet}
If j=10 then Str(KK[lv]:19:14,Zahl); {Auxiliary}
If j=11 then Str(KL[lv]:19:14,Zahl); {Auxiliary}
If j=12 then Str(KM[lv]:19:14,Zahl); {Auxiliary}
If j=13 then Str(KN[lv]:19:14,Zahl); {Auxiliary}
If j=14 then Str(KO[lv]:19:14,Zahl); {Auxiliary}
If j=15 then Str(KP[lv]:19:14,Zahl); {Auxiliary}
If j=16 then Str(KQ[lv]:19:14,Zahl); {Auxiliary}
If j=17 then Str(KR[lv]:19:14,Zahl); {Auxiliary}
If j=18 then Str(KS[lv]:19:14,Zahl); {Auxiliary}
If j=19 then Str(KT[lv]:19:14,Zahl); {Auxiliary}
If j=20 then Str(KU[lv]:19:14,Zahl); {Auxiliary}
If j=21 then Str(KV[lv]:19:14,Zahl); {Auxiliary}
If j=22 then Str(KW[lv]:19:14,Zahl); {Auxiliary}
If j=23 then Str(KX[lv]:19:14,Zahl); {Auxiliary}
If j=24 then Str(KY[lv]:19:14,Zahl); {Auxiliary}
If j=25 then Str(KZ[lv]:19:14,Zahl); {Auxiliary}
For k:=1 to Length(Zahl) do
begin {Keine Dezimalpunkte verwenden, sondern Kommata}
If Zahl[k]<>'.' then write(fout,Zahl[k]);
If Zahl[k]='.' then write(fout,',');
end;
Write(fout,chr(9)); {Daten-Trennung, Tabulator}
end;
Writeln(fout,''); {Zeilen-Trennung}
end;
end;
Close(fout);
end;
Function Sgn(Zahl:Integer):Double;
Var merk : Double;
begin
merk:=0;
If Zahl>0 then merk:=+1;
If Zahl<0 then merk:=-1;
Sgn:=merk;
end;
Procedure Magnetfeld_zuweisen_01; {homogenes Magnetfeld}
Var i,j,k : Integer;
begin
For i:=-Bn to Bn do {in x-Richtung}
begin
For j:=-Bn to Bn do {in y-Richtung}
begin
For k:=-Bn to Bn do {in z-Richtung}
begin
Bx[i,j,k]:=0.0; {Telsa}
By[i,j,k]:=1.0; {Telsa}
Bz[i,j,k]:=0.0; {Telsa}
OrtBx[i,j,k]:=i*Bsw;
OrtBy[i,j,k]:=j*Bsw;
OrtBz[i,j,k]:=k*Bsw;
end;
end;
end;
end;
Procedure Magnetfeld_zuweisen_02; {willkürlicher Versuch eines inhomogenen Magnetfeldes}
Var i,j,k : Integer;
begin
For i:=-Bn to Bn do {in x-Richtung}
begin
For j:=-Bn to Bn do {in y-Richtung}
begin
For k:=-Bn to Bn do {in z-Richtung}
begin
Bx[i,j,k]:=-Sgn(i)/(i*i+j*j+k*k+1); If i=0 then Bx[i,j,k]:=0; {Telsa}
By[i,j,k]:= 10/(i*i+j*j+k*k+1); {Telsa}
Bz[i,j,k]:=-Sgn(k)/(i*i+j*j+k*k+1); If k=0 then Bz[i,j,k]:=0; {Telsa}
OrtBx[i,j,k]:=i*Bsw;
OrtBy[i,j,k]:=j*Bsw;
OrtBz[i,j,k]:=k*Bsw;
{ Writeln('Ort:',OrtBx[i,j,k]:12:8,', ',OrtBy[i,j,k]:12:8,', ',OrtBz[i,j,k]:12:8); Wait; }
end;
end;
end;
end;
Procedure Magnetfeld_zuweisen_03;
Var KRPx,KRPy,KRPz : Double; {kartesische Komponenten des Kreuzprodukts im Zähler}
lmsbetrag : Double; {Betrag im Nenner}
lmsbetraghoch3 : Double; {Hilfsvariable}
qwill : Double; {Ladung willkürlich nach S.7}
om : Double; {Frequenz zum Anpassen von qwill an I}
t : Double; {Zeit als Laufvariable von 0 ... 2*pi/om}
sx,sy,sz : Double; {Aufpunkt, an dem das Feld bestimmt werden soll}
dHx,dHy,dHz : Double; {Infinitesimales Feldelement für Biot-Savert}
Hx,Hy,Hz : Double; {Gesamtfeld am Ort des Aufpunkts}
dphi : Double; {Aufteilung der Spulenrings}
Hxkl,Hykl,Hzkl : Double; {klassische Berechnung im Vgl.}
Nenner : Double; {Hilfsgröße für klassische Feldberechnung}
i2,j2,k2 : Integer;{Laufvarible zum Durchgehen des felderfüllten Raumes}
BXmax,BYmax,BZmax : Double; {maximaler Feldwert auf der y-Achse}
Procedure Berechne_dH;
begin
KRPx:=-om*MEro*cos(om*t)*(MEyo-sy);
KRPy:=+om*MEro*cos(om*t)*(MEro*cos(om*t)-sx)+om*MEro*sin(om*t)*(MEro*sin(om*t)-sz);
KRPz:=-om*MEro*sin(om*t)*(MEyo-sy);
lmsbetrag:=Sqr(MEro*cos(om*t)-sx)+Sqr(MEyo-sy)+Sqr(MEro*sin(om*t)-sz);
lmsbetrag:=Sqrt(lmsbetrag);
lmsbetraghoch3:=lmsbetrag*lmsbetrag*lmsbetrag;
If lmsbetraghoch3<=1E-50 then begin dHx:=0; dHy:=0; dHz:=0; end;
If lmsbetraghoch3>=1E-50 then
begin
dHx:=qwill*KRPx/4/pi/lmsbetraghoch3*dphi/2/pi;
dHy:=qwill*KRPy/4/pi/lmsbetraghoch3*dphi/2/pi;
dHz:=qwill*KRPz/4/pi/lmsbetraghoch3*dphi/2/pi;
end;
{ Writeln('Infinitesimales Feldelement: ',dHx:12:7,', ',dHy:12:7,', ',dHz:12:7,' A/m'); }
end;
Procedure Berechne_Hges;
Var ilok : Integer;{Laufvarible für Zählschleife zur Zerteilung der Spule}
begin
Hx:=0; Hy:=0; Hz:=0; {Initialisierung des Gesamtfelds für die Addition der Feldelemente}
qwill:=1; om:=2*pi*MEI/qwill; {Ladung und der Kreisfrequenz in der Magnetfeld-Emulationsspule}
dphi:=2*pi/1000; {Radianten bei der Aufteilung der Spule in 1000 Abschnitte}
For ilok:=0 to 999 do {1000 Zählschritte}
begin
t:=ilok*dphi/om; {Laufvariable (Zeit), zur Umrundung der Spule}
{ Writeln('ilok = ',ilok:4,' => ',om*t:12:6); Wait; }
Berechne_dH; {Infinitesimales Feldelement nach Biot-Savart berechnen}
Hx:=Hx+dHx;
Hy:=Hy+dHy;
Hz:=Hz+dHz;
end;
{ Writeln('Gesamtes Feld am Aufpunkt. : ',Hx:12:7,', ',Hy:12:7,', ',Hz:12:7,' A/m'); }
Hxkl:=0; Hzkl:=0; {klassische Berechnung im Vgl.}
Nenner:=Sqrt(MEro*MEro+(MEyo-sy)*(MEyo-sy)); Nenner:=2*Nenner*Nenner*Nenner;
Hykl:=MEI*MEro*MEro/Nenner; {Der klassische Vergleich geht nur entlang der y-Achse.}
{ Writeln('Vgl. klass. entlang y-Achse: ',Hxkl:12:7,', ',Hykl:12:7,', ',Hzkl:12:7,' A/m'); }
end;
begin
Writeln; Writeln('Magnetfeld Emulations-Spulenpaar nach *1 von S.5');
Writeln('y-Koordinaten der Magnetfeld-Emulationsspulen nach *1 von S.5: ',MEyo:8:5,' m');
Writeln('Radius der Magnetfeld-Emulationsspulen nach *1 von S.5: ',MEro:8:5,' m');
Writeln('Strom der Magnetfeld-Emulationsspulen nach *1 von S.5: ',MEI:8:5,' Ampere');
Writeln('Anzahl der Schritte: ',Bn,' hoch 3 => ', 2*Bn+1,' Bildschirm-Aktionspunkte je Spule.');
{ Zuerst die obere Spule durchlaufen lassen: }
For i2:=-Bn to Bn do {in x-Richtung}
begin
For j2:=-Bn to Bn do {in y-Richtung}
begin
For k2:=-Bn to Bn do {in z-Richtung}
begin
OrtBx[i2,j2,k2]:=i2*Bsw; sx:=OrtBx[i2,j2,k2];
OrtBy[i2,j2,k2]:=j2*Bsw; sy:=OrtBy[i2,j2,k2];
OrtBz[i2,j2,k2]:=k2*Bsw; sz:=OrtBz[i2,j2,k2];
Berechne_Hges;
Bx[i2,j2,k2]:=muo*Hx; {Telsa}
By[i2,j2,k2]:=muo*Hy; {Telsa}
Bz[i2,j2,k2]:=muo*Hz; {Telsa}
{ Write(OrtBx[i2,j2,k2]:10:6,', ',OrtBy[i2,j2,k2]:10:6,', ',OrtBz[i2,j2,k2]:10:6);
Writeln(' =>',Bx[i2,j2,k2]*1E8:7:4,'E-8, ',By[i2,j2,k2]*1E8:7:4,'E-8, ',Bz[i2,j2,k2]*1E8:7:4,'E-8
Tesla');
Wait; }
end;
end;
Write('.');
end; Writeln(' Obere Spule ist durchgerechnet.');
{ Writeln('Obere Spule, Feld am Ursprung: ');
Writeln(Bx[0,0,0],', ',By[0,0,0],', ',Bz[0,0,0]*1E8:7:4,' T'); }
{ Dann die untere Spule dazu addieren: }
MEyo:=-MEyo; {Position der unteren Spule}
For i2:=-Bn to Bn do {in x-Richtung}
begin
For j2:=-Bn to Bn do {in y-Richtung}
begin
For k2:=-Bn to Bn do {in z-Richtung}
begin
OrtBx[i2,j2,k2]:=i2*Bsw; sx:=OrtBx[i2,j2,k2];
OrtBy[i2,j2,k2]:=j2*Bsw; sy:=OrtBy[i2,j2,k2];
OrtBz[i2,j2,k2]:=k2*Bsw; sz:=OrtBz[i2,j2,k2];
Berechne_Hges;
Bx[i2,j2,k2]:=Bx[i2,j2,k2]+muo*Hx; {Telsa}
By[i2,j2,k2]:=By[i2,j2,k2]+muo*Hy; {Telsa}
Bz[i2,j2,k2]:=Bz[i2,j2,k2]+muo*Hz; {Telsa}
{ Write(OrtBx[i2,j2,k2]:10:6,', ',OrtBy[i2,j2,k2]:10:6,', ',OrtBz[i2,j2,k2]:10:6);
Writeln(' =>',Bx[i2,j2,k2]*1E8:7:4,'E-8, ',By[i2,j2,k2]*1E8:7:4,'E-8, ',Bz[i2,j2,k2]*1E8:7:4,'E-8
Tesla');
Wait; }
end;
end;
Write('.');
end; Writeln(' Untere Spule ist durchgerechnet.'); Writeln;
MEyo:=-MEyo; {MEyo zurücksetzen.}
Writeln('Gesamtes Feld am Koordinaten-Ursprung: ');
Writeln(Bx[0,0,0],', ',By[0,0,0],', ',Bz[0,0,0],' T');
Writeln; Writeln('Gesamtes Feld im Zentrum der oberen Spule:');
{oberen Spulenmittelpunkt suchen:} sx:=0; sy:=MEyo; sz:=0;
Berechne_Hges; BXmax:=muo*Hx; BYmax:=muo*Hy; BZmax:=muo*Hz;
{unteren Spulenmittelpunkt suchen:} sx:=0; sy:=-MEyo; sz:=0;
Berechne_Hges; BXmax:=BXmax+muo*Hx; BYmax:=BYmax+muo*Hy; BZmax:=BZmax+muo*Hz;
Writeln(BXmax,', ',BYmax,', ',BZmax,' T');
Writeln('Ist dieses Feld gewünscht ? ? ! ? ? ! ? ?');
Wait; Wait;
end;
Procedure Magnetfeld_anzeigen;
Var i,j,k : Integer;
begin
Writeln('Feld "Magnetische Induktion" des Dauermagneten:');
For i:=-Bn to Bn do {in x-Richtung}
begin
For j:=-Bn to Bn do {in y-Richtung}
begin
For k:=-Bn to Bn do {in z-Richtung}
begin
Write('x,y,z=',OrtBx[i,j,k]*100:5:2,', ',OrtBy[i,j,k]*100:5:2,', ',OrtBz[i,j,k]*100:5:2,'cm =>
B=');
Write(Bx[i,j,k]:8:4,', ');
Write(By[i,j,k]:8:4,', ');
Write(Bz[i,j,k]:8:4,' T ');
Wait;
end;
end;
end;
end;
Procedure Stromverteilung_zuweisen_03;
Var i : Integer; {gemäß Aufbau in Bild *1 auf S.5}
begin
Writeln('Kontrolle der Magnetfeld-Emulations-Spulen:');
For i:=1 to Round(MESEanz/2) do
begin
MESEx[i]:=MEro*cos((i-1)/Round(MESEanz/2)*2*pi); {Orte der oberen Magnetfeld-Emulations-Spulen-
Elemente}
MESEy[i]:=MEyo; {Orte der oberen Magnetfeld-Emulations-Spulen-
Elemente}
MESEz[i]:=MEro*sin((i-1)/Round(MESEanz/2)*2*pi); {Orte der oberen Magnetfeld-Emulations-Spulen-
Elemente}
MESEdx[i]:=-sin((i-1)/Round(MESEanz/2)*2*pi); {Laufrichtungen der Magnetfeld-Emulations-Spulen-
Elemente}
MESEdy[i]:=0; {Laufrichtungen der Magnetfeld-Emulations-Spulen-
Elemente}
MESEdz[i]:=cos((i-1)/Round(MESEanz/2)*2*pi); {Laufrichtungen der Magnetfeld-Emulations-Spulen-
Elemente}
{ Writeln(i:4,': x,y,z = ',MESEx[i]:12:6 ,', ',MESEy[i]:12:6 ,', ',MESEz[i]:12:6 ,' m');
Writeln(i:4,': dx,y,z= ',MESEdx[i]:12:6,', ',MESEdy[i]:12:6,', ',MESEdz[i]:12:6,' ');
Writeln('Laengenkontrolle: ',Sqr(MESEdx[i])+Sqr(MESEdz[i])); Wait; }
end;
For i:=Round(MESEanz/2)+1 to MESEanz do
begin
MESEx[i]:=MEro*cos((i-1)/Round(MESEanz/2)*2*pi); {Orte der unteren Magnetfeld-Emulations-Spulen-
Elemente}
MESEy[i]:=-MEyo; {Orte der unteren Magnetfeld-Emulations-Spulen-
Elemente}
MESEz[i]:=MEro*sin((i-1)/Round(MESEanz/2)*2*pi); {Orte der unteren Magnetfeld-Emulations-Spulen-
Elemente}
MESEdx[i]:=-sin((i-1)/Round(MESEanz/2)*2*pi); {Laufrichtungen der Magnetfeld-Emulations-Spulen-
Elemente}
MESEdy[i]:=0; {Laufrichtungen der Magnetfeld-Emulations-Spulen-
Elemente}
MESEdz[i]:=cos((i-1)/Round(MESEanz/2)*2*pi); {Laufrichtungen der Magnetfeld-Emulations-Spulen-
Elemente}
{ Writeln(i:4,': x,y,z = ',MESEx[i]:12:6 ,', ',MESEy[i]:12:6 ,', ',MESEz[i]:12:6 ,' m');
Writeln(i:4,': dx,y,z= ',MESEdx[i]:12:6,', ',MESEdy[i]:12:6,', ',MESEdz[i]:12:6,' ');
Writeln('Laengenkontrolle: ',Sqr(MESEdx[i])+Sqr(MESEdz[i])); Wait; }
end;
end;
Procedure Spulen_zuweisen; {Spule für den Input der Steuer-Energie}
Var i,j : Integer;
begin
{Zuerst die Stützpunkte des Polygone:}
For i:=0 to 2*zo do
begin {Anfang äußerst links unten, gehe erst in z-Richtung}
SpIx[i+1]:=-xo*Spsw; SpIy[i+1]:=-yo*Spsw; SpIz[i+1]:=(i-zo)*Spsw; {Stützpunkt}
SpTx[i+1]:=+xo*Spsw; SpTy[i+1]:=-yo*Spsw; SpTz[i+1]:=(i-zo)*Spsw; {Stützpunkt}
SIx[i+1] :=-xo*Spsw; SIy[i+1] :=-yo*Spsw; SIz[i+1] :=(0.5+i-zo)*Spsw; {Ort,Mittelpunkt}
STx[i+1] :=-xo*Spsw; STy[i+1] :=-yo*Spsw; STz[i+1] :=(0.5+i-zo)*Spsw; {Ort,Mittelpunkt}
dSIx[i+1]:=0; dSIy[i+1]:=0; dSIz[i+1]:=+Spsw; {Richtungsvektor}
dSTx[i+1]:=0; dSTy[i+1]:=0; dSTz[i+1]:=+Spsw; {Richtungsvektor}
end;
For i:=0 to 2*yo do
begin {gehe dann weiter in y-Richtung}
SpIx[2*zo+i+1]:=-xo*Spsw; SpIy[2*zo+i+1]:=(i-yo)*Spsw; SpIz[2*zo+i+1]:=+zo*Spsw; {Stützpunkt}
SpTx[2*zo+i+1]:=+xo*Spsw; SpTy[2*zo+i+1]:=(i-yo)*Spsw; SpTz[2*zo+i+1]:=+zo*Spsw; {Stützpunkt}
SIx[2*zo+i+1] :=-xo*Spsw; SIy[2*zo+i+1] :=(0.5+i-yo)*Spsw; SIz[2*zo+i+1] :=+zo*Spsw;
{Ort,Mittelpunkt}
STx[2*zo+i+1] :=+xo*Spsw; STy[2*zo+i+1] :=(0.5+i-yo)*Spsw; STz[2*zo+i+1] :=+zo*Spsw;
{Ort,Mittelpunkt}
dSIx[2*zo+i+1]:=0; dSIy[2*zo+i+1]:=Spsw; dSIz[2*zo+i+1]:=0;
{Richtungsvektor}
dSTx[2*zo+i+1]:=0; dSTy[2*zo+i+1]:=Spsw; dSTz[2*zo+i+1]:=0;
{Richtungsvektor}
end;
For i:=0 to 2*zo do
begin {gehe dann in z-Richtung zurück}
SpIx[2*zo+2*yo+i+1]:=-xo*Spsw; SpIy[2*zo+2*yo+i+1]:=yo*Spsw; SpIz[2*zo+2*yo+i+1]:=(zo-i)*Spsw;
{Stützpunkt}
SpTx[2*zo+2*yo+i+1]:=+xo*Spsw; SpTy[2*zo+2*yo+i+1]:=yo*Spsw; SpTz[2*zo+2*yo+i+1]:=(zo-i)*Spsw;
{Stützpunkt}
SIx[2*zo+2*yo+i+1] :=-xo*Spsw; SIy[2*zo+2*yo+i+1] :=yo*Spsw; SIz[2*zo+2*yo+i+1] :=(zo-i-0.5)*Spsw;
{Ort,Mittelpunkt}
STx[2*zo+2*yo+i+1] :=+xo*Spsw; STy[2*zo+2*yo+i+1] :=yo*Spsw; STz[2*zo+2*yo+i+1] :=(zo-i-0.5)*Spsw;
{Ort,Mittelpunkt}
dSIx[2*zo+2*yo+i+1]:=0; dSIy[2*zo+2*yo+i+1]:=0; dSIz[2*zo+2*yo+i+1]:=-Spsw;
{Richtungsvektor}
dSTx[2*zo+2*yo+i+1]:=0; dSTy[2*zo+2*yo+i+1]:=0; dSTz[2*zo+2*yo+i+1]:=-Spsw;
{Richtungsvektor}
end;
For i:=0 to 2*yo do
begin {und zu guter Letzt in y-Richtung wieder runter}
SpIx[4*zo+2*yo+i+1]:=-xo*Spsw; SpIy[4*zo+2*yo+i+1]:=(yo-i)*Spsw; SpIz[4*zo+2*yo+i+1]:=-zo*Spsw;
{Stützpunkt}
SpTx[4*zo+2*yo+i+1]:=+xo*Spsw; SpTy[4*zo+2*yo+i+1]:=(yo-i)*Spsw; SpTz[4*zo+2*yo+i+1]:=-zo*Spsw;
{Stützpunkt}
SIx[4*zo+2*yo+i+1] :=-xo*Spsw; SIy[4*zo+2*yo+i+1] :=(yo-i-0.5)*Spsw; SIz[4*zo+2*yo+i+1] :=-zo*Spsw;
{Ort,Mittelpunkt}
STx[4*zo+2*yo+i+1] :=+xo*Spsw; STy[4*zo+2*yo+i+1] :=(yo-i-0.5)*Spsw; STz[4*zo+2*yo+i+1] :=-zo*Spsw;
{Ort,Mittelpunkt}
dSIx[4*zo+2*yo+i+1]:=0; dSIy[4*zo+2*yo+i+1]:=-Spsw; dSIz[4*zo+2*yo+i+1]:=0;
{Richtungsvektor}
dSTx[4*zo+2*yo+i+1]:=0; dSTy[4*zo+2*yo+i+1]:=-Spsw; dSTz[4*zo+2*yo+i+1]:=0;
{Richtungsvektor}
end; {Der letzte Punkt ist dem ersten identisch}
SpN:=4*zo+4*yo+1;
Writeln('Anzahl der Punkte der Spulen-Linienaufteilung: von 1 - ',SpN);
If SpN>SpNmax then
begin
Writeln('--- ERROR --- zu viele Spulen-Linienelemente');
Writeln('--- ABHILFE -> Array groesser dimensionieren');
Wait; Wait; Halt;
end;
{Dann die Flächenelemente:}
For j:=1 to 2*yo do
begin
For i:=1 to 2*zo do
begin
FlIx[i+(j-1)*2*zo]:=-xo*Spsw; FlIy[i+(j-1)*2*zo]:=(j-0.5-yo)*Spsw; FlIz[i+(j-1)*2*zo]:=(i-0.5-
zo)*Spsw;
FlTx[i+(j-1)*2*zo]:=+xo*Spsw; FlTy[i+(j-1)*2*zo]:=(j-0.5-yo)*Spsw; FlTz[i+(j-1)*2*zo]:=(i-0.5-
zo)*Spsw;
end;
end;
FlN:=4*zo*yo;
Writeln('Anzahl der Flaechenelemente jeder Spulen: von 1 - ',FlN);
If FlN>FlNmax then
begin
Writeln('--- ERROR --- zu viele Spulen-Flaechenelemente');
Writeln('--- ABHILFE -> Array groesser dimensionieren');
Wait; Wait; Halt;
end;
end;
Procedure Spulen_anzeigen; {Spule für den Input der Steuer-Energie}
Var i : Integer;
begin
Writeln('Input-Sp.-> Stuetzpunkte des Polygons, Orte der FE, Richtungsvektoren der FE:');
For i:=1 to SpN do
begin
Writeln('SP [',i:5,']= ',SpIx[i]*100:10:6,', ',SpIy[i]*100:10:6,', ',SpIz[i]*100:10:6,' cm ');
Writeln('ORT[',i:5,']= ', SIx[i]*100:10:6,', ', SIy[i]*100:10:6,', ', SIz[i]*100:10:6,' cm ');
Writeln('RV [',i:5,']= ',dSIx[i]*100:10:6,', ',dSIy[i]*100:10:6,', ',dSIz[i]*100:10:6,' cm ');
Wait;
end;
Writeln('Turbo-Sp.-> Stuetzpunkte des Polygons, Orte der FE, Richtungsvektoren der FE:');
For i:=1 to SpN do
begin
Writeln('SP [',i:5,']= ',SpTx[i]*100:10:6,', ',SpTy[i]*100:10:6,', ',SpTz[i]*100:10:6,' cm ');
Writeln('ORT[',i:5,']= ', STx[i]*100:10:6,', ', STy[i]*100:10:6,', ', STz[i]*100:10:6,' cm ');
Writeln('RV [',i:5,']= ',dSTx[i]*100:10:6,', ',dSTy[i]*100:10:6,', ',dSTz[i]*100:10:6,' cm ');
Wait;
end;
Writeln('Input-Spule -> Flaechenelemente, deren Mittelpunktspositionen:');
For i:=1 to FlN do
begin
Write('x,y,z[',i:5,']= ',FlIx[i]*100:10:6,', ',FlIy[i]*100:10:6,', ',FlIz[i]*100:10:6,' cm ');
Wait;
end;
Writeln('Turbo-Spule -> Flaechenelemente, deren Mittelpunktspositionen:');
For i:=1 to FlN do
begin
Write('x,y,z[',i:5,']= ',FlTx[i]*100:10:6,', ',FlTy[i]*100:10:6,', ',FlTz[i]*100:10:6,' cm ');
Wait;
end;
Writeln('--------------------------------------------------------------------------------');
end;
Procedure Magnet_drehen(fi:Double); {Drehen um Drehwinkel "fi":}
Var i,j,k : LongInt; {Laufvariablen}
begin
fi:=fi/180*pi; {Umrechnen des Winkels in Radianten}
For i:=-Bn to Bn do {x-Anteile}
begin
For j:=-Bn to Bn do {y-Anteile}
begin
For k:=-Bn to Bn do {z-Anteile}
begin
{Drehung der Ortsvektoren:}
OrtBxDR[i,j,k]:=+OrtBx[i,j,k]*cos(-fi)+OrtBy[i,j,k]*sin(-fi);
OrtByDR[i,j,k]:=-OrtBx[i,j,k]*sin(-fi)+OrtBy[i,j,k]*cos(-fi);
OrtBzDR[i,j,k]:=+OrtBz[i,j,k];
{Drehung der Feldstärke-Vektoren:}
BxDR[i,j,k]:=+Bx[i,j,k]*cos(-fi)+By[i,j,k]*sin(-fi);
ByDR[i,j,k]:=-Bx[i,j,k]*sin(-fi)+By[i,j,k]*cos(-fi);
BzDR[i,j,k]:=+Bz[i,j,k];
{Magnetfeld zeilenweise erst ungedreht und dann gedreht anzeigen:}
{ Write('x,y,z=',OrtBx[i,j,k]:5:2,', ',OrtBy[i,j,k]:5:2,', ',OrtBz[i,j,k]:5:2,'mm => B=');
Write(Bx[i,j,k]:8:4,', ');
Write(By[i,j,k]:8:4,', ');
Write(Bz[i,j,k]:8:4,' T '); Writeln;
Write('x,y,z=',OrtBxDR[i,j,k]:5:2,', ',OrtByDR[i,j,k]:5:2,', ',OrtBzDR[i,j,k]:5:2,'mm => B=');
Write(BxDR[i,j,k]:8:4,', ');
Write(ByDR[i,j,k]:8:4,', ');
Write(BzDR[i,j,k]:8:4,' T ');
Wait; Writeln; }
end;
end;
end;
end;
Procedure Feldstaerke_am_Ort_suchen(xpos,ypos,zpos:Double); {an dem Ort suche ich die Feldstärke}
Var ixo,iyo,izo : Integer;
ix,iy,iz : Integer;
dist,disto : Double;
begin
{Zuerst suche ich, welcher Feldort zum xpos,ypos,zpos den kürzesten Abstand hat.}
ixo:=0; iyo:=0; izo:=0;
disto:=Sqrt(Sqr(xpos-OrtBxDR[ixo,iyo,izo])+Sqr(ypos-OrtByDR[ixo,iyo,izo])+Sqr(zpos-
OrtBzDR[ixo,iyo,izo]));
{ Writeln('Anfangs-Abstand vom Nullpunkt: ',disto*100:1:15,' cm'); }
For ix:=-Bn to Bn do {x-Suche}
begin
For iy:=-Bn to Bn do {y-Suche}
begin
For iz:=-Bn to Bn do {z-Suche}
begin
dist:=Sqrt(Sqr(xpos-OrtBxDR[ix,iy,iz])+Sqr(ypos-OrtByDR[ix,iy,iz])+Sqr(zpos-OrtBzDR[ix,iy,iz]));
If dist<=disto then
begin
ixo:=ix; iyo:=iy; izo:=iz;
disto:=dist;
{ Write('Position: ',OrtBxDR[ix,iy,iz]*100:8:5,', ',OrtByDR[ix,iy,iz]*100:8:5,',
',OrtBzDR[ix,iy,iz]*100:8:5,' cm'); }
{ Writeln(disto);} {Wait;}
end;
end;
end;
end;
{ Writeln('Punkt Nummer (ixo,iyo,izo): ',ixo,', ',iyo,', ',izo); }
{Dann gebe ich das Magnetfeld ebendort an:}
{ Writeln('Magnetfeld dort: ',BxDR[ixo,iyo,izo]:8:4,', ',ByDR[ixo,iyo,izo]:8:4,',
',BzDR[ixo,iyo,izo]:8:4,' T '); }
{Jetzt brauche ich noch den magnetischen Fluß durch das dortige Spulen-Flächenelement:}
PsiSFE:=BxDR[ixo,iyo,izo]*Spsw*Spsw; {nach *1 von S.3}
{ Writeln('Magn. Fluss durch Spulen-Flaechenelement: ',PsiSFE,' T*m^2'); }
end;
Procedure Gesamtfluss_durch_Input_Spule; {gemäß *2 von S.3}
Var i : Integer;
begin
PsiGES:=0;
For i:=1 to FlN do
begin
Feldstaerke_am_Ort_suchen(FlIx[i],FlIy[i],FlIz[i]);
PsiGES:=PsiGES+PsiSFE;
end;
end;
Procedure Gesamtfluss_durch_Turbo_Spule; {gemäß *2 von S.3}
Var i : Integer;
begin
PsiGES:=0;
For i:=1 to FlN do
begin
Feldstaerke_am_Ort_suchen(FlTx[i],FlTy[i],FlTz[i]);
PsiGES:=PsiGES+PsiSFE;
end;
end;
Procedure FourierDatenspeicherung(PSIF : Array of Double); {Magnetischer Fluß für Fourier-Entwicklung}
Var i : Integer;
fout : Text;
begin
Assign(fout,'PSIF.DAT'); Rewrite(fout); {File öffnen}
Writeln('FOURIER - HIER:');
For i:=0 to 360 do Writeln(fout,PSIF[i]);
Close(fout);
end;
Procedure FourierEntwicklung;
Var i : Integer;
PSIF : Array [0..360] of Double;
fin : Text;
QSplus,QSmitte,QSminus : Double;
Qanf,Q1p,Q1m,Q2p,Q2m,Q3p,Q3m : Double; {für B1,2,3 - Iteration}
Q4p,Q4m,Q5p,Q5m : Double; {für B4,5 - Iteration}
QSminimum : Double; {zur Minimums-Suche}
weiter : Boolean;
Function QuadSum1:Double;
Var merk : Double;
i : Integer;
begin
merk:=0; {'i' ist Laufvariable für den Winkel, anzugeben in Grad}
For i:=0 to 360 do merk:=merk+Sqr(PSIF[i]-B1*sin(i/360*2*pi));
QuadSum1:=merk;
end;
Function Fourier(t,Ko1,Ko2,Ko3,Ko4,Ko5:Double):Double;
Var merk : Double;
begin {'t' ist Variable für den Winkel, anzugeben in Grad}
merk:=Ko1*sin(t/360*2*pi);
merk:=merk+Ko2*sin(2*t/360*2*pi);
merk:=merk+Ko3*sin(3*t/360*2*pi);
merk:=merk+Ko4*sin(4*t/360*2*pi);
merk:=merk+Ko5*sin(5*t/360*2*pi);
Fourier:=merk;
end;
Function QuadSum3(Koeff1,Koeff2,Koeff3:Double):Double;
Var merk : Double;
i : Integer;
begin
merk:=0; {'i' ist Laufvariable für den Winkel, anzugeben in Grad}
For i:=0 to 360 do merk:=merk+Sqr(PSIF[i]-Koeff1*sin(i/360*2*pi)-Koeff2*sin(2*i/360*2*pi)-
Koeff3*sin(3*i/360*2*pi));
QuadSum3:=merk;
end;
Function QuadSum5(Koeff1,Koeff2,Koeff3,Koeff4,Koeff5:Double):Double;
Var merk : Double;
i : Integer;
begin
merk:=0;
For i:=0 to 360 do {'i' ist Laufvariable für den Winkel, anzugeben in Grad}
begin
If PSIF[i]<>0 then merk:=merk+Sqr(PSIF[i]-Fourier(i,Koeff1,Koeff2,Koeff3,Koeff4,Koeff5));
end;
QuadSum5:=merk;
end;
begin
Assign(fin,'PSIF.DAT'); Reset(fin); {File öffnen}
Writeln('FOURIER - ENTWICKLUNG:');
For i:=0 to 360 do Readln(fin,PSIF[i]);
Close(fin);
B1:=0; {Mittelwert über erste Periode als Startwert für Grundschwingung}
For i:=0 to 180 do B1:=B1+PSIF[i];
{Zuerst die Größenordnung von B1 abschätzen:}
B1:=B1/90; {writeln('B1 : ',B1); Wait;}
{Jetzt B1 anpassen über die Minimierung der Abweichungsquadrate:}
Repeat
B1:=0.99*B1; QSminus:=QuadSum1;
B1:=B1/0.99; QSmitte:=QuadSum1;
B1:=1.01*B1; QSplus:=QuadSum1; B1:=B1/1.01;
weiter:=false;
If QSminus<QSmitte then begin B1:=0.99*B1; weiter:=true; end;
If QSplus<QSmitte then begin B1:=1.01*B1; weiter:=true; end;
{ Writeln('QS: ',QSminus,', ',QSmitte,', ',QSplus); }
Until Not(weiter);
writeln('B1-vorab : ',B1,', QS = ',QSmitte);
{Die Werte zur Kontrolle herausschreiben:}
AnzP:=360; Abstd:=1;
For i:=0 to 360 do {'i' ist Laufvariable für den Winkel, anzugeben in Grad}
begin
Q[i]:=PSIF[i]; Qp[i]:=B1*sin(i/360*2*pi);
end;
{Dann B1 & B2 & B3 anpassen über die Minimierung der Abweichungsquadrate:}
{Startwerte für B2 suchen:}
B2:=0;
B2:=+B1/10; QSplus:=QuadSum3(B1,B2,0);
B2:=-B1/10; QSminus:=QuadSum3(B1,B2,0);
If QSplus<QSminus then B2:=+B1/10;
If QSminus<QSplus then B2:=-B1/10;
{Startwerte für B3 suchen:}
B3:=0;
B3:=+B1/10; QSplus:=QuadSum3(B1,B2,B3);
B3:=-B1/10; QSminus:=QuadSum3(B1,B2,B3);
If QSplus<QSminus then B3:=+B1/10;
If QSminus<QSplus then B3:=-B1/10;
Writeln('AnfB1,2,3: ',B1:20,' , ',B2:20,' , ',B3:20);
{Jetzt über Iteration die B1, B2, B3 fitten:}
Repeat
{QuadSummen berechnen:}
Qanf:=QuadSum3(B1,B2,B3);
Q1p:=QuadSum3(B1*1.01,B2,B3); Q1m:=QuadSum3(B1*0.99,B2,B3);
Q2p:=QuadSum3(B1,B2*1.01,B3); Q2m:=QuadSum3(B1,B2*0.99,B3);
Q3p:=QuadSum3(B1,B2,B3*1.01); Q3m:=QuadSum3(B1,B2,B3*0.99);
{Kleinste QuadSumme suchen:}
QSminimum:=Qanf;
If Q1p<QSminimum then QSminimum:=Q1p; If Q1m<QSminimum then QSminimum:=Q1m;
If Q2p<QSminimum then QSminimum:=Q2p; If Q2m<QSminimum then QSminimum:=Q2m;
If Q3p<QSminimum then QSminimum:=Q3p; If Q3m<QSminimum then QSminimum:=Q3m;
{Koeffizienten zur kleinsten QuadSumme einstellen:}
weiter:=false;
If Q1p=QSminimum then begin B1:=B1*1.01; weiter:=true; end;
If Q1m=QSminimum then begin B1:=B1*0.99; weiter:=true; end;
If Q2p=QSminimum then begin B2:=B2*1.01; weiter:=true; end;
If Q2m=QSminimum then begin B2:=B2*0.99; weiter:=true; end;
If Q3p=QSminimum then begin B3:=B3*1.01; weiter:=true; end;
If Q3m=QSminimum then begin B3:=B3*0.99; weiter:=true; end;
{ Writeln('QS: ',QSminimum); }
Until Not(weiter);
Writeln('Nun B1 = ',B1:17,', B2 = ',B2:17,' B3 = ',B3:17);
Writeln('Zugehoerige Quadsum: ',Quadsum3(B1,B2,B3));
{Die Werte zur Kontrolle herausschreiben:}
For i:=0 to 360 do
begin
Qpp[i]:=B1*sin(i/360*2*pi)+B2*sin(2*i/360*2*pi)+B3*sin(3*i/360*2*pi);
end;
{Nun will ich alle Ausreißer mit mehr als 75% Abweichung löschen:}
For i:=0 to 360 do
begin
If Abs(PSIF[i]-(B1*sin(i/360*2*pi)-B2*sin(2*i/360*2*pi)-B3*sin(3*i/360*2*pi)))>Abs(0.75*B1) then
PSIF[i]:=0;
end;
{Dazu will nun eine Fourier-Reihe mit 5 Koeffizienten fitten:}
{Startwerte für B4 suchen:}
B4:=0;
B4:=+B1/40; QSplus:=QuadSum5(B1,B2,B3,B4,0);
B4:=-B1/40; QSminus:=QuadSum5(B1,B2,B3,B4,0);
If QSplus<QSminus then B4:=+B1/40;
If QSminus<QSplus then B4:=-B1/40;
{Startwerte für B5 suchen:}
B5:=0;
B5:=+B1/40; QSplus:=QuadSum5(B1,B2,B3,B4,B5);
B5:=-B1/40; QSminus:=QuadSum5(B1,B2,B3,B4,B5);
If QSplus<QSminus then B5:=+B1/10;
If QSminus<QSplus then B5:=-B1/10;
Writeln('Und B4,5: ',B4:20,' , ',B5:20);
Writeln('Anf Quadsum: ',QuadSum5(B1,B2,B3,B4,B5));
{Jetzt über Iteration die B1, B2, B3, B4, B5 fitten:}
Repeat
{QuadSummen berechnen:}
Qanf:=QuadSum5(B1,B2,B3,B4,B5);
Q1p:=QuadSum5(B1*1.01,B2,B3,B4,B5); Q1m:=QuadSum5(B1*0.99,B2,B3,B4,B5);
Q2p:=QuadSum5(B1,B2*1.01,B3,B4,B5); Q2m:=QuadSum5(B1,B2*0.99,B3,B4,B5);
Q3p:=QuadSum5(B1,B2,B3*1.01,B4,B5); Q3m:=QuadSum5(B1,B2,B3*0.99,B4,B5);
Q4p:=QuadSum5(B1,B2,B3,B4*1.01,B5); Q4m:=QuadSum5(B1,B2,B3,B4*0.99,B5);
Q5p:=QuadSum5(B1,B2,B3,B4,B5*1.01); Q5m:=QuadSum5(B1,B2,B3,B4,B5*0.99);
{Kleinste QuadSumme suchen:}
QSminimum:=Qanf;
If Q1p<QSminimum then QSminimum:=Q1p; If Q1m<QSminimum then QSminimum:=Q1m;
If Q2p<QSminimum then QSminimum:=Q2p; If Q2m<QSminimum then QSminimum:=Q2m;
If Q3p<QSminimum then QSminimum:=Q3p; If Q3m<QSminimum then QSminimum:=Q3m;
If Q4p<QSminimum then QSminimum:=Q4p; If Q4m<QSminimum then QSminimum:=Q4m;
If Q5p<QSminimum then QSminimum:=Q5p; If Q5m<QSminimum then QSminimum:=Q5m;
{Koeffizienten zur kleinsten QuadSumme einstellen:}
weiter:=false;
If Q1p=QSminimum then begin B1:=B1*1.01; weiter:=true; end;
If Q1m=QSminimum then begin B1:=B1*0.99; weiter:=true; end;
If Q2p=QSminimum then begin B2:=B2*1.01; weiter:=true; end;
If Q2m=QSminimum then begin B2:=B2*0.99; weiter:=true; end;
If Q3p=QSminimum then begin B3:=B3*1.01; weiter:=true; end;
If Q3m=QSminimum then begin B3:=B3*0.99; weiter:=true; end;
If Q4p=QSminimum then begin B4:=B4*1.01; weiter:=true; end;
If Q4m=QSminimum then begin B4:=B4*0.99; weiter:=true; end;
If Q5p=QSminimum then begin B5:=B5*1.01; weiter:=true; end;
If Q5m=QSminimum then begin B5:=B5*0.99; weiter:=true; end;
{ Writeln('QS: ',QSminimum); }
Until Not(weiter);
Writeln('Ergebnis: B1 = ',B1:17,', B2 = ',B2:17,' B3 = ',B3:17);
Writeln(' B4 = ',B4:17,', B5 = ',B5:17);
Writeln('Endliche Quadsum: ',Quadsum5(B1,B2,B3,B4,B5));
{Die Werte zur Kontrolle herausschreiben:}
For i:=0 to 360 do
begin
phipp[i]:=Fourier(i,B1,B2,B3,B4,B5)
end;
ExcelAusgabe('fourier.dat',6);
end;
Function FlussI(alpha:Double):Double;
Var merk : Double; {Hier ist alpha in 'radianten' anzugeben.}
begin
merk:=B1I*sin(alpha);
merk:=merk+B2I*sin(2*alpha);
merk:=merk+B3I*sin(3*alpha);
merk:=merk+B4I*sin(4*alpha);
merk:=merk+B5I*sin(5*alpha);
FlussI:=merk;
end;
Function FlussT(alpha:Double):Double;
Var merk : Double; {Hier ist alpha in 'radianten' anzugeben.}
begin
merk:=B1T*sin(alpha);
merk:=merk+B2T*sin(2*alpha);
merk:=merk+B3T*sin(3*alpha);
merk:=merk+B4T*sin(4*alpha);
merk:=merk+B5T*sin(5*alpha);
FlussT:=merk;
end;
Procedure SinusEntwicklung_fuer_Drehmoment;
Var i,j,jmerk : Integer;
PSIF : Array [0..360] of Double;
fin : Text;
QSalt,QSneu : Double;
weiter : Boolean;
Qanf,QB1plus,QB1minus,Qphaseplus,Qphaseminus : Double; {für numerische Iteration}
QSminimum : Double; {Zur Suche des kleinsten Abweichungsquadrates.}
Function QuadSum2(B1lok,phaselok:Double):Double;
Var merk : Double;
i : Integer;
begin
merk:=0; {'i' ist Laufvariable für den Winkel, anzugeben in Grad}
For i:=0 to 360 do merk:=merk+Sqr(PSIF[i]-B1lok*sin((i+phaselok)/360*2*pi));
QuadSum2:=merk;
end;
begin
Assign(fin,'PSIF.DAT'); Reset(fin); {File öffnen}
Writeln('FOURIER-ENTWICKLUNG FUER DIE SCHNELLE DREHMOMENTS-BERECHNUNG:');
For i:=0 to 360 do Readln(fin,PSIF[i]);
Close(fin);
B1:=0; {Startwert für Grundschwingung "B1" suchen}
For i:=0 to 360 do
begin
If PSIF[i]>B1 then B1:=PSIF[i];
end;
Writeln('Startwert von B1: ',B1); Wait;
phase:=0; QSalt:=QuadSum2(B1,phase); jmerk:=Round(phase); {Startwert für Grundschwingung "phase" suchen}
For j:=1 to 360 do
begin
phase:=j; QSneu:=QuadSum2(B1,phase);
If QSneu<QSalt then
begin
QSalt:=QSneu;
jmerk:=j;
{ Writeln(phase,' => ',QSalt); Wait; }
end;
phase:=jmerk;
end;
Writeln('Startwert von phase: ',phase); Wait;
{Jetzt folgt noch eine genaue Iteration der Parameter:}
Repeat
{QuadSummen berechnen:}
Qanf:=QuadSum2(B1,phase);
QB1plus:=QuadSum2(B1*1.0001,phase);
QB1minus:=QuadSum2(B1*0.9999,phase);
Qphaseplus:=QuadSum2(B1,phase*1.0001);
Qphaseminus:=QuadSum2(B1,phase*0.9999);
{Kleinste QuadSumme suchen:}
QSminimum:=Qanf;
If QB1plus<QSminimum then QSminimum:=QB1plus;
If QB1minus<QSminimum then QSminimum:=QB1minus;
If Qphaseplus<QSminimum then QSminimum:=Qphaseplus;
If Qphaseminus<QSminimum then QSminimum:=Qphaseminus;
{Koeffizienten zur kleinsten QuadSumme einstellen:}
weiter:=false;
If QB1plus=QSminimum then begin B1:=B1*1.0001; weiter:=true; end;
If QB1minus=QSminimum then begin B1:=B1*0.9999; weiter:=true; end;
If Qphaseplus=QSminimum then begin phase:=phase*1.0001; weiter:=true; end;
If Qphaseminus=QSminimum then begin phase:=phase*0.9999; weiter:=true; end;
Writeln('QS: ',QSminimum);
Until Not(weiter);
phase:=phase/360*2*pi; {Phase auf Radianten einstellen}
B1dreh:=B1; {Drehmoment-Amplitude weitergeben.}
end;
Function Schnell_Drehmoment(winkel:Double):Double;
begin
Schnell_Drehmoment:=B1dreh*sin(winkel+phase);
end;
Procedure Magfeld_Turbo_Berechnen(rx,ry,rz,Strom:Double);
Var i : Integer;
sx,sy,sz : Double; {Orte der Leiterschleifen-Elemente}
dsx,dsy,dsz : Double; {Laufrichtungen der Leiterschleifen-Elemente}
AnzLSE : Integer; {Anzahl der Leiterschleifen-Elemente}
smrx,smry,smrz : Double; {Differenzen für das nachfolgende Kreuzprodukt}
krpx,krpy,krpz : Double; {Kreuzprodukt in Biot-Savart}
smrbetrhoch3 : Double; {Betragsbildung für Nenner}
dHx,dHy,dHz : Double; {Infinitesimales Magnetfeld}
Hgesx,Hgesy,Hgesz:Double;{Gesamt-Magnetfeld der Input-Spule am Aufpunkt}
begin
{ Spulen_anzeigen; } {Optional aufrufbares Unterprogramm.}
AnzLSE:=SpN-1;
If AnzLSE<>4*yo+4*zo then
begin
Writeln('Da timmt wat nich: Vernetzung der felderzeugenden Spule ist falsch.');
Writeln('Problem bei der TURBO-Spule:');
Writeln('Anzahl der Stuetzpunkte der Spulen, AnzLSE = ',AnzLSE);
Writeln('Hingegen: 4*yo+4*zo = ',4*yo+4*zo);
Wait; Wait; Halt;
end;
{Ort und Richtungsvektoren der Leiterschleifen-Elemente feststellen, Feld am Aufpunkt ausrechnen nach
Biot-Savart:}
Hgesx:=0; Hgesy:=0; Hgesz:=0;
For i:=1 to AnzLSE do
begin
sx:=SpTx[i]; sy:=SpTy[i]; sz:=SpTz[i]; {Orte der Leiterschleifen-Elemente}
dsx:=dSTx[i]; dsy:=dSTy[i]; dsz:=dSTz[i]; {Richtungsvektoren der Leiterschleifen-Elemente}
smrx:=sx-rx; smry:=sy-ry; smrz:=sz-rz; {Differenzen für das nachfolgende Kreuzprodukt}
krpx:=dsy*smrz-dsz*smry; krpy:=dsz*smrx-dsx*smrz; krpz:=dsx*smry-dsy*smrx; {Kreuzprodukt}
smrbetrhoch3:=Sqrt(Sqr(smrx)+Sqr(smry)+Sqr(smrz));
If smrbetrhoch3<Spsw/1000 then
begin
Writeln('Mechanische Kollision -> Magnet beruehrt Turbo-Spule. STOP.');
Writeln('Spulen-Element bei: ',sx:18,', ',sy:18,', ',sz:18,'m.');
Writeln('Magnet-Ort bei: ',rx:18,', ',ry:18,', ',rz:18,'m.');
Wait; Wait; Halt;
end;
smrbetrhoch3:=smrbetrhoch3*smrbetrhoch3*smrbetrhoch3; {Betragsbildung für Nenner in Biot-Savart}
dHx:=Strom*krpx/4/pi/smrbetrhoch3; {Finites Magnetfeld des Leiterschleifen-Elements}
dHy:=Strom*krpy/4/pi/smrbetrhoch3;
dHz:=Strom*krpz/4/pi/smrbetrhoch3;
Hgesx:=Hgesx+dHx; Hgesy:=Hgesy+dHy; Hgesz:=Hgesz+dHz; {Summation der Feldelemente}
end; {Vorzeichen in der nachfolgenden Zeile gemäß technischer Stromrichtung.}
BTx:=-muo*Hgesx*Nturbo; BTy:=-muo*Hgesy*Nturbo; BTz:=-muo*Hgesz*Nturbo;
end;
Procedure Magfeld_Input_Berechnen(rx,ry,rz,Strom:Double);
Var i : Integer;
sx,sy,sz : Double; {Orte der Leiterschleifen-Elemente}
dsx,dsy,dsz : Double; {Laufrichtungen der Leiterschleifen-Elemente}
AnzLSE : Integer; {Anzahl der Leiterschleifen-Elemente}
smrx,smry,smrz : Double; {Differenzen für das nachfolgende Kreuzprodukt}
krpx,krpy,krpz : Double; {Kreuzprodukt in Biot-Savart}
smrbetrhoch3 : Double; {Betragsbildung für Nenner}
dHx,dHy,dHz : Double; {Infinitesimales Magnetfeld}
Hgesx,Hgesy,Hgesz:Double;{Gesamt-Magnetfeld der Input-Spule am Aufpunkt}
begin
{ Spulen_anzeigen; } {Optional aufrufbares Unterprogramm.}
AnzLSE:=SpN-1;
If AnzLSE<>4*yo+4*zo then
begin
Writeln('Da timmt wat nich: Vernetzung der felderzeugenden Spule ist falsch.');
Writeln('Problem bei der INPUT-Spule:');
Writeln('Anzahl der Stuetzpunkte der Spulen, AnzLSE = ',AnzLSE);
Writeln('Hingegen: 4*yo+4*zo = ',4*yo+4*zo);
Wait; Wait; Halt;
end;
{Ort und Richtungsvektoren der Leiterschleifen-Elemente feststellen, Feld am Aufpunkt ausrechnen nach
Biot-Savart:}
Hgesx:=0; Hgesy:=0; Hgesz:=0;
For i:=1 to AnzLSE do
begin
sx:=SpIx[i]; sy:=SpIy[i]; sz:=SpIz[i]; {Orte der Leiterschleifen-Elemente}
dsx:=dSIx[i]; dsy:=dSIy[i]; dsz:=dSIz[i]; {Richtungsvektoren der Leiterschleifen-Elemente}
smrx:=sx-rx; smry:=sy-ry; smrz:=sz-rz; {Differenzen für das nachfolgende Kreuzprodukt}
krpx:=dsy*smrz-dsz*smry; krpy:=dsz*smrx-dsx*smrz; krpz:=dsx*smry-dsy*smrx; {Kreuzprodukt}
smrbetrhoch3:=Sqrt(Sqr(smrx)+Sqr(smry)+Sqr(smrz));
If smrbetrhoch3<Spsw/1000 then
begin
Writeln('Mechanische Kollision -> Magnet beruehrt Input-Spule. STOP.');
Writeln('Spulen-Element bei: ',sx:18,', ',sy:18,', ',sz:18,'m.');
Writeln('Magnet-Ort bei: ',rx:18,', ',ry:18,', ',rz:18,'m.');
Wait; Wait; Halt;
end;
smrbetrhoch3:=smrbetrhoch3*smrbetrhoch3*smrbetrhoch3; {Betragsbildung für Nenner in Biot-Savart}
dHx:=Strom*krpx/4/pi/smrbetrhoch3; {Finites Magnetfeld des Leiterschleifen-Elements}
dHy:=Strom*krpy/4/pi/smrbetrhoch3;
dHz:=Strom*krpz/4/pi/smrbetrhoch3;
Hgesx:=Hgesx+dHx; Hgesy:=Hgesy+dHy; Hgesz:=Hgesz+dHz; {Summation der Feldelemente}
end; {Vorzeichen in der nachfolgenden Zeile gemäß technischer Stromrichtung.}
BIx:=-muo*Hgesx*Ninput; BIy:=-muo*Hgesy*Ninput; BIz:=-muo*Hgesz;
end;
Function Drehmoment(alpha:Double):Double; {Das Argument ist der Winkel der Magnetstellung "alpha"}
Var i : Integer; {Laufvariable}
Idlx,Idly,Idlz : Double; {Kartesische Komponenten von dl-Vektor nach (*1 von S.11)}
Bxlok,Bylok,Bzlok : Double; {lokale Magnetfeld-Werte}
FLx,FLy,FLz : Double; {Lorentz-Kraft als Kreuzprodukt}
dMx,dMy,dMz : Double; {Drehmoment, das jedes Leiterschleifen-Element auf seinen gesamten Magneten
ausübt.}
MgesX,MgesY,MgesZ : Double; {Gesamt-Drehmoment der Turbo- & Input- Spule auf den Magneten (aus
Emulations-Spulen).}
rx,ry,rz : Double; {Ortsangabe der Magnetfeld-Emulationsspulen-Elemente nach Dreh-Transformation}
begin
MgesX:=0; MgesY:=0; MgesZ:=0;
For i:=1 to MESEanz do
begin
{Wir beginnen mit der Berechnung der Lorentz-Kraft auf jedes einzelne Element der Magnetfeld-
Emulations-Spule}
Idlx:=MEI*MESEdx[i]*4*pi*MEro/MESEanz; {Magnetfeld-Emulations-Leiterschleifen-Element}
Idly:=MEI*MESEdy[i]*4*pi*MEro/MESEanz; {Magnetfeld-Emulations-Leiterschleifen-Element}
Idlz:=MEI*MESEdz[i]*4*pi*MEro/MESEanz; {Magnetfeld-Emulations-Leiterschleifen-Element}
{Es folgt die Berechnung der Magnetfeld-Stärke der Input- und Turbo- Spule am Ort des Leiterschleifen-
Elements}
Magfeld_Input_Berechnen(MESEx[i],MESEy[i],MESEz[i],qpoI); {Strom durch die Input-Spule einstellen !!}
Magfeld_Turbo_Berechnen(MESEx[i],MESEy[i],MESEz[i],qpoT); {Strom "QP" durch die Input-Spule einstellen
!!}
Bxlok:=BIx+BTx; Bylok:=BIy+BTy; Bzlok:=BIz+BTz; {lokales B-feld der Input- und der Turbo- Spule am
Ort des Leiterschleifen-Elements}
{Kreuzprodukt bilden zur Berechnung der Lorentz-Kraft:}
FLx:=Idly*Bzlok-Idlz*Bylok;
FLy:=Idlz*Bxlok-Idlx*Bzlok;
FLz:=Idlx*Bylok-Idly*Bxlok;
{Kontrolle der Lorentz-Kraft:}
{ Writeln('Ort: ',MESEx[i],', ',MESEy[i],', ',MESEz[i]);
Writeln(' dl: ',MESEdx[i],', ',MESEdy[i],', ',MESEdz[i]);
Writeln('FLo: ',FLx,', ',FLy,', ',FLz); }
{Den wirkenden Ort, an dem das Drehmoment angreift, stellen wir durch eine Drehtransformation gemäß *1
von S.12 fest:}
rx:=+MESEx[i]*cos(-alpha)+MESEy[i]*sin(-alpha);
ry:=-MESEx[i]*sin(-alpha)+MESEy[i]*cos(-alpha);
rz:=MESEz[i];
{Daraus berechnen wir nun das zugehörige Drehmoment-Element, das dieses Lorenzt-Kraft-Element auf dem
Magneten ausübt:}
dMx:=ry*FLz-rz*FLy; {Drehmoment als Kreuzprodukt M = r x F }
dMy:=rz*FLx-rx*FLz;
dMz:=rx*FLy-ry*FLx;
{Kontrolle des Drehmoments:}
{ Writeln('Dreh:',dMx,', ',dMy,', ',dMz); Wait; }
MgesX:=MgesX+dMx; {Summation aller einzelnen Drehmoment-Elemente zum Gesamt-Drehmoment.}
MgesY:=MgesY+dMy; {in drei kartesischen Komponenten}
MgesZ:=MgesZ+dMz; {Wegen der Lagerung des Magneten spielt nur die z-Komponente des Drehmoments mit.}
end; {Der Magnet hat nämlich eine starre Achse und rotiert nur um die z-Achse.}
{ Writeln('Drehmoment:',MgesX:20,', ',Mgesy:20,', ',Mgesz:20); }
Drehmoment:=MgesZ;
end;
Procedure Daten_Speichern;
Var fout : Text;
i,j,k : Integer;
begin
Assign(fout,'schonda'); Rewrite(fout); {File öffnen}
{Zuerst die Parameter:}
Writeln(fout,Spsw);
Writeln(fout,xo);
Writeln(fout,yo);
Writeln(fout,zo);
Writeln(fout,Ninput);
Writeln(fout,Nturbo);
Writeln(fout,Bsw);
Writeln(fout,MEyo);
Writeln(fout,MEro);
Writeln(fout,MEI);
{Dann das Magnetfeld:} {Die Schritt-Anzahl Bn bleibt "Const."}
For i:=-Bn to Bn do {in x-Richtung}
begin
For j:=-Bn to Bn do {in y-Richtung}
begin
For k:=-Bn to Bn do {in z-Richtung}
begin
Writeln(fout,OrtBx[i,j,k]);
Writeln(fout,OrtBy[i,j,k]);
Writeln(fout,OrtBz[i,j,k]);
Writeln(fout,Bx[i,j,k]);
Writeln(fout,By[i,j,k]);
Writeln(fout,Bz[i,j,k]);
end;
end;
end;
{Spulenzuweisung und Stromverteilung brauche ich nicht speichern, die kann man rechnen lassen.}
{Die Drehmoments-Parameter muß ich auch abspeichern:}
Writeln(fout,B1T);
Writeln(fout,B2T);
Writeln(fout,B3T);
Writeln(fout,B4T);
Writeln(fout,B5T);
Writeln(fout,B1I);
Writeln(fout,B2I);
Writeln(fout,B3I);
Writeln(fout,B4I);
Writeln(fout,B5I);
Writeln(fout,B1dreh);
Writeln(fout,phase);
Writeln(fout,'Die Daten sind alleherausgeschrieben.');
Close(fout);
end;
Procedure Alte_Parameter_vergleichen;
Var fin : Text;
x : Double; {Parameter zum Einlesen}
n : Integer; {Parameter zum Einlesen}
i,j,k : Integer;
begin
Assign(fin,'schonda'); Reset(fin); {File öffnen}
{Zuerst die Parameter:}
Readln(fin,x); If x<>Spsw then begin schonda:=false; Writeln(' Spsw geaendert'); end;
Readln(fin,n); If n<>xo then begin schonda:=false; Writeln(' xo geaendert'); end;
Readln(fin,n); If n<>yo then begin schonda:=false; Writeln(' yo geaendert'); end;
Readln(fin,n); If n<>zo then begin schonda:=false; Writeln(' zo geaendert'); end;
Readln(fin,n); If n<>Ninput then begin schonda:=false; Writeln('Ninput geaendert'); end;
Readln(fin,n); If n<>Nturbo then begin schonda:=false; Writeln('Nturbo geaendert'); end;
Readln(fin,x); If x<>Bsw then begin schonda:=false; Writeln(' Bsw geaendert'); end;
Readln(fin,x); If x<>MEyo then begin schonda:=false; Writeln(' MEyo geaendert'); end;
Readln(fin,x); If x<>MEro then begin schonda:=false; Writeln(' MEro geaendert'); end;
Readln(fin,x); If x<>MEI then begin schonda:=false; Writeln(' MEI geaendert'); end;
If schonda then Writeln('Die Parameter sind bereits bekannt.');
If Not(schonda) then
begin
Writeln('Die Parameter sind neu. Es beginnt eine neue Vernetzung.');
Wait; Wait;
end;
{Dann das Magnetfeld:} {Die Schritt-Anzahl Bn bleibt "Const."}
For i:=-Bn to Bn do {in x-Richtung}
begin
For j:=-Bn to Bn do {in y-Richtung}
begin
For k:=-Bn to Bn do {in z-Richtung}
begin
Readln(fin,OrtBx[i,j,k]);
Readln(fin,OrtBy[i,j,k]);
Readln(fin,OrtBz[i,j,k]);
Readln(fin,Bx[i,j,k]);
Readln(fin,By[i,j,k]);
Readln(fin,Bz[i,j,k]);
end;
end;
end;
Writeln('Das Magnetfeld ist gelesen.');
{Spulenzuweisung und Stromverteilung brauche ich nicht speichern, die kann man rechnen lassen.}
{Die Drehmoments-Parameter muß ich auch abspeichern:}
Readln(fin,B1T);
Readln(fin,B2T);
Readln(fin,B3T);
Readln(fin,B4T);
Readln(fin,B5T);
Readln(fin,B1I);
Readln(fin,B2I);
Readln(fin,B3I);
Readln(fin,B4I);
Readln(fin,B5I);
Writeln('Die Parameter zur Berechnung des magnetischen Flusses sind gelesen.');
Readln(fin,B1dreh);
Readln(fin,phase);
Writeln('Die Parameter zur schnellen Berechnung des Drehmoments sind gelesen.');
Writeln('Damit steht alles fuer den DFEM-Algorithmus bereit.');
Close(fin);
end;
Function U7:Double; {Input-Spannung für den Input-Schwingkreis}
Var UAmpl : Double; {Spannungs-Amplitude}
Pulsdauer : LongInt; {Pulsdauer in Zeitschritten von "dt"}
Phasenshift : Double; {Phasendifferenz zwischen oberem Umkehrpunkt und Spannungs-Impuls}
Umerk : Double; {Merk-Wert für die Ausgabe der Spannung}
begin
Umerk:=0; {Initialisierung des Merk-Werts für die Spannungs-Ausgabe}
UAmpl:=6E-6; {Volt, Spannungs-Amplitude}
Pulsdauer:=20; {Pulsdauer, Anzahl der Zeitschritte von "dt"}
Phasenshift:=000; {Phasendifferenz zwischen oberem Umkehrpunkt und Spannungs-Impuls in Zeitschritten
von "dt"}
{ If i<=Pulsdauer then Umerk:=UAmpl; {falls gewünscht: Start-Impuls geben}
If i>=Pulsdauer then {Getriggerte Pulse im Betrieb geben}
begin
If (i>=iumk+Phasenshift)and(i<=iumk+Pulsdauer+Phasenshift) then {Hier wird das Trigger-Signal am
oberen Umkehrpunkt festgemacht.}
begin Umerk:=UAmpl; end; {Spannung anlegen} {Alternativ könnte man ihn z.B. auch
am Nulldurchgang festmachen.}
end;
U7:=Umerk*0; {Wir wollen jetzt keine Energie-Zufuhr. Die Maschine soll ein Selbstläufer werden.}
end;
Function Reibung_nachregeln:Double;
Var merk:Double;
begin {Eine kleine Schalt-Hysterese muß ich einbauen:}
merk:=cr; {Falls ich nicht außerhalb der Schalt-Hysterese liege.}
If (phipo/2/pi*60)>1.000001*phipZiel then merk:=cr*1.000001; {Wenn's zu schnell läuft => abbremsen}
If (phipo/2/pi*60)<0.999999*phipZiel then merk:=cr*0.999999; {Wenn's zu langsam läuft => weniger
Reibung}
If (merk<0.8*crAnfang) then merk:=0.8*crAnfang; {Regelung nicht zu arg schwingen lassen, vor Allen nicht
Aufschwingen.}
If (merk>1.2*crAnfang) then merk:=1.2*crAnfang; {Regelung nicht zu arg schwingen lassen, vor Allen nicht
Aufschwingen.}
Reibung_nachregeln:=merk;
end;
Begin {Hauptprogramm}
{ Eingabe-Daten-Anmerkung: Die Input-Spannung für die Input-Spule steht als letztes Unterprogramm vor dem
Beginn des Hauptprogramms.}
{ Initialisierung - Vorgabe der Werte: } {Wir arbeiten in SI-Einheiten}
Writeln('DFEM-Simulation des EMDR-Motors.');
{ Naturkonstanten:}
epo:=8.854187817E-12{As/Vm}; {Magnetische Feldkonstante}
muo:=4*pi*1E-7{Vs/Am}; {Elektrische Feldkonstante}
LiGe:=Sqrt(1/muo/epo){m/s}; Writeln('Lichtgeschwindigkeit c = ',LiGe, ' m/s');
{ Zum Lösen der Dgl. und zur Darstellung der Ergebnisse:}
AnzP:=100000000; {Zum Lösen der Dgl.: Anzahl der tatsächlich berechneten Zeit-Schritte}
dt:=43E-9; {Sekunden} {Zum Lösen der Dgl.: Dauer der Zeitschritte zur iterativen Lsg. der Dgl.}
Abstd:=1; {Nur für die Vorbereitung, nicht zum Lösen der Dgl.: Jeden wievielten Punkt soll ich
plotten ins Excel}
PlotAnfang:=0000; {Zum Lösen der Dgl.: Erster-Plot-Punkt: Anfang des Daten-Exports nach Excel}
PlotEnde:=100000000; {Zum Lösen der Dgl.: Letzter-Plot-Punkt: Ende des Daten-Exports nach Excel}
PlotStep:=4000; {Zum Lösen der Dgl.: Schrittweite des Daten-Exports nach Excel}
{ Die beiden Spulen, vgl. Zeichnung *2 von S.1 :} {Die Spulen werden nach Vorgabe der Geometrieparameter
automatisch vernetzt}
Spsw:=0.01; {Angabe in Metern: Die Spulen-Aufgliederung ist in 0.01-Meter-Schritten}
xo:=0; yo:=6; zo:=5; {Angaben in Vielfachen von Spsw} {Geometrieparameter nach Zeichnung*2 von S.1}
Spulen_zuweisen; {Spule für den Input der Steuer-Energie}
Ninput:=100; {Zahl der Wicklungen der Input-Spule}
Nturbo:=9; {Zahl der Wicklungen der Turbo-Spule}
nebeninput:=10; {Windungen nebeneinander in der Input-Spule}
ueberinput:=10; {Windungen uebereinander in der Input-Spule}
nebenturbo:=3; {Windungen nebeneinander in der Turbo-Spule}
ueberturbo:=3; {Windungen uebereinander in der Turbo-Spule}
If nebeninput*ueberinput<>Ninput then
begin
Writeln; Writeln('Windungszahl falsch: So kann man die Input-Spule nicht anordnen !');
Wait; Wait; Halt;
end;
If nebenturbo*ueberturbo<>Nturbo then
begin
Writeln; Writeln('Windungszahl falsch: So kann man die Turbo-Spule nicht anordnen !');
Wait; Wait; Halt;
end;
{ Spulen_anzeigen; {Optionales Unterprogramm zur Kontrolle der Positionen.}
{ Dauermagnet-Emulation:} Writeln; {Magnetfeld muß nach Messung mit Hall-Sonde eingegeben werden.}
Bsw:=1E-2; {Magnetfeld-Speicherung nach *1 von S.2 in Zentimeter-Schritten}
{Ich emuliere hier das Magnetfeld eines 1T-Magneten durch ein Spulenpaar nach *1 von S.5}
MEyo:=0.05; {y-Koordinaten der Magnetfeld-Emulationsspulen nach *1 von S.5}
MEro:=0.01; {Radius der Magnetfeld-Emulationsspulen nach *1 von S.5}
MEI:=15899.87553474; {Strom des Magnetfeld-Emulationsspulenpaares nach *1 von S.5, Angabe in Ampere}
schonda:=true; Alte_Parameter_vergleichen;
If Not(schonda) then Magnetfeld_zuweisen_03; {Magnetfeld zuweisen und anzeigen}
Stromverteilung_zuweisen_03; {Stromverteilung in den Magnetfeld-Emulations-Spulen zuweisen.}
{ Allgemeine technische Größen:}
DD:=0.010; {Meter} {Durchmesser des Spulendrahtes zur Angabe der Drahtstärke}
rho:=1.35E-8; {Ohm*m} {Spez. elektr. Widerstand von Kupfer, je nach Temperatur, Kohlrausch,T193}
rhoMag:=7.8E3; {kg/m^3} {Dichte des Magnet-Materials, Eisen, Kohlrausch Bd.3}
CT:=101.7E-6; {150E-6;} {Farad} {Kapazität des Kondensators, der mit in der Turbo-Spule (!) in Reihe
geschaltet}
CI:=100E-6; {Farad} {Kapazität des Kondensators, der mit in der Input-Spule (!) in Reihe
geschaltet}
{ Sonstige (zur Eingabe):}
Rlast:=0.030; {Ohm} {Ohm'scher Lastwiderstand im LC-Turbo-Schwingkreis}
UmAn:=30000; {U/min} {Anfangsbedingung mechanisch - Rotierender Magnet: Startdrehzahl}
Uc:=0;{Volt} Il:=0; {Ampere} {Anfangsbedingung elektrisch - Kondensatorspannung = 0, Kein Spulenstrom}
{ Mechanische Leistungs-Entnahme (geschwindigkeits-proportional, aber nicht nur Reibung:}
crAnfang:=45E-6; {Koeffizient einer geschwindigkeits-proportionalen Reibung zwecks mechanischer
Leistungs-Entnahme}
phipZiel:=30100; {Ziel-Drehzahl, an der die Reibungs-Nachregelung ausgerichtet wird.}
{ Abgeleitete Parameter. Die Größen werden aus den obigen Parametern berechnet, es ist keine Eingabe
möglich:}
DLI:=4*(yo+zo)*Spsw*Ninput; {Meter} {Länge des Spulendrahtes, Input-Spule}
DLT:=4*(yo+zo)*Spsw*Nturbo; {Meter} {Länge des Spulendrahtes, Turbo-Spule}
RI:=rho*(DLI)/(pi/4*DD*DD); {Ohm} {Ohm`scher Widerstand des Spulendrahtes, Input-Spule}
RT:=rho*(DLT)/(pi/4*DD*DD); {Ohm} {Ohm`scher Widerstand des Spulendrahtes, Turbo-Spule}
BreiteI:=nebeninput*DD; HoeheI:=ueberinput*DD; {Breite und Höhe des Input-Spulenlörpers}
BreiteT:=nebenturbo*DD; HoeheT:=ueberturbo*DD; {Breite und Höhe des Turbo-Spulenlörpers}
fkI:=Sqrt(HoeheI*HoeheI+4/pi*2*yo*2*zo)/HoeheI;{Korrekturfaktor zur Induktivität der kurzen Input-Spule}
fkT:=Sqrt(HoeheT*HoeheT+4/pi*2*yo*2*zo)/HoeheT;{Korrekturfaktor zur Induktivität der kurzen Turbo-Spule}
Writeln('Induktivitaets-Korrektur: fkI = ',fkI:12:5,', fkT = ',fkT:12:5);
LI:=muo*(2*yo+BreiteI)*(2*zo+BreiteI)*Ninput*Ninput/(HoeheI*fkI); {Geometrische Mittelung =>
Induktivität der Input-Spule}
LT:=muo*(2*yo+BreiteT)*(2*zo+Breitet)*Nturbo*Nturbo/(HoeheT*fkT); {Geometrische Mittelung =>
Induktivität der Turbo-Spule}
omT:=1/Sqrt(LT*CT); {Kreis-Eigenfrequenz des Turbo-Spulen-Schwingkreises aus LT & CT}
TT:=2*pi/omT; {Schwingungsdauer des Turbo-Spulen-Schwingkreises aus LT & CT.}
Mmag:=rhoMag*(pi*MEro*MEro)*(2*MEyo);{Masse des Magneten} {Rotation des Magneten um Querachse !!}
J:=Mmag/4*(MEro*MEro+4*MEyo*MEyo/3); {Trägheitsmoment des Magneten bei Rotation, siehe *2 von S.13 und
Dubbel S.B-32}
{ Sonstige, auch abgeleitete (aus den obigen Parametern berechnete) Größen:}
omAn:=UmAn/60*2*pi; {Rotierender Magnet: Winkelgeschwindigkeit (rad/sec.), Startdrehzahl}
UmSec:=UmAn/60; {Rotierender Magnet: Umdrehungen pro Sekunde, Startdrehzahl}
{ Anzeige der Werte:}
Writeln('*******************************************************************************');
Writeln('Anzeige einiger auszurechnender Parameter:');
Writeln('Laenge des Spulendrahtes, Input-Spule: ',DLI,' m');
Writeln('Laenge des Spulendrahtes, Turbo-Spule: ',DLT,' m');
Writeln('Ohm`scher Widerstand des Input-Spulendrahts: RI = ',RI:8:2,' Ohm');
Writeln('Ohm`scher Widerstand des Turbo-Spulendrahts: RT = ',RT:8:2,' Ohm');
Writeln('Induktivitaet der Input-Spule, ca.: LI = ',LI,' Henry');
Writeln('Induktivitaet der Turbo-Spule, ca.: LT = ',LT,' Henry');
Writeln('Eigen-Kreisfreq des Turbo LT-CT-Schwinkreises: omT = ',omT:8:4,' Hz (omega)');
Writeln('=> Schwingungsdauer TT = 2*pi/omT = ',TT:15,'sec.');
Writeln('Magnet: Start-Winkelgeschw.: omAn = ',omAn,' rad/sec');
Writeln('Magnet: Startdrehzahl, Umdr./sec.: UmSec = ',UmSec:15:10,' Hz');
Writeln('Masse des Magnet = ',Mmag:10:6,' kg');
Writeln('Traegheitsmoment Magnet bei QUER-Rotation',J,' kg*m^2');
Writeln('Gesamtdauer der Betrachtung: ',AnzP*dt,' sec.');
Writeln('Excel-Export: ',PlotAnfang*dt:14,'...',PlotEnde*dt:14,' sec., Step ',PlotStep*dt:14,' sec.');
Writeln('Das sind ',(PlotEnde-PlotAnfang)/PlotStep:8:0,' Datenpunkte (also Zeilen).');
If ((PlotEnde-PlotAnfang)/PlotStep)>AnzPmax then
begin
Writeln; Writeln('FEHLER: Zu viele Datenpunkte.');
Writeln('So viele Datenpunkte koennen in Excel nicht dargestellt werden.');
Writeln('=> Berechnung wird hier GESTOPPT.'); Wait; Wait; Halt;
end;
{ Wait; }
{ Hilfsarbeiten: Für die Vorbereitungen brauche ihch AnzP=360, danach brauche ich wieder den eingegebenen
Wert.}
AnzPmerk:=AnzP; {Merken des Wertes für später}
AnzP:=360; {Eine Umdrehung in Winkel-Grad-Schritten}
{ Ein Test der Daten-Transport-Routine ins Excel:}
For i:= 1 to AnzP do
begin
Q[i]:=i*dt; Qp[i]:=2*i*dt; Qpp[i]:=3*i*dt; phi[i]:=4*i*dt; phip[i]:=5*i*dt; phipp[i]:=6*i*dt;
KG[i]:=7*i; KH[i]:=8*i; KI[i]:=9*i; KJ[i]:=10*i; KK[i]:=11*i; KL[i]:=12*i; KM[i]:=13*i; KN[i]:=14*i;
end;
{ExcelAusgabe('test.dat',14);} {Optionales Upgm. zur Datenausgabe nach Excel.}
{Alle Felder zurücksetzen, um möglicher Verwirrung für später vorzubeugen}
For i:= 1 to AnzP do
begin
Q[i]:=0; Qp[i]:=0; Qpp[i]:=0; phi[i]:=0; phip[i]:=0; phipp[i]:=0;
KG[i]:=0; KH[i]:=0; KI[i]:=0; KJ[i]:=0; KK[i]:=0; KL[i]:=0; KM[i]:=0; KN[i]:=0;
end;
{ Hier beginnt das Rechenprogramm.}
{Teil 1: Eine Test-Berechnung der Drehmoment-Wirkung der beiden Spulen auf den Magneten:}
Writeln; {Wir beginnen mit der Bestimmung des Magnetfeld des beiden Spulen an einem beliebigen
Aufpunkt}
Writeln('Hier steht vorerst zu Testzwecken die Feldberechnung der Input- und Turbo-Spule');
Magfeld_Input_Berechnen(-0.00,0.01,0.01,1.0); {drei kartesische Komponenten für Aufpunkt und Strom =
1.0 Ampere}
Writeln('B_Input_x,y,z:',BIx:19,', ',BIy:19,', ',BIz:19,' T');
Magfeld_Turbo_Berechnen(+0.00,0.01,0.01,1.0); {drei kartesische Komponenten für Aufpunkt und Strom =
1.0 Ampere}
Writeln('B_Turbo_x,y,z:',BTx:19,', ',BTy:19,', ',BTz:19,' T');
merk:=Sqrt((2*yo*Spsw*2*zo*Spsw)+Sqr(xo*Spsw)); merk:=merk*merk*merk;
Writeln('Vgl->Input: Runde Leiterschleife, Feld im Ursprung:
',muo*Ninput*1.0*2*yo*Spsw*2*zo*Spsw/2/merk,' T');
Writeln('Vgl->Turbo: Runde Leiterschleife, Feld im Ursprung:
',muo*Nturbo*1.0*2*yo*Spsw*2*zo*Spsw/2/merk,' T');
{Die Berechnung des Magnetfeldes der beiden Spulen (Input & Turbo) ist jetzt getestet und funktioniert.}
If Not(schonda) then
begin {Das ist nur eine Kontrolle.}
For i:=0 to 360 do
begin
KN[i]:=Drehmoment(i/180*pi);
Writeln(i:4,'Grad => Drehmoment-Komponente: Mz = ',KN[i]); {Das Argument ist der Winkel der
Magnetstellung "alpha"}
end;
ExcelAusgabe('drehmom.dat',14); {Optionales Upgm. zur Datenausgabe nach Excel.}
Writeln('Damit ist die Drehmoments-Berechnung des Magneten geschafft.');
end;
{Teil 2: Ausprobieren der Flußberechnung durch die beiden Spulen unter Magnet-Drehung (führt später zur
induz. Spannung):}
If Not(schonda) then
begin
Writeln('Es folgt die Berechnung des magnetischen Flusses fuer Geometrie "03"');
Magnet_drehen(00); {Drehwinkel in Grad angeben, 0...360}
Gesamtfluss_durch_Input_Spule; Writeln('Gesamtfluss durch Input-Spule: ',PsiGES,' T*m^2');
Magnet_drehen(01); {Drehwinkel in Grad angeben, 0...360}
Gesamtfluss_durch_Input_Spule; Writeln('Gesamtfluss durch Input-Spule: ',PsiGES,' T*m^2');
Writeln('-----------------------');
Magnet_drehen(00); {Drehwinkel in Grad angeben, 0...360}
Gesamtfluss_durch_Turbo_Spule; Writeln('Gesamtfluss durch Turbo-Spule: ',PsiGES,' T*m^2');
Magnet_drehen(01); {Drehwinkel in Grad angeben, 0...360}
Gesamtfluss_durch_Turbo_Spule; Writeln('Gesamtfluss durch Turbo-Spule: ',PsiGES,' T*m^2');
Writeln('-----------------------');
end;
{Ergebnis bis hier: Die Differenz zwischen beiden erlaubt die Berechnung der induzierten Spannung}
{ Test: Einmal den Magneten drehen und den magnetischen Fluss / die induzierte Spannung messen:}
{Zum Test stehen 360 Zeiteinheiten = 360*dt = 36 Millisekunden für eine Umdrehung, entsprechend 1666.666
U/min}
If Not(schonda) then
begin
Writeln('Zuerst die Input-Spule:');
For i:= 0 to 360 do {Zuerst probiere ich's mit der Input-Spule}
begin
phi[i]:=i; {Angabe in Grad}
Magnet_drehen(phi[i]); Gesamtfluss_durch_Input_Spule; {setzt auf "PsiGES" den Ergebnis-Wert ab.}
PSIinput[i]:=PsiGES; {Dies ist der magnetische Fluß durch die Input-Spule}
Writeln('phi = ',phi[i]:5:1,' grad => magn. ges. Fluss = ',PSIinput[i],' T*m^2');
If i=0 then UindInput[i]:=0;
If i>0 then UindInput[i]:=-Ninput*(PSIinput[i]-PSIinput[i-1])/dt;
KG[i]:=0; KH[i]:=PSIinput[i]; KI[i]:=UindInput[i]; {Zur Excel-Ausgabe weiterleiten}
end; Writeln('---------------------------------');
Writeln('Danach die Turbo-Spule:');
For i:= 0 to 360 do {Danach probiere ich's auch noch mit der Turbo-Spule}
begin
phi[i]:=i; {Angabe in Grad}
Magnet_drehen(phi[i]); Gesamtfluss_durch_Turbo_Spule; {setzt auf "PsiGES" den Ergebnis-Wert ab.}
PSIturbo[i]:=PsiGES; {Dies ist der magnetische Fluß durch die Turbo-Spule}
Writeln('phi = ',phi[i]:5:1,' grad => magn. ges. Fluss = ',PSIturbo[i],' T*m^2');
If i=0 then Uindturbo[i]:=0;
If i>0 then Uindturbo[i]:=-Nturbo*(PSIturbo[i]-PSIturbo[i-1])/dt;
KJ[i]:=0; KK[i]:=PSIturbo[i]; KL[i]:=Uindturbo[i]; {Zur Excel-Ausgabe weiterleiten}
KM[i]:=0; KN[i]:=KN[i]; {Am Ende noch zwei Leerspalten}
end;
{Jetzt muß man das Signal noch gegen Rauschen glätten:}
FourierDatenspeicherung(PSIturbo); FourierEntwicklung;
B1T:=B1; B2T:=B2; B3T:=B3; B4T:=B4; B5T:=B5;
{**}Writeln('Aktuelle Kontrolle der Fourier-Koeffizienten für den Turbo-Fluß:');
{**}writeln(B1T:13,', ',B2T:13,', ',B3T:13,', ',B4T:13,', ',B5T:13); Wait;
FourierDatenspeicherung(PSIinput); FourierEntwicklung;
B1I:=B1; B2I:=B2; B3I:=B3; B4I:=B4; B5I:=B5;
{Kontroll-Output der geglätteten Fluß-Werte in den ersten beiden Kolumnen des Excel-Datensatzes:}
For i:=0 to 360 do
begin {FlussI und FlussT gibt den geglätteten magnetischen Fluß durch die Spulen an.}
KJ[i]:=FlussI(i/360*2*pi); {Der Lagewinkel des Magneten wird in Radianten angegeben.}
KM[i]:=FlussT(i/360*2*pi); {Der Lagewinkel des Magneten wird in Radianten angegeben.}
end;
end;
{Die Drehmoments-Berechnung absorbiert noch zu viel CPU-Zeit, um mit sehr feiner Zeit-Schrittweite
rechnen zu können.}
{Daher entwickele ich jetzt auch eine Fourier-Reihe zur Beschleunigung der Drehmoments-Berechnung:}
If Not(schonda) then
begin
qpoT:=1; qpoI:=0; {Schnell-Berechnungs-Kalibrierung nur für Turbo-Spule, 1A, aber ohne Input-Spule}
Writeln('Drehmoment in einen Sinus-Term umrechnen, zur spaeteren CPU-Zeit Ersparnis:');
For i:=0 to 360 do
begin {Das gesamt-Drehmoment, das der Magnet im Feld der beiden Spulen (Input&Turbo) aufnimmt.}
KN[i]:=Drehmoment(i*2*pi/360); {Der Lagewinkel des Magneten wird in Radianten angegeben.}
Write('.'); {Writeln(KN[i]);}
end;
FourierDatenspeicherung(KN); SinusEntwicklung_fuer_Drehmoment;
Writeln('Drehmom-Ampl: ',B1dreh,' und Phase: ',phase);
{Kontrolle, ob die Schnell-Drehmoments-Berechnung richtige Ergebnisse liefert:}
For i:=0 to 360 do
begin
KG[i]:=Schnell_Drehmoment(i*2*pi/360); {Der Lagewinkel des Magneten wird in Radianten angegeben.}
end;
end;
{Daten abspeichern, falls eine Parameter-Konfiguration vorliegt:}
{If Not(schonda) then} Daten_Speichern;
{Damit ist die Vorbereitung beendet.}
{Ich kontrolliere jetzt, ob alle Parameter und Daten mit und ohne "schonda" angekommen sind:}
For i:=0 to 360 do
begin {FlussI und FlussT gibt den geglätteten magnetischen Fluß durch die Spulen an.}
KJ[i]:=FlussI(i*2*pi/360); {Magnetischer Fluss durch Input-Spule, Winkel des Magneten in Radianten}
KM[i]:=FlussT(i*2*pi/360); {Magnetischer Fluss durch Turbo-Spule, Winkel des Magneten in Radianten}
end;
For i:=0 to 360 do
begin
KG[i]:=Schnell_Drehmoment(i*2*pi/360); {Drehmoment auf den Magneten, Winkel des Magneten in Radianten}
end;
ExcelAusgabe('kontroll.dat',14); {Optionales Upgm. zur Datenausgabe nach Excel.}
{Hilfsarbeiten: Zum Lösen der Dgl. brauche ich wieder vorgegebene Anzahl von Iterationsschritten:}
AnzP:=AnzPmerk;
{Damit stehen jetzt alle Daten zur DFEM-Berechnung bereit.}
Writeln('*******************************************************************************');
{Noch eine Daten-Initialisierung: Zurücksetzen aller Felder für die "ExcelLangAusgabe":}
For i:=0 to AnzPmax do
begin
Zeit[i]:=0; Q[i]:=0; Qp[i]:=0; Qpp[i]:=0; QI[i]:=0; QpI[i]:=0; QppI[i]:=0;
phi[i]:=0; phip[i]:=0; phipp[i]:=0; KJ[i]:=0; KK[i]:=0; KL[i]:=0; KM[i]:=0;
KN[i]:=0; KO[i]:=0; KP[i]:=0; KQ[i]:=0; KR[i]:=0; KS[i]:=0; KT[i]:=0;
KU[i]:=0; KV[i]:=0; KW[i]:=0; KX[i]:=0; KY[i]:=0;
end;
{Initialisierung für die Suche der Maximalwerte zur Strom-, Drehzahl- und Spannungsangabe bei der
Auslegung:}
QTmax:=0; QImax:=0; QpTmax:=0; QpImax:=0; QppTmax:=0; QppImax:=0; phipomax:=0;
Wentnommen:=0; {Initialisierung der entnommenen Energie am Lastwiderstand}
Ereib:=0; {Initialisierung der entnommenen mechanischen Energie über Reibung}
{Initialisierung der Referenz für das Input-Spannungs-Signal:}
steigtM:=false; steigtO:=false;
Ezuf:=0; {Initialisierung der zugeführten Energie über die Input-Spannung}
LPP:=0; {Initialisierung der Anzahl der Datenpunkt für den Excel-Plot}
{ Damit ist alles vorbereitet, und ich kann jetzt anfangen, in die Lösung der System-Differentialgleichung
zu gehen:}
{ Also kommt jetzt der Rechen-Kern:}
{ Zuerst: Anfangsbedingungen einsetzen:}
phio:=0; phipo:=omAn; {phippo:=0;} {Anfangsbedingungen der Magnetrotation (mechanisch)}
{Starten mit gegebener Anfangs-Winkelgeschwindigkeit ist vorgesehen.}
qoT:=CT*Uc; qpoT:=Il; {qppoT:=0;} {Anfangsbedingungen Turbo-Spule (elektrisch)}
{Ein geladener Kondensator im Schwingkreis der Turbo-Spule ist vorgesehen.}
qoI:=0; qpoI:=0; qppoI:=0; {Anfangsbedingungen Input-Spule (elektrisch), zunächst inaktiv}
{ Beim "nullten" Schritt ist der alten Schritt nicht der "minus erste", sondern auch der nullte Schritt:}
{phim:=phio;}{phipm:=phipm;} {phippm:=phippm;}
qmT:=qoT; {qpmT:=qpmT;} {qppmT:=qppmT;}
{qmI:=qoI;} {qpmI:=qpmI;} {qppmI:=qppmI;}
{ Jetzt das eigentliche Lösen der Differential-Gleichung:} {Zunächst noch ohne Input-Spule !!}
For i:=0 to AnzP do
begin
{Initialisierung der Referenz für das Input-Spannungs-Signal:}
If i=0 then iumk:=0;
If i>=1 then {Input-Spannungs-Referenz hier an der Turbo-Spule festmachen.}
begin
steigtM:=steigtO; {alten Flanken-Steigungs-Zustand merken}
If qoT>qmT then steigtO:=true;
If qoT<qmT then steigtO:=false;
If (steigtM)and(Not(steigtO)) then iumk:=i;
end;
{Aktueller Moment der Analyse, laufende Zeit in Sekunden, "Jetzt-Schritt":}
Tjetzt:=i*dt;
{Für den neuen Schritt, wird der alte Vorgänger-Schritt zum vorletzten Schritt heruntergezählt:}
phim:=phio; phipm:=phipo; {phippm:=phippo;} {Drehbewegung}
qmT:=qoT; qpmT:=qpoT; {qppmT:=qppoT;} {Turbo-Spule}
qmI:=qoI; qpmI:=qpoI; qppmI:=qppoI; {Input-Spule}
{Und jetzt rechne ich den neuen Schritt aus:}
{Zuerst die Drehung des Magneten, Drehmoment kommt aus Spulenströmen. Vorhandene Drehmoments-
Berechnung benutzen:}
{KK}phippo:=Schnell_Drehmoment(phim)*qpoT/J; {Upgm "Schnell_Drehmoment" ist skaliert ITurbo=1A &
IInput=0A, geht linear mit dem Turbo-Strom.}
{!! Alle Zeilen mit doppelten Ausrufezeichen dienen der zusätzlichen Aufnahme der Input-Spule.}
{!! phippo:=Drehmoment(phim)/J; {Vollwertige Drehmoment-Berechnung mit Turbo-Spule und Input-Spule,
geht langsam.}
{Für phippo muß ich eine der beiden vorangehenden Alternativen verwenden, je nach dem ob nur die Turbo-
Spule aktiv ist, oder auch die Input-Spule.}
{Falls die Input-Spule auch aktiv ist, dann soll ich "schonda" von Anfang an auf "false" setzen und immer
die komplette Vorbereitung durchrechnen.}
{Alle mit "GG" kommentierten Zeilen dienen einer geschwindigkeits-proportionalen mechanischen
Leistungsentnahme:}
{GG}If i=1 then cr:=crAnfang; {Geschwindigkeits-proportionaler Reibungs-Koeffizient}
{GG}If i>1 then cr:=Reibung_nachregeln; {Dieser wird nachgeregelt, um eine konstante Drehzahl
einzustellen für stabilen Betrieb der Maschine.}
{GG}If phipo>0 then phippo:=phippo-cr*phipm/J; {Die neg. Beschleunigung wirkt immer der Geschwindigkeit
entgegen.}
{GG}If phipo=0 then phippo:=phippo;
{GG}If phipo<0 then phippo:=phippo+cr*phipm/J; {Die neg. Beschleunigung wirkt immer der Geschwindigkeit
entgegen.}
{GG}{Jetzt ist die geschwindigkeits-proportionale Reibung berechnet.}
If (i mod 100000)=0 then write('.');
phipo:=phipm+phippo*dt; {1. Integrationsschritt, ohne mechanische Reibung}
phio:=phim+phipo*dt; {2. Integrationsschritt}
{GG}Preib:=cr*phipm*phipo; {Leistungsentnahme zur geschwindigkeits-proportionalen Reibung}
{GG}Ereib:=Ereib+Preib*dt; {Gesamte über Reibung entnommene Leistung}
{Dann die Turbo-Spule. Gedämpfte elektrische Schwingung, dazu induzierte Spannung aufgrund Magnet-
Drehung:}
{FF}qppoT:=-1/(LT*CT)*qmT-(RT+Rlast)/LT*qpmT; {Dgl. der gedämpfte Schwingung.}
UinduzT:=-Nturbo*(FlussT(phio)-FlussT(phim))/dt;{Wirkung durch die induzierte Spannung (aufgrund der
Magnet-Drehung) hinzunehmen}
qppoT:=qppoT-UinduzT/LT; {Wirkung der induzierte Spannung auf die zweite Ableitung
von q, also "qppoT")}
{??}qpoT:=qpmT+qppoT*dt; {-Rlast/(2*LT)*qpmT*dt;} {1. Integrationsschritt, nach *5 von S.6 im alten Skript
bzw *1 von S.14 im neunen Skript}
qoT:=qmT+qpoT*dt; {2. Integrationsschritt, nach *3 & *4 von S.6 im alten
Skript bzw *1 von S.14 im neunen Skript}
{Dann die Input-Spule:} UinduzI:=0;
qoI:=qmI; qpoI:=qpmI; qppoI:=qppmI; {Die Input-Spule macht noch gar nichts, sie spielt jetzt
noch nicht mit.}
{Und wenn die Input-Spule doch mitspielt, muß ich die nachfolgenden fünf Zeilen zur Input-Spule
aktivieren:}
{!! qppoI:=-1/(LI*CI)*qmI-RI/LI*qpmI+U7/LI; {Dgl. der gedämpfte Schwingung, dazu Störfunktion für
Input-Spannung in den Input-Schwingkreis}
{!! UinduzI:=-Ninput*(FlussI(phio)-FlussI(phim))/dt; {Wirkung durch die induzierte Spannung (aufgrund der
Magnet-Drehung) hinzunehmen}
{!! qppoI:=qppoI-UinduzI/LI; {Wirkung der induzierte Spannung auf die zweite Ableitung
von q, also "qppoT")}
{!! qpoI:=qpmI+qppoI*dt; {1. Integrationsschritt, nach *5 von S.6 im alten Skript
bzw *1 von S.14 im neunen Skript}
{!! qoI:=qmI+qpoI*dt; {2. Integrationsschritt, nach *3 & *4 von S.6 im alten
Skript bzw *1 von S.14 im neunen Skript}
Pzuf:=U7;{*qpoI} {Über die Input-Spannung zugeführte Leistung}
Ezuf:=Ezuf+Pzuf*dt; {Zugeführte Energie über die Input-Spannung}
{Achtung: Die Drehmoments-Schnell-Berechnung "phippo" geht so noch nicht für Turbo-Input-Spule. Dazu muß
ich noch die Ströme in die einzelnen Upgme durchreichen.}
{Jetzt muß ich noch die Maximalwerte für Strom, Spannung und Drehzahl der Auslegung bestimmen:}
If Abs(qoT)>QTmax then QTmax:=Abs(qoT); {Maximum der Ladung im Turbo-Kondensator festhalten}
If Abs(qoI)>QImax then QImax:=Abs(qoI); {Maximum der Ladung im Input-Kondensator festhalten}
If Abs(qpoT)>QpTmax then QpTmax:=Abs(qpoT); {Maximum des Stroms in der Turbo-Spule festhalten}
If Abs(qpoI)>QpImax then QpImax:=Abs(qpoI); {Maximum des Stroms in der Input-Spule festhalten}
If Abs(qppoT)>QppTmax then QppTmax:=Abs(qppoT); {Maximum des Ipunkt in der Turbo-Spule festhalten}
If Abs(qppoI)>QppImax then QppImax:=Abs(qppoI); {Maximum des Ipunkt in der Input-Spule festhalten}
If Abs(phipo)>phipomax then phipomax:=Abs(phipo); {Maximum der Winkelgeschwindigkeit des Magneten
festhalten}
Wentnommen:=Wentnommen+Rlast*qpoT*qpoT*dt; {Summierung der am Lastwiderstand im Turbo-Schwingkreis
entnommenen Gesamtenergie}
{Ggf. muß ich jetzt einen Plot-Punkt für's Excel ausgeben:}
If (i>=PlotAnfang)and(i<=PlotEnde) then {diese Punkte ins Excel plotten}
begin
If ((i-PlotAnfang)mod(PlotStep))=0 then
begin
znr:=Round((i-PlotAnfang)/PlotStep);
Zeit[znr]:=Tjetzt; {Zeitpunkt für Excel abspeichern.}
Q[znr]:=qoT; Qp[znr]:=qpoT; Qpp[znr]:=qppoT; {Turbo-Spule, im Array (und nur dort) ohne
Index "T".}
QI[znr]:=qoI; QpI[znr]:=qpoI; QppI[znr]:=qppoI; {Input-Spule}
phi[znr]:=phio; phip[znr]:=phipo; phipp[znr]:=phippo; {Drehung des Magneten}
KK[znr]:=FlussT(phio); KL[znr]:=FlussI(phio); {Magnetischer Fluß durch die Spulen}
KM[znr]:=UinduzT; KN[znr]:=UinduzI; {In den Spulen induzierte Spannung}
KO[znr]:=1/2*LT*qpoT*qpoT; {Energie in der Input-Spule}
KP[znr]:=1/2*LI*qpoI*qpoI; {Energie in der Turbo-Spule}
KQ[znr]:=1/2*qoT*qoT/CT; {Energie im Input-Kondensator}
KR[znr]:=1/2*qoI*qoI/CI; {Energie im Turbo-Kondensator}
KS[znr]:=1/2*J*phipo*phipo; {Energie der Magnet-Rotation}
KT[znr]:=KO[znr]+KP[znr]+KQ[znr]+KR[znr]+KS[znr]; {Gesamt-Energie im System}
KU[znr]:=Rlast*qpoT*qpoT; {Am Lastwiderstand entnommene Leistung, nur Turbo-seitig}
KV[znr]:=U7; {Kontrolle der Input-Spannung im Input-Schwingkreis}
KW[znr]:=Pzuf; {Zugeführte Leistung über die Input-Spannung}
KX[znr]:=cr; {geregelter Reibungskoeffizient zur mechanischen Leistungsentnahme}
KY[znr]:=Preib; {Entnommene mechanische Leistung, emuliert durch geschwindigkeits-proportionale
Reibung}
KZ[znr]:=0; {Noch eine Spalte in Reserve, für optionale Daten, die ins Excel sollen.}
LPP:=znr; {Letzter Plot-Punkt; Wert wird für Datenausgabe benutzt -> ExcelLangAusgabe}
end;
end;
AnfEnergie:=KU[0]; {Anfangs-Gesamt-Energie im System}
EndEnergie:=KU[LPP]; {End-Gesamt-Energie im System}
end;
Writeln; Writeln('Anzahl Datenpunkte fuer Excel-Plot: LPP = ',LPP);
Writeln; Writeln('Anzeigen der Amplituden der Auslegung: (nicht Effektivwerte, sondern Spitze)');
Writeln('Input-Kondensator, Spannung, UmaxI =',QImax/CI,' Volt'); {Maximum der Ladung im Input-
Kondensator}
Writeln('Turbo-Kondensator, Spannung, UmaxT =',QTmax/CT,' Volt'); {Maximum der Ladung im Turbo-
Kondensator}
Writeln('Input-Schwingkreis, Strom, ImaxI =',QpImax,' Ampere'); {Maximum des Stroms in der Input-
Spule}
Writeln('Turbo-Schwingkreis, Strom, ImaxT =',QpTmax,' Ampere'); {Maximum des Stroms in der Turbo-
Spule}
Writeln('Input-Spule, Spannung, UmaxSI=',LI*QppImax,' Volt'); {Maximum des Ipunkt in der Input-
Spule}
Writeln('Turbo-Spule, Spannung, UmaxST=',LT*QppTmax,' Volt'); {Maximum des Ipunkt in der Turbo-
Spule}
Writeln('Maximale Magnet-Rotationsdrehzahl =',phipomax,' rad/sec');{Maximum der Winkelgeschwindigkeit
des Magneten}
Writeln('Maximale Magnet-Rotationsdrehzahl=',phipomax/2/pi*60:15:6,' U/min.'); {Maximum der
Winkelgeschwindigkeit des Magneten}
Writeln('Am Ende erreichte End-Drehzahl = ',phip[LPP]/2/pi*60:15:6,' U/min.');
Writeln;
Writeln('Anfangs-Energie im System: ',AnfEnergie:18:11,' Joule');
Writeln('End-Energie im System: ',EndEnergie:18:11,' Joule');
Writeln('Energie-Zunahme im System: ',(EndEnergie-AnfEnergie):18:11,' Joule');
Writeln('Leistungs-Aenderung im System:',(EndEnergie-AnfEnergie)/(AnzP*dt):18:11,' Watt');
Writeln('Am Lastwiderstand entnommene Gesamtenergie = ',Wentnommen:18:11,' Joule');
Writeln('entsprechend einer mittleren entnommenen Leistg:',Wentnommen/(AnzP*dt):18:11,' Watt');
Writeln('Ueber Input-Spannung zugefuehrte Gesamt-Energie: ',Ezuf,' Joule');
Writeln('entsprechend einer mittleren zugefuehrten Leistg:',Ezuf/(AnzP*dt),' Watt');
Writeln('Gesamte mechanisch entnommene Energie = ',Ereib:18:11,' Joule');
Writeln('entsprechend einer mittleren Leistung = ',Ereib/(AnzP*dt):18:11,' Watt');
Writeln('bei einer Betrachtungs-Dauer von',(AnzP*dt):18:11,' sec.');
ExcelLangAusgabe('test.dat',25);
Writeln; Writeln('Fertig gerechnet -> Adele.');
Wait; Wait;
End.
