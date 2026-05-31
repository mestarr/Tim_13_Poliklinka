-- Ante Skroče - upiti

-- 1. Financijski pregled računa
-- Koliko je za svaki račun plaćeno i koliko je ostalo za platiti?
SELECT
    r.broj_racuna,
    CONCAT(p.ime, ' ', p.prezime) AS pacijent,
    r.status_racuna,
    r.ukupno_za_placanje,
    COALESCE(SUM(u.iznos), 0) AS ukupno_placeno,
    ROUND(r.ukupno_za_placanje - COALESCE(SUM(u.iznos), 0), 2) AS dug
FROM racun r
LEFT JOIN pregled pr ON pr.id = r.id_pregled
LEFT JOIN pacijent p ON p.id = COALESCE(r.id_pacijent, pr.id_pacijent)
LEFT JOIN uplata u ON u.id_racun = r.id
GROUP BY
    r.id,
    r.broj_racuna,
    p.ime,
    p.prezime,
    r.status_racuna,
    r.ukupno_za_placanje
ORDER BY dug DESC;

-- 2. Zakazani termini
-- Koji su termini zakazani i s kojim pacijentom, zaposlenikom i ordinacijom su povezani?
SELECT
    tp.id AS id_termina,
    CONCAT(p.ime, ' ', p.prezime) AS pacijent,
    CONCAT(z.ime, ' ', z.prezime) AS zaposlenik,
    o.naziv AS ordinacija,
    tp.vrijeme_odrzavanja,
    tp.status_termina
FROM termin_pacijenta tp
JOIN pacijent p ON p.id = tp.id_pacijent
LEFT JOIN zaposlenik z ON z.id = tp.id_zaposlenik
JOIN ordinacija o ON o.id = tp.id_ordinacija
WHERE tp.status_termina = 'ZAKAZAN'
ORDER BY tp.vrijeme_odrzavanja;

-- 3. Broj pregleda po zaposleniku
-- Koliko pregleda je obavio svaki zaposlenik?
SELECT
    z.id AS id_zaposlenik,
    CONCAT(z.ime, ' ', z.prezime) AS zaposlenik,
    z.titula,
    COUNT(pr.id) AS broj_pregleda
FROM zaposlenik z
LEFT JOIN pregled pr ON pr.id_zaposlenik = z.id
GROUP BY
    z.id,
    z.ime,
    z.prezime,
    z.titula
ORDER BY broj_pregleda DESC, zaposlenik;

-- 4. Raspored zaposlenika
-- Kakav je raspored rada zaposlenika?
SELECT
    z.id AS id_zaposlenik,
    CONCAT(z.ime, ' ', z.prezime) AS zaposlenik,
    s.naziv AS specijalizacija,
    rz.datum,
    rz.vrijeme_od,
    rz.vrijeme_do
FROM raspored_zaposlenika rz
JOIN zaposlenik z ON z.id = rz.id_zaposlenik
JOIN specijalizacija s ON s.id = z.id_specijalizacija
ORDER BY rz.datum, rz.vrijeme_od, zaposlenik;

-- 5. Naplaćeni računi po mjesecu
-- Koliko je računa plaćeno po mjesecima?
SELECT
    DATE_FORMAT(r.datum_izdavanja, '%Y-%m') AS mjesec,
    COUNT(r.id) AS broj_racuna,
    ROUND(SUM(r.ukupno_za_placanje), 2) AS ukupno_naplaceno
FROM racun r
WHERE r.status_racuna = 'PLACEN'
GROUP BY DATE_FORMAT(r.datum_izdavanja, '%Y-%m')
ORDER BY mjesec DESC;

-- 6. Dobna struktura pacijenata i potrošnja
-- Kako su pacijenti raspoređeni po dobnim skupinama i potrošnji?
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, p.datum_rodjenja, CURDATE()) < 18 THEN '0-17'
        WHEN TIMESTAMPDIFF(YEAR, p.datum_rodjenja, CURDATE()) BETWEEN 18 AND 39 THEN '18-39'
        WHEN TIMESTAMPDIFF(YEAR, p.datum_rodjenja, CURDATE()) BETWEEN 40 AND 64 THEN '40-64'
        ELSE '65+'
    END AS dobna_skupina,
    COUNT(DISTINCT p.id) AS broj_pacijenata,
    ROUND(COALESCE(SUM(r.ukupno_za_placanje), 0), 2) AS ukupna_potrosnja
FROM pacijent p
LEFT JOIN pregled pr ON pr.id_pacijent = p.id
LEFT JOIN racun r ON r.id_pacijent = p.id OR r.id_pregled = pr.id
GROUP BY dobna_skupina
ORDER BY dobna_skupina;

