-- Ante Orlović - upiti

-- 1. Najprofitabilnije usluge
-- Koje usluge ostvaruju najveći prihod?
SELECT
  u.naziv AS usluga,
  COUNT(pu.id) AS broj_izvrsenja,
  ROUND(SUM(pu.ukupni_iznos), 2) AS ukupni_prihod
FROM pregled_usluga pu
JOIN usluga u ON u.id = pu.id_usluga
GROUP BY u.id, u.naziv
ORDER BY ukupni_prihod DESC
LIMIT 10;

-- 2. Učestalost dijagnoza
-- Koje se dijagnoze najčešće pojavljuju na završenim pregledima?
SELECT
  d.sifra,
  d.naziv,
  COUNT(pd.id) AS broj_pojavljivanja
FROM dijagnoza d
JOIN pregled_dijagnoza pd ON pd.id_dijagnoza = d.id
JOIN pregled p ON p.id = pd.id_pregled
WHERE p.status_pregleda = 'ZAVRSEN'
GROUP BY d.id, d.sifra, d.naziv
ORDER BY broj_pojavljivanja DESC;

-- 3. Neplaćeni računi i financijski rizik
-- Koliki je broj neplaćenih računa i ukupan dug?
SELECT
  COUNT(*) AS broj_neplacenih_racuna,
  SUM(ukupno_za_placanje) AS ukupni_dug
FROM racun
WHERE status_racuna = 'IZDAN'
  AND datum_dospijeca < CURRENT_DATE;

-- 4. Promet i prihod po mjesecima
-- Kakav je mjesečni promet i prihod po računima?
SELECT
  YEAR(r.datum_izdavanja) AS godina,
  MONTH(r.datum_izdavanja) AS mjesec,
  COUNT(r.id) AS broj_racuna,
  SUM(r.ukupno_bez_poreza) AS prihod_bez_poreza,
  SUM(r.ukupni_porez) AS porez,
  SUM(r.ukupno_za_placanje) AS ukupni_prihod
FROM racun r
WHERE r.status_racuna IN ('IZDAN','PLACEN')
GROUP BY YEAR(r.datum_izdavanja), MONTH(r.datum_izdavanja);

-- 5. Opterećenost zaposlenika pregledima
-- Koji zaposlenici imaju najveću prosječnu vrijednost obavljenih pregleda?
SELECT
z.id AS id_zaposlenik,
CONCAT(z.ime, ' ', z.prezime) AS zaposlenik,
COUNT(DISTINCT pr.id) AS broj_pregleda,
ROUND(SUM(pu.ukupni_iznos), 2) AS ukupna_vrijednost_usluga,
ROUND(SUM(pu.ukupni_iznos) / COUNT(DISTINCT pr.id), 2) AS prosjecna_vrijednost_pregleda
FROM zaposlenik z
JOIN pregled pr ON pr.id_zaposlenik = z.id
JOIN pregled_usluga pu ON pu.id_pregled = pr.id
GROUP BY z.id, z.ime, z.prezime
ORDER BY prosjecna_vrijednost_pregleda DESC;

-- 6. Dolasci i otkazivanja termina
-- Koliko ima termina po pojedinom statusu?
SELECT
  status_termina,
  COUNT(*) AS broj_termina
FROM termin_pacijenta
GROUP BY status_termina;

-- 7. Prihod po odjelima kroz račune
-- Koji odjeli ostvaruju najveći prihod?
SELECT
  o.naziv AS odjel,
  COUNT(DISTINCT r.id) AS broj_racuna,
  SUM(r.ukupno_za_placanje) AS ukupni_prihod
FROM racun r
JOIN pregled p ON p.id = r.id_pregled
JOIN pregled_usluga pu ON pu.id_pregled = p.id
JOIN usluga u ON u.id = pu.id_usluga
JOIN odjel o ON o.id = u.id_odjel
WHERE r.status_racuna IN ('IZDAN','PLACEN')
GROUP BY o.id, o.naziv
ORDER BY ukupni_prihod DESC;

