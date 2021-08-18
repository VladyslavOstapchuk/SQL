/*Baza danych jest stworzona dla przychowywania informacji o dowodach rejestracyjnych.
Kazdy samochód ma swój numer rejestracyjny, numer VIN, kolor, typ, wlasciciela,
datę waznosci ostatniego przegladu, datę waznosci ubezpieczenia*/


--Usuwam tabeli, gdy istnieją
DROP TABLE IF EXISTS Dowody_rejestracyjne;
DROP TABLE IF EXISTS Samochody;
DROP TABLE IF EXISTS Wlascicieli;
DROP TABLE IF EXISTS Marki;
DROP TABLE IF EXISTS Typy;
DROP TABLE IF EXISTS Kolory;
DROP TABLE IF EXISTS Historia;
GO
--Tworzę tabele 
CREATE TABLE Samochody(
	Numer_VIN VARCHAR(17) NOT NULL,
	id_Marki int NOT NULL,
	id_Typu int NOT NULL,
	id_Koloru int NOT NULL,
	Data_waznosci_ubezpieczenia date NOT NULL,
	Data_waznosci_ostatniego_przegladu date NOT NULL,
	CONSTRAINT Samochody_PK PRIMARY KEY(Numer_VIN)
);

CREATE TABLE Dowody_rejestracyjne(
	Numer_rejestracyjny varchar(8) NOT NULL,
	Numer_VIN varchar(17) NOT NULL,
	Pesel_wlasciciela int NOT NULL,
	CONSTRAINT Dowody_rejestracyjne_PK PRIMARY KEY (Numer_rejestracyjny)
);

--Tabela dla przychowywania historii zmian
CREATE TABLE Historia(
	id INT,
	Data_zmiany	DATE NOT NULL,
	Czas_zmiany TIME NOT NULL,
	Zmiana VARCHAR(80) NOT NULL,
	CONSTRAINT id_PK PRIMARY KEY (id)
);

CREATE TABLE Wlascicieli(
	Pesel int NOT NULL,
	Imie varchar(20)NOT NULL,
	Nazwisko varchar(20) NOT NULL,
	Data_urodzenia date NOT NULL,
	CONSTRAINT Wlascicieli_PK PRIMARY KEY (Pesel)
);

CREATE TABLE Marki(
	id_Marki int NOT NULL,
	Nazwa_marki varchar(20) NOT NULL,
	CONSTRAINT Marki_PK PRIMARY KEY (id_Marki)
);

CREATE TABLE Typy(
	id_Typu int NOT NULL,
	Typ varchar(20) NOT NULL,
	CONSTRAINT Typy_PK PRIMARY KEY (id_Typu)
);

CREATE TABLE Kolory(
	id_Koloru int NOT NULL,
	Nazwa_koloru varchar(20) NOT NULL,
	CONSTRAINT Kolory_PK PRIMARY KEY (id_Koloru)
);
GO

--Dodaję FK
--Dla Dowodów rejestracyjnych
ALTER TABLE Dowody_rejestracyjne ADD CONSTRAINT Dowody_rejestracyjne_Numer_VIN_FK 
FOREIGN KEY (Numer_VIN)
REFERENCES Samochody(Numer_VIN)
ALTER TABLE Dowody_rejestracyjne ADD CONSTRAINT Dowody_rejestracyjne_Pesel
FOREIGN KEY (Pesel_wlasciciela)
REFERENCES Wlascicieli(Pesel);
GO

--Dla Samochodów
ALTER TABLE Samochody ADD CONSTRAINT Samochody_Marki_FK
FOREIGN KEY (id_Marki)
REFERENCES Marki(id_Marki)
ALTER TABLE Samochody ADD CONSTRAINT Samochody_Typy_FK
FOREIGN KEY (id_Typu)
REFERENCES Typy(id_Typu)
ALTER TABLE Samochody ADD CONSTRAINT Samochody_Kolory_FK
FOREIGN KEY (id_Koloru)
REFERENCES Kolory(id_Koloru);
GO

--Usuwam wyzwalacz, gdy już był utworzony
DROP TRIGGER IF EXISTS Dowody_rejestracyjne_wyzwalacz;
GO

--Wyzwalacz dla tabeli dowodów rejestracyjnych
CREATE TRIGGER Samochody_wyzwalacz
ON Samochody
AFTER INSERT
AS
BEGIN
	DECLARE @newID INT=(SELECT MAX(id) + 1 FROM HISTORIA);
	INSERT INTO Historia VALUES (ISNULL(@newID,1),CAST(GETDATE() AS DATE),CAST(GETDATE() AS TIME),'Dodany rekord do tabeli Dowody rejestracyjne')
END;
GO

--Wypełniam tabele dannymi
--Marki
INSERT INTO Marki VALUES (1,'Mercedes');
INSERT INTO Marki VALUES (2,'BMW');
INSERT INTO Marki VALUES (3,'Volkswagen');
INSERT INTO Marki VALUES (4,'Chevrolet');
INSERT INTO Marki VALUES (5,'Lada');

--Typy
INSERT INTO Typy VALUES (1,'Minivan');
INSERT INTO Typy VALUES (2,'Kombi');
INSERT INTO Typy VALUES (3,'VAN');
INSERT INTO Typy VALUES (4,'Kabriolet');
INSERT INTO Typy VALUES (5,'Sedan');

--Kolory
INSERT INTO Kolory VALUES (1,'CZARNY');
INSERT INTO Kolory VALUES (2,'BIALY');
INSERT INTO Kolory VALUES (3,'NIEBIESKI');
INSERT INTO Kolory VALUES (4,'ZIELONY');
INSERT INTO Kolory VALUES (5,'ZOLTY');

--Samochody 
INSERT INTO Samochody VALUES ('123123123', 5, 5, 5, CONVERT(DATE,'12-12-2020', 105), CONVERT(DATE,'12-12-2020', 105));
INSERT INTO Samochody VALUES ('321321321', 2, 1, 4, CONVERT(DATE,'02-11-2018', 105), CONVERT(DATE,'13-02-2018', 105));
INSERT INTO Samochody VALUES ('121212121', 1, 1, 1, CONVERT(DATE,'11-11-2011', 105), CONVERT(DATE,'12-12-2011', 105));
INSERT INTO Samochody VALUES ('333333333', 3, 3, 3, CONVERT(DATE,'03-03-2003', 105), CONVERT(DATE,'03-03-2003', 105));


--Wlascicieli
INSERT INTO Wlascicieli VALUES (123123123,'Vladyslav','Ostapchuk',CONVERT(DATE,'12-11-1998',105));
INSERT INTO Wlascicieli VALUES (123123124,'Powiel','Pasichnik',CONVERT(DATE,'17-09-2001',105));
INSERT INTO Wlascicieli VALUES (123123125,'Kakoj-to','Tip',CONVERT(DATE,'11-11-2011',105));
INSERT INTO Wlascicieli VALUES (123123126,'Valerii','Albertovich',CONVERT(DATE,'12-12-1974',105));

--Dowody rejestracyjne
INSERT INTO Dowody_rejestracyjne 
VALUES ('FK1211DT','321321321',123123123);
INSERT INTO Dowody_rejestracyjne 
VALUES ('FK1211DS','123123123',123123124);
INSERT INTO Dowody_rejestracyjne 
VALUES ('FK1211DP','121212121',123123125);
INSERT INTO Dowody_rejestracyjne 
VALUES ('FK1211DD','333333333',123123126);
GO

--Tworzę procedurę
--Usuwam procedurę gdy już była utworzona
DROP PROCEDURE IF EXISTS PokazHistorie
GO

--Tworzę procedurę Info, która wypisuje wykonane w bazie dannych zmiany  
CREATE PROCEDURE PokazHistorie
AS
BEGIN 
	SELECT Data_zmiany "Data zmiany", Czas_zmiany "Czas zmiany", Zmiana FROM Historia;
END;
GO

--Wykonanie procedury
EXEC PokazHistorie;
GO

--Tworzę procedurę
--Usuwam procedurę gdy już była utworzona
DROP PROCEDURE IF EXISTS Info;
GO

--Tworzę procedurę Info, która wypisuje wszystkie danne o samochodach
CREATE PROCEDURE Info AS
BEGIN
SELECT 
Numer_rejestracyjny AS "Numer rejestracyjny",Nazwa_marki AS "Marka",Typ,Nazwa_koloru AS "Kolor",Imie, Nazwisko,Data_waznosci_ubezpieczenia AS "Data waznosci ubezpieczenia",Data_waznosci_ostatniego_przegladu as "Data waznosci ostatniego przegladu"
FROM Dowody_rejestracyjne AS D
JOIN Samochody AS S ON D.Numer_VIN = S.Numer_VIN
JOIN Wlascicieli AS W ON D.Pesel_wlasciciela = W.Pesel
JOIN Kolory AS K ON S.id_Koloru = K.id_Koloru
JOIN Typy AS T ON S.id_Typu = T.id_Typu
JOIN Marki AS M ON S.id_Marki = M.id_Marki
END;
GO

--Wykonanie procedury Info
EXEC Info;
GO

--Tworzę procedurę
--Usuwam procedurę gdy już była utworzona
DROP PROCEDURE IF EXISTS nieWazneUbezpieczenia;
GO

--Tworzę procedurę Info, która wypisuje dane samochodów z przeterminowanym ubezpieczeniem
CREATE PROCEDURE nieWazneUbezpieczenia
AS
BEGIN
	DECLARE dowody CURSOR FOR
	
	SELECT Numer_rejestracyjny FROM Dowody_rejestracyjne AS D
	JOIN Samochody AS S ON D.Numer_VIN = S.Numer_VIN
	WHERE S.Data_waznosci_ubezpieczenia < GETDATE();
	
	DECLARE @Numer_rejestracyjny_p VARCHAR(8);
	OPEN dowody;
		FETCH NEXT FROM dowody INTO @Numer_rejestracyjny_p;
		WHILE @@FETCH_STATUS=0
		BEGIN
			PRINT 'Samochód o numerze ' +  @Numer_rejestracyjny_p + ' ma przeterminowane ubezpieczenie';
			FETCH NEXT FROM dowody INTO @Numer_rejestracyjny_p
		END;
		CLOSE dowody;
		DEALLOCATE dowody; 
END;
GO

--Wykonanie procedury nieWazneUbezpieczenia
EXECUTE nieWazneUbezpieczenia;
GO



