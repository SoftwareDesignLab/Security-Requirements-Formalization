# LLM-based formalization approach
This directory contains resources needed for the LLM-based requirements formalization approach. 

## Files:
* **llm-prompts.docx** contains the various prompts used for the LLM-based formalization approach. 
* **AlloyStatementExtractor.py** contains the program that parses an LLM's (natural language) output to extract formal Alloy statements from the LLM-formalized requirements.
* **AlloyCriteriaGenerator.py** contains the program that generates input to an Alloy run{} statement when given truth values for each desired Alloy statement. This generates a set of constraints with which an Alloy model can be run and checked. 

Note: each of these files contains instructions for use within. 
