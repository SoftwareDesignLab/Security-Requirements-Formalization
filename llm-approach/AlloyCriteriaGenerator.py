''' ALLOY CRITERIA GENERATOR - generates input to an Alloy run{} statement
Input: Alloy statements followed by truth values (separated by \t)
Output: (1) Implications used (when one Alloy statement implies another)
        (2) Formatted Alloy criteria
Note: This can be done on any number of Alloy statements and they can be new/unique
'''

def apply_implications(values, implications):
    """
    Apply recursive implications: if A -> B and A is TRUE, then set B = TRUE.
    Returns the updated values and a list of implications used.
    """
    updated = dict(values)
    used = set()

    changed = True
    while changed:
        changed = False
        for cause, effect in implications.items():
            if updated.get(cause) is True and updated.get(effect) is not True:
                updated[effect] = True
                used.add(f"{cause} -> {effect}")
                changed = True  # Keep applying recursively
    return updated, sorted(used)


def main():
    import sys

    print("Paste your Alloy statements and their truth values. Press Ctrl+D (or Ctrl+Z on Windows) when done:")

    try:
        lines = sys.stdin.read().strip().splitlines()
    except EOFError:
        print("No input received.")
        return

    # Parse input into a dictionary
    values = {}
    for line in lines:
        if not line.strip():
            continue
        try:
            statement, truth = line.rsplit('\t', 1)
            truth = truth.strip().upper()
            if truth == "TRUE":
                values[statement.strip()] = True
            elif truth == "FALSE":
                values[statement.strip()] = False
        except ValueError:
            print(f"Skipping malformed line: {line}")

    # Implication rules
    implications = {
        "Attempts in Authentication.has_restriction": "Authentication in Authentication.use_of",
        "Attempts in Recovery_Mechanism.has_restriction": "Recovery_Mechanism in Password.allows",
        "Common in Password.has_restriction": "Password in Authentication.uses",
        "Config_File in Password.stored_in": "Password in Authentication.uses",
        "Contextual_String in Password.has_restriction": "Password in Authentication.uses",
        "Encrypted in Sensitive_Data.stored_as": "Sensitive_Data in Sensitive_Data.use_of",
        "Expiration_Date in Password.has_restriction": "Reset in Password.requires",
        "File_Type in Input_File.has_restriction": "Input_Validation in Input_File.has_restriction",
        "GUI in Credentials.stored_in": "GUI in Sensitive_Data.stored_in",
        "GUI in Sensitive_Data.stored_in": "Sensitive_Data in Sensitive_Data.use_of",
        "Input_Validation in Input_File.has_restriction": "Input_File in User_Input.obtained_as",
        "Input_Validation in Other_User_Input.has_restriction": "Other_User_Input in User_Input.obtained_as",
        "IP_Address in Authentication.uses": "Authentication in Authentication.use_of",
        "Length in Password.has_restriction": "Password in Authentication.uses",
        "Log_File in Credentials.stored_in": "Sensitive_Data in Sensitive_Data.use_of",
        "Log_File in Sensitive_Data.stored_in": "Sensitive_Data in Sensitive_Data.use_of",
        "Multi_Factor_Authentication in Authentication.is": "Authentication in Authentication.use_of",
        "Multiple_Security_Questions in Recovery_Mechanism.has_restriction": "Recovery_Mechanism in Password.allows",
        "Original_Password in Reset.requires": "Reset in Password.requires",
        "Password in Authentication.uses": "Authentication in Authentication.use_of",
        "Recovery_Mechanism in Password.allows": "Password in Authentication.uses",
        "Reset in Password.requires": "Password in Authentication.uses",
        "Reuse in Password.has_restriction": "Password in Authentication.uses",
        "Sensitive_Data in Sensitive_Data.transport_of": "Sensitive_Data in Sensitive_Data.use_of",
        "Session_Expiration in Session.has_restriction": "Authentication in Authentication.use_of",
        "Strong_Security_Questions in Recovery_Mechanism.has_restriction": "Recovery_Mechanism in Password.allows",
        "Temporary_Password in Recovery_Mechanism.has_restriction": "Recovery_Mechanism in Password.allows",
        "Verification in Where_To_Send.requires": "Where_To_Send in Recovery_Mechanism.has_restriction",
        "Where_To_Send in Recovery_Mechanism.has_restriction": "Recovery_Mechanism in Password.allows"
    }

    # Apply implications recursively
    updated_values, used_implications = apply_implications(values, implications)

    # Detect Multi-Factor Authentication based on number of Authentication.uses
    uses_auth = [
        stmt for stmt in updated_values
        if stmt.endswith("in Authentication.uses") and updated_values[stmt]
    ]

    # Extract the left-hand side X of each 'X in Authentication.uses'
    lhs_entities = set(stmt.split(" in ")[0] for stmt in uses_auth)

    if len(lhs_entities) > 1:
        mfa_stmt = "Multi_Factor_Authentication in Authentication.is"
        if updated_values.get(mfa_stmt) is not True:
            updated_values[mfa_stmt] = True
            used_implications.append(
                "Multiple entities in Authentication.uses -> Multi_Factor_Authentication in Authentication.is")

    # Report used implication rules
    if used_implications:
        print("\nImplications used:")
        for rule in used_implications:
            print(rule)
    else:
        print("\nNo implications were applied.")

    # Output formatted result
    print("\nFormatted Alloy criteria:")
    statements = sorted(updated_values.keys())
    output_lines = []
    for stmt in statements:
        prefix = "not " if not updated_values[stmt] else ""
        output_lines.append(f"{prefix}{stmt}")

    for i, line in enumerate(output_lines):
        suffix = " and" if i < len(output_lines) - 1 else ""
        print(f"{line}{suffix}")


if __name__ == "__main__":
    main()
