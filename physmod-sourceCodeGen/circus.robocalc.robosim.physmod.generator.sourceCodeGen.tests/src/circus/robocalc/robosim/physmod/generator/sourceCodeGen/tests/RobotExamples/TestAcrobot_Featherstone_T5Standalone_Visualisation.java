package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.RobotExamples;

import static org.junit.jupiter.api.Assertions.*;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
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
 * STANDALONE_VISUALISATION mode test for Acrobot (Featherstone):
 * - Generates physics engine with visualization but without orchestrator
 * - Only gravity is applied (no controller torques)
 * - Compiles and runs standalone executable with visualization
 * - Useful for debugging visualization issues (link positions, transforms, etc.)
 */
@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestAcrobot_Featherstone_T5Standalone_Visualisation {

    @Inject
    private ParseHelper<SlnRefs> slnRefParseHelper;

    private ParseHelper<Solution> solutionDSLParseHelper;
    private static final String SKO_TESTDATA_PROJECT_PATH =
        "../../physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/Acrobot/SKO/standalone_visualisation";
    private static final String TESTDATA_PROJECT_PATH =
        "../../physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/Acrobot/FEATHERSTONE/standalone_visualisation";

    private ParseHelper<Solution> getSolutionDSLParseHelper() {
        if (solutionDSLParseHelper == null) {
            SlnDFInjectorProvider provider = new SlnDFInjectorProvider();
            Injector injector = provider.getInjector();
            solutionDSLParseHelper = injector.getInstance(ParseHelper.class);
        }
        return solutionDSLParseHelper;
    }

    private Path standaloneVisRoot() {
        return Paths.get("").toAbsolutePath().resolve(TESTDATA_PROJECT_PATH);
    }

    private Path skoStandaloneVisRoot() {
        return Paths.get("").toAbsolutePath().resolve(SKO_TESTDATA_PROJECT_PATH);
    }

    @Test
    public void testStandaloneVisualisationMode() throws Exception {
        // Clean temp directory
        Path tempDir = standaloneVisRoot().resolve("temp");
        if (Files.exists(tempDir)) {
            deleteDirectory(tempDir);
        }

        // Input: acrobot slnRef (gravity only, no controller)
        Path input = standaloneVisRoot().resolve("input").resolve("acrobot_gravity_only.slnRef");
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

            // STAGE 2.5: Add trajectory logging to platform1_engine.cpp
            System.out.println("\n=== STAGE 2.5: Adding Trajectory Logging ===");
            Path engineFile = stage2SrcDir.resolve("platform1_engine.cpp");
            String engineCode = Files.readString(engineFile);
            String modifiedEngineCode = addTrajectoryLogging(engineCode);
            Files.writeString(engineFile, modifiedEngineCode);
            System.out.println("✓ Trajectory logging added to platform1_engine.cpp");

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
            Path visualizationServer = buildDir.resolve("visualization_server");
            assertTrue(Files.exists(physicsEngine), "platform1_sim executable not found");
            assertTrue(Files.exists(visualizationServer), "visualization_server executable not found");
            System.out.println("✓ Both executables created (platform1_sim, visualization_server)");

            // STAGE 5: Run simulation and capture trajectory
            System.out.println("\n=== STAGE 5: Running Simulation to Capture Trajectory ===");
            Path trajectoryFile = buildDir.resolve("trajectory.csv");

            // Run physics simulation for 5 seconds (timeout after 10 to kill it)
            System.out.println("Running 5-second simulation to capture trajectory...");
            ProcessBuilder pb = new ProcessBuilder("timeout", "10", "./platform1_sim");
            pb.directory(buildDir.toFile());
            pb.redirectErrorStream(true);
            Process process = pb.start();

            // Capture output
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (line.contains("Simulation time:") || line.contains("ERROR") || line.contains("WARNING")) {
                        System.out.println("[platform1_sim] " + line);
                    }
                }
            }

            boolean finished = process.waitFor(15, TimeUnit.SECONDS);
            if (!finished) {
                process.destroyForcibly();
            }
            // Note: timeout command returns 124 when it times out (expected behavior)
            // The simulation runs for 30s but we kill it after 10s, which is fine

            assertTrue(Files.exists(trajectoryFile), "Trajectory file was not created");

            // Analyze trajectory
            List<String> trajectoryLines = Files.readAllLines(trajectoryFile);
            assertTrue(trajectoryLines.size() > 10, "Trajectory too short: " + trajectoryLines.size() + " lines");
            System.out.println("✓ Trajectory captured: " + trajectoryLines.size() + " timesteps");

            // Print first few and last few lines
            System.out.println("\nFirst 5 timesteps:");
            for (int i = 0; i < Math.min(5, trajectoryLines.size()); i++) {
                System.out.println(trajectoryLines.get(i));
            }
            System.out.println("\nLast 5 timesteps:");
            int start = Math.max(0, trajectoryLines.size() - 5);
            for (int i = start; i < trajectoryLines.size(); i++) {
                System.out.println(trajectoryLines.get(i));
            }

            System.out.println("\nFull trajectory saved to: " + trajectoryFile.toAbsolutePath());

            Path skoTrajectoryFile = skoStandaloneVisRoot()
                .resolve("temp")
                .resolve("stage2")
                .resolve("build")
                .resolve("trajectory.csv");
            assertTrue(Files.exists(skoTrajectoryFile),
                "Missing SKO trajectory file: " + skoTrajectoryFile +
                " (run TestAcrobot_T5Standalone_Visualisation first)");
            compareTrajectories(trajectoryFile, skoTrajectoryFile, 1e-3);

            // STAGE 6: Ready for manual testing
            System.out.println("\n=== STAGE 6: Ready for Manual Testing ===");
            System.out.println("To visualize the Acrobot with gravity only:");
            System.out.println("1. Terminal 1: cd " + buildDir.toAbsolutePath());
            System.out.println("            ./visualization_server");
            System.out.println("2. Terminal 2: cd " + buildDir.toAbsolutePath());
            System.out.println("            ./platform1_sim");
            System.out.println("\nThe robot should swing down under gravity.");
            System.out.println("Check that:");
            System.out.println("  - Links are properly connected");
            System.out.println("  - Upper link (L1) is 1.1m long, lower link (L2) is 2.1m long");
            System.out.println("  - Base link (L3) is a 0.2×0.2×0.2m box at the pivot");
            System.out.println("  - Robot swings naturally under gravity");
            System.out.println("\nVisualization files:");
            System.out.println("  Generated code: " + stage2SrcDir.toAbsolutePath());
            System.out.println("  Build directory: " + buildDir.toAbsolutePath());
            System.out.println("  Physics Engine: " + physicsEngine.toAbsolutePath());
            System.out.println("  Viz Server:     " + visualizationServer.toAbsolutePath());

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

    private void compareTrajectories(Path featherstoneTrajectory, Path skoTrajectory, double tolerance) throws Exception {
        List<double[]> featherRows = readTrajectory(
            featherstoneTrajectory,
            new String[] {"time", "q0", "q1", "dq0", "dq1"}
        );
        List<double[]> skoRows = readTrajectory(
            skoTrajectory,
            new String[] {"time", "theta0", "theta1", "dtheta0", "dtheta1"}
        );

        assertFalse(featherRows.isEmpty(), "Featherstone trajectory is empty");
        assertFalse(skoRows.isEmpty(), "SKO trajectory is empty");

        int featherCount = featherRows.size();
        int skoCount = skoRows.size();
        int commonCount = Math.min(featherCount, skoCount);
        assertTrue(commonCount > 0,
            "No overlapping trajectory rows: Featherstone=" + featherCount + ", SKO=" + skoCount);

        Path diffFile = featherstoneTrajectory.getParent().resolve("trajectory_diff.csv");
        writeTrajectoryDiff(diffFile, featherRows, skoRows, commonCount);
        System.out.println("Trajectory diff saved to: " + diffFile.toAbsolutePath());

        double maxTime = 0.0;
        double maxQ0 = 0.0;
        double maxQ1 = 0.0;
        double maxDq0 = 0.0;
        double maxDq1 = 0.0;
        double maxQ0Swap = 0.0;
        double maxQ1Swap = 0.0;
        double maxDq0Swap = 0.0;
        double maxDq1Swap = 0.0;

        for (int i = 0; i < commonCount; i++) {
            double[] f = featherRows.get(i);
            double[] s = skoRows.get(i);

            maxTime = Math.max(maxTime, Math.abs(f[0] - s[0]));
            maxQ0 = Math.max(maxQ0, Math.abs(f[1] - s[1]));
            maxQ1 = Math.max(maxQ1, Math.abs(f[2] - s[2]));
            maxDq0 = Math.max(maxDq0, Math.abs(f[3] - s[3]));
            maxDq1 = Math.max(maxDq1, Math.abs(f[4] - s[4]));

            maxQ0Swap = Math.max(maxQ0Swap, Math.abs(f[1] - s[2]));
            maxQ1Swap = Math.max(maxQ1Swap, Math.abs(f[2] - s[1]));
            maxDq0Swap = Math.max(maxDq0Swap, Math.abs(f[3] - s[4]));
            maxDq1Swap = Math.max(maxDq1Swap, Math.abs(f[4] - s[3]));
        }

        double featherEndTime = featherRows.get(featherCount - 1)[0];
        double skoEndTime = skoRows.get(skoCount - 1)[0];
        double minEndTime = Math.min(featherEndTime, skoEndTime);
        assertTrue(minEndTime >= 9.0,
            String.format(
                Locale.US,
                "Trajectories too short for a stable comparison (min end time %.3fs; Featherstone end %.3fs, SKO end %.3fs). Diff saved to: %s",
                minEndTime, featherEndTime, skoEndTime, diffFile.toAbsolutePath()
            )
        );

        int lengthDelta = Math.abs(featherCount - skoCount);
        if (lengthDelta != 0) {
            System.out.println(
                String.format(
                    Locale.US,
                    "Trajectory length differs by %d steps (Featherstone=%d, SKO=%d; endTimes Featherstone=%.3fs, SKO=%.3fs); comparing overlapping range only.",
                    lengthDelta, featherCount, skoCount, featherEndTime, skoEndTime
                )
            );
        }

        boolean matches = maxTime <= tolerance &&
            maxQ0Swap <= tolerance &&
            maxQ1Swap <= tolerance &&
            maxDq0Swap <= tolerance &&
            maxDq1Swap <= tolerance;

        String message = String.format(
            "Trajectory mismatch (tol=%.6f, SKO reversed). Max diffs: time=%.6f direct q0=%.6f q1=%.6f dq0=%.6f dq1=%.6f; reversed q0=%.6f q1=%.6f dq0=%.6f dq1=%.6f. Diff saved to: %s",
            tolerance, maxTime, maxQ0, maxQ1, maxDq0, maxDq1, maxQ0Swap, maxQ1Swap, maxDq0Swap, maxDq1Swap,
            diffFile.toAbsolutePath()
        );
        assertTrue(matches, message);
    }

    private void writeTrajectoryDiff(Path diffFile, List<double[]> featherRows, List<double[]> skoRows, int count) throws Exception {
        List<String> lines = new ArrayList<>();
        lines.add(String.join(",",
            "time",
            "f_q0", "f_q1", "f_dq0", "f_dq1",
            "s_q0_raw", "s_q1_raw", "s_dq0_raw", "s_dq1_raw",
            "s_q0_rev", "s_q1_rev", "s_dq0_rev", "s_dq1_rev",
            "df_q0_raw", "df_q1_raw", "df_dq0_raw", "df_dq1_raw",
            "df_q0_rev", "df_q1_rev", "df_dq0_rev", "df_dq1_rev"
        ));

        for (int i = 0; i < count; i++) {
            double[] f = featherRows.get(i);
            double[] s = skoRows.get(i);

            double sQ0Rev = s[2];
            double sQ1Rev = s[1];
            double sDq0Rev = s[4];
            double sDq1Rev = s[3];

            double dfQ0Raw = f[1] - s[1];
            double dfQ1Raw = f[2] - s[2];
            double dfDq0Raw = f[3] - s[3];
            double dfDq1Raw = f[4] - s[4];

            double dfQ0Rev = f[1] - sQ0Rev;
            double dfQ1Rev = f[2] - sQ1Rev;
            double dfDq0Rev = f[3] - sDq0Rev;
            double dfDq1Rev = f[4] - sDq1Rev;

            lines.add(String.format(Locale.ROOT,
                "%.6f,%.6f,%.6f,%.6f,%.6f," +
                "%.6f,%.6f,%.6f,%.6f," +
                "%.6f,%.6f,%.6f,%.6f," +
                "%.6f,%.6f,%.6f,%.6f," +
                "%.6f,%.6f,%.6f,%.6f",
                f[0],
                f[1], f[2], f[3], f[4],
                s[1], s[2], s[3], s[4],
                sQ0Rev, sQ1Rev, sDq0Rev, sDq1Rev,
                dfQ0Raw, dfQ1Raw, dfDq0Raw, dfDq1Raw,
                dfQ0Rev, dfQ1Rev, dfDq0Rev, dfDq1Rev
            ));
        }

        Files.write(diffFile, lines);
    }

    private List<double[]> readTrajectory(Path trajectoryPath, String[] columns) throws Exception {
        List<String> lines = Files.readAllLines(trajectoryPath);
        assertTrue(lines.size() > 1, "Trajectory file too short: " + trajectoryPath);

        String[] headers = lines.get(0).trim().split(",");
        Map<String, Integer> headerIndex = new HashMap<>();
        for (int i = 0; i < headers.length; i++) {
            headerIndex.put(headers[i].trim(), i);
        }

        int[] indices = new int[columns.length];
        for (int i = 0; i < columns.length; i++) {
            Integer index = headerIndex.get(columns[i]);
            assertNotNull(index, "Missing trajectory column '" + columns[i] + "' in " + trajectoryPath);
            indices[i] = index;
        }

        List<double[]> rows = new ArrayList<>();
        for (int i = 1; i < lines.size(); i++) {
            String line = lines.get(i).trim();
            if (line.isEmpty()) {
                continue;
            }
            String[] parts = line.split(",");
            assertTrue(parts.length >= headers.length,
                "Malformed trajectory row in " + trajectoryPath + ": " + line);

            double[] row = new double[columns.length];
            for (int j = 0; j < columns.length; j++) {
                row[j] = Double.parseDouble(parts[indices[j]]);
            }
            rows.add(row);
        }

        return rows;
    }

    /**
     * Add trajectory logging to the generated platform1_engine.cpp.
     * This modifies the physics_update() function to log state to trajectory.csv.
     */
    private String addTrajectoryLogging(String engineCode) throws Exception {
        // Add logging globals after includes (after #pragma endregion includes)
        String loggingGlobals = "\n// Trajectory logging globals\n" +
            "static std::ofstream traj_log;\n" +
            "static bool traj_initialized = false;\n";

        engineCode = engineCode.replace(
            "#pragma endregion includes",
            "#pragma endregion includes" + loggingGlobals
        );

        // Wrap physics_update to add logging
        if (engineCode.contains("void physics_update() {")) {
            // Find the entire physics_update function
            int startIdx = engineCode.indexOf("void physics_update() {");
            int braceCount = 0;
            int bodyStart = engineCode.indexOf("{", startIdx) + 1;
            int endIdx = bodyStart;

            // Find matching closing brace
            for (int i = bodyStart; i < engineCode.length(); i++) {
                if (engineCode.charAt(i) == '{') braceCount++;
                if (engineCode.charAt(i) == '}') {
                    if (braceCount == 0) {
                        endIdx = i;
                        break;
                    }
                    braceCount--;
                }
            }

            String physicsBody = engineCode.substring(bodyStart, endIdx);

            // Create wrapper with logging
            String wrapperCode = 
                "void physics_update_impl() {\n" + physicsBody + "\n}\n\n" +
                "void physics_update() {\n" +
                "    // Initialize trajectory log on first call\n" +
                "    if (!traj_initialized) {\n" +
                "        traj_log.open(\"trajectory.csv\");\n" +
                "        traj_log << \"time,q0,q1,dq0,dq1\" << std::endl;\n" +
                "        traj_initialized = true;\n" +
                "    }\n\n" +
                "    // Run physics computation\n" +
                "    physics_update_impl();\n\n" +
                "    // Log trajectory data\n" +
                "    if (traj_initialized && traj_log.is_open()) {\n" +
                "        traj_log << std::fixed << std::setprecision(6) << t\n" +
                "                 << \",\" << q(0) << \",\" << q(1)\n" +
                "                 << \",\" << d_q(0) << \",\" << d_q(1) << std::endl;\n" +
                "        if (static_cast<int>(t / dt) % 100 == 0) traj_log.flush();\n" +
                "    }\n" +
                "}\n";

            engineCode = engineCode.substring(0, startIdx) + wrapperCode + engineCode.substring(endIdx + 1);
        }

        return engineCode;
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
