package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests;

import static org.junit.jupiter.api.Assertions.*;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;

import org.eclipse.xtext.generator.InMemoryFileSystemAccess;
import org.eclipse.xtext.testing.util.ParseHelper;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import com.google.inject.Inject;
import com.google.inject.Injector;

import circus.robocalc.robosim.physmod.generator.sourceCodeGen.SolutionRefGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.MultiFileCppGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnRefInjectorProvider;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnDFInjectorProvider;
import circus.robocalc.robosim.physmod.slnRef.SlnRefStandaloneSetup;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs;
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution;

/**
 * STANDALONE_VISUALISATION mode test for SimpleArmSerial:
 * - Generates physics engine with visualization but without orchestrator
 * - Only gravity is applied (no controller torques)
 * - Compiles and runs standalone executable with visualization
 * - Useful for debugging visualization issues (link positions, transforms, etc.)
 */
@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestSKO_T5Standalone_Visualisation {

    @Inject
    private ParseHelper<SlnRefs> slnRefParseHelper;

    private ParseHelper<Solution> solutionDSLParseHelper;
    private static final String TESTDATA_PROJECT_PATH =
        "../../physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/SKO/";

    private ParseHelper<Solution> getSolutionDSLParseHelper() {
        if (solutionDSLParseHelper == null) {
            SlnDFInjectorProvider provider = new SlnDFInjectorProvider();
            Injector injector = provider.getInjector();
            solutionDSLParseHelper = injector.getInstance(ParseHelper.class);
        }
        return solutionDSLParseHelper;
    }

    private Path integrationRoot() {
        return Paths.get("").toAbsolutePath()
            .resolve("tests")
            .resolve("integrationTests")
            .resolve("SKO");
    }

    private Path standaloneVisRoot() {
        return integrationRoot().resolve("standalone_visualisation");
    }

    private Path testdataRoot() {
        return Paths.get("").toAbsolutePath().resolve(TESTDATA_PROJECT_PATH);
    }

    @Test
    public void testStandaloneVisualisationMode() throws Exception {
        // Clean temp directory
        Path tempDir = standaloneVisRoot().resolve("temp");
        if (Files.exists(tempDir)) {
            deleteDirectory(tempDir);
        }

        // Input: SimpleArmSerial slnRef (gravity only, no controller)
        Path input = testdataRoot().resolve("standalone_visualisation").resolve("input").resolve("SimpleArmSerial_gravity_only.slnRef");
        assertTrue(Files.exists(input), "Missing input slnRef: " + input);

        String slnRefText = Files.readString(input);

        Injector injector = new SlnRefStandaloneSetup().createInjectorAndDoEMFRegistration();
        @SuppressWarnings("unchecked")
        ParseHelper<SlnRefs> parseHelper = injector.getInstance(ParseHelper.class);
        SlnRefs slnRefs = parseHelper.parse(slnRefText);
        assertNotNull(slnRefs, "Failed to parse SlnRefs");
        assertTrue(slnRefs.eResource().getErrors().isEmpty(), 
            "Parsing errors: " + slnRefs.eResource().getErrors());

        // Verify Geom records are present
        boolean hasGeom = Pattern.compile("(L\\d+_geom|geom_\\d{2})").matcher(slnRefText).find();
        assertTrue(hasGeom, 
            "Visualisation requires Geom records in the slnRef (e.g., L1_geom, L2_geom). " +
            "Add Geom records to the Visual SolutionRef before running this test.");

        String oldMode = System.getProperty("physmod.generation.mode");
        String oldVisual = System.getProperty("physmod.visualisation.enabled");
        try {
            // Set STANDALONE_VISUALISATION mode
            System.setProperty("physmod.generation.mode", "STANDALONE_VISUALISATION");
            System.setProperty("physmod.visualisation.enabled", "true");

            // STAGE 1: SlnRef -> Solution DSL
            System.out.println("=== STAGE 1: SlnRef -> Solution DSL (STANDALONE_VISUALISATION) ===");
            SolutionRefGenerator gen = new SolutionRefGenerator();
            String solutionDSL = gen.compile(slnRefs);

            assertNotNull(solutionDSL, "Generated Solution DSL is null");
            assertFalse(solutionDSL.trim().isEmpty(), "Generated Solution DSL is empty");

            Path stage1Dir = standaloneVisRoot().resolve("temp").resolve("stage1");
            Files.createDirectories(stage1Dir);
            Path solutionFile = stage1Dir.resolve("solution.sln");
            Files.writeString(solutionFile, solutionDSL);
            System.out.println("Stage 1 output: " + solutionFile);

            // Parse generated Solution DSL
            Solution solution = getSolutionDSLParseHelper().parse(solutionDSL);
            assertNotNull(solution, "Generated Solution DSL failed to parse");
            assertTrue(solution.eResource().getErrors().isEmpty(),
                "Solution DSL parse errors: " + solution.eResource().getErrors());
            System.out.println("✓ Stage 1: Solution DSL validated");

            // STAGE 2: Solution DSL -> C++ files
            System.out.println("\n=== STAGE 2: Solution DSL -> C++ (STANDALONE_VISUALISATION) ===");
            MultiFileCppGenerator cppGen = new MultiFileCppGenerator();
            InMemoryFileSystemAccess fsa = new InMemoryFileSystemAccess();
            cppGen.doGenerate(solution.eResource(), fsa, null);

            Map<String, Object> files = fsa.getAllFiles();
            assertFalse(files.isEmpty(), "No files generated by T5");

            // Write Stage 2 outputs
            Path stage2Dir = standaloneVisRoot().resolve("temp").resolve("stage2");
            Files.createDirectories(stage2Dir);
            Path stage2SrcDir = stage2Dir.resolve("src");
            Files.createDirectories(stage2SrcDir);

            for (Map.Entry<String, Object> e : files.entrySet()) {
                String name = e.getKey();
                if (name.startsWith("DEFAULT_OUTPUT")) {
                    name = name.substring("DEFAULT_OUTPUT".length());
                }
                while (name.startsWith("/")) {
                    name = name.substring(1);
                }
                
                // Determine target directory: C++ sources go to src/, CMakeLists to root
                Path outputFile;
                if (name.endsWith(".cpp") || name.endsWith(".hpp") || name.endsWith(".h")) {
                    // Generator may already include a src/ prefix; stage2SrcDir already points at .../src
                    if (name.startsWith("src/")) {
                        name = name.substring(4);
                    }
                    outputFile = stage2SrcDir.resolve(name);
                } else {
                    outputFile = stage2Dir.resolve(name);
                }
                
                Files.createDirectories(outputFile.getParent());
                Files.writeString(outputFile, e.getValue().toString());
            }
            System.out.println("Stage 2: Generated " + files.size() + " C++ files");

            // Create minimal stub interfaces.hpp for standalone mode
            // (generator currently references it from platform1_state.hpp even in standalone mode)
            String stubInterfaces = 
                "#ifndef INTERFACES_HPP\n" +
                "#define INTERFACES_HPP\n" +
                "// Minimal stub for standalone mode - no orchestrator interfaces needed\n" +
                "#endif // INTERFACES_HPP\n";
            Files.writeString(stage2SrcDir.resolve("interfaces.hpp"), stubInterfaces);

            // Verify key files were generated
            List<String> expectedFiles = List.of(
                "src/platform1_engine.cpp",
                "src/platform1_state.hpp",
                "src/visualization_client.h",
                "src/visualization_server.cpp",
                "CMakeLists.txt"
            );

            for (String file : expectedFiles) {
                Path filePath = stage2Dir.resolve(file);
                assertTrue(Files.exists(filePath), "Missing generated file: " + file);
            }
            System.out.println("✓ Stage 2: All expected files generated");

            // STAGE 3: Compile
            System.out.println("\n=== STAGE 3: CMake Configuration ===");
            Path buildDir = stage2Dir.resolve("build");
            Files.createDirectories(buildDir);

            assertTrue(runProcess(
                new String[]{"cmake", "..", "-DCMAKE_BUILD_TYPE=Release"},
                buildDir,
                60),
                "CMake configuration failed");
            System.out.println("✓ CMake configuration successful");

            System.out.println("\n=== STAGE 4: Build ===");
            assertTrue(runProcess(
                new String[]{"cmake", "--build", ".", "--", "-j4"},
                buildDir,
                120),
                "CMake build failed");
            System.out.println("✓ Build successful");

            // Verify executables exist
            Path physicsEngine = buildDir.resolve("platform1_sim");
            assertTrue(Files.exists(physicsEngine), "platform1_sim executable not found");
            System.out.println("✓ Executable created");

            // STAGE 5: Ready for manual testing
            System.out.println("\n=== STAGE 5: Ready for Manual Testing ===");
            System.out.println("To visualize the SimpleArmSerial with gravity only:");
            System.out.println("1. cd " + buildDir.toAbsolutePath());
            System.out.println("2. ./platform1_sim");
            System.out.println("\nThe robot should drop under gravity.");
            System.out.println("Check that:");
            System.out.println("  - Links are properly connected");
            System.out.println("  - Link 1 (gripper) is a 0.5×0.5×0.5m box");
            System.out.println("  - Link 2 (upper link) is a cylinder radius=0.25m, length=4.0m");
            System.out.println("  - Link 3 (base) is a 1.0×1.0×0.5m box");
            System.out.println("  - Robot drops naturally under gravity (starts at z=4.0m)");
            System.out.println("\nVisualization files:");
            System.out.println("  Generated code: " + stage2SrcDir.toAbsolutePath());
            System.out.println("  Build directory: " + buildDir.toAbsolutePath());
            System.out.println("  Executable: " + physicsEngine.toAbsolutePath());

        } finally {
            restoreProperty("physmod.generation.mode", oldMode);
            restoreProperty("physmod.visualisation.enabled", oldVisual);
        }
    }

    private void restoreProperty(String key, String oldValue) {
        if (oldValue == null) {
            System.clearProperty(key);
        } else {
            System.setProperty(key, oldValue);
        }
    }

    private boolean runProcess(String[] command, Path workingDir, int timeoutSeconds) throws Exception {
        System.out.println("[" + String.join(" ", command) + "]");
        ProcessBuilder pb = new ProcessBuilder(command);
        pb.directory(workingDir.toFile());
        pb.redirectErrorStream(true);

        Process process = pb.start();
        
        // Stream output in real-time
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println("[" + command[0] + "] " + line);
            }
        }

        boolean finished = process.waitFor(timeoutSeconds, TimeUnit.SECONDS);
        if (!finished) {
            process.destroyForcibly();
            System.err.println("Process timed out after " + timeoutSeconds + " seconds");
            return false;
        }

        return process.exitValue() == 0;
    }

    private void deleteDirectory(Path directory) throws Exception {
        if (Files.exists(directory)) {
            Files.walk(directory)
                .sorted((a, b) -> b.compareTo(a))
                .forEach(path -> {
                    try {
                        Files.delete(path);
                    } catch (Exception e) {
                        // Ignore
                    }
                });
        }
    }
}
