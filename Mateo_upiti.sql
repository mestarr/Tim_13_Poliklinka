-- Mateo Kruljac - upiti 

-- 1. Cjenik aktivnih usluga po odjelima
-- Koje su aktivne usluge dostupne po odjelima?
SELECT
    o.naziv AS odjel,
    u.sifra,
    u.naziv AS usluga,
    u.trajanje_pregleda_minute,
    cu.iznos,
    cu.valuta,
    cu.porezna_stopa
FROM usluga u
JOIN odjel o ON o.id = u.id_odjel
JOIN cijena_usluge cu ON cu.id_usluga = u.id
WHERE u.aktivna = TRUE
  AND CURDATE() BETWEEN cu.datum_od AND cu.datum_do
ORDER BY o.naziv, u.naziv;

-- 2. Najčešće tražene usluge u terminima
-- Koje se usluge najčešće traže pri naručivanju termina?
SELECT
    u.naziv AS usluga,
    o.naziv AS odjel,
    COUNT(tpu.id) AS broj_termina
FROM termin_pacijenta_usluga tpu
JOIN usluga u ON u.id = tpu.id_usluga
LEFT JOIN odjel o ON o.id = u.id_odjel
GROUP BY u.id, u.naziv, o.naziv
ORDER BY broj_termina DESC, usluga
LIMIT 20;

-- 3. Pregledi i obavljene usluge s iznosima
-- Koje su usluge obavljene na pregledima i koliki su njihovi iznosi?
SELECT
    pr.id AS id_pregled,
    p.ime,
    p.prezime,
    u.naziv AS usluga,
    pu.kolicina,
    pu.cijena,
    pu.popust,
    pu.ukupni_iznos
FROM pregled_usluga pu
JOIN pregled pr ON pr.id = pu.id_pregled
JOIN pacijent p ON p.id = pr.id_pacijent
JOIN usluga u ON u.id = pu.id_usluga
ORDER BY pr.id, u.naziv;

-- 4. Ukupni iznos obavljenih usluga po odjelu
-- Koji odjeli ostvaruju najveći iznos kroz obavljene usluge?
SELECT
    o.naziv AS odjel,
    COUNT(pu.id) AS broj_obavljenih_usluga,
    ROUND(SUM(pu.ukupni_iznos), 2) AS ukupni_iznos
FROM pregled_usluga pu
JOIN usluga u ON u.id = pu.id_usluga
JOIN odjel o ON o.id = u.id_odjel
GROUP BY o.id, o.naziv
ORDER BY ukupni_iznos DESC;

-- 5. Odjeli s najvećom prosječnom cijenom usluge
-- Koji odjeli imaju najveću prosječnu cijenu usluga?
SELECT
    o.naziv AS odjel,
    COUNT(u.id) AS broj_usluga,
    ROUND(AVG(cu.iznos), 2) AS prosjecna_cijena
FROM odjel o
JOIN usluga u ON u.id_odjel = o.id
JOIN cijena_usluge cu ON cu.id_usluga = u.id
WHERE CURDATE() BETWEEN cu.datum_od AND cu.datum_do
GROUP BY o.id, o.naziv
ORDER BY prosjecna_cijena DESC;

-- 6. Usluge koje donose najveći prihod po mjesecu
-- Koje usluge po mjesecima ostvaruju najveći prihod?
WITH prihod_usluga AS (
    SELECT
        DATE_FORMAT(pr.vrijeme_odrzavanja_pregleda, '%Y-%m') AS mjesec,
        u.id AS id_usluga,
        u.naziv AS usluga,
        o.naziv AS odjel,
        COUNT(pu.id) AS broj_obavljanja,
        ROUND(SUM(pu.ukupni_iznos), 2) AS prihod
    FROM pregled_usluga pu
    JOIN pregled pr ON pr.id = pu.id_pregled
    JOIN usluga u ON u.id = pu.id_usluga
    JOIN odjel o ON o.id = u.id_odjel
    GROUP BY DATE_FORMAT(pr.vrijeme_odrzavanja_pregleda, '%Y-%m'), u.id, u.naziv, o.naziv
),
rangirano AS (
    SELECT
        prihod_usluga.*,
        ROW_NUMBER() OVER (PARTITION BY mjesec ORDER BY prihod DESC) AS rang_u_mjesecu
    FROM prihod_usluga
)
SELECT *
FROM rangirano
WHERE rang_u_mjesecu <= 5
ORDER BY mjesec, rang_u_mjesecu;

