package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;

import org.eclipse.xtext.generator.InMemoryFileSystemAccess;
import org.eclipse.xtext.testing.util.ParseHelper;

import com.google.inject.Injector;

import circus.robocalc.robosim.physmod.generator.sourceCodeGen.MultiFileCppGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.SolutionRefGenerator;
import circus.robocalc.robosim.physmod.slnDF.SlnDFStandaloneSetup;
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution;
import circus.robocalc.robosim.physmod.slnRef.SlnRefStandaloneSetup;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs;

public class T5StandaloneCli {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Usage: T5StandaloneCli <input.slnRef> <output_dir>");
            System.exit(1);
        }

        Path input = Paths.get(args[0]);
        Path outputDir = Paths.get(args[1]);

        try {
            String slnRefText = Files.readString(input);

            Injector slnInjector = new SlnRefStandaloneSetup().createInjectorAndDoEMFRegistration();
            @SuppressWarnings("unchecked")
            ParseHelper<SlnRefs> slnParseHelper = slnInjector.getInstance(ParseHelper.class);
            SlnRefs slnRefs = slnParseHelper.parse(slnRefText);
            if (slnRefs == null || !slnRefs.eResource().getErrors().isEmpty()) {
                throw new IllegalStateException("Failed to parse slnRef: " + slnRefs.eResource().getErrors());
            }

            System.setProperty("physmod.generation.mode", "STANDALONE_VISUALISATION");
            System.setProperty("physmod.visualisation.enabled", "true");

            SolutionRefGenerator refGen = new SolutionRefGenerator();
            String solutionDsl = refGen.compile(slnRefs);
            if (solutionDsl == null || solutionDsl.trim().isEmpty()) {
                throw new IllegalStateException("Generated Solution DSL is empty");
            }

            Injector solutionInjector = new SlnDFStandaloneSetup().createInjectorAndDoEMFRegistration();
            @SuppressWarnings("unchecked")
            ParseHelper<Solution> solutionParseHelper = solutionInjector.getInstance(ParseHelper.class);
            Solution solution = solutionParseHelper.parse(solutionDsl);
            if (solution == null || !solution.eResource().getErrors().isEmpty()) {
                throw new IllegalStateException("Failed to parse Solution DSL: " + solution.eResource().getErrors());
            }

            MultiFileCppGenerator cppGen = new MultiFileCppGenerator();
            InMemoryFileSystemAccess fsa = new InMemoryFileSystemAccess();
            cppGen.doGenerate(solution.eResource(), fsa, null);

            Files.createDirectories(outputDir);
            Files.writeString(outputDir.resolve("solution.sln"), solutionDsl);

            for (Map.Entry<String, Object> entry : fsa.getAllFiles().entrySet()) {
                String filePath = entry.getKey();
                if (filePath.contains(":")) {
                    filePath = filePath.split(":", 2)[1];
                } else if (filePath.startsWith("DEFAULT_OUTPUT")) {
                    filePath = filePath.substring("DEFAULT_OUTPUT".length());
                }
                while (filePath.startsWith("/")) {
                    filePath = filePath.substring(1);
                }

                Path outputFile;
                if (filePath.contains("/") || filePath.contains("\\")) {
                    outputFile = outputDir.resolve(filePath);
                } else if (filePath.endsWith(".cpp") || filePath.endsWith(".hpp") || filePath.endsWith(".h")) {
                    outputFile = outputDir.resolve("src").resolve(filePath);
                } else {
                    outputFile = outputDir.resolve(filePath);
                }

                if (outputFile.getParent() != null) {
                    Files.createDirectories(outputFile.getParent());
                }
                Files.writeString(outputFile, entry.getValue().toString());
            }

            Path interfacesStub = outputDir.resolve("src").resolve("interfaces.hpp");
            if (!Files.exists(interfacesStub)) {
                Files.createDirectories(interfacesStub.getParent());
                Files.writeString(
                    interfacesStub,
                    "#ifndef INTERFACES_HPP\n#define INTERFACES_HPP\n// Stub for standalone mode.\n#endif\n"
                );
            }

            System.out.println("Generated T5 output at " + outputDir.toAbsolutePath());
        } catch (Exception e) {
            System.err.println("Error running T5StandaloneCli: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
