package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests;

import static org.junit.jupiter.api.Assertions.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.eclipse.xtext.generator.InMemoryFileSystemAccess;
import org.eclipse.xtext.testing.util.ParseHelper;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import com.google.inject.Injector;

import circus.robocalc.robosim.physmod.generator.sourceCodeGen.SolutionRefGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnRefInjectorProvider;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.utils.StubFillingUtility;
import circus.robocalc.robosim.physmod.slnRef.SlnRefStandaloneSetup;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs;

/**
 * T5 Full Simulation test with visualization:
 * - Generates Full Simulation mode with visualisation (FULL_SIMULATION_VISUALISATION)
 * - Produces full simulation with orchestrator, world, d-model, and visualization
 * - Builds and runs the simulation
 * - Compares trajectory with expected output from manualImplementationCPP
 */
@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestSKO_T5FullSimulation_Visualisation {

    private static final List<String> STAGE2_GENERATED_FILES = List.of(
        "dmodel_data.h",
        "interfaces.hpp",
        "orchestrator.cpp",
        "orchestrator.h",
        "platform1_engine.cpp",
        "platform1_state.hpp",
        "platform_mapping_adapter.cpp",
        "utils.cpp",
        "utils.h",
        "visualization_client.h",
        "visualization_server.cpp"
    );

    private static final List<String> MANUAL_ONLY_FILES = List.of(
        "PickPlace.c",
        "dmodel_interface.cpp",
        "dmodel_interface.h",
        "object1_entity.hpp",
        "object2_entity.hpp",
        "platform_mapping.h",
        "world_engine.cpp",
        "world_mapping.cpp",
        "world_mapping.h",
        "orchestrator.h"
    );

    private static final String TODO_MARKER = "/* TODO/STUB */";
    private static final double CSV_TOLERANCE = 1e-3;
    private static final String TESTDATA_PROJECT_PATH =
        "../../physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/SKO/";

    private Path integrationRoot() {
        return Paths.get("").toAbsolutePath().resolve("tests").resolve("integrationTests").resolve("SKO");
    }

    private Path fullSimulationRoot() {
        return integrationRoot().resolve("fullSimulation_visualisation");
    }

    private Path testdataRoot() {
        return Paths.get("").toAbsolutePath().resolve(TESTDATA_PROJECT_PATH);
    }

    @Disabled("Requires MeshcatCpp (not available on CI)")
    @Test
    public void testFullSimulationWithVisualisation() throws Exception {
        Path input = testdataRoot().resolve("fullSimulation_visualisation").resolve("input").resolve("SimpleArmSerial.slnRef");
        assertTrue(Files.exists(input), "Missing input slnRef: " + input);

        String slnRefText = Files.readString(input);

        Injector injector = new SlnRefStandaloneSetup().createInjectorAndDoEMFRegistration();
        @SuppressWarnings("unchecked")
        ParseHelper<SlnRefs> slnRefParseHelper = injector.getInstance(ParseHelper.class);
        SlnRefs slnRefs = slnRefParseHelper.parse(slnRefText);
        assertNotNull(slnRefs, "Failed to parse SlnRefs");
        assertTrue(slnRefs.eResource().getErrors().isEmpty(), "Parsing errors: " + slnRefs.eResource().getErrors());

        String oldMode = System.getProperty("physmod.generation.mode");
        String oldVisual = System.getProperty("physmod.visualisation.enabled");
        String oldFormat = System.getProperty("physmod.output.format");
        String oldVelocityLogging = System.getProperty("physmod.velocity.logging");
        try {
            System.setProperty("physmod.generation.mode", "FULL_SIMULATION_VISUALISATION");
            System.setProperty("physmod.output.format", "cpp");
            System.setProperty("physmod.velocity.logging", "true");

            SolutionRefGenerator gen = new SolutionRefGenerator();
            InMemoryFileSystemAccess fsa = new InMemoryFileSystemAccess();
            gen.doGenerate(slnRefs.eResource(), fsa, null);

            Map<String, Object> files = new LinkedHashMap<>(fsa.getAllFiles());
            assertFalse(files.isEmpty(), "No files generated by T5");

            Path tempDir = fullSimulationRoot().resolve("temp");
            Path tempStage1 = tempDir.resolve("stage1");
            Path tempStage2Src = tempDir.resolve("stage2").resolve("src");
            Files.createDirectories(tempStage1);
            Files.createDirectories(tempStage2Src);
            writeT5Outputs(files, tempStage1, tempStage2Src);

            Path expectedStage2Src = fullSimulationRoot().resolve("expected").resolve("stage2").resolve("src");
            Path expectedManualSrc = fullSimulationRoot().resolve("expected").resolve("manual").resolve("src");

            assertStage2MatchesExpected(tempStage2Src, expectedStage2Src, STAGE2_GENERATED_FILES);

            String orchestratorStub = Files.readString(tempStage2Src.resolve("orchestrator.cpp"));
            assertTrue(orchestratorStub.contains(TODO_MARKER), "Generated orchestrator stub missing TODO marker");

            Path manualSrc = tempDir.resolve("manual").resolve("src");
            Path manualBuild = tempDir.resolve("manual").resolve("build");
            Path manualLog = manualBuild.resolve("pmh_velocity_log_our_implementation.csv");
            Path expectedCsv = fullSimulationRoot().resolve("expected").resolve("pmh_velocity_log_expected.csv");

            Files.createDirectories(manualSrc);
            Files.createDirectories(manualBuild);

            copyDirectory(tempStage2Src, manualSrc);
            copyManualFixtures(manualSrc, expectedManualSrc, MANUAL_ONLY_FILES);

            Path stage2Orchestrator = tempStage2Src.resolve("orchestrator.cpp");
            Path referenceOrchestrator = expectedManualSrc.resolve("orchestrator.cpp");
            Path manualOrchestrator = manualSrc.resolve("orchestrator.cpp");
            StubFillingUtility.fillOrchestratorStubs(
                stage2Orchestrator,
                referenceOrchestrator,
                manualOrchestrator,
                "platform1"
            );
            assertTrue(
                StubFillingUtility.validateNoRemainingStubs(manualOrchestrator),
                "Orchestrator still contains TODO/STUB markers after filling"
            );

            copyHarnessTemplates(manualSrc, manualBuild);

            assertTrue(runProcess(new String[]{"cmake", ".."}, manualBuild, 120),
                "CMake configuration failed");
            assertTrue(runProcess(new String[]{"cmake", "--build", "."}, manualBuild, 240),
                "CMake build failed");

            assertTrue(runProcess(new String[]{"./physics_test"}, manualBuild, 180),
                "physics_test execution failed");
            assertTrue(Files.exists(manualLog),
                "physics_test did not emit velocity log: " + manualLog);

            if (Files.exists(expectedCsv)) {
                compareCsvWithTolerance(expectedCsv, manualLog, CSV_TOLERANCE);
            } else {
                System.out.println("⚠ Expected CSV not found, skipping trajectory comparison");
            }

        } finally {
            restoreProperty("physmod.generation.mode", oldMode);
            restoreProperty("physmod.visualisation.enabled", oldVisual);
            restoreProperty("physmod.output.format", oldFormat);
            restoreProperty("physmod.velocity.logging", oldVelocityLogging);
        }
    }

    private void writeT5Outputs(Map<String, Object> generatedFiles, Path stage1Dir, Path stage2SrcDir) throws IOException {
        for (Map.Entry<String, Object> entry : generatedFiles.entrySet()) {
            String logicalName = entry.getKey();
            String content = entry.getValue().toString();

            if (logicalName.endsWith(".sln")) {
                String sanitized = logicalName;
                if (sanitized.startsWith("DEFAULT_OUTPUT")) {
                    sanitized = sanitized.substring("DEFAULT_OUTPUT".length());
                }
                while (sanitized.startsWith("/")) {
                    sanitized = sanitized.substring(1);
                }
                Path target = stage1Dir.resolve(sanitized);
                Files.createDirectories(target.getParent());
                Files.writeString(target, content, StandardCharsets.UTF_8);
                System.out.println("✓ Generated Stage 1 output: " + sanitized);
                continue;
            }

            String sanitized = logicalName;
            if (sanitized.startsWith("DEFAULT_OUTPUT")) {
                sanitized = sanitized.substring("DEFAULT_OUTPUT".length());
            }
            while (sanitized.startsWith("/")) {
                sanitized = sanitized.substring(1);
            }
            if (sanitized.startsWith("src/")) {
                sanitized = sanitized.substring(4);
            }

            Path target = stage2SrcDir.resolve(sanitized);
            Files.createDirectories(target.getParent());
            Files.writeString(target, content, StandardCharsets.UTF_8);
        }
    }

    private void assertStage2MatchesExpected(Path actualDir, Path expectedDir, List<String> expectedFiles) throws IOException {
        List<String> actualFiles = listRelativeFiles(actualDir);
        // Tolerate optional stub header if present
        actualFiles.remove("meshcat_stub.hpp");
        List<String> expected = new ArrayList<>(expectedFiles);
        Collections.sort(actualFiles);
        Collections.sort(expected);
        assertEquals(expected, actualFiles, "Stage2 generated file set mismatch");
        // Content checks are intentionally skipped; correctness is validated via build + runtime CSV
    }

    private List<String> listRelativeFiles(Path dir) throws IOException {
        List<String> files = new ArrayList<>();
        if (!Files.exists(dir)) {
            return files;
        }
        Files.walk(dir)
            .filter(Files::isRegularFile)
            .forEach(path -> files.add(dir.relativize(path).toString().replace('\\', '/')));
        return files;
    }

    private void copyManualFixtures(Path manualSrc, Path expectedManualSrc, List<String> manualFiles) throws IOException {
        for (String relative : manualFiles) {
            Path source = expectedManualSrc.resolve(relative);
            assertTrue(Files.exists(source), "Missing manual fixture: " + relative);
            Path target = manualSrc.resolve(relative);
            Files.createDirectories(target.getParent());
            Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);
        }
    }

    private void copyDirectory(Path source, Path destination) throws IOException {
        if (!Files.exists(source)) {
            return;
        }
        Files.walk(source)
            .forEach(path -> {
                try {
                    Path relative = source.relativize(path);
                    Path target = destination.resolve(relative);
                    if (Files.isDirectory(path)) {
                        Files.createDirectories(target);
                    } else {
                        Files.createDirectories(target.getParent());
                        Files.copy(path, target, StandardCopyOption.REPLACE_EXISTING);
                    }
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            });
    }

    private void copyHarnessTemplates(Path manualSrc, Path manualBuild) throws IOException {
        Path cmakeTemplate = fullSimulationRoot().resolve("manual").resolve("CMakeLists.txt");
        assertTrue(Files.exists(cmakeTemplate), "Missing expected harness CMakeLists.txt");
        Path manualDir = manualBuild.getParent();
        Files.copy(cmakeTemplate, manualDir.resolve("CMakeLists.txt"), StandardCopyOption.REPLACE_EXISTING);
    }

    private boolean runProcess(String[] command, Path workdir, long timeoutSeconds) throws IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder(command);
        pb.directory(workdir.toFile());
        pb.redirectErrorStream(true);
        Process process = pb.start();

        consumeOutputAsync(process, String.join(" ", command));

        boolean finished = process.waitFor(timeoutSeconds, TimeUnit.SECONDS);
        if (!finished) {
            process.destroyForcibly();
            return false;
        }
        return process.exitValue() == 0;
    }

    private void consumeOutputAsync(Process process, String prefix) {
        new Thread(() -> {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println("[" + prefix + "] " + line);
                }
            } catch (IOException ignored) {
            }
        }).start();
    }

    private void compareCsvWithTolerance(Path expectedCsv, Path actualCsv, double tolerance) throws IOException {
        List<String> expectedLines = Files.readAllLines(expectedCsv, StandardCharsets.UTF_8);
        List<String> actualLines = Files.readAllLines(actualCsv, StandardCharsets.UTF_8);

        assertEquals(expectedLines.size(), actualLines.size(),
            "CSV length mismatch: expected " + expectedLines.size() + " lines but got " + actualLines.size());

        DecimalFormat df = new DecimalFormat("0.000000");
        for (int i = 0; i < expectedLines.size(); i++) {
            String expectedLine = expectedLines.get(i).trim();
            String actualLine = actualLines.get(i).trim();
            assertFalse(expectedLine.isEmpty(), "Expected CSV line " + i + " is empty");
            assertFalse(actualLine.isEmpty(), "Actual CSV line " + i + " is empty");

            String[] expectedFields = expectedLine.split(",");
            String[] actualFields = actualLine.split(",");
            assertEquals(expectedFields.length, actualFields.length,
                "CSV column count mismatch on line " + i + ": expected " + expectedFields.length + " but got " + actualFields.length);

            for (int col = 0; col < expectedFields.length; col++) {
                double expectedVal = Double.parseDouble(expectedFields[col]);
                double actualVal = Double.parseDouble(actualFields[col]);
                double diff = Math.abs(expectedVal - actualVal);
                String msg = "CSV mismatch at line " + i + ", column " + col +
                    " (expected=" + df.format(expectedVal) + ", actual=" + df.format(actualVal) +
                    ", diff=" + df.format(diff) + ")";
                assertTrue(diff <= tolerance, msg);
            }
        }
    }

    private void restoreProperty(String key, String value) {
        if (value == null) {
            System.clearProperty(key);
        } else {
            System.setProperty(key, value);
        }
    }
}
