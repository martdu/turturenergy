Program Oszillator_im_DFEM_mit_OVER_UNITY;
{$APPTYPE CONSOLE}
uses
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;
Var epo,muo : Double; {Naturkonstanten}
c : Double; {Propagationsgeschwindigkeit der Wellen und Felder}
D : Double; {Federkonstante}
m1,m2 : Double; {Massen der beiden Körper}
Q1,Q2 : Double; {Ladungen der beiden Körper}
RLL,FL : Double; {Ruhelage-Länge und gespannte Länge der Feder}
r : Double; {Abstand für die verzögerte Propagation der Felder}
diff,ds,ds1 : Double; {Hilfsvariablen}
FK1,FK2 : Double; {Federkräfte auf die beiden Körper Nr.1 und Nr.2}
FEL1,FEL2 : Double; {Elektrische Kräfte auf die Körper Nr.1 und Nr.2}
delt : Double; {Zeitschritte für die Bewegungen der Ladungen und Felder}
x1,x2,v1,v2 : Array [0..200000] of Real48; {Zeit,Orte,Gescheindigkeiten der Ladungen}
t : Double; {Hilfsvariable für die Laufzeit der Felder vorab}
a1,a2 : Double; {Beschleunigungen der beiden Körper}
i : Integer; {Laufvariable, Zählung der Ladungsorte}
tj,ts,tr : Extended;{Variablen zur Bestimmung der Feld-lauf-dauer in Teil 3}
ianf,iend : Integer; {Anfang und Ende des Plot-Bereichs}
Abstd : Integer; {Jeder wievielte Datenpunkt soll geplottet werden ?}
Ukp,UkpAlt : Double; {Zum Ermitteln der Umkehrpunkte in Teil 3}
unten,neu : Boolean; {Charakterisierung des letzten Umkehrpunktes}
AmplAnf,AmplEnd : Double; {Zwecks Bestimmung der Zunahme der Amplitude}
Reib : Double; {Fuer Reibungskraft}
P : Double; {Leistung}
Pn : Double; {Zahl der Werte zur Leistungsermittlung}
Procedure Wait;
Var Ki : Char;
begin
Write('<W>'); Read(Ki); Write(Ki);
If Ki='e' then Halt;
end;
Procedure Excel_Datenausgabe(Name:String);
Var fout : Text; {Daten-File zum Aufschreiben der Ergebnisse}
Zahl : String;
i,j : Integer; {Laufvariablen}
begin {Daten für Excel aufbereiten und ausgeben:}
Assign(fout,Name); Rewrite(fout); {File öffnen}
For i:=ianf to iend do {von "plotanf" bis "plotend"}
begin
If (i mod Abstd)=0 then
begin
{ Zuerst die Zeit als Argument:}
Str(i*delT:10:5,Zahl);
For j:=1 to Length(Zahl) do
begin {Keine Dezimalpunkte verwenden, sondern Kommata}
If Zahl[j]<>'.' then write(fout,Zahl[j]);
If Zahl[j]='.' then write(fout,',');
end;
Write(fout,chr(9)); {Daten-Trennung}
{ Dann als erste Funktion die Position des Teilchens 1:}
Str(x1[i]:10:5,Zahl);
For j:=1 to Length(Zahl) do
begin {Keine Dezimalpunkte verwenden, sondern Kommata}
If Zahl[j]<>'.' then write(fout,Zahl[j]);
If Zahl[j]='.' then write(fout,',');
end;
Write(fout,chr(9)); {Daten-Trennung}
{ Dann als zweite Funktion die Position des Teilchens 2:}
Str(x2[i]:10:5,Zahl);
For j:=1 to Length(Zahl) do
begin {Keine Dezimalpunkte verwenden, sondern Kommata}
If Zahl[j]<>'.' then write(fout,Zahl[j]);
If Zahl[j]='.' then write(fout,',');
end;
Write(fout,chr(9)); {Daten-Trennung}
{ Dann als dritte Funktion die Geschwindigkeit des Teilchens 1:}
Str(v1[i]:10:5,Zahl);
For j:=1 to Length(Zahl) do
begin {Keine Dezimalpunkte verwenden, sondern Kommata}
If Zahl[j]<>'.' then write(fout,Zahl[j]);
If Zahl[j]='.' then write(fout,',');
end;
Write(fout,chr(9)); {Daten-Trennung}
{ Dann als vierte Funktion die Geschwindigkeit des Teilchens 2:}
Str(v2[i]:10:5,Zahl);
For j:=1 to Length(Zahl) do
begin {Keine Dezimalpunkte verwenden, sondern Kommata}
If Zahl[j]<>'.' then write(fout,Zahl[j]);
If Zahl[j]='.' then write(fout,',');
end;
Writeln(fout,''); {Zeilen-Trennung}
end;
end;
Close(fout);
end;
Begin {Hauptprogramm}
{ Initialisierung - Vorgabe der Werte: }
D:=0; r:=0; {Zur Vermeidung von Delphi-Meldungen}
epo:=8.854187817E-12;{As/Vm} {Magnetische Feldkonstante, fuer spaeter}
muo:=4*pi*1E-7;{Vs/Am} {Elektrische Feldkonstante, fuer spaeter}
c:=Sqrt(1/muo/epo);{m/s} {Lichtgeschwindigkeit einsetzen, fuer spaeter}
m1:=1;{kg} {Masse des Körpers Nr.1}
m2:=1;{kg} {Masse des Körpers Nr.2}
delt:=1E-3;{sec.} {Äquidistante Zeitschritte für Bewegungen}
ianf:=0; iend:=100000; {Nummer des ersten und letzten Zeitschritts}
Abstd:=2; {Jeder wievielte Datenpunkt soll geplottet werden ?}
Writeln('Oszillator im DFEM mit OVER-UNITY:');
Writeln('epo=',epo:20,'; muo=',muo:20,'; c=',c:20);
Writeln('m1,m2=',m1:15,', ',m2:15,'; D=',D:15);
Writeln;
{ Beginn des Rechenprogramms.}
{ Teil 1 waren Vorbereitungen bei der Programm-Erstellung ohne bleibenden geistigen Nährwert}
{ Teil 2: Test -> anharmonische Schwingung, mit elektr. Ladung, oder Magnet: STATISCH !}
For i:=ianf to iend do
begin
x1[i]:=0; x2[i]:=0; {Orte zu Null setzen}
v1[i]:=0; v2[i]:=0; {Geschwindigkeiten zu Null setzen}
end;
i:=0; {t:=i*delT;} {Zeitschritte in Abständen von delt.}
Q1:=2.01E-5{C}; Q2:=2.01E-5{C}; {Ladungen der beiden Körper}
D:=0.20;{N/m} {Federkonstante}
RLL:=6.0;{m} {Ruhelage-Länge der Feder} {Ruhelage-Positionen bei +/-RLL/2}
x1[0]:=-3.8; x2[0]:=+3.8; {Startpositionen der Massen mit Vorspannung}
v1[0]:=00.00; v2[0]:=00.00; {Startgeschwindigk. der schwingenden Massen}
{ Jetzt beginnt die schrittweise Ermittlung der Bewegung:}
Repeat
i:=i+1;
FL:=x2[i-1]-x1[i-1]; {Federlänge}
FK1:=(FL-RLL)*D; {pos. Kraft zieht nach rechts, neg. Kraft nach links}
FK2:=(RLL-FL)*D; {pos. Kraft zieht nach rechts, neg. Kraft nach links}
FEL1:=0; FEL2:=0;
If FL<=1E-20 then
begin
Writeln;
Writeln('Exception: Federlaenge bei Teil 2 zu kurz in Schritt ',i);
Excel_Datenausgabe('XLS-Nr-02.DAT');
Writeln('Daten wurden gespeichert in "XLS-Nr-02.DAT", dann Abbruch der Berechnung.');
Wait; Halt;
end;
If FL>1E-20 then
begin
FEL1:=+Q1*Q2/4/pi/epo/FL/Abs(FL); {Elektrostatische Kraft zw. Q1 & Q2}
FEL2:=-Q1*Q2/4/pi/epo/FL/Abs(FL); {Elektrostatische Kraft zw. Q1 & Q2}
end;
{Kontrolle:} If i=1 then Writeln('El.-kraefte: ',FEL1,' und ',FEL2,' Newton');
{Kontrolle:} If i=1 then Writeln('Federkraefte: ',FK1, ' und ',FK2,' Newton');
a1:=(FK1+FEL1)/m1; a2:=(FK2+FEL2)/m2; {Beschleunigungen der beiden Körper}
v1[i]:=v1[i-1]+a1*delt; {So verändert die Beschl. die Geschw. des Körpers 1}
v2[i]:=v2[i-1]+a2*delt; {So verändert die Beschl. die Geschw. des Körpers 2}
x1[i]:=x1[i-1]+v1[i-1]*delt; {So verändert die Geschw. die Pos. des Körpers 1}
x2[i]:=x2[i-1]+v2[i-1]*delt; {So verändert die Geschw. die Pos. des Körpers 2}
Until i=iend;
Excel_Datenausgabe('XLS-Nr-02.DAT'); {Orte und Geschw. als Fkt der Zeit}
Writeln('Teil 2 ist fertig.');
{ Teil 3: Test -> Mit endlicher Propagationsgeschwindigkeit der Felder}
P:=0; Pn:=0; {Leistung zu Null setzen}
For i:=ianf to iend do
begin
x1[i]:=0; x2[i]:=0; {Orte zu Null setzen}
v1[i]:=0; v2[i]:=0; {Geschwindigkeiten zu Null setzen}
end;
i:=0; {Laufvariable: Beginn der Zählung der Orte und der Geschwindigkeiten}
c:=1.4; {Sqrt(1/muo/epo)};{m/s} {Hier Propagationsgeschwindigkeit einsetzen}
Q1:=3E-5{C}; Q2:=3E-5{C}; {Ladungen der beiden Körper}
D:=2.7;{N/m} {Federkonstante}
RLL:=8.0;{m} {Ruhelage-Länge der Feder} {Ruhelage-Positionen bei +/-RLL/2}
x1[0]:=-3.0; x2[0]:=+3.0; {Startpositionen der Massen mit Vorspannung}
v1[0]:=00.00; v2[0]:=00.00; {Startgeschwindigk. der schwingenden Massen}
Ukp:=x2[0]; UkpAlt:=Ukp; unten:=true; neu:=true; {Vorgabe des ersten unteren Umkehrpunktes}
Writeln('Umkehrpunkt: ',Ukp:12:6,' m ');
{ Jetzt beginnt die schrittweise Ermittlung der Bewegung:}
Repeat
i:=i+1;
FL:=x2[i-1]-x1[i-1]; {Federlänge}
FK1:=(FL-RLL)*D; {Federkraft: pos. Kraft zieht nach rechts, neg. Kraft nach links}
FK2:=(RLL-FL)*D; {Federkraft: pos. Kraft zieht nach rechts, neg. Kraft nach links}
{ Berechnung der Feld-lauf-dauer, Feld-lauf-strecke und daraus Feld-stärke}
FEL1:=0; FEL2:=0;
tj:=i; ts:=i; {ich nehme i als Maß für die Zeit}
{Zuerst eine natürlichzahlige Iteration:}
{ Writeln('tj=',tj*delt:9:5,' ts=',ts*delt:9:5,'=>',x2[Round(tj)]-x1[Round(ts)]-c*(tj-ts)*delt:9:5); }
Repeat
ts:=ts-1;
diff:=x2[Round(tj)]-x1[Round(ts)]-c*(tj-ts)*delt;
{ Writeln('tj=',tj*delt:9:5,' ts=',ts*delt:9:5,'=>',diff:9:5); }
Until ((diff<0)or(ts<=0));
If diff>=0 then {Vor Beginn beim Zeitpunkt Null waren die Körper am Ausgangspunkt ruhend}
begin
r:=x2[Round(tj)]-x1[0];
{ Writeln('diff>=0; r=',r); }
end;
If diff<0 then {Jetzt noch eine Nachkomma-Positions-Bestimmung als lineare Iteration}
begin
{ Writeln('diff<0 ==> tj=',tj,' ts=',ts);
Write('x2[',Round(tj),']=',x2[Round(tj)]:13:9);
Write(' und x1[',Round(ts),']=',x1[Round(ts)]:13:9);
Write(' und x1[',Round(ts+1),']=',x1[Round(ts+1)]:13:9); Writeln; }
ds:=x2[Round(tj)]-x1[Round(ts)]-c*(tj-ts)*delt;
ds1:=x2[Round(tj)]-x1[Round(ts+1)]-c*(tj-(ts+1))*delt;
{ Writeln('ds1=',ds1:13:9,' und ds=',ds:13:9); }
tr:=ts*delt+delt*(-ds)/(ds1-ds); {für die lineare Interpolation}
tj:=tj*delt;
{ Write('tj=',tj:13:9,' und tr_vor=',tr:13:9); }
tr:=(tj-tr); {interpolierter Feldemissionszeitpunkt}
r:=c*tr; {interpolierter echter Abstand}
{ Writeln(' und tr=',tr:13:9,' und r=',r:13:9); }
end;
If r<=1E-10 then
begin
Writeln;
Writeln('Exception: Federlaenge bei Teil 3 zu kurz in Schritt ',i);
Excel_Datenausgabe('XV-03.DAT');
Writeln('Daten wurden gespeichert in "XV-03.DAT", dann Abbruch der Berechnung.');
Wait; Halt;
end;
If r>1E-10 then {Jetzt in das Coulomb-Gesetz einsetzen:}
begin
FEL1:=+Q1*Q2/4/pi/epo/r/Abs(r); {Elektrostatische Kraft zw. Q1 & Q2}
FEL2:=-Q1*Q2/4/pi/epo/r/Abs(r); {Elektrostatische Kraft zw. Q1 & Q2}
end;
Reib:=0.0; {Reibung: Berechnung beginnt hier.}
If i>=10000 then
begin
If FEL1>0 then FEL1:=FEL1-Reib;
If FEL1<0 then FEL1:=FEL1+Reib;
If FEL2>0 then FEL2:=FEL2-Reib;
If FEL2<0 then FEL2:=FEL2+Reib;
P:=P+Reib*Abs(x1[i]-x1[i-1])/delt;
Pn:=Pn+1;
end; {Reibung: Berechnung endet hier.}
{Kontrolle:} If i=1 then Writeln('El.-kraefte: ',FEL1,' und ',FEL2,' Newton');
{Kontrolle:} If i=1 then Writeln('Federkraefte: ',FK1, ' und ',FK2,' Newton');
a1:=(FK1+FEL1)/m1; a2:=(FK2+FEL2)/m2; {Beschleunigungen der beiden Körper}
v1[i]:=v1[i-1]+a1*delt; {So verändert die Beschl. die Geschw. des Körpers 1}
v2[i]:=v2[i-1]+a2*delt; {So verändert die Beschl. die Geschw. des Körpers 2}
x1[i]:=x1[i-1]+v1[i-1]*delt; {So verändert die Geschw. die Pos. des Körpers 1}
x2[i]:=x2[i-1]+v2[i-1]*delt; {So verändert die Geschw. die Pos. des Körpers 2}
{ If (i mod 1000)=0 then Writeln ('Feldstaerke= ',Q1/4/pi/epo/r/Abs(r),' N/C'); }
{ Bestimmung der Umkehrpunkte, damit ich die Amplituden nicht extra im Excel auswerten muß:}
If unten then
begin
If x2[i]>Ukp then begin Ukp:=x2[i]; end;
If x2[i]<Ukp then
begin
Writeln('Umkehrpunkt: ',Ukp:12:6,' m , Amplitude=',Abs(UkpAlt-Ukp));
If Not(neu) then AmplEnd:=Abs(UkpAlt-Ukp);
If neu then begin AmplAnf:=Abs(UkpAlt-Ukp); neu:=false; end;
unten:=Not(unten); UkpAlt:=Ukp;
end;
end;
If Not(unten) then
begin
If x2[i]<Ukp then begin Ukp:=x2[i]; end;
If x2[i]>Ukp then
begin
Writeln('Umkehrpunkt: ',Ukp:12:6,' m , Amplitude=',Abs(UkpAlt-Ukp));
If Not(neu) then AmplEnd:=Abs(UkpAlt-Ukp);
If neu then begin AmplAnf:=Abs(UkpAlt-Ukp); neu:=false; end;
unten:=Not(unten); UkpAlt:=Ukp;
end;
end;
Until i=iend;
Writeln('Zunahme der Amplitude: ',AmplEnd-AmplAnf:12:6,' Meter. ');
Writeln('Die Leistung lautet',P/Pn,' Watt.');
Excel_Datenausgabe('XV-03.DAT'); {Orte und Geschw. als Fkt der Zeit}
Wait; Wait;
End.
