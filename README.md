# Security-Requirements-Formalization



## Summary 

1. **Input:**  
   Five datasets of natural language software requirements.

2. **Formalization:**  
   Each requirement was mapped to formal Alloy criteria using:
   - The **keyword-based approach** (deterministic rules derived from the thesaurus).  
   - The **LLaMA-based approach** (prompted using few-shot and distractor label prompting techniques).

3. **Evaluation (Formalization Tabs):**  
   - Each generated mapping was compared to the ground truth.  
   - Multiple prompt variants (e.g., 0-shot, 1-shot, 3-shot) were tested, indexed as `P##-[run]`.

4. **Weakness Detection (CWE Tabs):**  
   - The Alloy model was executed using the formalized criteria to detect software weaknesses (CWEs).  
   - Only results from **distractor label prompting** are reported, representing the practical, single-run scenario.  

5. **Provenance Generation:**  
   - After Alloy analysis, **Amalgam** produced textual explanations (provenances) describing the causal link between requirements, Alloy statements, and detected weaknesses.

---


