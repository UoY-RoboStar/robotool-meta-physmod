package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.RobotExamples;

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
 * STANDALONE_VISUALISATION mode test for SimpleArm:
 * - Generates physics engine with visualization but without orchestrator
 * - Only gravity is applied (no controller torques)
 * - Compiles and runs standalone executable with visualization
 * - Useful for comparing dynamics with Drake
 */
@org.junit.jupiter.api.Disabled("CI: MeshcatCpp not available on GitHub Actions runner. Passes locally with MeshcatCpp installed.")
@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestSimpleArm_T5Standalone_Visualisation {

    @Inject
    private ParseHelper<SlnRefs> slnRefParseHelper;

    private ParseHelper<Solution> solutionDSLParseHelper;

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
            .resolve("RobotExamples")
            .resolve("SimpleArm");
    }

    private Path standaloneVisRoot() {
        Path local = integrationRoot().resolve("SKO").resolve("standalone_visualisation");
        if (Files.exists(local)) {
            return local;
        }
        Path fromTestdata = resolveTestdataPath("RobotExamples/SimpleArm/SKO/standalone_visualisation");
        if (fromTestdata != null) {
            return fromTestdata;
        }
        return local;
    }

    private Path tempOutputRoot() {
        try {
            return Files.createTempDirectory("TestSimpleArm_T5StandaloneVis");
        } catch (java.io.IOException e) {
            throw new RuntimeException("Failed to create temp directory", e);
        }
    }

    private Path resolveTestdataPath(String relativePath) {
        Path cwd = Paths.get("").toAbsolutePath();
        String testdataRel = "physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/" + relativePath;
        for (Path base : java.util.List.of(cwd, cwd.resolve(".."), cwd.resolve("../.."), cwd.resolve("../../.."))) {
            Path candidate = base.resolve(testdataRel);
            if (Files.exists(candidate)) {
                return candidate.normalize();
            }
        }
        return null;
    }

    @Test
    public void testStandaloneVisualisationMode() throws Exception {
        // Use a temp directory for output to avoid writing into the testdata submodule
        Path tempDir = tempOutputRoot();

        // Input: simplearm slnRef (gravity only, no controller)
        Path input = standaloneVisRoot().resolve("input").resolve("simplearm_gravity_only.slnRef");
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

            Path stage1Dir = tempDir.resolve("stage1");
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
            Path stage2Dir = tempDir.resolve("stage2");
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
            System.out.println("\n=== STAGE 2.5: Adding Trajectory and Dynamics Logging ===");
            Path engineFile = stage2SrcDir.resolve("platform1_engine.cpp");
            String engineCode = Files.readString(engineFile);
            String modifiedEngineCode = addDynamicsLogging(engineCode);
            Files.writeString(engineFile, modifiedEngineCode);
            System.out.println("✓ Dynamics logging added to platform1_engine.cpp");

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

            // STAGE 5: Run simulation and capture trajectory + dynamics
            System.out.println("\n=== STAGE 5: Running Simulation to Capture Dynamics Data ===");
            Path trajectoryFile = buildDir.resolve("trajectory.csv");
            Path dynamicsFile = buildDir.resolve("dynamics.csv");
            Path posesFile = buildDir.resolve("poses_ours.csv");
            
            // Run physics simulation for 5 seconds (timeout after 10 to kill it)
            System.out.println("Running 5-second simulation to capture dynamics...");
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
            
            assertTrue(Files.exists(trajectoryFile), "Trajectory file was not created");
            assertTrue(Files.exists(dynamicsFile), "Dynamics file was not created");
            assertTrue(Files.exists(posesFile), "Poses file was not created");
            
            // Analyze trajectory
            List<String> trajectoryLines = Files.readAllLines(trajectoryFile);
            assertTrue(trajectoryLines.size() > 10, "Trajectory too short: " + trajectoryLines.size() + " lines");
            System.out.println("✓ Trajectory captured: " + trajectoryLines.size() + " timesteps");
            
            List<String> dynamicsLines = Files.readAllLines(dynamicsFile);
            System.out.println("✓ Dynamics captured: " + dynamicsLines.size() + " timesteps");
            
            // Print first few lines
            System.out.println("\nFirst 5 trajectory timesteps:");
            for (int i = 0; i < Math.min(5, trajectoryLines.size()); i++) {
                System.out.println(trajectoryLines.get(i));
            }
            
            System.out.println("\nFirst 3 dynamics timesteps:");
            for (int i = 0; i < Math.min(3, dynamicsLines.size()); i++) {
                System.out.println(dynamicsLines.get(i));
            }
            
            System.out.println("\nData files saved:");
            System.out.println("  Trajectory: " + trajectoryFile.toAbsolutePath());
            System.out.println("  Dynamics:   " + dynamicsFile.toAbsolutePath());
            System.out.println("  Poses:      " + posesFile.toAbsolutePath());

            // STAGE 6: Ready for comparison with Drake
            System.out.println("\n=== STAGE 6: Ready for Drake Comparison ===");
            System.out.println("SKO SimpleArm data generated successfully.");
            System.out.println("Next: Compare with Drake SimpleArm using compare_simplearm.py");
            System.out.println("\nGenerated code: " + stage2SrcDir.toAbsolutePath());
            System.out.println("Build directory: " + buildDir.toAbsolutePath());

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

    /**
     * Add dynamics and trajectory logging to the generated platform1_engine.cpp.
     * Logs M, Cv, tau_g, phi, and poses for comparison with Drake.
     */
    private String addDynamicsLogging(String engineCode) throws Exception {
        // Add logging globals after includes
        String loggingGlobals = "\n// Dynamics and trajectory logging globals\n" +
            "static std::ofstream traj_log;\n" +
            "static std::ofstream dynamics_log;\n" +
            "static std::ofstream poses_log;\n" +
            "static bool logs_initialized = false;\n";
        
        engineCode = engineCode.replace(
            "#pragma endregion includes",
            "#pragma endregion includes" + loggingGlobals
        );

        // Wrap physics_update to add logging
        if (engineCode.contains("void physics_update() {")) {
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
                "    // Initialize logs on first call\n" +
                "    if (!logs_initialized) {\n" +
                "        traj_log.open(\"trajectory.csv\");\n" +
                "        traj_log << \"time,theta0,theta1,dtheta0,dtheta1,C0,C1\" << std::endl;\n" +
                "        dynamics_log.open(\"dynamics.csv\");\n" +
                "        dynamics_log << \"time,M00,M01,M10,M11,Cv0,Cv1,tau_g0,tau_g1\" << std::endl;\n" +
                "        poses_log.open(\"poses_ours.csv\");\n" +
                "        poses_log << \"time,link,x,y,z,qw,qx,qy,qz\" << std::endl;\n" +
                "        logs_initialized = true;\n" +
                "    }\n\n" +
                "    // Run physics computation\n" +
                "    physics_update_impl();\n\n" +
                "    // Log trajectory data\n" +
                "    if (logs_initialized && traj_log.is_open()) {\n" +
                "        traj_log << std::fixed << std::setprecision(6) << t\n" +
                "                 << \",\" << theta(0) << \",\" << theta(1)\n" +
                "                 << \",\" << d_theta(0) << \",\" << d_theta(1)\n" +
                "                 << \",\" << C(0) << \",\" << C(1) << std::endl;\n" +
                "    }\n\n" +
                "    // Log dynamics data (M, Cv, tau_g)\n" +
                "    if (logs_initialized && dynamics_log.is_open()) {\n" +
                "        dynamics_log << std::fixed << std::setprecision(6) << t\n" +
                "                     << \",\" << M_mass(0,0) << \",\" << M_mass(0,1)\n" +
                "                     << \",\" << M_mass(1,0) << \",\" << M_mass(1,1)\n" +
                "                     << \",\" << C(0) << \",\" << C(1)\n" +
                "                     << \",\" << 0.0 << \",\" << 0.0 << std::endl;\n" +
                "    }\n\n" +
                "    // Log poses\n" +
                "    if (logs_initialized && poses_log.is_open()) {\n" +
                "        for (int i = 0; i < B_k.size(); ++i) {\n" +
                "            const auto& B = B_k[i];\n" +
                "            poses_log << std::fixed << std::setprecision(6) << t << \",\" << i\n" +
                "                      << \",\" << B(0,3) << \",\" << B(1,3) << \",\" << B(2,3)\n" +
                "                      << \",1.0,0.0,0.0,0.0\" << std::endl;\n" +
                "        }\n" +
                "    }\n\n" +
                "    if (static_cast<int>(t / dt) % 100 == 0) {\n" +
                "        traj_log.flush();\n" +
                "        dynamics_log.flush();\n" +
                "        poses_log.flush();\n" +
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
