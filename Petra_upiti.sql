-- Petra Podunavac - upiti

-- 1. Cjeloviti karton pacijenta kroz termine, preglede, nalaze i račune
-- Kako izgleda cjeloviti pregled podataka o pacijentu kroz termine, preglede, nalaze i račune?
SELECT
    p.id AS id_pacijent,
    p.ime,
    p.prezime,
    t.id AS id_termin,
    t.vrijeme_odrzavanja,
    pr.id AS id_pregled,
    n.id AS id_nalaz,
    r.broj_racuna,
    r.status_racuna,
    r.ukupno_za_placanje
FROM pacijent p
LEFT JOIN termin_pacijenta t ON t.id_pacijent = p.id
LEFT JOIN pregled pr ON pr.id_termin_pacijenta = t.id
LEFT JOIN nalaz n ON n.id_pregled = pr.id
LEFT JOIN racun r ON r.id_pregled = pr.id
ORDER BY p.id, t.vrijeme_odrzavanja;

-- 2. Pacijenti s povezanim pregledom, nalazom, terapijom i računom
-- Koji pacijenti imaju kompletno evidentiran proces od pregleda do računa?
SELECT
    p.id AS id_pacijent,
    CONCAT(p.ime, ' ', p.prezime) AS pacijent,
    pr.id AS id_pregled,
    pr.vrijeme_odrzavanja_pregleda,
    n.id AS id_nalaz,
    n.status_nalaza,
    t.id AS id_terapija,
    r.broj_racuna,
    r.status_racuna,
    r.ukupno_za_placanje
FROM pacijent p
JOIN pregled pr ON pr.id_pacijent = p.id
JOIN nalaz n ON n.id_pregled = pr.id
JOIN terapija t ON t.id_pregled = pr.id
JOIN racun r ON r.id_pregled = pr.id
ORDER BY pr.vrijeme_odrzavanja_pregleda DESC;

-- 3. Prosječno vrijeme od termina do pregleda po odjelu
-- U kojim odjelima je najveće prosječno odstupanje između termina i stvarnog pregleda?
SELECT
    o.naziv AS odjel,
    COUNT(pr.id) AS broj_pregleda,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, tp.vrijeme_odrzavanja, pr.vrijeme_odrzavanja_pregleda)), 2) AS prosjecno_kasnjenje_min,
    MIN(TIMESTAMPDIFF(MINUTE, tp.vrijeme_odrzavanja, pr.vrijeme_odrzavanja_pregleda)) AS minimalno_kasnjenje_min,
    MAX(TIMESTAMPDIFF(MINUTE, tp.vrijeme_odrzavanja, pr.vrijeme_odrzavanja_pregleda)) AS maksimalno_kasnjenje_min
FROM pregled pr
JOIN termin_pacijenta tp ON tp.id = pr.id_termin_pacijenta
JOIN termin_pacijenta_usluga tpu ON tpu.id_termin_pacijenta = tp.id
JOIN usluga u ON u.id = tpu.id_usluga
JOIN odjel o ON o.id = u.id_odjel
GROUP BY o.id, o.naziv
ORDER BY prosjecno_kasnjenje_min DESC;

-- 4. Pacijenti s više različitih specijalizacija
-- Koji su pacijenti imali preglede kod zaposlenika različitih specijalizacija?
SELECT
    p.id AS id_pacijent,
    CONCAT(p.ime, ' ', p.prezime) AS pacijent,
    COUNT(DISTINCT s.id) AS broj_specijalizacija,
    GROUP_CONCAT(DISTINCT s.naziv ORDER BY s.naziv SEPARATOR ', ') AS specijalizacije
FROM pacijent p
JOIN pregled pr ON pr.id_pacijent = p.id
LEFT JOIN zaposlenik z ON z.id = pr.id_zaposlenik
LEFT JOIN specijalizacija s ON s.id = z.id_specijalizacija
GROUP BY p.id, pacijent
HAVING COUNT(DISTINCT s.id) >= 2
ORDER BY broj_specijalizacija DESC, pacijent;

-- 5. Pregledi bez nalaza, terapije ili računa
-- Koji pregledi nemaju evidentiran nalaz, terapiju ili račun?
SELECT
    pr.id AS id_pregled,
    p.ime,
    p.prezime,
    pr.vrijeme_odrzavanja_pregleda,
    CASE WHEN n.id IS NULL THEN 'nema nalaz' ELSE 'ima nalaz' END AS nalaz_status,
    CASE WHEN t.id IS NULL THEN 'nema terapiju' ELSE 'ima terapiju' END AS terapija_status,
    CASE WHEN r.id IS NULL THEN 'nema racun' ELSE 'ima racun' END AS racun_status
FROM pregled pr
JOIN pacijent p ON p.id = pr.id_pacijent
LEFT JOIN nalaz n ON n.id_pregled = pr.id
LEFT JOIN terapija t ON t.id_pregled = pr.id
LEFT JOIN racun r ON r.id_pregled = pr.id
WHERE n.id IS NULL OR t.id IS NULL OR r.id IS NULL
ORDER BY pr.vrijeme_odrzavanja_pregleda DESC;

-- 6. Usporedba planiranog trajanja termina i trajanja usluga
-- Kod kojih termina postoji najveća razlika između planiranog trajanja i trajanja obavljenih usluga?
SELECT
    tp.id AS id_termina,
    p.ime,
    p.prezime,
    tp.procjenjeno_trajanje_pregleda_minute AS planirano_minuta,
    SUM(u.trajanje_pregleda_minute) AS zbroj_trajanja_usluga,
    SUM(u.trajanje_pregleda_minute) - tp.procjenjeno_trajanje_pregleda_minute AS razlika_minuta
FROM termin_pacijenta tp
JOIN pacijent p ON p.id = tp.id_pacijent
JOIN termin_pacijenta_usluga tpu ON tpu.id_termin_pacijenta = tp.id
JOIN usluga u ON u.id = tpu.id_usluga
GROUP BY tp.id, p.ime, p.prezime, tp.procjenjeno_trajanje_pregleda_minute
ORDER BY ABS(razlika_minuta) DESC;
