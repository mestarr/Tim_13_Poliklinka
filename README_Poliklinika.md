# Informacijski sustav za upravljanje pacijentima i organizaciju rada poliklinike

Ovaj repozitorij sadrži projektni zadatak iz kolegija **Baze podataka I**. Projekt je izrađen kao relacijska baza podataka za prikaz rada poliklinike kroz organizacijski, medicinski i financijski dio sustava.

## Tim 13

- Mateo Kruljac
- Stjepan Paun
- Petra Podunavac
- Ante Orlović
- Ante Skroče

## Opis projekta

Cilj projekta je osmisliti i implementirati bazu podataka koja prati osnovni tijek rada poliklinike. Sustav obuhvaća evidentiranje pacijenata, naručivanje termina, provedbu pregleda, vođenje nalaza, terapija i preporučenih lijekova te financijski dio koji uključuje račune, stavke računa, uplate i načine plaćanja.

Baza koristi testne podatke izrađene isključivo za potrebe demonstracije funkcionalnosti sustava. Podaci nisu stvarni medicinski podaci.

## Sadržaj projekta

Projekt uključuje:

- ER dijagram izrađen u Lucidchartu
- EER dijagram izrađen u MySQL Workbenchu
- SQL DDL skriptu za izradu baze i tablica
- SQL insert skriptu za unos testnih podataka
- CSV datoteke s podacima
- SQL upite po članovima tima
- projektnu dokumentaciju
- završnu video prezentaciju projekta

## Glavne cjeline baze

Baza je organizirana kroz nekoliko povezanih cjelina:

- organizacijski dio: odjeli, ordinacije, specijalizacije, zaposlenici i raspored zaposlenika
- naručivanje pacijenata: pacijenti, termini i usluge vezane uz termine
- medicinski dio: pregledi, dijagnoze, nalazi, laboratorijski parametri i laboratorijski rezultati
- terapijski dio: terapije i preporučeni lijekovi
- financijski dio: računi, stavke računa, uplate i načini plaćanja

## Pokretanje projekta u MySQL Workbenchu

1. Otvoriti **MySQL Workbench**.
2. Spojiti se na lokalni MySQL server.
3. Pokrenuti DDL skriptu:

```sql
poliklinika_mysql_ddl.sql
```

4. Nakon uspješnog kreiranja baze i tablica pokrenuti insert skriptu:

```sql
poliklinika_seed_inserts.sql
```

5. Provjeriti podatke jednostavnim SELECT upitima, primjerice:

```sql
SELECT * FROM pacijent;
SELECT * FROM zaposlenik;
SELECT * FROM pregled;
SELECT * FROM racun;
```

6. Nakon toga pokrenuti SQL upite po članovima tima.

## SQL upiti po članovima tima

Upiti su podijeljeni prema članovima tima:

- Mateo Kruljac: usluge, cijene i prihodi po odjelima
- Stjepan Paun: dijagnoze, terapije i preporučeni lijekovi
- Petra Podunavac: cjeloviti proces pacijenta kroz termine, preglede, nalaze i račune
- Ante Orlović: financijska i menadžerska analiza sustava
- Ante Skroče: zakazani termini, raspored zaposlenika, računi i naplata

## CSV datoteke

CSV paket sadrži zasebnu CSV datoteku za svaku tablicu u bazi. Datoteke služe za pregled podataka izvan MySQL Workbencha ili za ručni unos podataka ako je potrebno.

## Korišteni alati

U izradi projekta korišteni su:

- MySQL Workbench
- Lucidchart
- SQL
- CSV format
- LibreOffice Writer / Microsoft Word / PDF
- GitHub
- alati za snimanje i obradu videozapisa

## Napomena

Projekt je izrađen za potrebe kolegija **Baze podataka I** i služi za demonstraciju modeliranja, izrade i korištenja relacijske baze podataka. Baza ne koristi stvarne podatke pacijenata, nego testne podatke osmišljene za potrebe projekta.
