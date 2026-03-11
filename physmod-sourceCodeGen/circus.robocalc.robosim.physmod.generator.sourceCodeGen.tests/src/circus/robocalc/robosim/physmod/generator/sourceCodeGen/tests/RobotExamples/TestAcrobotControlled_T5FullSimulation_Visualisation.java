package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.RobotExamples;

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
import java.util.regex.Pattern;

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
 * T5 Full Simulation visualisation test for the AcrobotControlled scenario.
 * Uses controller support (Actuator::ControlledActuator) and gravity (NewtonEulerInverseDynamics_gravity).
 */
@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestAcrobotControlled_T5FullSimulation_Visualisation {

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
        "AcrobotSwingUpLQRModule_generated.c",
        "PickPlace.c",
        "dmodel_interface.cpp",
        "dmodel_interface.h",
        "object1_entity.hpp",
        "object2_entity.hpp",
        "platform_mapping.h",
        "world_stubs.cpp",
        "world_engine.cpp",
        "world_mapping.cpp",
        "world_mapping.h",
        "orchestrator.h"
    );

    private static final String TODO_MARKER = "/* TODO/STUB */";
    private static final double CSV_TOLERANCE = 1e-3;
    private static final long CSV_POLL_INTERVAL_MS = 200;
    private static final String TESTDATA_PROJECT_PATH =
        "../../physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/AcrobotControlled/SKO/FullSimulation_Visualisation/";

    private Path scenarioRoot() {
        return Paths.get("").toAbsolutePath().resolve(TESTDATA_PROJECT_PATH);
    }

    // Temp directory in testdata project for generated artifacts (preserved for inspection)
    private Path tempRoot() {
        return scenarioRoot().resolve("temp");
    }

    @Test
    public void testFullSimulationWithVisualisation() throws Exception {
        // Clean temp directory to avoid stale artifacts
        Path tempDir = tempRoot();
        if (Files.exists(tempDir)) {
            deleteDirectory(tempDir);
        }

        Path input = scenarioRoot().resolve("input").resolve("AcrobotControlled.slnRef");
        assertTrue(Files.exists(input), "Missing input slnRef: " + input);

        String slnRefText = Files.readString(input);

        Injector injector = new SlnRefStandaloneSetup().createInjectorAndDoEMFRegistration();
        @SuppressWarnings("unchecked")
        ParseHelper<SlnRefs> slnRefParseHelper = injector.getInstance(ParseHelper.class);
        SlnRefs slnRefs = slnRefParseHelper.parse(slnRefText);
        assertNotNull(slnRefs, "Failed to parse SlnRefs");
        assertTrue(slnRefs.eResource().getErrors().isEmpty(), "Parsing errors: " + slnRefs.eResource().getErrors());

        // Lightweight guard: ensure Geom is present before running T5 visualisation
        boolean hasGeom = Pattern.compile("(L\\d+_geom|geom_\\d{2})").matcher(slnRefText).find();
        assertTrue(
            hasGeom,
            "Visualisation requires Geom records in the slnRef (e.g., L1_geom or geom_11). " +
            "If this slnRef is pipeline-produced, fix T3/T4 to emit Geom before running visualisation.");

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

            // Verify T5 derived visuals are emitted (no defaults path available)
            String engineSrc = files.entrySet().stream()
                .filter(e -> e.getKey().endsWith("src/platform1_engine.cpp"))
                .map(e -> e.getValue().toString())
                .findFirst().orElse(null);
            assertNotNull(engineSrc, "platform1_engine.cpp not generated");
            assertTrue(engineSrc.contains("static const Geom L1_geom"),
                "Expected Geom declarations missing from platform1_engine.cpp");

            Path tempStage1 = tempDir.resolve("stage1");
            Path tempStage2Src = tempDir.resolve("stage2").resolve("src");
            Files.createDirectories(tempStage1);
            Files.createDirectories(tempStage2Src);
            writeT5Outputs(files, tempStage1, tempStage2Src);

            Path expectedStage2Src = scenarioRoot().resolve("expected").resolve("stage2").resolve("src");
            Path expectedManualSrc = scenarioRoot().resolve("expected").resolve("manual").resolve("src");

            assertStage2MatchesExpected(tempStage2Src, expectedStage2Src, STAGE2_GENERATED_FILES);

            String orchestratorStub = Files.readString(tempStage2Src.resolve("orchestrator.cpp"));
            assertTrue(orchestratorStub.contains(TODO_MARKER), "Generated orchestrator stub missing TODO marker");

            Path manualSrc = tempDir.resolve("manual").resolve("src");
            Path manualBuild = tempDir.resolve("manual").resolve("build");
            Path manualLog = manualBuild.resolve("pmh_velocity_log_our_implementation.csv");
            Path expectedCsv = scenarioRoot().resolve("expected").resolve("pmh_velocity_log_expected.csv");

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
            assertTrue(runPhysicsTest(manualBuild, manualLog, manualOrchestrator),
                "physics_test execution failed");
            assertTrue(Files.exists(manualLog),
                "physics_test did not emit velocity log: " + manualLog);

            assertTrue(Files.exists(expectedCsv),
                "Expected CSV not found for trajectory comparison: " + expectedCsv);
            compareCsvWithTolerance(expectedCsv, manualLog, CSV_TOLERANCE);

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
                System.out.println("Generated Stage 1 output: " + sanitized);
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
        assertEquals(expected, actualFiles, "Stage2 output mismatch");
        // Content checks are intentionally skipped; correctness is validated via build + runtime CSV
    }

    private List<String> listRelativeFiles(Path dir) throws IOException {
        if (!Files.exists(dir)) {
            return List.of();
        }
        try (var stream = Files.walk(dir)) {
            List<String> files = new ArrayList<>();
            stream.filter(Files::isRegularFile)
                .forEach(path -> files.add(dir.relativize(path).toString().replace('\\', '/')));
            Collections.sort(files);
            return files;
        }
    }

    private void copyManualFixtures(Path manualSrc, Path expectedManualSrc, List<String> manualOnlyFiles) throws IOException {
        for (String relative : manualOnlyFiles) {
            Path source = expectedManualSrc.resolve(relative);
            assertTrue(Files.exists(source), "Missing manual artefact: " + source);
            Path target = manualSrc.resolve(relative);
            Files.createDirectories(target.getParent());
            Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);
        }
    }

    private void copyDirectory(Path source, Path destination) throws IOException {
        if (!Files.exists(source)) {
            return;
        }
        Files.walk(source).forEach(path -> {
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

    private void deleteDirectory(Path directory) throws IOException {
        if (!Files.exists(directory)) {
            return;
        }
        Files.walk(directory)
            .sorted(java.util.Comparator.reverseOrder())
            .forEach(path -> {
                try {
                    Files.delete(path);
                } catch (IOException e) {
                    System.err.println("Failed to delete: " + path + " - " + e.getMessage());
                }
            });
    }

    private void copyHarnessTemplates(Path manualSrc, Path manualBuild) throws IOException {
        Path cmakeTemplate = scenarioRoot().resolve("manual").resolve("CMakeLists.txt");
        assertTrue(Files.exists(cmakeTemplate), "Missing expected harness CMakeLists.txt");
        Path manualDir = manualBuild.getParent();
        Files.copy(cmakeTemplate, manualDir.resolve("CMakeLists.txt"), StandardCopyOption.REPLACE_EXISTING);

        // Ensure engine_interface.cpp is present as the harness entrypoint
        Path engineIfFromSrc = scenarioRoot().resolve("expected").resolve("manual").resolve("src").resolve("engine_interface.cpp");
        Path engineIfFromRoot = scenarioRoot().resolve("expected").resolve("manual").resolve("engine_interface.cpp");
        Path engineIf = Files.exists(engineIfFromSrc) ? engineIfFromSrc : engineIfFromRoot;
        assertTrue(Files.exists(engineIf), "Missing engine_interface.cpp for harness");
        Files.createDirectories(manualSrc);
        Files.copy(engineIf, manualSrc.resolve("engine_interface.cpp"), StandardCopyOption.REPLACE_EXISTING);
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

    private boolean runPhysicsTest(Path workdir, Path manualLog, Path orchestrator) throws IOException, InterruptedException {
        SimulationBudget budget = computeSimulationBudget(orchestrator);

        ProcessBuilder pb = new ProcessBuilder("./physics_test");
        pb.directory(workdir.toFile());
        pb.redirectOutput(ProcessBuilder.Redirect.DISCARD);
        pb.redirectError(ProcessBuilder.Redirect.DISCARD);
        Process process = pb.start();

        long deadlineNanos = System.nanoTime() + TimeUnit.SECONDS.toNanos(budget.timeoutSeconds);
        while (System.nanoTime() < deadlineNanos) {
            if (budget.expectedCsvLines > 0 && csvHasAtLeastLines(manualLog, budget.expectedCsvLines)) {
                terminateProcess(process, budget.timeoutSeconds);
                return true;
            }
            if (!process.isAlive()) {
                break;
            }
            Thread.sleep(CSV_POLL_INTERVAL_MS);
        }

        if (process.isAlive()) {
            System.out.println("[./physics_test] Timed out after " + budget.timeoutSeconds
                + "s (simulation budget). Terminating process.");
            terminateProcess(process, budget.timeoutSeconds);
        }
        return Files.exists(manualLog);
    }

    private static final class SimulationBudget {
        final long timeoutSeconds;
        final long expectedCsvLines;

        SimulationBudget(long timeoutSeconds, long expectedCsvLines) {
            this.timeoutSeconds = timeoutSeconds;
            this.expectedCsvLines = expectedCsvLines;
        }
    }

    private SimulationBudget computeSimulationBudget(Path orchestrator) throws IOException {
        String source = Files.readString(orchestrator, StandardCharsets.UTF_8);
        Pattern dtPattern = Pattern.compile("\\.platform_dt\\s*=\\s*([0-9]+(?:\\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)");
        Pattern stepsPattern = Pattern.compile("\\.max_steps\\s*=\\s*(\\d+)");

        var dtMatch = dtPattern.matcher(source);
        var stepsMatch = stepsPattern.matcher(source);
        if (dtMatch.find() && stepsMatch.find()) {
            double dt = Double.parseDouble(dtMatch.group(1));
            long steps = Long.parseLong(stepsMatch.group(1));
            double simSeconds = dt * steps;
            // Don't wait for the d-model to terminate (known issue); instead, budget enough
            // time for the simulation to emit the full CSV, then terminate the process.
            long timeout = (long) Math.ceil(simSeconds + 5.0);
            return new SimulationBudget(Math.max(1L, timeout), steps + 1);
        }

        // Fallback to the previous hard timeout if the config cannot be parsed.
        return new SimulationBudget(180, 0);
    }

    private boolean csvHasAtLeastLines(Path csv, long expectedLines) {
        if (!Files.exists(csv)) {
            return false;
        }
        try (var lines = Files.lines(csv, StandardCharsets.UTF_8)) {
            return lines.count() >= expectedLines;
        } catch (IOException ignored) {
            return false;
        }
    }

    private void terminateProcess(Process process, long timeoutSeconds) throws InterruptedException {
        process.destroy();
        if (!process.waitFor(2, TimeUnit.SECONDS)) {
            process.destroyForcibly();
            if (!process.waitFor(2, TimeUnit.SECONDS)) {
                System.out.println("[./physics_test] Failed to terminate after " + timeoutSeconds + "s budget");
            }
        }
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

            // Skip header rows (lines where first field is not numeric)
            if (expectedFields.length > 0) {
                try {
                    Double.parseDouble(expectedFields[0].trim());
                } catch (NumberFormatException e) {
                    continue; // Skip header row
                }
            }

            assertEquals(expectedFields.length, actualFields.length,
                "CSV column mismatch at line " + i + ": expected " + expectedFields.length + " but got " + actualFields.length);

            for (int j = 0; j < expectedFields.length; j++) {
                double expectedValue = Double.parseDouble(expectedFields[j]);
                double actualValue = Double.parseDouble(actualFields[j]);
                double diff = Math.abs(expectedValue - actualValue);
                if (diff > tolerance) {
                    fail("CSV mismatch at line " + i + ", column " + j
                        + ": expected=" + df.format(expectedValue)
                        + ", actual=" + df.format(actualValue)
                        + ", diff=" + df.format(diff));
                }
            }
        }
    }

    private void restoreProperty(String key, String previous) {
        if (previous == null) {
            System.clearProperty(key);
        } else {
            System.setProperty(key, previous);
        }
    }
}
