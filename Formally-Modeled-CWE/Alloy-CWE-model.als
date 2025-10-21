//-------INITIALIZE MODEL ELEMENTS-------//
abstract sig Authentication_Method {}
one sig Password extends Authentication_Method {
	has_restriction: set Restriction,
	allows: lone Recovery_Mechanism,
	requires: lone Reset,
	stored_as: set Data_Storage_Type,
	stored_in: set Data_Storage_Location
}

one sig Reset {
	requires: lone Original_Password
}

one sig Original_Password {}

one sig Recovery_Mechanism {
	has_restriction: set Restriction
}

one sig IP_Address extends Authentication_Method {}

abstract sig Security_Checking_Method extends Authentication_Method {}
one sig Authentication extends Security_Checking_Method {
	uses: set Authentication_Method,
	use_of: lone Authentication,
	has_restriction: lone Attempts, 
	is: lone Multi_Factor_Authentication}
one sig Multi_Factor_Authentication extends Authentication_Method {}
one sig Security_Check extends Security_Checking_Method {}

abstract sig Restriction {}
one sig Length, Reuse, Common, Contextual_String, Expiration_Date, Attempts extends Restriction {}
one sig Strong_Security_Questions, Temporary_Password, Multiple_Security_Questions extends Restriction {}
one sig Where_To_Send extends Restriction {
	requires: lone Verification}

one sig Verification {}

abstract sig Session_Restriction {}
one sig Session_Expiration extends Session_Restriction {}

abstract sig Sensitive_Information {
	stored_as: set Data_Storage_Type,
	stored_in: set Data_Storage_Location}
one sig Sensitive_Data extends Sensitive_Information {
	transport_of: lone Sensitive_Data,
	use_of: lone Sensitive_Data}
one sig Credentials extends Sensitive_Information {
	transport_of: lone Credentials,
	use_of: lone Credentials}

abstract sig Data_Storage_Type {}
one sig Cleartext extends Data_Storage_Type {}
one sig Encrypted extends Data_Storage_Type {}

abstract sig Data_Storage_Location {}
one sig GUI extends Data_Storage_Location {}
one sig Log_File extends Data_Storage_Location {
	has_restriction: set Storage_Restriction
}
one sig Config_File extends Data_Storage_Location {}

abstract sig Storage_Restriction {}
one sig File_Size extends Storage_Restriction {}

one sig Access_Controls {
	include: set Access_Control_Policy
}

one sig Administrator {
	has: lone Administrator_Security_Controls
}

one sig Administrator_Security_Controls {} 

abstract sig Access_Control_Policy {}
one sig Compartmentalization extends Access_Control_Policy {} 
one sig Privilege_Separation extends Access_Control_Policy {} 
one sig Least_Privilege extends Access_Control_Policy {} 
one sig Trust_Zone extends Access_Control_Policy {} 
one sig Trust_Boundary extends Access_Control_Policy {} 

one sig Logging {
	use_for: set Event
}

abstract sig Event {}
one sig Security_Event extends Event {}

one sig Session {
	has_restriction: set Session_Expiration} 
	
one sig User_Input {
	obtained_as: set Input_Type
}

abstract sig Input_Type {
	has_restriction: set Input_Type_Restriction
}
one sig Other_User_Input extends Input_Type {}
one sig Input_File extends Input_Type {}

abstract sig Input_Type_Restriction {}
one sig Input_Validation extends Input_Type_Restriction {}
one sig File_Type extends Input_Type_Restriction {}


//-------INITIALIZE CWEs-------//
abstract sig CWE {}

one sig CWE268, CWE269, CWE276, CWE282, CWE284, CWE250, CWE283 extends CWE {
	affected_by: lone Access_Controls
} 

one sig CWE521, CWE262, CWE258, CWE620, CWE260 extends CWE { 
	affected_by: lone Password,
}

one sig CWE256 extends CWE {
	affected_by: lone Credentials 
}

one sig CWE308, CWE287, CWE291, CWE307 extends CWE {
	affected_by: lone Authentication
}

one sig CWE317, CWE532 extends CWE {
	affected_by: set Sensitive_Information
}

one sig CWE311, CWE312, CWE319 extends CWE {
	affected_by: lone Sensitive_Data
}

one sig CWE640 extends CWE {
	affected_by: lone Recovery_Mechanism
}

one sig CWE778 extends CWE {
	affected_by: lone Logging
}

one sig CWE779 extends CWE {
	affected_by: lone Log_File
}

one sig CWE613 extends CWE {
	affected_by: lone Session
}

one sig CWE671 extends CWE {
	affected_by: lone Administrator
}

one sig CWE20, CWE434 extends CWE {
	affected_by: lone User_Input
}

//-------AUXILIARY FACTS (PREVENT LOGIC ERRORS)-------//
// ensure that if password has expiration date, it requires a reset
fact {Expiration_Date in Password.has_restriction iff Reset in Password.requires}

// ensure that recovery mechanism doesn't have password restrictions and vice versa
fact {not Length in Recovery_Mechanism.has_restriction and 
	not Reuse in Recovery_Mechanism.has_restriction and 
	not Common in Recovery_Mechanism.has_restriction and 
	not Contextual_String in Recovery_Mechanism.has_restriction and 
	not Expiration_Date in Recovery_Mechanism.has_restriction and 
	not Length in Recovery_Mechanism.has_restriction and 
	not Strong_Security_Questions in Password.has_restriction and 
	not Temporary_Password in Password.has_restriction and 
	not Where_To_Send in Password.has_restriction and 
	not Multiple_Security_Questions in Password.has_restriction }

// ensure that Authentication does not use itself, MFA, or generic term "security check" 
fact {not Authentication in Authentication.uses and
	not Security_Check in Authentication.uses and 
	not Multi_Factor_Authentication in Authentication.uses}

// ensure that Session_Expiration is only applicable when Authentication is actually used
fact {not Authentication in Authentication.use_of implies not Session_Expiration in Session.has_restriction}

// ensure that if data is stored as Cleartext or in the GUI, it is NOT considered to be encrypted
fact {(Cleartext in Sensitive_Data.stored_as or 
	GUI in Sensitive_Data.stored_in) implies not Encrypted in Sensitive_Data.stored_as}
fact {(Cleartext in Credentials.stored_as or 
	GUI in Credentials.stored_in) 
	implies not Encrypted in Credentials.stored_as}
fact {(Cleartext in Password.stored_as or 
	GUI in Password.stored_in) 
	implies not Encrypted in Password.stored_as}

// ensure that if sensitive information is stored as cleartext, it is not encrypted
fact{(Cleartext in Sensitive_Data.stored_as) implies not Encrypted in Sensitive_Data.stored_as}
fact{(Cleartext in Credentials.stored_as) implies not Encrypted in Credentials.stored_as}
fact{(Cleartext in Password.stored_as) implies not Encrypted in Password.stored_as}

// ensure that if a method of authentication is being used, model regonizes that authentication is being used
fact {(Password in Authentication.uses or
	IP_Address in Authentication.uses) 
	implies Authentication in Authentication.use_of}

// ensure that if no method of authentication is being used, model does not recognize authentication as being used
fact {not (Password in Authentication.uses or
	IP_Address in Authentication.uses or 
	Multi_Factor_Authentication in Authentication.is) 
	implies not Authentication in Authentication.use_of}
	
// ensure that multiple factors of authentication being used implies multi-factor authentication 
// note: since other types of multi-factor authentication can be used, these two *specific* types of authentication are not both required for MFA
fact {#Authentication.uses >= 2 implies Multi_Factor_Authentication in Authentication.is}

// ensure that password stored in configuration file implies credentials and sensitive data stored in configuration file
fact { Config_File in Password.stored_in implies (Config_File in Sensitive_Data.stored_in and Config_File in Credentials.stored_in)}
fact { not(Config_File in Password.stored_in) implies (not Config_File in Sensitive_Data.stored_in and not Config_File in Credentials.stored_in)}

// ensure that data is either stored in cleartext or encrypted
fact {Sensitive_Data in Sensitive_Data.use_of iff (Cleartext in Sensitive_Data.stored_as or Encrypted in Sensitive_Data.stored_as)}
fact {Credentials in Credentials.use_of iff (Cleartext in Credentials.stored_as or Encrypted in Credentials.stored_as)}
fact {Password in Authentication.uses iff (Cleartext in Password.stored_as or Encrypted in Password.stored_as)}

// ensure that transporting/storing credentials or other data implies that credentials/data are in use
fact {Credentials in Credentials.transport_of implies Credentials in Credentials.use_of}
fact {Sensitive_Data in Sensitive_Data.transport_of implies Sensitive_Data in Sensitive_Data.use_of}
fact {(Encrypted in Credentials.stored_as or Cleartext in Credentials.stored_as) iff Credentials in Credentials.use_of}
fact {(Encrypted in Sensitive_Data.stored_as or Cleartext in Sensitive_Data.stored_as) iff Sensitive_Data in Sensitive_Data.use_of}
fact {(GUI in Sensitive_Data.stored_in or Log_File in Sensitive_Data.stored_in) implies Sensitive_Data in Sensitive_Data.use_of}

// ensure that password/credentials is equal to sensitive data
fact { Cleartext in Password.stored_as implies (Cleartext in Sensitive_Data.stored_as and Cleartext in Credentials.stored_as)}
fact { Cleartext in Credentials.stored_as implies Cleartext in Sensitive_Data.stored_as}
fact { Encrypted in Password.stored_as implies (Encrypted in Sensitive_Data.stored_as and Encrypted in Credentials.stored_as)}
fact { Encrypted in Credentials.stored_as implies Encrypted in Sensitive_Data.stored_as}

fact { GUI in Password.stored_in implies (GUI in Sensitive_Data.stored_in and GUI in Credentials.stored_in)}
fact { GUI in Credentials.stored_in implies GUI in Sensitive_Data.stored_in}

fact { Log_File in Password.stored_in implies (Log_File in Sensitive_Data.stored_in and Log_File in Credentials.stored_in)}
fact { Log_File in Credentials.stored_in implies Log_File in Sensitive_Data.stored_in}

// ensure that password does not have an attempts restriction ("authentication does")
fact { not Attempts in Password.has_restriction} 

// ensure that user input logic is sound
fact {not File_Type in Other_User_Input.has_restriction} // other user input might not be a file
fact {(File_Type in Input_File.has_restriction or Input_Validation in Input_File.has_restriction) implies Input_File in User_Input.obtained_as} // can't have a restriction on input that doesn't exist
fact {Input_Validation in Other_User_Input.has_restriction implies Other_User_Input in User_Input.obtained_as} // can't have a restriction on input that doesn't exist

// ensure that if Where_To_Send does not exist, neither does Verification of Where_To_Send; if no Recovery_Mechanism, then no restrictions 
fact {not Where_To_Send in Recovery_Mechanism.has_restriction implies not Verification in Where_To_Send.requires}
fact {not Recovery_Mechanism in Password.allows implies not Where_To_Send in Recovery_Mechanism.has_restriction}
fact {not Recovery_Mechanism in Password.allows implies not Strong_Security_Questions in Recovery_Mechanism.has_restriction}
fact {not Recovery_Mechanism in Password.allows implies not Temporary_Password in Recovery_Mechanism.has_restriction}
fact {not Recovery_Mechanism in Password.allows implies not Multiple_Security_Questions in Recovery_Mechanism.has_restriction}
fact {not Recovery_Mechanism in Password.allows implies not Attempts in Recovery_Mechanism.has_restriction}


//-------CWE FACTS (CAUSES AND MITIGATIONS)-------//
// Show whether or not CWEs occur
fact CWE521cause{not (Length in Password.has_restriction) implies (Password in CWE521.affected_by)}
fact CWE521cause{not (Reuse in Password.has_restriction) implies (Password in CWE521.affected_by)}
fact CWE521cause{not (Common in Password.has_restriction) implies (Password in CWE521.affected_by)}
fact CWE521cause{not (Contextual_String in Password.has_restriction) implies (Password in CWE521.affected_by)}
fact CWE521mitigation{(Length in Password.has_restriction) and 
	(Reuse in Password.has_restriction) and 
	(Common in Password.has_restriction) and 
	(Contextual_String in Password.has_restriction) 
	implies not (Password in CWE521.affected_by)}

fact CWE262cause{not (Reuse in Password.has_restriction) implies Password in CWE262.affected_by}
fact CWE262cause{not (Expiration_Date in Password.has_restriction) implies Password in CWE262.affected_by}
fact CWE262mitigation{(Reuse in Password.has_restriction) and
	(Expiration_Date in Password.has_restriction) implies not Password in CWE262.affected_by}

fact CWE256cause{Cleartext in Credentials.stored_as implies Credentials in CWE256.affected_by}
fact CWE256mitigation{not Cleartext in Credentials.stored_as implies not Credentials in CWE256.affected_by}

fact CWE287cause{not Authentication in Authentication.use_of implies Authentication in CWE287.affected_by}
fact CWE287mitigation{Authentication in Authentication.use_of implies not Authentication in CWE287.affected_by}

fact CWE308cause{not Multi_Factor_Authentication in Authentication.is implies Authentication in CWE308.affected_by}
fact CWE308mitigation{Multi_Factor_Authentication in Authentication.is implies not Authentication in CWE308.affected_by}

fact CWE258cause{not (Length in Password.has_restriction) implies Password in CWE258.affected_by}
fact CWE258mitigation{(Length in Password.has_restriction) implies not Password in CWE258.affected_by}

fact CWE291cause{(not Multi_Factor_Authentication in Authentication.is and 
	IP_Address in Authentication.uses) implies Authentication in CWE291.affected_by}
fact CWE291mitigation{(Multi_Factor_Authentication in Authentication.is and 
	IP_Address in Authentication.uses) implies not Authentication in CWE291.affected_by}
fact CWE291mitigation{(not IP_Address in Authentication.uses) implies not Authentication in CWE291.affected_by}

fact CWE317cause{(GUI in Sensitive_Data.stored_in and Cleartext in Sensitive_Data.stored_as) implies Sensitive_Data in CWE317.affected_by}
fact CWE317cause{(GUI in Credentials.stored_in and Cleartext in Credentials.stored_as) implies Credentials in CWE317.affected_by}
fact CWE317mitigation{not (GUI in Sensitive_Data.stored_in and Cleartext in Sensitive_Data.stored_as) implies not Sensitive_Data in CWE317.affected_by}
fact CWE317mitigation{not (GUI in Credentials.stored_in and Cleartext in Credentials.stored_as) implies not Credentials in CWE317.affected_by}

fact CWE307cause{not Attempts in Authentication.has_restriction implies Authentication in CWE307.affected_by}
fact CWE307mitigation{Attempts in Authentication.has_restriction implies not Authentication in CWE307.affected_by}

fact CWE640cause{not (Recovery_Mechanism in Password.allows implies Strong_Security_Questions in Recovery_Mechanism.has_restriction) implies Recovery_Mechanism in CWE640.affected_by}
fact CWE640cause{not (Recovery_Mechanism in Password.allows implies Temporary_Password in Recovery_Mechanism.has_restriction) implies Recovery_Mechanism in CWE640.affected_by}
fact CWE640cause{not (Recovery_Mechanism in Password.allows implies Where_To_Send in Recovery_Mechanism.has_restriction) implies Recovery_Mechanism in CWE640.affected_by}
fact CWE640cause{not (Recovery_Mechanism in Password.allows implies Multiple_Security_Questions in Recovery_Mechanism.has_restriction) implies Recovery_Mechanism in CWE640.affected_by}
fact CWE640cause{not (Recovery_Mechanism in Password.allows implies Attempts in Recovery_Mechanism.has_restriction) implies Recovery_Mechanism in CWE640.affected_by}
fact CWE640cause{not (Where_To_Send in Recovery_Mechanism.has_restriction implies Verification in Where_To_Send.requires) implies Recovery_Mechanism in CWE640.affected_by}
fact CWE640mitigation{((Recovery_Mechanism in Password.allows implies Strong_Security_Questions in Recovery_Mechanism.has_restriction) and
	(Recovery_Mechanism in Password.allows implies Temporary_Password in Recovery_Mechanism.has_restriction) and 
	(Recovery_Mechanism in Password.allows implies Where_To_Send in Recovery_Mechanism.has_restriction and Verification in Where_To_Send.requires) and
	(Recovery_Mechanism in Password.allows implies Multiple_Security_Questions in Recovery_Mechanism.has_restriction) and
	(Recovery_Mechanism in Password.allows implies Attempts in Recovery_Mechanism.has_restriction))
	implies not Recovery_Mechanism in CWE640.affected_by}

fact CWE620cause{not (Reset in Password.requires implies Original_Password in Reset.requires) implies Password in CWE620.affected_by}
fact CWE620cause{not (Recovery_Mechanism in Password.allows implies Strong_Security_Questions in Recovery_Mechanism.has_restriction) implies Password in CWE620.affected_by}
fact CWE620cause{not (Recovery_Mechanism in Password.allows implies Where_To_Send in Recovery_Mechanism.has_restriction) implies Password in CWE620.affected_by}
fact CWE620mitigation{((Reset in Password.requires implies Original_Password in Reset.requires) and 
	((Recovery_Mechanism in Password.allows implies Strong_Security_Questions in Recovery_Mechanism.has_restriction) and 
	(Recovery_Mechanism in Password.allows implies Where_To_Send in Recovery_Mechanism.has_restriction))) 
	implies not Password in CWE620.affected_by}

fact CWE532cause{(Log_File in Sensitive_Data.stored_in) implies Sensitive_Data in CWE532.affected_by}
fact CWE532cause{(Log_File in Credentials.stored_in) implies Credentials in CWE532.affected_by}
//fact CWE532mitigation{(not Log_File in Sensitive_Data.stored_in and not Log_File in Credentials.stored_in) implies not Sensitive_Information in CWE532.affected_by} // had to remove this due to logic error
fact CWE532mitigation{not (Log_File in Sensitive_Data.stored_in) implies not Sensitive_Data in CWE532.affected_by}
fact CWE532mitigation{not (Log_File in Credentials.stored_in) implies not Credentials in CWE532.affected_by}

fact CWE268cause{(not Privilege_Separation in Access_Controls.include) implies Access_Controls in CWE268.affected_by}
fact CWE268cause{(not Trust_Zone in Access_Controls.include) implies Access_Controls in CWE268.affected_by}
fact CWE268cause{(not Least_Privilege in Access_Controls.include) implies Access_Controls in CWE268.affected_by}
fact CWE268mitigation{(Least_Privilege in Access_Controls.include and Trust_Zone in Access_Controls.include and Privilege_Separation in Access_Controls.include) implies not Access_Controls in CWE268.affected_by}

fact CWE269cause{(not Privilege_Separation in Access_Controls.include) implies Access_Controls in CWE269.affected_by}
fact CWE269cause{(not Trust_Zone in Access_Controls.include) implies Access_Controls in CWE269.affected_by}
fact CWE269cause{(not Least_Privilege in Access_Controls.include) implies Access_Controls in CWE269.affected_by}
fact CWE269mitigation{(Least_Privilege in Access_Controls.include and Trust_Zone in Access_Controls.include and Privilege_Separation in Access_Controls.include) implies not Access_Controls in CWE269.affected_by}

fact CWE276cause{(not Privilege_Separation in Access_Controls.include) implies Access_Controls in CWE276.affected_by}
fact CWE276cause{(not Trust_Boundary in Access_Controls.include) implies Access_Controls in CWE276.affected_by}
fact CWE276cause{(not Least_Privilege in Access_Controls.include) implies Access_Controls in CWE276.affected_by}
fact CWE276cause{(not Compartmentalization in Access_Controls.include) implies Access_Controls in CWE276.affected_by}
fact CWE276mitigation{(Compartmentalization in Access_Controls.include and Least_Privilege in Access_Controls.include and Trust_Boundary in Access_Controls.include and Privilege_Separation in Access_Controls.include) implies not Access_Controls in CWE276.affected_by}

fact CWE282cause{(not Trust_Zone in Access_Controls.include) implies Access_Controls in CWE282.affected_by}
fact CWE282mitigation{(Trust_Zone in Access_Controls.include) implies not Access_Controls in CWE282.affected_by}

fact CWE284cause{(not Trust_Zone in Access_Controls.include) implies Access_Controls in CWE284.affected_by}
fact CWE284cause{(not Trust_Boundary in Access_Controls.include) implies Access_Controls in CWE284.affected_by}
fact CWE284cause{(not Least_Privilege in Access_Controls.include) implies Access_Controls in CWE284.affected_by}
fact CWE284cause{(not Compartmentalization in Access_Controls.include) implies Access_Controls in CWE284.affected_by}
fact CWE284mitigation{(Compartmentalization in Access_Controls.include and Least_Privilege in Access_Controls.include and Trust_Boundary in Access_Controls.include and Trust_Zone in Access_Controls.include) implies not Access_Controls in CWE284.affected_by}

fact CWE260cause{not (Config_File in Password.stored_in implies Encrypted in Password.stored_as) implies Password in CWE260.affected_by}
fact CWE260mitigation{(Config_File in Password.stored_in implies Encrypted in Password.stored_as) implies not Password in CWE260.affected_by}

fact CWE250cause{(not Least_Privilege in Access_Controls.include) implies Access_Controls in CWE250.affected_by}
fact CWE250mitigation{(Least_Privilege in Access_Controls.include) implies not Access_Controls in CWE250.affected_by}

fact CWE283cause{(not Trust_Zone in Access_Controls.include) implies Access_Controls in CWE283.affected_by}
fact CWE283cause{(not Privilege_Separation in Access_Controls.include) implies Access_Controls in CWE283.affected_by}
fact CWE283mitigation{(Privilege_Separation in Access_Controls.include and Trust_Zone in Access_Controls.include) implies not Access_Controls in CWE283.affected_by}

fact CWE778cause{not (Security_Event in Logging.use_for) implies Logging in CWE778.affected_by}
fact CWE778mitigation{(Security_Event in Logging.use_for) implies not Logging in CWE778.affected_by}

fact CWE779cause{not (File_Size in Log_File.has_restriction) implies Log_File in CWE779.affected_by}
fact CWE779mitigation{(File_Size in Log_File.has_restriction) implies not Log_File in CWE779.affected_by}

fact CWE613cause{(Authentication in Authentication.use_of and not Session_Expiration in Session.has_restriction) implies Session in CWE613.affected_by}
fact CWE613mitigation{(Session_Expiration in Session.has_restriction) implies not Session in CWE613.affected_by}
fact CWE613mitigation{(not Authentication in Authentication.use_of) implies not Session in CWE613.affected_by}

fact CWE311cause{(Sensitive_Data in Sensitive_Data.use_of and not Encrypted in Sensitive_Data.stored_as) implies Sensitive_Data in CWE311.affected_by}
fact CWE311mitigation{((Sensitive_Data in Sensitive_Data.use_of and Encrypted in Sensitive_Data.stored_as) or (not Sensitive_Data in Sensitive_Data.use_of)) implies not Sensitive_Data in CWE311.affected_by}

fact CWE312cause{(GUI in Sensitive_Data.stored_in and not Encrypted in Sensitive_Data.stored_as) implies Sensitive_Data in CWE312.affected_by}
fact CWE312cause{(Log_File in Sensitive_Data.stored_in and not Encrypted in Sensitive_Data.stored_as) implies Sensitive_Data in CWE312.affected_by}
fact CWE312mitigation{((Encrypted in Sensitive_Data.stored_as) or (not GUI in Sensitive_Data.stored_in and not Log_File in Sensitive_Data.stored_in)) implies not Sensitive_Data in CWE312.affected_by}

fact CWE319cause{(Sensitive_Data in Sensitive_Data.transport_of and not Encrypted in Sensitive_Data.stored_as) implies Sensitive_Data in CWE319.affected_by}
fact CWE319mitigation{((Sensitive_Data in Sensitive_Data.transport_of and Encrypted in Sensitive_Data.stored_as) or (not Sensitive_Data in Sensitive_Data.transport_of)) implies not Sensitive_Data in CWE319.affected_by}

fact CWE671cause{not Administrator_Security_Controls in Administrator.has implies Administrator in CWE671.affected_by}
fact CWE671mitigation{Administrator_Security_Controls in Administrator.has implies not Administrator in CWE671.affected_by}

fact CWE20cause{(Input_File in User_Input.obtained_as and not Input_Validation in Input_File.has_restriction) implies User_Input in CWE20.affected_by}
fact CWE20cause{(Other_User_Input in User_Input.obtained_as and not Input_Validation in Other_User_Input.has_restriction) implies User_Input in CWE20.affected_by}
fact CWE20mitigation{(Input_File in User_Input.obtained_as and Input_Validation in Input_File.has_restriction and Other_User_Input in User_Input.obtained_as and Input_Validation in Other_User_Input.has_restriction) implies not User_Input in CWE20.affected_by}
fact CWE20mitigation{(not Input_File in User_Input.obtained_as and not Other_User_Input in User_Input.obtained_as) implies not User_Input in CWE20.affected_by}
fact CWE20mitigation{(not Input_File in User_Input.obtained_as and Input_Validation in Other_User_Input.has_restriction) implies not User_Input in CWE20.affected_by}
fact CWE20mitigation{(Input_Validation in Input_File.has_restriction and not Other_User_Input in User_Input.obtained_as) implies not User_Input in CWE20.affected_by}

fact CWE434cause{(Input_File in User_Input.obtained_as and (not Input_Validation in Input_File.has_restriction or not File_Type in Input_File.has_restriction)) implies User_Input in CWE434.affected_by}
fact CWE434mitigation{((Input_File in User_Input.obtained_as and Input_Validation in Input_File.has_restriction and File_Type in Input_File.has_restriction) or not Input_File in User_Input.obtained_as) implies not User_Input in CWE434.affected_by}


//-------RUN-------//
// NOTE: "for X int" sets bitwidth (scope on int atoms - equal to the number of possible ints corresponding to bitwidth)
// All criteria below are defaults -- change to reflect the system being modeled
run model{
not Attempts in Recovery_Mechanism.has_restriction and
not Attempts in Authentication.has_restriction and
not Authentication in Authentication.use_of and
not Common in Password.has_restriction and
not Compartmentalization in Access_Controls.include and
not Config_File in Password.stored_in and
not Contextual_String in Password.has_restriction and
not Expiration_Date in Password.has_restriction and
not File_Size in Log_File.has_restriction and
not GUI in Credentials.stored_in and
not GUI in Sensitive_Data.stored_in and
not IP_Address in Authentication.uses and
not Least_Privilege in Access_Controls.include and
not Length in Password.has_restriction and
not Log_File in Credentials.stored_in and
not Log_File in Sensitive_Data.stored_in and
not Multi_Factor_Authentication in Authentication.is and
not Multiple_Security_Questions in Recovery_Mechanism.has_restriction and
not Original_Password in Reset.requires and
not Password in Authentication.uses and
not Privilege_Separation in Access_Controls.include and
not Recovery_Mechanism in Password.allows and
not Reset in Password.requires and
not Reuse in Password.has_restriction and
not Security_Event in Logging.use_for and
not Strong_Security_Questions in Recovery_Mechanism.has_restriction and
not Temporary_Password in Recovery_Mechanism.has_restriction and
not Trust_Boundary in Access_Controls.include and
not Trust_Zone in Access_Controls.include and
not Where_To_Send in Recovery_Mechanism.has_restriction and 
not Verification in Where_To_Send.requires and
not Session_Expiration in Session.has_restriction and
not Sensitive_Data in Sensitive_Data.use_of and
not Encrypted in Sensitive_Data.stored_as and
not Sensitive_Data in Sensitive_Data.transport_of and
not Administrator_Security_Controls in Administrator.has and
not Input_File in User_Input.obtained_as and
not Input_Validation in Input_File.has_restriction and
not Other_User_Input in User_Input.obtained_as and
not Input_Validation in Other_User_Input.has_restriction and
not File_Type in Input_File.has_restriction 
} for 4 int // default = 4 int
