# OPTIMAL PIPELINE v2  GARVIS Node Learning Loop

## BUILD Phase
1. **Mode:** context  
   **Purpose:** Gather background and constraints.  
   **Prompt:** `Aider mode: context. Topic: <topic>. Goal: <goal>. Module: <module>.`

2. **Mode:** architect  
   **Purpose:** Design high‑level structure.  
   **Prompt:** `Aider mode: architect. Topic: <topic>. Goal: <goal>. Module: <module>.`

3. **Mode:** code  
   **Purpose:** Implement core functionality.  
   **Prompt:** `Aider mode: code. Topic: <topic>. Goal: <goal>. Module: <module>.`

4. **Mode:** ask  
   **Purpose:** Clarify ambiguities and refine specs.  
   **Prompt:** `Aider mode: ask. Topic: <topic>. Goal: <goal>. Module: <module>.`

*Summary:* Build the foundation, design, code, and validate requirements.

## POLISH Phase
5. **Mode:** code  
   **Purpose:** Refactor and improve readability.  
   **Prompt:** `Aider mode: code. Topic: <topic>. Goal: <goal>. Module: <module>.`

6. **Mode:** ask  
   **Purpose:** Verify edge cases and error handling.  
   **Prompt:** `Aider mode: ask. Topic: <topic>. Goal: <goal>. Module: <module>.`

7. **Mode:** context  
   **Purpose:** Document usage and examples.  
   **Prompt:** `Aider mode: context. Topic: <topic>. Goal: <goal>. Module: <module>.`

*Summary:* Polish code quality, test coverage, and documentation.

## VERIFY Phase
8. **Mode:** code  
   **Purpose:** Write automated tests.  
   **Prompt:** `Aider mode: code. Topic: <topic>. Goal: <goal>. Module: <module>.`

9. **Mode:** ask  
   **Purpose:** Review test results and fix failures.  
   **Prompt:** `Aider mode: ask. Topic: <topic>. Goal: <goal>. Module: <module>.`

10. **Mode:** context  
    **Purpose:** Final sanity check and deployment notes.  
    **Prompt:** `Aider mode: context. Topic: <topic>. Goal: <goal>. Module: <module>.`

*Summary:* Validate with tests, resolve issues, and prepare for release.
