# AlloyGeneration

AlloyGeneration is a Java program that automatically translates (maps) natural-language software security requirements to predefined Alloy model statements using our *keyword approach*.
It leverages lemmatization (via the Stanford CoreNLP library) and a customizable thesaurus of security-related terms to detect relevant security concepts within each requirement and output their corresponding Alloy mappings.

## Overview

This tool reads a list of software requirements (one per line) and analyzes each sentence for security-related terms defined in a thesaurus file.
For every requirement, it identifies matching keywords and outputs all corresponding Alloy statements that represent those concepts.
It is designed to support security requirements analysis, traceability, and formal modeling automation within secure software engineering research and practice.

## files/ directory
* **sentences.txt** should be modified to contain natural language (English) security requirements that the user would like to translate into Alloy. Requirements should be input as one sentence (requirement) per line.
* **thesaurus.csv** contains the security thesaurus used for keyword (or key-phrase) matching. This should only be modified if the user desires to customize or augment the thesaurus. Note: if any customization in keyword-based mapping is desired, the mapping program must also be updated to search for the new keywords.
