import edu.stanford.nlp.simple.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class alloyGeneration {
    // Define the mapping from lemma to word
    private static Map<String, String> thesaurus = new HashMap<>();

    public static void main(String[] args) {
        // Load the thesaurus from CSV file
        loadThesaurus("C:\\Users\\vkosc\\eclipse-workspace\\AlloyGeneration\\files\\thesaurus.csv");

        // Process the sentences
        processSentences("C:\\Users\\vkosc\\eclipse-workspace\\AlloyGeneration\\files\\sentences.txt");
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

    private static void processSentences(String filename) {
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            while ((line = br.readLine()) != null) {
                List<String> lemmas = lemmatize(line);
                boolean passFound = false;
                boolean authenFound = false;

                // Check for lemma matches in the thesaurus
                for (String lemma : lemmas) {
                    String word = thesaurus.get(lemma);
                    if (word != null) {
                        if (word.equals("password")) {
                            passFound = true;
                        } else if (word.equals("authentication")) {
                            authenFound = true;
                        }
                    }
                }

                // Map the sentence based on the matches
                if (passFound) {
                    System.out.println(line + " maps to pass found");
                }
                if (authenFound) {
                    System.out.println(line + " maps to authen");
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
            }
        }
        return lemmas;
    }
}