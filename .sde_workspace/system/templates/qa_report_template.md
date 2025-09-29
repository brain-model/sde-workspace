# Relatório de Quality Assurance: [TÍTULO DA FEATURE]

---

**TASK-ID:** [ID DA TAREFA DO WORKSPACE]
**Spec Document:** [CAMINHO/PARA/O/SPEC_DOCUMENT.MD]
**Branch Analisada:** [NOME-DA-BRANCH-GIT]
**Commit Analisado:** [HASH-DO-COMMIT-SQUASHED]
**Autor(es):** Agente de QA
**Data:** {{YYYY-MM-DD}}

---

## 1. Sumário Executivo

### Descreva em 1-2 frases o resultado geral da análise. O código atende aos requisitos principais? Foram encontrados problemas críticos?

**Decisão Final:** **APROVADO_QA** | **REVISAO_QA_NECESSARIA**

## 2. Checklist de Validação de Requisitos

*(Valide cada requisito funcional e não-funcional do `Spec Document`. Use esta seção como uma prova de que a especificação foi completamente coberta.)*

| Requisito do Spec | Status | Observações |
| :--- | :--- | :--- |
| **[Funcional 1.1]** API deve retornar `201 Created` | PASS | |
| **[Funcional 1.2]** Validação de `nome` obrigatório | PASS | |
| **[Não-Funcional 4.1]** Resposta da API < 200ms | PASS | Média de 150ms em testes locais. |
| **[Não-Funcional 4.2]** Acesso requer escopo `recurso:escrever` | FAIL | Acesso está público, sem validação de escopo. |

## 3. Análise de Casos de Borda e Cenários de Falha

### Documente aqui os testes que vão além do "caminho feliz" para garantir a robustez da aplicação

| Cenário de Teste | Passos para Reprodução | Resultado Esperado | Resultado Observado | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Corpo da requisição vazio** | Enviar `POST` para `/api/v1/novo-recurso` com `{}`. | Retornar `400 Bad Request` com mensagem clara. | Retorna `500 Internal Server Error`. | FAIL |
| **Entrada com caracteres especiais** | Enviar `nome` com `"><script>alert(1)</script>"`. | O sistema deve sanitizar a entrada e salvá-la sem executar o script. | A entrada é salva como está, criando uma vulnerabilidade de XSS. | FAIL |
| **Banco de dados indisponível** | Simular indisponibilidade do serviço de banco de dados. | A API deve retornar `503 Service Unavailable`. | A API retorna `503 Service Unavailable` como esperado. | PASS |

## 4. Itens Acionáveis para o Desenvolvedor

*(Se a decisão for `REVISAO_QA_NECESSARIA`, liste aqui de forma clara e objetiva os problemas que precisam ser corrigidos. Cada item deve ser uma instrução direta.)*

1. **[CRÍTICO - SEGURANÇA]** Implementar a verificação do escopo de autorização (`recurso:escrever`) no endpoint da API, conforme definido no `Spec Document`. Atualmente, o endpoint está desprotegido.
2. **[CRÍTICO - ROBUSTEZ]** Adicionar validação para o corpo da requisição. Um request vazio (`{}`) está causando uma exceção não tratada (`Internal Server Error 500`) em vez de um `Bad Request 400`.
3. **[MÉDIO - SEGURANÇA]** Implementar sanitização na entrada do campo `nome` para prevenir vulnerabilidades de Cross-Site Scripting (XSS).
