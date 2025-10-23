# Security-Requirements-Formalization
This repository contains findings, collected data, evaluations, and source code of our Security Requirements Formalization project. 

## Contents:
- `Formally-Modeled-CWE/` - Contains the Alloy-CWE model (default criteria can be replaced to analyze specific requirements documents), as well as an executable file which runs the Alloy Analyzer tool and the Amalgam plug-in.
- `keyword-approach/` - Contains resources and code (in `keyword-approach/AlloyGeneration/`) needed for keyword-based requirements formalization. The output is  a list of Alloy statements that makes up Alloy `run{}` criteria. 
- `llm-approach/` - Contains a list of LLM-based requirements formalization prompts (for tested prompt engineering techniques) and code needed for LLM-based requirements formalization. Code consists of two programs: one for parsing LLM outputs, and one for generating Alloy `run{}` criteria based on the parsed output.
- `results/` - Contains results for: (1) requirements formalization using the keyword approach, (2) requirements formalization using the LLM approach, (3) weakness (CWE) detection using the keyword approach, (4) weakness (CWE) detection using the LLM approach, and (5) provenances (weakness/CWE root causes) for each of the five evaluated datasets.
- `requirements.xlsx` - Contains data used for our analysis from **five real requirements specifications documents**: the Indiana Supreme Court's Court Case Management System (CCMS), Judicial Council of California (JCC) Facilities Services, Access 4 Learning (A4L) Community, Vermont Health Care Uniform Reporting and Evaluation System (VHCURES), and Maryland Statewide Personnel System (MSPS). Note: our analysis uses only *security* requirements from these documents, and only these are labeled with Alloy ground truth mappings. However, this spreadsheet also contains *functional* requirements which may be useful to researchers for additional analyses. 

## Summary (how it all works together):

1. **Input:** Five datasets of natural language software requirements (from `requirements.xlsx`). 

2. **Formalization:** Each requirement was mapped/translated to formal Alloy criteria using one or both of the following:
   - The **keyword-based approach** (`keyword-approach/`).  
   - The **LLM-based approach** (`llm-approach/`).
   - (Both result in generated Alloy `run{}` criteria which describes the set of formalized requirements.)
   - Formalizations using both approaches were compared to the ground truth and recorded in `results/`.

3. **Weakness (CWE) Detection:** The `run{}` criteria is input into the Alloy model (`Formally-Modeled-CWE/Alloy-CWE-model.als`) and evaluated using the Alloy Analyzer (`Formally-Modeled-CWE/amalgam.jar`).
   - The Alloy Analyzer outputs a model that shows which weaknesses are present in the requirements. 
   - Detected CWEs were compared to the ground truth and recorded in `results/` (for distractor label LLM prompting-based and keyword-based approaches).

4. **Provenance Generation:**  
   - After Alloy analysis, **Amalgam** (`Formally-Modeled-CWE/amalgam.jar`) produced formal textual explanations (provenances) describing the causal link between  detected weaknesses and specific security tactics described within the requirements for each system.

#### Flowchart describing the technique:
Natural language requirements → KW-based or LLM-based formalization → formalized requirements (Alloy criteria) → Alloy analysis → results and optional Amalgam analysis.

#### Note: 
Each directory has its own readme file describing its contents individually in more detail. 

