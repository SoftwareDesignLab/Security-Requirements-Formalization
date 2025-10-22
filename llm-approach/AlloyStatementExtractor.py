''' ALLOY STATEMENT EXTRACTOR / ALLOY FINDER - Finds all Alloy statements mapped to requirements in a prompt response
Input: Prompt responses from LLM (requirements mapped to Alloy statements)
Output: (1) Evaluated input
        (2) Found Alloy statements
        (3) Negated Alloy statements
        (4) Truth values for all 41 possible Alloy statements in alphabetical order
'''


def main():
    target_strings = [
        "Administrator_Security_Controls in Administrator.has",
        "Attempts in Authentication.has_restriction",
        "Attempts in Recovery_Mechanism.has_restriction",
        "Authentication in Authentication.use_of",
        "Common in Password.has_restriction",
        "Compartmentalization in Access_Controls.include",
        "Config_File in Password.stored_in",
        "Contextual_String in Password.has_restriction",
        "Encrypted in Sensitive_Data.stored_as",
        "Expiration_Date in Password.has_restriction",
        "File_Size in Log_File.has_restriction",
        "File_Type in Input_File.has_restriction",
        "GUI in Credentials.stored_in",
        "GUI in Sensitive_Data.stored_in",
        "Input_File in User_Input.obtained_as",
        "Input_Validation in Input_File.has_restriction",
        "Input_Validation in Other_User_Input.has_restriction",
        "IP_Address in Authentication.uses",
        "Least_Privilege in Access_Controls.include",
        "Length in Password.has_restriction",
        "Log_File in Credentials.stored_in",
        "Log_File in Sensitive_Data.stored_in",
        "Multi_Factor_Authentication in Authentication.is",
        "Multiple_Security_Questions in Recovery_Mechanism.has_restriction",
        "Original_Password in Reset.requires",
        "Other_User_Input in User_Input.obtained_as",
        "Password in Authentication.uses",
        "Privilege_Separation in Access_Controls.include",
        "Recovery_Mechanism in Password.allows",
        "Reset in Password.requires",
        "Reuse in Password.has_restriction",
        "Security_Event in Logging.use_for",
        "Sensitive_Data in Sensitive_Data.transport_of",
        "Sensitive_Data in Sensitive_Data.use_of",
        "Session_Expiration in Session.has_restriction",
        "Strong_Security_Questions in Recovery_Mechanism.has_restriction",
        "Temporary_Password in Recovery_Mechanism.has_restriction",
        "Trust_Boundary in Access_Controls.include",
        "Trust_Zone in Access_Controls.include",
        "Verification in Where_To_Send.requires",
        "Where_To_Send in Recovery_Mechanism.has_restriction"
    ]

    print("Paste your input. Press Enter then Ctrl+D to finish:\n") # ctrl+z if ctrl+d doesn't work

    # Read all input as a single string
    try:
        user_input = ""
        while True:
            line = input()
            user_input += line + "\n"
    except EOFError:
        pass

    input_string = user_input

    found = []
    negated = []

    print("User input: ")
    print(input_string)

    for s in target_strings:
        if f"NOT {s}" in input_string:
            negated.append(s)
        elif f"NOT [{s}]" in input_string:
            negated.append(s)
        elif s in input_string:
            found.append(s)


    # Output results
    print("\nFound Alloy statements:")
    for s in found:
        print(s)

    print("\nNegated Alloy statements (found with 'NOT'):")
    for s in negated:
        print("NOT", s)

    def evaluate_statements(found, negated):
        statements = [
            "Administrator_Security_Controls in Administrator.has",
            "Attempts in Authentication.has_restriction",
            "Attempts in Recovery_Mechanism.has_restriction",
            "Authentication in Authentication.use_of",
            "Common in Password.has_restriction",
            "Compartmentalization in Access_Controls.include",
            "Config_File in Password.stored_in",
            "Contextual_String in Password.has_restriction",
            "Encrypted in Sensitive_Data.stored_as",
            "Expiration_Date in Password.has_restriction",
            "File_Size in Log_File.has_restriction",
            "File_Type in Input_File.has_restriction",
            "GUI in Credentials.stored_in",
            "GUI in Sensitive_Data.stored_in",
            "Input_File in User_Input.obtained_as",
            "Input_Validation in Input_File.has_restriction",
            "Input_Validation in Other_User_Input.has_restriction",
            "IP_Address in Authentication.uses",
            "Least_Privilege in Access_Controls.include",
            "Length in Password.has_restriction",
            "Log_File in Credentials.stored_in",
            "Log_File in Sensitive_Data.stored_in",
            "Multi_Factor_Authentication in Authentication.is",
            "Multiple_Security_Questions in Recovery_Mechanism.has_restriction",
            "Original_Password in Reset.requires",
            "Other_User_Input in User_Input.obtained_as",
            "Password in Authentication.uses",
            "Privilege_Separation in Access_Controls.include",
            "Recovery_Mechanism in Password.allows",
            "Reset in Password.requires",
            "Reuse in Password.has_restriction",
            "Security_Event in Logging.use_for",
            "Sensitive_Data in Sensitive_Data.transport_of",
            "Sensitive_Data in Sensitive_Data.use_of",
            "Session_Expiration in Session.has_restriction",
            "Strong_Security_Questions in Recovery_Mechanism.has_restriction",
            "Temporary_Password in Recovery_Mechanism.has_restriction",
            "Trust_Boundary in Access_Controls.include",
            "Trust_Zone in Access_Controls.include",
            "Verification in Where_To_Send.requires",
            "Where_To_Send in Recovery_Mechanism.has_restriction"
        ]

        for statement in statements:
            if statement in found:
                print("true")
            else:
                print("false")

    print("\nThe truth values:")
    evaluate_statements(found, negated)


if __name__ == "__main__":
    main()
