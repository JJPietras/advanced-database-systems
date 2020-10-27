/************************************************
 *												*
 *	Zadanie: 2 (Biuro)							*
 *	Termin:  27.10.2020							*
 *												*
 *	Autor:   Patryk  Amsolik (224246)			*
 *	Autor:   Jakub   Pietras (224404)			*
 *												*
 ************************************************/
 

--1	Wy�wietl zawarto�� ka�dej z tabeli schematu

	SELECT * FROM biura
	SELECT * FROM biura2
	SELECT * FROM klienci
	SELECT * FROM nieruchomosci
	SELECT * FROM nieruchomosci2
	SELECT * FROM personel
	SELECT * FROM rejestracje
	SELECT * FROM wizyty
	SELECT * FROM wlasciciele
	SELECT * FROM wynajecia



--2	Sprawd�, ile razy by�a wynajmowana i ogl�dana ka�da nieruchomo��

	SELECT nieruchomoscNr,
	(SELECT COUNT(*) FROM wizyty w1 WHERE w1.nieruchomoscnr = w.nieruchomoscNr) AS ile_wizyt,
	(SELECT COUNT(*) FROM wynajecia w2 WHERE w2.nieruchomoscNr = w.nieruchomoscNr) AS ile_wynajmow 
	FROM wynajecia w
	GROUP BY nieruchomoscNr



--3	Sprawd�, o ile procent wzr�s� czynsz od pierwszego wynajmu do chwili obecnej 
--	(warto�� aktualnego czynszu znajduje si� w tabeli nieruchomo�ci, poprzednie 
--	warto�ci w wynaj�cia). Wyniki podaj w postaci ...%

	-- �LE WYST�PI� POWT�RZENIA

	SELECT n.nieruchomoscnr, Str(n.czynsz * 100 / w.czynsz - 100) + '%'
	FROM nieruchomosci n
	INNER JOIN wynajecia w ON n.nieruchomoscnr = w.nieruchomoscNr
	WHERE w.nieruchomoscNr = n.nieruchomoscnr
	ORDER BY n.nieruchomoscnr

	--PRAWID�OWO

	SELECT N1.nieruchomoscNr, str((N1.Czynsz*100 / W1.Czynsz) -100) + '%' AS Podwyzka
	FROM nieruchomosci N1, wynajecia W1
	WHERE N1.nieruchomoscnr = w1.nieruchomoscNr AND w1.od_kiedy = (
	SELECT min(W2.Od_kiedy) FROM wynajecia W2 WHERE W2.nieruchomoscNr = N1.nieruchomoscnr)




--4	Podaj, ile ��cznie zap�acono czynszu za ka�de wynajmowane mieszkanie 
--	(wysoko�� czynszu w tabeli podawana jest na miesi�c)

	SELECT nieruchomoscNr, SUM(czynsz * (DATEDIFF(MONTH, od_kiedy, do_kiedy) + 1))
	FROM wynajecia
	GROUP BY nieruchomoscNr



--5	Zak�adaj�c, �e 30% czynszu z wynajmu pobiera biuro, podaj, ile zarobi�o ka�de biuro

	SELECT n.biuroNr, SUM(w.czynsz * (DATEDIFF(MONTH, od_kiedy, do_kiedy) + 1)) * 0.3
	FROM wynajecia w
	INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
	GROUP BY n.biuroNr



--6	Podaj nazw� miasta, w kt�rym:

--		a) biura wynaj�y najwi�cej mieszka� (liczy si� ilo��)

		SELECT miasto, COUNT(*) AS ile
		FROM wynajecia w
		INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
		GROUP BY miasto
		ORDER BY ile DESC

--		b) przych�d z wynajmu by� najwy�szy (liczy si� czas)

		SELECT miasto, SUM(w.czynsz * (DATEDIFF(MONTH, od_kiedy, do_kiedy) + 1)) AS ile
		FROM wynajecia w
		INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
		WHERE w.nieruchomoscNr = n.nieruchomoscnr
		GROUP BY miasto
		ORDER BY ile DESC



--7	Sprawd�, czy klienci, kt�rzy ogl�dali nieruchomo�ci (wizyty), p�niej j� wynaj�li
--	(podaj numery tych klient�w i nieruchomo�ci)

	SELECT DISTINCT i.klientnr, i.nieruchomoscnr
	FROM wizyty i, wynajecia y
	WHERE i.klientnr = y.klientnr AND i.nieruchomoscnr = y.nieruchomoscNr



--8	Ile nieruchomo�ci ogl�da� ka�dy klient przed wynaj�ciem jednej z nich?

	SELECT w.klientnr, COUNT(DISTINCT w.nieruchomoscnr) 
	FROM wizyty w, wynajecia y
	WHERE w.klientnr = y.klientnr AND w.nieruchomoscnr <> y.nieruchomoscNr
	GROUP BY w.klientnr



--9	Podaj, kt�rzy klienci wynaj�li mieszkanie p�ac�c za czynsz wi�cej ni� deklarowali maksymalnie

	SELECT DISTINCT k.klientnr
	FROM klienci k
	INNER JOIN wynajecia w ON k.klientnr = w.klientnr
	WHERE w.czynsz > k.max_czynsz



--10 Podaj numery biur, kt�re nie oferuj� �adnej nieruchomo�ci

	SELECT biuroNr
	FROM biura
	WHERE biuroNr NOT IN 
	(
		SELECT n.biuroNr 
		FROM wynajecia w 
		INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
	)



--11 Ile kobiet i m�czyzn

--		a) zatrudnia ca�a sie� biur

		SELECT	SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel

--		b) zatrudniaj� poszczeg�lne biura

		SELECT	b.biuroNr,
				SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel
		INNER JOIN biura b ON b.biuroNr = personel.biuroNr
		GROUP BY b.biuroNr

--		c) zatrudniaj� poszczeg�lne miasta

		SELECT	b.miasto,
				SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel
		INNER JOIN biura b ON b.biuroNr = personel.biuroNr
		GROUP BY b.miasto

--		d) jest zatrudnionych na poszczeg�lnych stanowiskach

		SELECT	stanowisko,
				SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel
		GROUP BY stanowisko