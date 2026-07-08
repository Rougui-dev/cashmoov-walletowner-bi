CREATE TABLE IF NOT EXISTS wallet_history (
    DATE_RAPPORT TEXT,
    NAME TEXT,
    MSISDN TEXT,
    PROFILE TEXT,
    Country TEXT,
    GNF_Solde TEXT,
    XOF_Solde TEXT,
    USD_Solde TEXT,
    EUR_Solde TEXT,
    GNF_Comm TEXT,
    XOF_Comm TEXT,
    USD_Comm TEXT,
    EUR_Comm TEXT
);

INSERT INTO wallet_history 
SELECT 
    '2026-07-06' AS DATE_RAPPORT, -- Changez juste la date du jour ici (AAAA-MM-JJ)
    NAME, MSISDN, PROFILE, Country, 
    GNF_Solde, XOF_Solde, USD_Solde, EUR_Solde,
    GNF_Comm, XOF_Comm, USD_Comm, EUR_Comm
FROM wallet;
