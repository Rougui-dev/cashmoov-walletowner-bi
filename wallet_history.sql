SELECT 
    sub.DATE_RAPPORT AS "DATE_RAPPORT", 
    CASE 
        WHEN sub."NAME" LIKE 'COO%' OR sub."NAME" LIKE 'COB%' OR sub."NAME" LIKE 'COC %' 
            THEN SUBSTR(sub."NAME", 1, 3) || ' ' || REPLACE(REPLACE(sub."TYPE_SOLDE", 'SOLDES ', ''), 'TOTAL', '') 
        WHEN sub."NAME" LIKE '%CASHMOOV%' AND sub."PROFILE" IN ('Agent', 'Branch', 'Institute') 
            THEN 'CASHMOOV ' || REPLACE(REPLACE(sub."TYPE_SOLDE", 'SOLDES ', ''), 'TOTAL', '') 
        WHEN sub."PROFILE" IN ('Agent', 'Branch', 'Institute') AND sub."NAME" NOT LIKE '%CASHMOOV%' AND sub."NAME" NOT LIKE 'COO%' AND sub."NAME" NOT LIKE 'COB%' AND sub."NAME" NOT LIKE 'COC %' 
            THEN 'AUTRES AGENTS ' || REPLACE(REPLACE(sub."TYPE_SOLDE", 'SOLDES ', ''), 'TOTAL', '') 
        WHEN sub."PROFILE" = 'Employer' AND sub."NAME" = 'ECOMAS' THEN 'EMPLOYER ECOMAS' 
        WHEN sub."PROFILE" = 'Employer' AND sub."NAME" = 'Entreprise CASHMOOV' THEN 'EMPLOYER CASHMOOV' 
        WHEN sub."PROFILE" = 'Control Account' THEN 'Control Account' 
        WHEN sub."PROFILE" = 'Subscriber' THEN 'Subscriber' 
        WHEN sub."PROFILE" = 'Service Provider' AND sub."NAME" IN ('Intech', 'Intouch', 'SAMA', 'PAYSEN', 'Sochitel','Thunes') THEN 'SP (ISPT...)' 
        WHEN sub."PROFILE" = 'Service Provider' AND sub."NAME" = 'CASHMOOV' THEN 'SP CASHMOOV' 
        WHEN sub."PROFILE" = 'Service Provider' AND sub."NAME" = 'EDG' THEN 'SP EDG' 
        WHEN sub."PROFILE" IN ('Merchant', 'Outlet') THEN 'SOLDE MER&OUT' 
        ELSE sub."PROFILE" 
    END AS "GROUP_PROFILE", 
    SUM(CASE WHEN sub."TYPE_SOLDE" = 'SOLDES POSITIFS' AND CAST(REPLACE(sub.GNF_Solde, ' ', '') AS DECIMAL) >= 0 THEN CAST(REPLACE(sub.GNF_Solde, ' ', '') AS DECIMAL) WHEN sub."TYPE_SOLDE" = 'SOLDES NEGATIFS' AND CAST(REPLACE(sub.GNF_Solde, ' ', '') AS DECIMAL) < 0 THEN CAST(REPLACE(sub.GNF_Solde, ' ', '') AS DECIMAL) WHEN sub."TYPE_SOLDE" = 'TOTAL' THEN CAST(REPLACE(sub.GNF_Solde, ' ', '') AS DECIMAL) ELSE 0 END) AS total_GNF, 
    SUM(CASE WHEN sub."TYPE_SOLDE" = 'SOLDES POSITIFS' AND CAST(REPLACE(sub.XOF_Solde, ' ', '') AS DECIMAL) >= 0 THEN CAST(REPLACE(sub.XOF_Solde, ' ', '') AS DECIMAL) WHEN sub."TYPE_SOLDE" = 'SOLDES NEGATIFS' AND CAST(REPLACE(sub.XOF_Solde, ' ', '') AS DECIMAL) < 0 THEN CAST(REPLACE(sub.XOF_Solde, ' ', '') AS DECIMAL) WHEN sub."TYPE_SOLDE" = 'TOTAL' THEN CAST(REPLACE(sub.XOF_Solde, ' ', '') AS DECIMAL) ELSE 0 END) AS total_XOF, 
    SUM(CASE WHEN sub."TYPE_SOLDE" = 'SOLDES POSITIFS' AND CAST(REPLACE(sub.USD_Solde, ' ', '') AS DECIMAL) >= 0 THEN CAST(REPLACE(sub.USD_Solde, ' ', '') AS DECIMAL) WHEN sub."TYPE_SOLDE" = 'SOLDES NEGATIFS' AND CAST(REPLACE(sub.USD_Solde, ' ', '') AS DECIMAL) < 0 THEN CAST(REPLACE(sub.USD_Solde, ' ', '') AS DECIMAL) WHEN sub."TYPE_SOLDE" = 'TOTAL' THEN CAST(REPLACE(sub.USD_Solde, ' ', '') AS DECIMAL) ELSE 0 END) AS total_USD, 
    SUM(CASE WHEN sub."TYPE_SOLDE" = 'SOLDES POSITIFS' AND CAST(REPLACE(sub.EUR_Solde, ' ', '') AS DECIMAL) >= 0 THEN CAST(REPLACE(sub.EUR_Solde, ' ', '') AS DECIMAL) WHEN sub."TYPE_SOLDE" = 'SOLDES NEGATIFS' AND CAST(REPLACE(sub.EUR_Solde, ' ', '') AS DECIMAL) < 0 THEN CAST(REPLACE(sub.EUR_Solde, ' ', '') AS DECIMAL) WHEN sub."TYPE_SOLDE" = 'TOTAL' THEN CAST(REPLACE(sub.EUR_Solde, ' ', '') AS DECIMAL) ELSE 0 END) AS total_EUR 
FROM (
    SELECT wallet_history.*, t.TYPE_SOLDE 
    FROM wallet_history 
    CROSS JOIN (
        SELECT 'SOLDES POSITIFS' AS TYPE_SOLDE UNION ALL 
        SELECT 'SOLDES NEGATIFS' UNION ALL 
        SELECT 'TOTAL'
    ) t
) sub 
WHERE 
    ((sub."NAME" LIKE 'COO%' OR sub."NAME" LIKE 'COB%' OR sub."NAME" LIKE 'COC %' OR (sub."PROFILE" IN ('Agent', 'Branch', 'Institute'))) AND sub.TYPE_SOLDE IN ('SOLDES POSITIFS', 'SOLDES NEGATIFS')) 
    OR 
    ((sub."PROFILE" IN ('Control Account', 'Subscriber', 'Dispute Account', 'Tax Account', 'Merchant', 'Outlet', 'Commission Receivable', 'Employer') OR sub."PROFILE" = 'Service Provider' OR sub."NAME" ='Entreprise CASHMOOV') AND sub.TYPE_SOLDE = 'TOTAL') 
GROUP BY 1, 2 
HAVING (total_GNF <> 0 OR total_XOF <> 0 OR total_USD <> 0 OR total_EUR <> 0) 

UNION ALL 

SELECT DATE_RAPPORT, 'COMMISSIONS GLOBALES', SUM(CAST(REPLACE(GNF_Comm, ' ', '') AS DECIMAL)), SUM(CAST(REPLACE(XOF_Comm, ' ', '') AS DECIMAL)), SUM(CAST(REPLACE(USD_Comm, ' ', '') AS DECIMAL)), SUM(CAST(REPLACE(EUR_Comm, ' ', '') AS DECIMAL)) FROM wallet_history GROUP BY DATE_RAPPORT

UNION ALL 

SELECT DATE_RAPPORT, 'COMMISSIONS AGENCES CASHMOOV', SUM(CAST(REPLACE(GNF_Comm, ' ', '') AS DECIMAL)), SUM(CAST(REPLACE(XOF_Comm, ' ', '') AS DECIMAL)), SUM(CAST(REPLACE(USD_Comm, ' ', '') AS DECIMAL)), SUM(CAST(REPLACE(EUR_Comm, ' ', '') AS DECIMAL)) FROM wallet_history WHERE "PROFILE" IN ('Agent', 'Branch', 'Institute') AND "NAME" LIKE '%CASHMOOV%' GROUP BY DATE_RAPPORT

UNION ALL 

SELECT DATE_RAPPORT, 'COMMISSIONS AUTRES AGENTS', SUM( CAST(REPLACE(GNF_Comm, ' ', '') AS DECIMAL)) - SUM(CASE WHEN "PROFILE" IN ('Agent', 'Branch', 'Institute') AND "NAME" LIKE '%CASHMOOV%' THEN CAST(REPLACE(GNF_Comm, ' ', '') AS DECIMAL) ELSE 0 END), SUM(CAST(REPLACE(XOF_Comm, ' ', '') AS DECIMAL)) - SUM(CASE WHEN "PROFILE" IN ('Agent', 'Branch', 'Institute') AND "NAME" LIKE '%CASHMOOV%' THEN CAST(REPLACE(XOF_Comm, ' ', '') AS DECIMAL) ELSE 0 END), SUM(CAST(REPLACE(USD_Comm, ' ', '') AS DECIMAL)) - SUM(CASE WHEN "PROFILE" IN ('Agent', 'Branch', 'Institute') AND "NAME" LIKE '%CASHMOOV%' THEN CAST(REPLACE(USD_Comm, ' ', '') AS DECIMAL) ELSE 0 END), SUM(CAST(REPLACE(EUR_Comm, ' ', '') AS DECIMAL)) - SUM(CASE WHEN "PROFILE" IN ('Agent', 'Branch', 'Institute') AND "NAME" LIKE '%CASHMOOV%' THEN CAST(REPLACE(EUR_Comm, ' ', '') AS DECIMAL) ELSE 0 END) FROM wallet_history GROUP BY DATE_RAPPORT

UNION ALL 

SELECT DATE_RAPPORT, 'SERVICE PROVIDER GLOBAL', SUM(CAST(REPLACE(GNF_Solde, ' ', '') AS DECIMAL)), SUM(CAST(REPLACE(XOF_Solde, ' ', '') AS DECIMAL)), SUM(CAST(REPLACE(USD_Solde, ' ', '') AS DECIMAL)), SUM(CAST(REPLACE(EUR_Solde, ' ', '') AS DECIMAL)) FROM wallet_history WHERE "PROFILE" = 'Service Provider' AND "NAME" IN ('CASHMOOV', 'Intech', 'Intouch', 'SAMA', 'PAYSEN', 'Sochitel', 'Thunes') GROUP BY DATE_RAPPORT

ORDER BY DATE_RAPPORT DESC, 2 ASC;
