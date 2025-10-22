import edu.stanford.nlp.simple.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AlloyGeneration {
    // Define the mapping from lemma to word
    private static Map<String, String> thesaurus = new HashMap<>();

    public static void main(String[] args) {
        // Load the thesaurus from CSV file
        loadThesaurus("./files/thesaurus.csv");

        // Process the sentences
        processSentences("./files/sentences.txt");
        
    }

    private static void loadThesaurus(String filename) {
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length == 2) {
                    thesaurus.put(parts[0].trim(), parts[1].trim());
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static List<String> lemmatize(String sentence) {
    	// Lemmatize the sentence using CoreNLP
        List<String> lemmas = new ArrayList<>();
        Document doc = new Document(sentence);
        for (Sentence sent : doc.sentences()) {
            for (String lemma : sent.lemmas()) {
                lemmas.add(lemma);
                //System.out.println(lemma);
            }
        }
        return lemmas;
    }
    
    private static void processSentences(String filename) {
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            while ((line = br.readLine()) != null) {
                List<String> lemmatizedPhrases = extractLemmatizedPhrases(line);
                //System.out.println(lemmatizedPhrases);
                boolean passFound = false;
                boolean authenFound = false;

                List<String> wordsFound = new ArrayList<>(); // thesaurus keywords found
                List<String> correspondingPhrases = new ArrayList<>(); // actual phrases corresponding to the keywords
                boolean fromOthersFlag = false;
                // Check for lemmatized phrase matches in the thesaurus
                // phrase is each lemmatized word/phrase in the sentence
                // word is each lemma found in the thesaurus (null when the word doesn't match anything in the thesaurus)
                for (String phrase : lemmatizedPhrases) {
                	//System.out.println(phrase);
                    String word = thesaurus.get(phrase.toLowerCase());
                    //System.out.println(word);
                    
                    
                    // "word.equals()" is specifically for phrases found in the thesaurus.
                    if (word != null) {
                    	//System.out.println(word);
                    	wordsFound.add(word); // wordsFound are words that we found in the thesaurus
                    	//System.out.println(wordsFound);
                    	correspondingPhrases.add(phrase); // correspondingPhrases are actual words/phrases in the sentence that correspond to thesaurus
                    	//System.out.println(phrase);
                    }
                }
                // Prints out all words found in the thesaurus for this sentence
                //System.out.println("\"" + line + "\",\""+ wordsFound.toString()+"\",\""+correspondingPhrases.toString()+"\"");
                
                
                
                // Prints out all Alloy statements that were found
                if ((wordsFound.contains("administrator") && wordsFound.contains("security controls"))) {
                	System.out.println("\"" + line + "\", Administrator_Security_Controls in Administrator.has");
                } // new addition
                if ((wordsFound.contains("authentication") && wordsFound.contains("attempt")) ||
                		(wordsFound.contains("password") && wordsFound.contains("attempt")) ||
                		(wordsFound.contains("sign on") && wordsFound.contains("attempt"))) {
                	System.out.println("\"" + line + "\", Attempts in Authentication.has_restriction");
                }
                if ((wordsFound.contains("recovery") && wordsFound.contains("attempt")) ||
                		(wordsFound.contains("reset") && wordsFound.contains("attempt"))) {
                	System.out.println("\"" + line + "\", Attempts in Recovery_Mechanism.has_restriction");
                }
                if ((wordsFound.contains("authentication")) ||
                		(wordsFound.contains("access")) ||
                		(wordsFound.contains("sign on")) ||
                		(wordsFound.contains("username")) ||
                		(wordsFound.contains("password")) ||
                		(wordsFound.contains("credential"))) {
                	System.out.println("\"" + line + "\", Authentication in Authentication.use_of");
                	// special case "authorized user"
                }
                if ((wordsFound.contains("complexity") && wordsFound.contains("password"))) {
                	System.out.println("\"" + line + "\", Common in Password.has_restriction");
                }
                if ((wordsFound.contains("secure") && fromOthersFlag)) {
                	System.out.println("\"" + line + "\", Compartmentalization in Access_Controls.include");
                	// special case: secure, "from others"
                }
                if ((wordsFound.contains("configuration") && wordsFound.contains("password") && wordsFound.contains("store"))) {
                	System.out.println("\"" + line + "\", Config_File in Password.stored_in");
                }
                if ((wordsFound.contains("configuration") && wordsFound.contains("contextual string"))) {
                	System.out.println("\"" + line + "\", Contextual_String in Password.has_restriction");
                }
                if ((wordsFound.contains("credential") && wordsFound.contains("encryption")) ||
                		(wordsFound.contains("password") && wordsFound.contains("encryption")) ||
                		(wordsFound.contains("sensitive data") && wordsFound.contains("encryption"))) {
                	System.out.println("\"" + line + "\", Encrypted in Sensitive_Data.stored_as");
                } // new addition
                if ((wordsFound.contains("password") && wordsFound.contains("expiration")) ||
                		(wordsFound.contains("password") && wordsFound.contains("reset")) ||
                		(wordsFound.contains("password") && wordsFound.contains("alter"))) {
                	System.out.println("\"" + line + "\", Expiration_Date in Password.has_restriction");
                }
                if ((wordsFound.contains("length") && wordsFound.contains("log"))) {
                	System.out.println("\"" + line + "\", File_Size in Log_File.has_restriction");
                }
                if ((wordsFound.contains("input") && wordsFound.contains("file") && wordsFound.contains("file type")) ||
                		(wordsFound.contains("input file") && wordsFound.contains("file type"))) {
                	System.out.println("\"" + line + "\", File_Type in Input_File.has_restriction");
                } // new addition
                if ((wordsFound.contains("gui") && wordsFound.contains("credential") && wordsFound.contains("store")) ||
                		(wordsFound.contains("gui") && wordsFound.contains("password") && wordsFound.contains("store"))) {
                	System.out.println("\"" + line + "\", GUI in Credentials.stored_in");
                }
                if ((wordsFound.contains("gui") && wordsFound.contains("credential") && wordsFound.contains("store")) ||
                		(wordsFound.contains("gui") && wordsFound.contains("sensitive data") && wordsFound.contains("store")) ||
                		(wordsFound.contains("gui") && wordsFound.contains("password") && wordsFound.contains("store"))) {
                	System.out.println("\"" + line + "\", GUI in Sensitive_Data.stored_in");
                }
                if ((wordsFound.contains("input") && wordsFound.contains("file")) ||
                		(wordsFound.contains("input file"))) {
                	System.out.println("\"" + line + "\", Input_File in User_Input.obtained_as");
                } // new addition
                if ((wordsFound.contains("input") && wordsFound.contains("file") && wordsFound.contains("validation")) ||
                		(wordsFound.contains("input file") && wordsFound.contains("validation"))) {
                	System.out.println("\"" + line + "\", Input_Validation in Input_File.has_restriction");
                } // new addition
                if ((wordsFound.contains("user") && wordsFound.contains("input") && wordsFound.contains("validation") && !wordsFound.contains("file"))) {
                	System.out.println("\"" + line + "\", Input_Validation in Other_User_Input.has_restriction");
                } // new addition
                if ((wordsFound.contains("ip address") && wordsFound.contains("authentication"))) {
                	System.out.println("\"" + line + "\", IP_Address in Authentication.uses");
                }
                if ((wordsFound.contains("user") && wordsFound.contains("privilege") && wordsFound.contains("appropriate")) ||
                		(wordsFound.contains("least privilege"))) {
                	System.out.println("\"" + line + "\", Least_Privilege in Access_Controls.include");
                }
                if ((wordsFound.contains("password") && wordsFound.contains("length")) ||
                		(wordsFound.contains("password") && wordsFound.contains("minimum") && wordsFound.contains("character"))) {
                	System.out.println("\"" + line + "\", Length in Password.has_restriction");
                }
                if ((wordsFound.contains("password") && wordsFound.contains("log")) ||
                		(wordsFound.contains("credential") && wordsFound.contains("log"))) {
                	System.out.println("\"" + line + "\", Log_File in Credentials.stored_in");
                }
                if ((wordsFound.contains("audit") && wordsFound.contains("user") && wordsFound.contains("data")) ||
                		(wordsFound.contains("log") && wordsFound.contains("user") && wordsFound.contains("data"))) {
                	System.out.println("\"" + line + "\", Log_File in Sensitive_Data.stored_in");
                }
                if ((wordsFound.contains("multi factor authentication"))) {
                	System.out.println("\"" + line + "\", Multi_Factor_Authentication in Authentication.is");
                }
                if ((wordsFound.contains("multiple") && wordsFound.contains("security question") && wordsFound.contains("recovery"))) {
                	System.out.println("\"" + line + "\", Multiple_Security_Questions in Recovery_Mechanism.has_restriction");
                }
                if ((wordsFound.contains("reset") && wordsFound.contains("original password"))) {
                	System.out.println("\"" + line + "\", Original_Password in Reset.requires");
                }
                if ((wordsFound.contains("user") && wordsFound.contains("input")) && !wordsFound.contains("file")) {
                	System.out.println("\"" + line + "\", Other_User_Input in User_Input.obtained_as");
                } // new addition
                if ((wordsFound.contains("password"))) {
                	System.out.println("\"" + line + "\", Password in Authentication.uses");
                }
                if ((wordsFound.contains("role")) ||
                		(wordsFound.contains("privilege separation")) ||
                		(wordsFound.contains("security profile")) ||
                		(wordsFound.contains("access level")) ||
                		(wordsFound.contains("access group")) ||
                		(wordsFound.contains("privilege") && wordsFound.contains("access")) ||
                		(wordsFound.contains("role") && wordsFound.contains("user")) ||
                		(wordsFound.contains("role") && wordsFound.contains("access")) ||
                		(wordsFound.contains("privilege") && wordsFound.contains("role")) ||
                		(wordsFound.contains("privilege") && wordsFound.contains("user"))) {
                	System.out.println("\"" + line + "\", Privilege_Separation in Access_Controls.include");
                }
                // special case: "access by," "based on," "control access"
                if ((wordsFound.contains("password") && wordsFound.contains("reset")) ||
                		(wordsFound.contains("password") && wordsFound.contains("recovery")) ||
                		(wordsFound.contains("credential") && wordsFound.contains("recovery"))) {
                	System.out.println("\"" + line + "\", Recovery_Mechanism in Password.allows");
                }
                if ((wordsFound.contains("password") && wordsFound.contains("reset"))) {
                	System.out.println("\"" + line + "\", Reset in Password.requires");
                }
                if ((wordsFound.contains("password") && wordsFound.contains("reuse"))) {
                	System.out.println("\"" + line + "\", Reuse in Password.has_restriction");
                }
                if ((wordsFound.contains("log") && wordsFound.contains("access")) ||
                		(wordsFound.contains("log") && wordsFound.contains("activity")) ||
                		(wordsFound.contains("log") && wordsFound.contains("attempt")) ||
                		(wordsFound.contains("log") && wordsFound.contains("authentication")) ||
                		(wordsFound.contains("log") && wordsFound.contains("ip address")) ||
                		(wordsFound.contains("log") && wordsFound.contains("host")) ||
                		(wordsFound.contains("log") && wordsFound.contains("password")) ||
                		(wordsFound.contains("log") && wordsFound.contains("sign on")) ||
                		(wordsFound.contains("log") && wordsFound.contains("user")) ||
                		(wordsFound.contains("log") && wordsFound.contains("security event")) ||
                		(wordsFound.contains("audit") && wordsFound.contains("security event")) ||
                		(wordsFound.contains("log") && wordsFound.contains("security") && wordsFound.contains("data")) ||
                		(wordsFound.contains("store") && wordsFound.contains("security") && wordsFound.contains("data")) ||
                		(wordsFound.contains("log") && wordsFound.contains("authorization"))) {
                	System.out.println("\"" + line + "\", Security_Event in Logging.use_for");
                }
                if ((wordsFound.contains("credential") && wordsFound.contains("transport")) ||
                		(wordsFound.contains("password") && wordsFound.contains("transport")) ||
                		(wordsFound.contains("sensitive data") && wordsFound.contains("transport"))) {
                	System.out.println("\"" + line + "\", Sensitive_Data in Sensitive_Data.transport_of");
                } // new addition
                if ((wordsFound.contains("credential")) ||
                		(wordsFound.contains("password")) ||
                		(wordsFound.contains("sensitive data"))) {
                	System.out.println("\"" + line + "\", Sensitive_Data in Sensitive_Data.use_of");
                } // new addition
                if ((wordsFound.contains("session") && wordsFound.contains("expiration")) ||
                		(wordsFound.contains("cookie") && wordsFound.contains("expiration"))) {
                	System.out.println("\"" + line + "\", Session_Expiration in Session.has_restriction");
                } // new addition
                if ((wordsFound.contains("strong") && wordsFound.contains("security question") && wordsFound.contains("recovery")) ||
                		(wordsFound.contains("strong") && wordsFound.contains("security question") && wordsFound.contains("reset"))) {
                	System.out.println("\"" + line + "\", Strong_Security_Questions in Recovery_Mechanism.has_restriction");
                }
                if ((wordsFound.contains("temporary") && wordsFound.contains("password") && wordsFound.contains("recovery")) ||
                		(wordsFound.contains("temporary") && wordsFound.contains("password") && wordsFound.contains("reset"))) {
                	System.out.println("\"" + line + "\", Temporary_Password in Recovery_Mechanism.has_restriction");
                }
                if ((wordsFound.contains("boundary"))) {
                	System.out.println("\"" + line + "\", Trust_Boundary in Access_Controls.include");
                }
                if ((wordsFound.contains("trust zone"))) {
                	System.out.println("\"" + line + "\", Trust_Zone in Access_Controls.include");
                }
                if ((wordsFound.contains("check") && wordsFound.contains("email")) ||
                		(wordsFound.contains("check") && wordsFound.contains("recovery"))) {
                	System.out.println("\"" + line + "\", Verification in Where_To_Send.has_restriction");
                } // new addition
                if ((wordsFound.contains("email") && wordsFound.contains("reset")) ||
                		(wordsFound.contains("email") && wordsFound.contains("recovery"))) {
                	System.out.println("\"" + line + "\", Where_To_Send in Recovery_Mechanism.has_restriction");
                }
                
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static List<String> extractLemmatizedPhrases(String sentence) {
    	int n = 4; // set this to choose the max length of phrases you want to check (4 recommended based on thesaurus)
        // Lemmatize the sentence using CoreNLP
        List<String> lemmas = lemmatize(sentence);
        // Split the lemmatized sentence into phrases of up to four lemmas
        List<String> phrases = new ArrayList<>();
        for (int i = 0; i < lemmas.size(); i++) {
            StringBuilder phraseBuilder = new StringBuilder();
            for (int j = i; j < Math.min(i + n, lemmas.size()); j++) {
                phraseBuilder.append(lemmas.get(j)).append(" ");
                phrases.add(phraseBuilder.toString().trim());
            }
        }
        //System.out.println(phrases);
        return phrases;
    }
}
