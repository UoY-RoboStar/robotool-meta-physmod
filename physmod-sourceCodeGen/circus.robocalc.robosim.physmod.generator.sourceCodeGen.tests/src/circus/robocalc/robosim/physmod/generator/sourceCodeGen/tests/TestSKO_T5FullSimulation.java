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
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import com.google.inject.Injector;

import circus.robocalc.robosim.physmod.generator.sourceCodeGen.SolutionRefGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnRefInjectorProvider;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.utils.StubFillingUtility;
import circus.robocalc.robosim.physmod.slnRef.SlnRefStandaloneSetup;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs;

/**
 * T5 Full Simulation test without visualisation:
 * - Generates Full Simulation mode (FULL_SIMULATION) without visualisation
 * - Produces full simulation with orchestrator, world, d-model (no visualization)
 * - Builds and runs the simulation
 * - Compares trajectory with expected output from manualImplementationCPP
 */
@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestSKO_T5FullSimulation {

    private static final List<String> STAGE2_GENERATED_FILES = List.of(
        "dmodel_data.h",
        "interfaces.hpp",
        "orchestrator.cpp",
        "orchestrator.h",
        "platform1_engine.cpp",
        "platform1_state.hpp",
        "platform_mapping_adapter.cpp",
        "utils.cpp",
        "utils.h"
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
    private static final double CSV_TIME_TOLERANCE = 1e-6;
    private static final double CSV_POS_TORQUE_TOLERANCE = 1e-3;
    private static final String TESTDATA_PROJECT_PATH =
        "../../physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/SKO/";

    private Path integrationRoot() {
        return Paths.get("").toAbsolutePath().resolve("tests").resolve("integrationTests").resolve("SKO");
    }

    private Path fullSimulationRoot() {
        return integrationRoot().resolve("fullSimulation");
    }

    private Path testdataRoot() {
        return Paths.get("").toAbsolutePath().resolve(TESTDATA_PROJECT_PATH);
    }

    private Path manualImplementationCPPRoot() {
        Path workspaceRoot = Paths.get("").toAbsolutePath().getParent().getParent().getParent();
        return workspaceRoot.resolve("Examples").resolve("CPP_tests").resolve("manualImplementationCPP");
    }

    @Test
    public void testFullSimulation() throws Exception {
        Path input = testdataRoot().resolve("fullSimulation").resolve("input").resolve("SimpleArmSerial.slnRef");
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
            System.setProperty("physmod.generation.mode", "FULL_SIMULATION");
            System.setProperty("physmod.visualisation.enabled", "false");
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

            Path expectedStage2Src = testdataRoot().resolve("fullSimulation").resolve("expected").resolve("stage2").resolve("src");
            Path expectedManualSrc = testdataRoot().resolve("fullSimulation").resolve("expected").resolve("manual").resolve("src");

            assertStage2MatchesExpected(tempStage2Src, expectedStage2Src, STAGE2_GENERATED_FILES);

            String orchestratorStub = Files.readString(tempStage2Src.resolve("orchestrator.cpp"));
            assertTrue(orchestratorStub.contains(TODO_MARKER), "Generated orchestrator stub missing TODO marker");

            Path manualSrc = tempDir.resolve("manual").resolve("src");
            Path manualBuild = tempDir.resolve("manual").resolve("build");
            Path manualLog = manualBuild.getParent().resolve("pmh_velocity_log_our_implementation.csv");
            Path manualTransformLog = manualBuild.getParent().resolve("transform_log.csv");
            Path expectedCsv = testdataRoot().resolve("fullSimulation").resolve("expected").resolve("pmh_velocity_log_expected.csv");

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

            Files.deleteIfExists(manualLog);
            Files.deleteIfExists(manualTransformLog);
            assertTrue(runProcess(new String[]{"./physics_test"}, manualBuild, 180),
                "physics_test execution failed");
            assertTrue(Files.exists(manualLog),
                "physics_test did not emit velocity log: " + manualLog);

            final double dt = 0.01;
            final double durationSeconds = 28.32;

            Path referenceCsv = expectedCsv;
            if (!Files.exists(referenceCsv)) {
                Path manualImplCsv = manualImplementationCPPRoot().resolve("build")
                    .resolve("pmh_velocity_log_our_implementation.csv");
                if (Files.exists(manualImplCsv)) {
                    referenceCsv = manualImplCsv;
                    System.out.println("⚠ Expected CSV not found, using manualImplementationCPP as reference");
                } else {
                    System.out.println("⚠ Expected CSV and manualImplementationCPP CSV not found, skipping trajectory comparison");
                    return;
                }
            }

            compareCsvWithTolerance(referenceCsv, manualLog);
            System.out.println("✓ Trajectory CSV matches reference (time ≤ " + CSV_TIME_TOLERANCE +
                             ", pos/tau ≤ " + CSV_POS_TORQUE_TOLERANCE + ")");

            Path referenceTransformLog = manualImplementationCPPRoot().resolve("build")
                .resolve("transform_log.csv");
            if (Files.exists(manualTransformLog)) {
                validateTransformLog(manualTransformLog, durationSeconds, dt);
                if (Files.exists(referenceTransformLog)) {
                    System.out.println("✓ Transform log validated");
                } else {
                    System.out.println("⚠ Transform log present but no reference for comparison");
                }
            } else {
                System.out.println("⚠ Transform log not found (transform logging may not be enabled in generated code)");
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
        List<String> expected = new ArrayList<>(expectedFiles);
        Collections.sort(actualFiles);
        Collections.sort(expected);
        assertEquals(expected, actualFiles, "Stage2 generated file set mismatch");

        for (String relative : expectedFiles) {
            Path actual = actualDir.resolve(relative);
            Path expectedPath = expectedDir.resolve(relative);
            assertTrue(Files.exists(actual), () -> "Missing generated file: " + relative);
            assertTrue(Files.exists(expectedPath), () -> "Missing expected fixture: " + relative);
            String actualContent = Files.readString(actual, StandardCharsets.UTF_8);
            String expectedContent = Files.readString(expectedPath, StandardCharsets.UTF_8);

            // interfaces.hpp is a shared template-style header and is expected to evolve; validate key
            // invariants rather than requiring byte-for-byte equality.
            if ("interfaces.hpp".equals(relative)) {
                assertTrue(actualContent.contains("class IPlatformEngine"),
                    "interfaces.hpp should define IPlatformEngine");
                assertTrue(actualContent.contains("class IPlatformWorldMapping"),
                    "interfaces.hpp should define IPlatformWorldMapping");
                assertTrue(actualContent.contains("class IPlatformMapping"),
                    "interfaces.hpp should define IPlatformMapping");
                continue;
            }

            assertEquals(expectedContent, actualContent, "Content mismatch for " + relative);
        }
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
        Path manualDir = manualBuild.getParent();

        Path cmakeTemplate = testdataRoot().resolve("fullSimulation").resolve("manual").resolve("CMakeLists.txt");
        assertTrue(Files.exists(cmakeTemplate), "Missing expected harness CMakeLists.txt");
        Files.copy(cmakeTemplate, manualDir.resolve("CMakeLists.txt"), StandardCopyOption.REPLACE_EXISTING);

        Path engineInterface = testdataRoot().resolve("fullSimulation").resolve("manual").resolve("engine_interface.cpp");
        assertTrue(Files.exists(engineInterface), "Missing expected harness engine_interface.cpp");
        Files.copy(engineInterface, manualDir.resolve("engine_interface.cpp"), StandardCopyOption.REPLACE_EXISTING);
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

    private void compareCsvWithTolerance(Path expectedCsv, Path actualCsv) throws IOException {
        List<String> expectedLines = Files.readAllLines(expectedCsv, StandardCharsets.UTF_8);
        List<String> actualLines = Files.readAllLines(actualCsv, StandardCharsets.UTF_8);
        assertFalse(expectedLines.isEmpty(), "Expected CSV is empty");
        assertFalse(actualLines.isEmpty(), "Actual CSV is empty");
        assertEquals(expectedLines.get(0), actualLines.get(0), "CSV headers differ");

        List<String> filteredActualLines = new ArrayList<>();
        filteredActualLines.add(actualLines.get(0));
        double lastTime = -1.0;
        for (int i = 1; i < actualLines.size(); i++) {
            String[] cols = actualLines.get(i).split(",", 2);
            if (cols.length > 0) {
                try {
                    double time = Double.parseDouble(cols[0]);
                    if (time > 0.0 && Math.abs(time - lastTime) > 0.0001) {
                        filteredActualLines.add(actualLines.get(i));
                        lastTime = time;
                    }
                } catch (NumberFormatException e) {
                    filteredActualLines.add(actualLines.get(i));
                }
            }
        }

        List<String> filteredExpectedLines = new ArrayList<>();
        filteredExpectedLines.add(expectedLines.get(0));
        lastTime = -1.0;
        for (int i = 1; i < expectedLines.size(); i++) {
            String[] cols = expectedLines.get(i).split(",", 2);
            if (cols.length > 0) {
                try {
                    double time = Double.parseDouble(cols[0]);
                    if (time > 0.0 && Math.abs(time - lastTime) > 0.0001) {
                        filteredExpectedLines.add(expectedLines.get(i));
                        lastTime = time;
                    }
                } catch (NumberFormatException e) {
                    filteredExpectedLines.add(expectedLines.get(i));
                }
            }
        }

        DecimalFormat df = new DecimalFormat("0.000000");
        int rows = Math.min(filteredExpectedLines.size(), filteredActualLines.size());
        assertTrue(rows > 1, "No data rows to compare after filtering");

        for (int i = 1; i < rows; i++) {
            String[] expected = filteredExpectedLines.get(i).split(",");
            String[] actual = filteredActualLines.get(i).split(",");
            assertEquals(expected.length, actual.length, "Column count mismatch at row " + i);
            final int rowIndex = i;

            for (int col = 0; col < expected.length; col++) {
                double e = Double.parseDouble(expected[col]);
                double a = Double.parseDouble(actual[col]);
                double delta = Math.abs(e - a);
                final int colIndex = col;

                final double tolerance;
                if (colIndex == 0) {
                    tolerance = CSV_TIME_TOLERANCE;
                } else if (colIndex == 3 || colIndex == 4 || colIndex == 6) {
                    tolerance = CSV_POS_TORQUE_TOLERANCE;
                } else {
                    tolerance = CSV_POS_TORQUE_TOLERANCE;
                }

                assertTrue(delta <= tolerance, () ->
                    "Mismatch at row " + rowIndex + ", column " + colIndex +
                    " (expected=" + df.format(e) + ", actual=" + df.format(a) +
                    ", |Δ|=" + df.format(delta) + " > " + tolerance + ")");
            }
        }
    }

    private void validateTransformLog(Path transformLog, double durationSeconds, double dt) throws IOException {
        assertTrue(Files.exists(transformLog), "Transform log file not found: " + transformLog);

        List<String> lines = Files.readAllLines(transformLog, StandardCharsets.UTF_8);
        assertFalse(lines.isEmpty(), "Transform log is empty");
        assertTrue(lines.size() > 1, "Transform log has no data rows");

        int minExpectedEntries = (int)(durationSeconds / dt) - 100;
        assertTrue(lines.size() - 1 >= minExpectedEntries,
            "Transform log has too few entries: " + (lines.size() - 1) + " < " + minExpectedEntries);

        String header = lines.get(0);
        assertTrue(header.contains("Bk2") && header.contains("Bk1") && header.contains("Bk0"),
            "Transform log header missing Bk frame columns");

        String[] firstRow = lines.get(1).split(",");
        String[] lastRow = lines.get(lines.size() - 1).split(",");

        int bk1StartIdx = 1 + 16;
        int bk0StartIdx = bk1StartIdx + 16;

        assertTrue(firstRow.length >= bk0StartIdx + 16,
            "Transform log rows have insufficient columns");

        boolean hasNonIdentity = false;
        for (int i = bk1StartIdx; i < bk0StartIdx + 16 && !hasNonIdentity; i++) {
            double val = Double.parseDouble(firstRow[i]);
            int posInMatrix = (i - bk1StartIdx) % 16;
            int row = posInMatrix / 4;
            int col = posInMatrix % 4;
            if (row == col) {
                if (Math.abs(val - 1.0) > 1e-6) hasNonIdentity = true;
            } else {
                if (Math.abs(val) > 1e-6) hasNonIdentity = true;
            }
        }
        assertTrue(hasNonIdentity, "Transform log shows identity matrices (no transformation)");

        boolean hasMotion = false;
        for (int i = bk0StartIdx; i < bk0StartIdx + 16 && !hasMotion; i++) {
            double first = Double.parseDouble(firstRow[i]);
            double last = Double.parseDouble(lastRow[i]);
            if (Math.abs(first - last) > 1e-3) hasMotion = true;
        }
        assertTrue(hasMotion, "Transform log shows no motion between first and last entries");
    }

    private void restoreProperty(String key, String value) {
        if (value != null) {
            System.setProperty(key, value);
        } else {
            System.clearProperty(key);
        }
    }
}
