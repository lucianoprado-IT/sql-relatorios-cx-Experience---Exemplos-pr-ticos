-- ====================================================
-- Script: Identificação de Clientes em Risco de Churn
-- Autor: Luciano Prado
-- Objetivo: Detectar padrões de insatisfação
-- ====================================================

WITH PerfilCliente AS (
    SELECT 
        ClienteID,
        COUNT(*) AS TotalContatosUltimos30Dias,
        AVG(NotaSatisfacao) AS MediaSatisfacao,
        SUM(CASE WHEN TipoContato = 'Reclamação' THEN 1 ELSE 0 END) AS TotalReclamacoes,
        MAX(DataHora) AS UltimoContato
    FROM 
        TabelaChamadas
    WHERE 
        DataHora >= DATEADD(DAY, -30, GETDATE())
    GROUP BY 
        ClienteID
)

SELECT 
    ClienteID,
    TotalContatosUltimos30Dias,
    MediaSatisfacao,
    TotalReclamacoes,
    UltimoContato,
    -- Score de risco (0-100)
    (TotalReclamacoes * 20) + 
    (CASE WHEN MediaSatisfacao < 3 THEN 30 ELSE 0 END) +
    (CASE WHEN TotalContatosUltimos30Dias > 5 THEN 20 ELSE 0 END) AS ScoreRisco,
    -- Classificação
    CASE 
        WHEN (TotalReclamacoes * 20) + 
             (CASE WHEN MediaSatisfacao < 3 THEN 30 ELSE 0 END) +
             (CASE WHEN TotalContatosUltimos30Dias > 5 THEN 20 ELSE 0 END) >= 50 
        THEN 'Alto Risco'
        WHEN (TotalReclamacoes * 20) + 
             (CASE WHEN MediaSatisfacao < 3 THEN 30 ELSE 0 END) +
             (CASE WHEN TotalContatosUltimos30Dias > 5 THEN 20 ELSE 0 END) >= 30 
        THEN 'Médio Risco'
        ELSE 'Baixo Risco'
    END AS ClassificacaoRisco
FROM 
    PerfilCliente
WHERE 
    (TotalReclamacoes * 20) + 
    (CASE WHEN MediaSatisfacao < 3 THEN 30 ELSE 0 END) +
    (CASE WHEN TotalContatosUltimos30Dias > 5 THEN 20 ELSE 0 END) >= 30
ORDER BY 
    ScoreRisco DESC;
