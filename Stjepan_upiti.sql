-- Stjepan Paun - upiti

-- 1. Dijagnoze za jedan konkretan pregled
-- Koje dijagnoze pripadaju određenom pregledu?
SELECT
    pr.id AS id_pregled,
    CONCAT(pa.ime, ' ', pa.prezime) AS pacijent,
    pr.status_pregleda,
    d.sifra,
    d.naziv AS dijagnoza,
    CASE
        WHEN pd.primarna_oznaka = TRUE THEN 'primarna'
        ELSE 'sporedna'
    END AS vrsta_dijagnoze
FROM pregled pr
JOIN pacijent pa ON pa.id = pr.id_pacijent
LEFT JOIN pregled_dijagnoza pd ON pd.id_pregled = pr.id
LEFT JOIN dijagnoza d ON d.id = pd.id_dijagnoza
WHERE pr.id = 1
ORDER BY pd.primarna_oznaka DESC, d.sifra;

-- 2. Dodavanje nove dijagnoze
-- Kako dodati novu dijagnozu u šifrarnik dijagnoza?
INSERT IGNORE INTO dijagnoza (
    sifra,
    naziv,
    opis
)
VALUES (
    'P98',
    'Hipertenzija - kontrola',
    'Dodatna dijagnoza uz prezentaciju.'
);

-- 3. Povezivanje dijagnoze s pregledom
-- Kako povezati dijagnozu s pregledom?
INSERT INTO pregled_dijagnoza (
    id_pregled,
    id_dijagnoza,
    primarna_oznaka
)
SELECT
    1,
    d.id,
    FALSE
FROM dijagnoza d
WHERE d.sifra = 'P98'
  AND NOT EXISTS (
      SELECT 1
      FROM pregled_dijagnoza pd
      WHERE pd.id_pregled = 1
        AND pd.id_dijagnoza = d.id
  );

-- 4. Dodavanje terapije za pregled
-- Kako dodati terapiju za odabrani pregled?
INSERT INTO terapija (
    id_pregled,
    id_nalaz,
    preporuceno_u,
    tekst_preporuke,
    potrebna_kontrola,
    datum_kontrole,
    napomena
)
VALUES (
    1,
    1,
    '2026-03-01 11:00:00',
    'Kontrola tlaka - dopuna terapije.',
    TRUE,
    '2026-06-01',
    '-'
);

-- 5. Dodavanje preporučenog lijeka
-- Kako dodati preporučeni lijek za terapiju?
INSERT INTO preporuceni_lijek (
    id_terapija,
    naziv_lijeka,
    doziranje,
    uputa,
    trajanje_dana,
    napomena
)
VALUES (
    LAST_INSERT_ID(),
    'Ramipril',
    '5 mg',
    '1 tableta ujutro',
    90,
    '-'
);

-- 6. Najčešće dijagnoze po pregledima
-- Koje dijagnoze pripadaju pregledima?
SELECT
    pr.id AS id_pregled,
    CONCAT(pa.ime, ' ', pa.prezime) AS pacijent,
    d.sifra AS sifra_dijagnoze,
    d.naziv AS dijagnoza,
    CASE
        WHEN pd.primarna_oznaka = TRUE THEN 'primarna'
        ELSE 'sporedna'
    END AS vrsta_dijagnoze
FROM pregled_dijagnoza pd
JOIN pregled pr ON pr.id = pd.id_pregled
JOIN dijagnoza d ON d.id = pd.id_dijagnoza
JOIN pacijent pa ON pa.id = pr.id_pacijent
WHERE pr.id = 1
ORDER BY pd.primarna_oznaka DESC, d.sifra;

-- 7. Terapije i lijekovi po pregledima
-- PKoje terapije i lijekovi pripadaju pregledu?
SELECT
    pr.id AS id_pregled,
    CONCAT(pa.ime, ' ', pa.prezime) AS pacijent,
    t.preporuceno_u,
    t.tekst_preporuke,
    t.potrebna_kontrola,
    t.datum_kontrole,
    pl.naziv_lijeka,
    pl.doziranje,
    pl.uputa,
    pl.trajanje_dana
FROM terapija t
JOIN pregled pr ON pr.id = t.id_pregled
JOIN pacijent pa ON pa.id = pr.id_pacijent
LEFT JOIN preporuceni_lijek pl ON pl.id_terapija = t.id
WHERE pr.id = 1
ORDER BY pl.naziv_lijeka;

